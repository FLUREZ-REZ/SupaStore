import { createClient } from "npm:@supabase/supabase-js@2";

const TOMAN_TO_RIAL = 10;

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
): Response {
  return new Response(
    JSON.stringify(body),
    {
      status,
      headers: {
        "Content-Type": "application/json",
      },
    },
  );
}

function htmlResponse(
  html: string,
  status = 200,
): Response {
  const headers = new Headers();

  headers.set(
    "Content-Type",
    "text/html; charset=utf-8",
  );

  headers.set(
    "Cache-Control",
    "no-store, no-cache, must-revalidate",
  );

  headers.set(
    "Pragma",
    "no-cache",
  );

  return new Response(
    html,
    {
      status,
      headers,
    },
  );
}

function escapeHtml(
  value: string,
): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll(
      "<",
      "&lt;",
    )
    .replaceAll(
      ">",
      "&gt;",
    )
    .replaceAll(
      '"',
      "&quot;",
    )
    .replaceAll(
      "'",
      "&#039;",
    );
}

function getSupabaseAdmin() {
  const supabaseUrl =
    Deno.env.get(
      "SUPABASE_URL",
    );

  if (!supabaseUrl) {
    throw new Error(
      "Missing SUPABASE_URL",
    );
  }

  let secretKey:
    string | undefined;

  const secretKeysRaw =
    Deno.env.get(
      "SUPABASE_SECRET_KEYS",
    );

  if (secretKeysRaw) {
    try {
      const secretKeys =
        JSON.parse(
          secretKeysRaw,
        );

      secretKey =
        secretKeys["default"];
    } catch (error) {
      console.error(
        "Failed to parse SUPABASE_SECRET_KEYS:",
        error,
      );
    }
  }

  if (!secretKey) {
    secretKey =
      Deno.env.get(
        "SUPABASE_SERVICE_ROLE_KEY",
      ) ?? undefined;
  }

  if (!secretKey) {
    throw new Error(
      "Missing Supabase secret key",
    );
  }

  return createClient(
    supabaseUrl,
    secretKey,
    {
      auth: {
        autoRefreshToken:
          false,

        persistSession:
          false,
      },
    },
  );
}

function getZarinPalConfig() {
  const merchantId =
    Deno.env.get(
      "ZARINPAL_MERCHANT_ID",
    );

  const sandboxValue =
    Deno.env.get(
      "ZARINPAL_SANDBOX",
    );

  const sandbox =
    sandboxValue?.toLowerCase() ===
    "true";

  if (!merchantId) {
    throw new Error(
      "Missing ZARINPAL_MERCHANT_ID",
    );
  }

  const baseUrl =
    sandbox
      ? "https://sandbox.zarinpal.com"
      : "https://payment.zarinpal.com";

  return {
    merchantId,

    sandbox,

    verifyUrl:
      `${baseUrl}/pg/v4/payment/verify.json`,
  };
}

function successPage(
  orderId: string,
  refId: string,
): string {
  return `
<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
  <meta charset="UTF-8">

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >

  <title>
    پرداخت موفق
  </title>

  <style>
    body {
      margin: 0;
      font-family: sans-serif;
      background: #f5f5f5;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
    }

    .card {
      width: 90%;
      max-width: 420px;
      background: white;
      border-radius: 16px;
      padding: 32px;
      text-align: center;
      box-shadow:
        0 8px 30px rgba(0, 0, 0, 0.08);
    }

    .success {
      color: #16a34a;
      font-size: 64px;
      margin-bottom: 16px;
    }

    h1 {
      margin-bottom: 12px;
    }

    p {
      color: #555;
      line-height: 2;
    }

    .ref {
      margin-top: 20px;
      padding: 12px;
      background: #f5f5f5;
      border-radius: 10px;
      direction: ltr;
      word-break: break-all;
    }
  </style>
</head>

<body>

  <div class="card">

    <div class="success">
      ✓
    </div>

    <h1>
      پرداخت موفق بود
    </h1>

    <p>
      سفارش شما با موفقیت پرداخت شد.
    </p>

    <p>
      شماره سفارش:
      <strong>
        ${escapeHtml(orderId)}
      </strong>
    </p>

    <div class="ref">
      شماره پیگیری:
      <strong>
        ${escapeHtml(refId)}
      </strong>
    </div>

  </div>

</body>
</html>
`;
}

