const SEP_PAYMENT_URL =
  "https://sep.shaparak.ir/OnlinePG/OnlinePG";

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function errorPage(
  status: number,
  message: string,
): Response {
  return new Response(
    `
<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>انتقال به درگاه</title>
</head>
<body>
  <div style="
    font-family: sans-serif;
    text-align: center;
    margin-top: 80px;
    padding: 20px;
  ">
    <h2>خطا در انتقال به درگاه پرداخت</h2>
    <p>${escapeHtml(message)}</p>
  </div>
</body>
</html>
`,
    {
      status,
      headers: {
        "Content-Type":
          "text/html; charset=utf-8",
        "Cache-Control":
          "no-store, no-cache, must-revalidate",
      },
    },
  );
}

Deno.serve(async (req: Request) => {
  try {
    if (req.method !== "GET") {
      return new Response(
        "Method Not Allowed",
        {
          status: 405,
          headers: {
            Allow: "GET",
          },
        },
      );
    }

    const requestUrl =
      new URL(req.url);

    const token =
      requestUrl.searchParams.get("token");

    if (
      !token ||
      token.trim().length === 0
    ) {
      return errorPage(
        400,
        "توکن پرداخت وجود ندارد.",
      );
    }

    const normalizedToken =
      token.trim();

    const safeToken =
      escapeHtml(normalizedToken);

    return new Response(
      `
<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
  <meta charset="UTF-8">

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >

  <title>در حال انتقال به درگاه</title>

  <style>
    body {
      margin: 0;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: #ffffff;
      font-family: Arial, sans-serif;
    }

    .container {
      text-align: center;
      padding: 24px;
    }

    .loader {
      width: 42px;
      height: 42px;
      margin: 0 auto 20px;
      border: 4px solid #eeeeee;
      border-top-color: #222222;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }

    p {
      color: #555555;
      font-size: 16px;
    }

    @keyframes spin {
      to {
        transform: rotate(360deg);
      }
    }

    button {
      margin-top: 16px;
      padding: 10px 18px;
      border: 0;
      border-radius: 8px;
      background: #222222;
      color: white;
      cursor: pointer;
    }
  </style>
</head>

<body>
  <div class="container">
    <div class="loader"></div>

    <p>
      در حال انتقال به درگاه پرداخت...
    </p>

    <form
      id="sep-payment-form"
      method="POST"
      action="${SEP_PAYMENT_URL}"
    >
      <input
        type="hidden"
        name="Token"
        value="${safeToken}"
      >

      <noscript>
        <button type="submit">
          ورود به درگاه پرداخت
        </button>
      </noscript>
    </form>
  </div>

  <script>
    document
      .getElementById("sep-payment-form")
      .submit();
  </script>
</body>
</html>
`,
      {
        status: 200,
        headers: {
          "Content-Type":
            "text/html; charset=utf-8",
          "Cache-Control":
            "no-store, no-cache, must-revalidate",
        },
      },
    );
  } catch (error) {
    console.error(
      "SEP redirect error:",
      error,
    );

    return errorPage(
      500,
      error instanceof Error
        ? error.message
        : "خطای داخلی سرور.",
    );
  }
});