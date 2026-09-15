import { createClient } from "npm:@supabase/supabase-js@2";

// ============================================================
// Types
// ============================================================

type PaymentInfo = {
  orderId: string;
  amount: number;
  currency: string;
  token: string;
};

// ============================================================
// Helpers
// ============================================================

function getRequiredEnv(name: string): string {
  const value = Deno.env.get(name);

  if (!value || value.trim().length === 0) {
    throw new Error(`${name} is not configured.`);
  }

  return value.trim();
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function formatPrice(value: number): string {
  return new Intl.NumberFormat("fa-IR").format(value);
}

function htmlResponse(
  html: string,
  status = 200,
): Response {
  return new Response(html, {
    status,
    headers: {
      "Content-Type": "text/html; charset=utf-8",
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff",
    },
  });
}

function errorPage(
  status: number,
  message: string,
): Response {
  return htmlResponse(
    `
<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
  <meta charset="UTF-8">

  <meta
    http-equiv="Content-Type"
    content="text/html; charset=UTF-8"
  >

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >

  <meta
    name="theme-color"
    content="#111827"
  >

  <title>خطا در درگاه آزمایشی</title>

  <style>
    * {
      box-sizing: border-box;
    }

    html,
    body {
      margin: 0;
      padding: 0;
      min-height: 100%;
    }

    body {
      min-height: 100vh;
      background: #f4f5f7;
      font-family:
        Tahoma,
        Arial,
        sans-serif;

      display: flex;
      align-items: center;
      justify-content: center;

      padding: 20px;
    }

    .card {
      width: 100%;
      max-width: 460px;

      background: #ffffff;
      border-radius: 24px;

      padding: 32px 24px;

      box-shadow:
        0 18px 50px rgba(0, 0, 0, 0.08);

      text-align: center;
    }

    .icon {
      width: 72px;
      height: 72px;

      margin: 0 auto 20px;

      border-radius: 50%;

      display: flex;
      align-items: center;
      justify-content: center;

      background: #fff1f2;
      color: #dc2626;

      font-size: 34px;
      font-weight: 700;
    }

    h1 {
      margin: 0 0 10px;

      font-size: 20px;
      color: #111827;
    }

    p {
      margin: 0;

      color: #6b7280;

      font-size: 14px;
      line-height: 1.9;
    }
  </style>
</head>

<body>

  <div class="card">

    <div class="icon">
      !
    </div>

    <h1>
      خطا در درگاه آزمایشی
    </h1>

    <p>
      ${escapeHtml(message)}
    </p>

  </div>

</body>
</html>
`,
    status,
  );
}

// ============================================================
// Admin Client
// ============================================================

function getAdminClient() {
  const supabaseUrl =
    getRequiredEnv("SUPABASE_URL");

  const secretKeysRaw =
    Deno.env.get(
      "SUPABASE_SECRET_KEYS",
    );

  if (!secretKeysRaw) {
    throw new Error(
      "SUPABASE_SECRET_KEYS is not configured.",
    );
  }

  let secretKeys:
    Record<string, string>;

  try {
    secretKeys =
      JSON.parse(
        secretKeysRaw,
      );
  } catch {
    throw new Error(
      "SUPABASE_SECRET_KEYS contains invalid JSON.",
    );
  }

  const secretKey =
    secretKeys["default"];

  if (
    !secretKey ||
    typeof secretKey !== "string" ||
    secretKey.trim().length === 0
  ) {
    throw new Error(
      "Default Supabase secret key is not configured.",
    );
  }

  return createClient(
    supabaseUrl,
    secretKey,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    },
  );
}

// ============================================================
// Main
// ============================================================