function failedPage(
  message: string,
): string {
  return `
<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>

  <meta charset="UTF-8">

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >

  <title>
    پرداخت ناموفق
  </title>

  <style>
    body {
      margin: 0;
      font-family: sans-serif;
      background: #f5f5f5;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
    }

    .card {
      width: 90%;
      max-width: 420px;
      background: white;
      border-radius: 16px;
      padding: 32px;
      text-align: center;
      box-shadow:
        0 8px 30px rgba(0, 0, 0, 0.08);
    }

    .failed {
      color: #dc2626;
      font-size: 64px;
      margin-bottom: 16px;
    }

    h1 {
      margin-bottom: 12px;
    }

    p {
      color: #555;
      line-height: 2;
    }
  </style>

</head>

<body>

  <div class="card">

    <div class="failed">
      ×
    </div>

    <h1>
      پرداخت ناموفق بود
    </h1>

    <p>
      ${escapeHtml(message)}
    </p>

  </div>

</body>
</html>
`;
}

Deno.serve(
  async (req: Request) => {
    try {
      /*
       * ----------------------------------------------------------
       * 1. Callback must be GET
       * ----------------------------------------------------------
       */

      if (req.method !== "GET") {
        return jsonResponse(
          {
            success: false,
            error:
              "Method not allowed",
          },
          405,
        );
      }

      /*
       * ----------------------------------------------------------
       * 2. Read ZarinPal callback
       * ----------------------------------------------------------
       */

      const url =
        new URL(req.url);

      const authority =
        url.searchParams.get(
          "Authority",
        );

      const status =
        url.searchParams.get(
          "Status",
        );

      if (!authority) {
        return htmlResponse(
          failedPage(
            "شناسه تراکنش نامعتبر است.",
          ),
          400,
        );
      }

      /*
       * ----------------------------------------------------------
       * 3. Admin client
       * ----------------------------------------------------------
       */

      const supabaseAdmin =
        getSupabaseAdmin();

      /*
       * ----------------------------------------------------------
       * 4. Find payment
       * ----------------------------------------------------------
       */

      const {
        data: payment,
        error: paymentError,
      } = await supabaseAdmin
        .from("payments")
        .select(`
          id,
          order_id,
          user_id,
          amount,
          gateway,
          status,
          authority,
          ref_id
        `)
        .eq(
          "authority",
          authority,
        )
        .eq(
          "gateway",
          "zarinpal",
        )
        .maybeSingle();

      if (paymentError) {
        console.error(
          "Payment lookup error:",
          paymentError,
        );

        return htmlResponse(
          failedPage(
            "خطا در دریافت اطلاعات پرداخت.",
          ),
          500,
        );
      }

      if (!payment) {
        return htmlResponse(
          failedPage(
            "تراکنش مورد نظر پیدا نشد.",
          ),
          404,
        );
      }

      /*
       * ----------------------------------------------------------
       * 5. Validate stored amount
       * ----------------------------------------------------------
       *
       * payments.amount = TOMAN
       */

      const amountInToman =
        payment.amount;

      if (
        typeof amountInToman !==
          "number" ||
        !Number.isSafeInteger(
          amountInToman,
        ) ||
        amountInToman <= 0
      ) {
        console.error(
          "Invalid payment amount:",
          amountInToman,
        );

        await supabaseAdmin
          .from("payments")
          .update({
            status:
              "failed",

            gateway_message:
              "Invalid stored payment amount",
          })
          .eq(
            "id",
            payment.id,
          );

        return htmlResponse(
          failedPage(
            "مبلغ تراکنش نامعتبر است.",
          ),
          500,
        );
      }

      /*
       * ----------------------------------------------------------
       * 6. Convert TOMAN -> RIAL
       * ----------------------------------------------------------
       */

      const amountInRial =
        amountInToman *
        TOMAN_TO_RIAL;

      if (
        !Number.isSafeInteger(
          amountInRial,
        ) ||
        amountInRial <= 0
      ) {
        return htmlResponse(
          failedPage(
            "مبلغ تراکنش بیش از حد مجاز است.",
          ),
          500,
        );
      }

      /*
       * ----------------------------------------------------------
       * 7. User canceled payment
       * ----------------------------------------------------------
       */

      if (status !== "OK") {
        console.log(
          "Payment canceled:",
          {
            authority,
            status,
            payment_id:
              payment.id,
            order_id:
              payment.order_id,
          },
        );

        if (
          payment.status !==
          "paid"
        ) {
          await supabaseAdmin
            .from("payments")
            .update({
              status:
                "canceled",

              gateway_message:
                `ZarinPal callback status: ${
                  status ??
                  "UNKNOWN"
                }`,
            })
            .eq(
              "id",
              payment.id,
            );

          await supabaseAdmin
            .from("orders")
            .update({
              payment_status:
                "canceled",
            })
            .eq(
              "id",
              payment.order_id,
            )
            .neq(
              "payment_status",
              "paid",
            );
        }

        return htmlResponse(
          failedPage(
            "پرداخت توسط کاربر تکمیل نشد یا لغو شد.",
          ),
          200,
        );
      }

      /*
       * ----------------------------------------------------------
       * 8. Already paid
       * ----------------------------------------------------------
       */

      if (
        payment.status ===
        "paid"
      ) {
        return htmlResponse(
          successPage(
            payment.order_id,
            payment.ref_id ??
              "ثبت شده",
          ),
          200,
        );
      }

      /*
       * ----------------------------------------------------------
       * 9. ZarinPal config
       * ----------------------------------------------------------
       */

      const {
        merchantId,
        sandbox,
        verifyUrl,
      } =
        getZarinPalConfig();

      console.log(
        "ZarinPal environment:",
        sandbox
          ? "SANDBOX"
          : "PRODUCTION",
      );

      /*
       * ----------------------------------------------------------
       * 10. Verify
       * ----------------------------------------------------------
       *
       * IMPORTANT:
       *
       * amount is taken from DB.
       *
       * DB:
       * TOMAN
       *
       * ZarinPal:
       * RIAL
       */

      const verifyPayload = {
        merchant_id:
          merchantId,

        amount:
          amountInRial,

        authority,
      };

      console.log(
        "ZarinPal verify request:",
        {
          payment_id:
            payment.id,

          order_id:
            payment.order_id,

          amount_toman:
            amountInToman,

          amount_rial:
            amountInRial,

          authority,

          sandbox,
        },
      );

      const verifyResponse =
        await fetch(
          verifyUrl,
          {
            method:
              "POST",

            headers: {
              "Content-Type":
                "application/json",

              Accept:
                "application/json",
            },

            body:
              JSON.stringify(
                verifyPayload,
              ),
          },
        );

      let verifyResult:
        any;

      try {
        verifyResult =
          await verifyResponse.json();
      } catch {
        verifyResult =
          null;
      }

      /*
       * ----------------------------------------------------------
       * 11. HTTP error
       * ----------------------------------------------------------
       */

      if (
        !verifyResponse.ok ||
        !verifyResult
      ) {
        console.error(
          "ZarinPal verify HTTP error:",
          {
            status:
              verifyResponse.status,

            response:
              verifyResult,
          },
        );

        await supabaseAdmin
          .from("payments")
          .update({
            status:
              "failed",

            gateway_message:
              "ZarinPal verification request failed",
          })
          .eq(
            "id",
            payment.id,
          )
          .neq(
            "status",
            "paid",
          );

        return htmlResponse(
          failedPage(
            "بررسی تراکنش در درگاه پرداخت با خطا مواجه شد.",
          ),
          502,
        );
      }

      /*
       * ----------------------------------------------------------
       * 12. Verify result
       * ----------------------------------------------------------
       */

      const verifyCode =
        verifyResult
          ?.data
          ?.code;

      const refId =
        verifyResult
          ?.data
          ?.ref_id;

      console.log(
        "ZarinPal verify response:",
        {
          payment_id:
            payment.id,

          order_id:
            payment.order_id,

          code:
            verifyCode,

          ref_id:
            refId ??
            null,
        },
      );

      /*
       * ----------------------------------------------------------
       * 13. SUCCESS
       * ----------------------------------------------------------
       *
       * 100 = verified
       * 101 = already verified
       */

      if (
        verifyCode === 100 ||
        verifyCode === 101
      ) {
        const finalRefId =
          refId !==
            undefined &&
          refId !== null
            ? String(refId)
            : payment.ref_id;

        /*
         * Update payment
         */

        const {
          error:
            paymentUpdateError,
        } = await supabaseAdmin
          .from("payments")
          .update({
            status:
              "paid",

            ref_id:
              finalRefId,

            gateway_message:
              verifyCode === 101
                ? "Payment already verified"
                : "Payment verified successfully",

            paid_at:
              new Date().toISOString(),
          })
          .eq(
            "id",
            payment.id,
          )
          .neq(
            "status",
            "paid",
          );

        if (
          paymentUpdateError
        ) {
          console.error(
            "Payment update error:",
            paymentUpdateError,
          );

          return htmlResponse(
            failedPage(
              "پرداخت تأیید شد اما ثبت نتیجه در سیستم با خطا مواجه شد.",
            ),
            500,
          );
        }

        /*
         * Update order
         */

        const {
          error:
            orderUpdateError,
        } = await supabaseAdmin
          .from("orders")
          .update({
            payment_status:
              "paid",

            status:
              "processing",
          })
          .eq(
            "id",
            payment.order_id,
          )
          .neq(
            "payment_status",
            "paid",
          );

        if (
          orderUpdateError
        ) {
          console.error(
            "Order update error:",
            orderUpdateError,
          );

          return htmlResponse(
            failedPage(
              "پرداخت با موفقیت انجام شد اما ثبت وضعیت سفارش با مشکل مواجه شد.",
            ),
            500,
          );
        }

        return htmlResponse(
          successPage(
            payment.order_id,

            finalRefId ??
              "ثبت شده",
          ),
          200,
        );
      }

      /*
       * ----------------------------------------------------------
       * 14. Verify failed
       * ----------------------------------------------------------
       */

      console.error(
        "ZarinPal verification failed:",
        {
          code:
            verifyCode,

          errors:
            verifyResult
              ?.errors,

          payment_id:
            payment.id,

          order_id:
            payment.order_id,
        },
      );

      await supabaseAdmin
        .from("payments")
        .update({
          status:
            "failed",

          gateway_message:
            JSON.stringify({
              code:
                verifyCode ??
                null,

              errors:
                verifyResult
                  ?.errors ??
                null,
            }),
        })
        .eq(
          "id",
          payment.id,
        )
        .neq(
          "status",
          "paid",
        );

      await supabaseAdmin
        .from("orders")
        .update({
          payment_status:
            "failed",
        })
        .eq(
          "id",
          payment.order_id,
        )
        .neq(
          "payment_status",
          "paid",
        );

      return htmlResponse(
        failedPage(
          "پرداخت توسط درگاه تأیید نشد.",
        ),
        200,
      );
    } catch (error) {
      console.error(
        "payment-callback error:",
        error,
      );

      return htmlResponse(
        failedPage(
          "خطای داخلی سرور رخ داد.",
        ),
        500,
      );
    }
  },
);