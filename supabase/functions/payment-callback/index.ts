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
        "Content-Type":
          "application/json",
      },
    },
  );
}

function redirectToApp({
  status,
  orderId,
  refId,
}: {
  status: string;
  orderId: string;
  refId?: string | null;
}): Response {
  const url =
    new URL(
      "supastore://payment/result",
    );

  url.searchParams.set(
    "status",
    status,
  );

  url.searchParams.set(
    "order_id",
    orderId,
  );

  if (
    refId != null &&
    refId.length > 0
  ) {
    url.searchParams.set(
      "ref_id",
      refId,
    );
  }

  console.log(
    "Redirecting to app:",
    url.toString(),
  );

  return Response.redirect(
    url.toString(),
    303,
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

      console.log(
        "ZarinPal callback:",
        {
          authority,
          status,
        },
      );

      if (!authority) {
        return new Response(
          "Missing Authority",
          {
            status: 400,
          },
        );
      }

      /*
       * ----------------------------------------------------------
       * 3. Supabase admin
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
        .select(
          `
            id,
            order_id,
            user_id,
            amount,
            gateway,
            status,
            authority,
            ref_id
          `,
        )
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

        return new Response(
          "Payment lookup failed",
          {
            status: 500,
          },
        );
      }

      if (!payment) {
        return new Response(
          "Payment not found",
          {
            status: 404,
          },
        );
      }

      /*
       * ----------------------------------------------------------
       * 5. Already paid
       * ----------------------------------------------------------
       */

      if (
        payment.status ===
        "paid"
      ) {
        return redirectToApp({
          status:
            "success",

          orderId:
            payment.order_id,

          refId:
            payment.ref_id,
        });
      }

      /*
       * ----------------------------------------------------------
       * 6. Validate amount
       * ----------------------------------------------------------
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

        return redirectToApp({
          status:
            "failed",

          orderId:
            payment.order_id,
        });
      }

      /*
       * ----------------------------------------------------------
       * 7. TOMAN -> RIAL
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
        return redirectToApp({
          status:
            "failed",

          orderId:
            payment.order_id,
        });
      }

      /*
       * ----------------------------------------------------------
       * 8. User canceled payment
       * ----------------------------------------------------------
       */

      if (status !== "OK") {
        console.log(
          "Payment canceled:",
          {
            authority,
            status,
            paymentId:
              payment.id,
            orderId:
              payment.order_id,
          },
        );

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
          )
          .neq(
            "status",
            "paid",
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

        return redirectToApp({
          status:
            "canceled",

          orderId:
            payment.order_id,
        });
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
        any = null;

      try {
        verifyResult =
          await verifyResponse.json();
      } catch {
        verifyResult = null;
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

        return redirectToApp({
          status:
            "failed",

          orderId:
            payment.order_id,
        });
      }

      /*
       * ----------------------------------------------------------
       * 12. Verify response
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

          return redirectToApp({
            status:
              "failed",

            orderId:
              payment.order_id,
          });
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

          return redirectToApp({
            status:
              "failed",

            orderId:
              payment.order_id,

            refId:
              finalRefId,
          });
        }

        /*
         * Redirect to Flutter
         */

        return redirectToApp({
          status:
            "success",

          orderId:
            payment.order_id,

          refId:
            finalRefId,
        });
      }

      /*
       * ----------------------------------------------------------
       * 14. Verification failed
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

      return redirectToApp({
        status:
          "failed",

        orderId:
          payment.order_id,
      });
    } catch (error) {
      console.error(
        "payment-callback error:",
        error,
      );

      return new Response(
        "Internal server error",
        {
          status: 500,
        },
      );
    }
  },
);