Deno.serve(
  async (req: Request) => {
    try {
      // ========================================================
      // Method
      // ========================================================

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

      // ========================================================
      // Mock enabled
      // ========================================================

      const mockEnabled =
        Deno.env.get(
          "SEP_MOCK",
        ) === "true";

      if (!mockEnabled) {
        return errorPage(
          404,
          "محیط آزمایشی SEP فعال نیست.",
        );
      }

      // ========================================================
      // Query
      // ========================================================

      const url =
        new URL(req.url);

      const token =
        url.searchParams.get(
          "token",
        );

      const orderId =
        url.searchParams.get(
          "order_id",
        );

      const amountParam =
        url.searchParams.get(
          "amount",
        );

      // ========================================================
      // Validate
      // ========================================================

      if (
        !token ||
        token.trim().length === 0
      ) {
        return errorPage(
          400,
          "توکن پرداخت وجود ندارد.",
        );
      }

      if (
        !orderId ||
        orderId.trim().length === 0
      ) {
        return errorPage(
          400,
          "شناسه سفارش وجود ندارد.",
        );
      }

      // ========================================================
      // Amount
      // ========================================================

      let amount = 0;

      if (
        amountParam &&
        amountParam.trim().length > 0
      ) {
        const parsedAmount =
          Number(
            amountParam,
          );

        if (
          Number.isFinite(
            parsedAmount,
          ) &&
          parsedAmount > 0
        ) {
          amount =
            Math.trunc(
              parsedAmount,
            );
        }
      }

      // ========================================================
      // Fallback: Database
      // ========================================================

      if (amount <= 0) {
        try {
          const supabase =
            getAdminClient();

          const {
            data: payment,
            error,
          } = await supabase
            .from("payments")
            .select(
              "amount",
            )
            .eq(
              "order_id",
              orderId,
            )
            .eq(
              "gateway",
              "sep",
            )
            .eq(
              "authority",
              token,
            )
            .order(
              "created_at",
              {
                ascending:
                  false,
              },
            )
            .limit(1)
            .maybeSingle();

          if (
            !error &&
            payment
          ) {
            const dbAmount =
              Number(
                payment.amount,
              );

            if (
              Number.isFinite(
                dbAmount,
              ) &&
              dbAmount > 0
            ) {
              amount =
                Math.trunc(
                  dbAmount,
                );
            }
          }
        } catch (error) {
          console.error(
            "Mock payment lookup error:",
            error,
          );
        }
      }

      // ========================================================
      // Payment Info
      // ========================================================

      const paymentInfo:
        PaymentInfo = {
        orderId:
          orderId.trim(),

        amount,

        currency:
          "TOMAN",

        token:
          token.trim(),
      };

      // ========================================================
      // Safe values
      // ========================================================

      const safeOrderId =
        escapeHtml(
          paymentInfo.orderId,
        );

      const safeToken =
        escapeHtml(
          paymentInfo.token,
        );

      const safeAmount =
        escapeHtml(
          formatPrice(
            paymentInfo.amount,
          ),
        );

      const callbackUrl =
        getRequiredEnv(
          "SEP_CALLBACK_URL",
        );

      const safeCallbackUrl =
        escapeHtml(
          callbackUrl,
        );

      const successRefNum =
        `MOCK-${paymentInfo.token}`;

      const successRrn =
        `MOCK-RRN-${paymentInfo.token}`;

      const safeSuccessRefNum =
        escapeHtml(
          successRefNum,
        );

      const safeSuccessRrn =
        escapeHtml(
          successRrn,
        );

      // ========================================================
      // HTML
      // ========================================================

      const html = `
<!DOCTYPE html>
<html lang="fa" dir="rtl">

<head>

  <meta charset="UTF-8">

  <meta
    http-equiv="Content-Type"
    content="text/html; charset=UTF-8"
  >

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >

  <meta
    name="theme-color"
    content="#111827"
  >

  <title>
    پرداخت سامان
  </title>

  <style>

    * {
      box-sizing: border-box;
    }

    html,
    body {
      margin: 0;
      padding: 0;
      min-height: 100%;
    }

    body {
      min-height: 100vh;

      background:
        linear-gradient(
          180deg,
          #f1f5f9 0%,
          #f8fafc 100%
        );

      font-family:
        Tahoma,
        Arial,
        sans-serif;

      color: #111827;

      display: flex;

      align-items: center;
      justify-content: center;

      padding: 16px;
    }

    .page {
      width: 100%;
      max-width: 480px;
    }

    .card {
      width: 100%;

      background: #ffffff;

      border-radius: 24px;

      overflow: hidden;

      border:
        1px solid
        rgba(148, 163, 184, 0.18);

      box-shadow:
        0 20px 60px
        rgba(15, 23, 42, 0.08);
    }

    /* ========================================================
       HEADER
       ======================================================== */

    .header {
      background:
        linear-gradient(
          135deg,
          #111827 0%,
          #1f2937 100%
        );

      color: #ffffff;

      padding:
        24px 20px;
    }

    .brand {
      display: flex;

      align-items: center;

      gap: 12px;
    }

    .brand-icon {
      width: 52px;
      height: 52px;

      flex-shrink: 0;

      display: flex;

      align-items: center;
      justify-content: center;

      border-radius: 16px;

      background:
        rgba(255, 255, 255, 0.10);

      border:
        1px solid
        rgba(255, 255, 255, 0.10);

      font-size: 17px;

      font-weight: 900;
    }

    .brand-title {
      font-size: 18px;

      font-weight: 800;

      margin-bottom: 4px;
    }

    .brand-subtitle {
      color:
        rgba(255, 255, 255, 0.68);

      font-size: 11px;
    }

    .badge {
      display: inline-flex;

      margin-top: 16px;

      padding:
        6px 10px;

      border-radius: 999px;

      background:
        rgba(245, 158, 11, 0.13);

      border:
        1px solid
        rgba(245, 158, 11, 0.20);

      color:
        #fbbf24;

      font-size: 10px;

      font-weight: 700;
    }

    /* ========================================================
       CONTENT
       ======================================================== */

    .content {
      padding: 20px;
    }

    /* ========================================================
       AMOUNT
       ======================================================== */

    .amount-box {
      text-align: center;

      background:
        #f8fafc;

      border:
        1px solid
        #e5e7eb;

      border-radius: 18px;

      padding:
        18px 14px;
    }

    .amount-label {
      color:
        #64748b;

      font-size: 12px;

      margin-bottom: 8px;
    }

    .amount {
      font-size: 28px;

      font-weight: 900;

      color:
        #111827;

      line-height: 1.3;
    }

    .currency {
      margin-top: 5px;

      color:
        #64748b;

      font-size: 11px;
    }

    /* ========================================================
       INFO
       ======================================================== */

    .info {
      margin-top: 18px;
    }

    .info-row {
      display: flex;

      justify-content: space-between;

      align-items: flex-start;

      gap: 16px;

      padding:
        13px 0;

      border-bottom:
        1px solid
        #eef2f7;
    }

    .info-row:last-child {
      border-bottom: 0;
    }

    .info-label {
      color:
        #64748b;

      font-size: 11px;

      white-space: nowrap;
    }

    .info-value {
      color:
        #111827;

      font-size: 11px;

      font-weight: 700;

      text-align: left;

      direction: ltr;

      word-break: break-all;
    }

    /* ========================================================
       ACTIONS
       ======================================================== */

    .actions {
      margin-top: 20px;

      display: grid;

      gap: 10px;
    }

    .action-form {
      margin: 0;
      padding: 0;
    }

    .button {
      width: 100%;

      min-height: 52px;

      border-radius: 14px;

      font-family:
        Tahoma,
        Arial,
        sans-serif;

      font-size: 14px;

      font-weight: 800;

      cursor: pointer;

      transition:
        transform 0.15s ease,
        box-shadow 0.15s ease,
        opacity 0.15s ease;
    }

    .button:hover {
      transform:
        translateY(-1px);
    }

    .button:active {
      transform:
        translateY(0);
    }

    .success-button {
      border: 0;

      color: #ffffff;

      background:
        linear-gradient(
          135deg,
          #15803d,
          #16a34a
        );

      box-shadow:
        0 10px 22px
        rgba(22, 163, 74, 0.18);
    }

    .cancel-button {
      border:
        1px solid
        #fecaca;

      color:
        #dc2626;

      background:
        #ffffff;
    }

    /* ========================================================
       SECURITY
       ======================================================== */

    .security {
      margin-top: 16px;

      padding: 12px;

      border-radius: 12px;

      background:
        #f8fafc;

      color:
        #64748b;

      font-size: 10px;

      line-height: 1.9;

      text-align: center;
    }

    .footer {
      margin-top: 14px;

      color:
        #94a3b8;

      font-size: 9px;

      text-align: center;
    }

    /* ========================================================
       MOBILE
       ======================================================== */

    @media (
      max-width: 420px
    ) {

      body {
        padding: 10px;
      }

      .header {
        padding:
          20px 16px;
      }

      .content {
        padding:
          16px;
      }

      .amount {
        font-size: 24px;
      }

      .brand-title {
        font-size: 16px;
      }

    }

  </style>

</head>

<body>

  <main class="page">

    <section class="card">

      <!-- HEADER -->

      <header class="header">

        <div class="brand">

          <div class="brand-icon">
            SEP
          </div>

          <div>

            <div class="brand-title">
              سامان پرداخت
            </div>

            <div class="brand-subtitle">
              درگاه پرداخت شبیه‌سازی‌شده
            </div>

          </div>

        </div>

        <div class="badge">
          محیط آزمایشی SupaStore
        </div>

      </header>

      <!-- CONTENT -->

      <section class="content">

        <!-- AMOUNT -->

        <div class="amount-box">

          <div class="amount-label">
            مبلغ قابل پرداخت
          </div>

          <div class="amount">
            ${safeAmount}
          </div>

          <div class="currency">
            تومان
          </div>

        </div>

        <!-- INFO -->

        <div class="info">

          <div class="info-row">

            <div class="info-label">
              شماره سفارش
            </div>

            <div class="info-value">
              ${safeOrderId}
            </div>

          </div>

          <div class="info-row">

            <div class="info-label">
              درگاه پرداخت
            </div>

            <div class="info-value">
              SEP Mock
            </div>

          </div>

          <div class="info-row">

            <div class="info-label">
              شناسه آزمایشی
            </div>

            <div class="info-value">
              ${safeToken}
            </div>

          </div>

        </div>

        <!-- ACTIONS -->

        <div class="actions">

          <!-- SUCCESS -->

          <form
            class="action-form"
            method="POST"
            action="${safeCallbackUrl}"
          >

            <input
              type="hidden"
              name="State"
              value="OK"
            >

            <input
              type="hidden"
              name="Status"
              value="OK"
            >

            <input
              type="hidden"
              name="RefNum"
              value="${safeSuccessRefNum}"
            >

            <input
              type="hidden"
              name="ResNum"
              value="${safeOrderId}"
            >

            <input
              type="hidden"
              name="RRN"
              value="${safeSuccessRrn}"
            >

            <input
              type="hidden"
              name="Token"
              value="${safeToken}"
            >

            <input
              type="hidden"
              name="Amount"
              value="${paymentInfo.amount}"
            >

            <button
              class="button success-button"
              type="submit"
            >
              پرداخت موفق
            </button>

          </form>

          <!-- CANCEL -->

          <form
            class="action-form"
            method="POST"
            action="${safeCallbackUrl}"
          >

            <input
              type="hidden"
              name="State"
              value="CANCELED"
            >

            <input
              type="hidden"
              name="Status"
              value="Canceled"
            >

            <input
              type="hidden"
              name="RefNum"
              value="${safeSuccessRefNum}"
            >

            <input
              type="hidden"
              name="ResNum"
              value="${safeOrderId}"
            >

            <input
              type="hidden"
              name="RRN"
              value=""
            >

            <input
              type="hidden"
              name="Token"
              value="${safeToken}"
            >

            <input
              type="hidden"
              name="Amount"
              value="${paymentInfo.amount}"
            >

            <button
              class="button cancel-button"
              type="submit"
            >
              لغو پرداخت
            </button>

          </form>

        </div>

        <!-- SECURITY -->

        <div class="security">
          این صفحه فقط برای تست جریان پرداخت
          SupaStore ساخته شده است و هیچ تراکنش
          بانکی واقعی انجام نمی‌دهد.
        </div>

        <div class="footer">
          SupaStore • SEP Mock Payment
        </div>

      </section>

    </section>

  </main>

</body>

</html>
`;

      // ========================================================
      // UTF-8 Response
      // ========================================================

      return htmlResponse(
        html,
      );
    } catch (error) {
      console.error(
        "SEP Mock payment error:",
        error,
      );

      return errorPage(
        500,
        error instanceof Error
          ? error.message
          : "خطای داخلی سرور.",
      );
    }
  },
);