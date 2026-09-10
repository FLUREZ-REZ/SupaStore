import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const TOMAN_TO_RIAL = 10;

const SUCCESS_VERIFY_CODES = [100, 101];

type ZarinPalConfig = {
  baseUrl: string;
  merchantId: string;
  sandbox: boolean;
};

function getZarinPalConfig(): ZarinPalConfig {
  const sandbox = Deno.env.get("ZARINPAL_SANDBOX") === "true";

  const merchantId = Deno.env.get("ZARINPAL_MERCHANT_ID");

  if (!merchantId) {
    throw new Error("ZARINPAL_MERCHANT_ID is not configured.");
  }

  return {
    baseUrl: sandbox
      ? "https://sandbox.zarinpal.com"
      : "https://payment.zarinpal.com",
    merchantId,
    sandbox,
  };
}

function getAdminClient() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");

  const secretKeysRaw = Deno.env.get(
    "SUPABASE_SECRET_KEYS",
  );

  if (!supabaseUrl) {
    throw new Error(
      "SUPABASE_URL is not configured.",
    );
  }

  if (!secretKeysRaw) {
    throw new Error(
      "SUPABASE_SECRET_KEYS is not configured.",
    );
  }

  let secretKeys: Record<string, string>;

  try {
    secretKeys = JSON.parse(secretKeysRaw);
  } catch {
    throw new Error(
      "SUPABASE_SECRET_KEYS contains invalid JSON.",
    );
  }

  const secretKey = secretKeys["default"];

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

function redirectToApp({
  status,
  orderId,
  refId,
}: {
  status: string;
  orderId: string;
  refId?: string | number | null;
}): Response {
  const url = new URL("supastore://payment/result");

  url.searchParams.set("status", status);
  url.searchParams.set("order_id", orderId);

  if (refId !== null && refId !== undefined) {
    const refIdString = String(refId);

    if (refIdString.length > 0) {
      url.searchParams.set("ref_id", refIdString);
    }
  }

  console.log("Redirecting to app:", {
    status,
    orderId,
    hasRefId: refId !== null && refId !== undefined,
  });

  return new Response(null, {
    status: 303,
    headers: {
      Location: url.toString(),
      "Cache-Control": "no-store",
    },
  });
}

function badRequest(message: string): Response {
  return new Response(message, {
    status: 400,
    headers: {
      "Content-Type": "text/plain; charset=utf-8",
    },
  });
}

function serverError(message: string): Response {
  return new Response(message, {
    status: 500,
    headers: {
      "Content-Type": "text/plain; charset=utf-8",
    },
  });
}

async function markPaymentAndOrderCanceled({
  supabase,
  paymentId,
  orderId,
  message,
}: {
  supabase: ReturnType<typeof createClient>;
  paymentId: string;
  orderId: string;
  message: string;
}) {
  const { error: paymentError } = await supabase
    .from("payments")
    .update({
      status: "canceled",
      gateway_message: message,
    })
    .eq("id", paymentId);

  if (paymentError) {
    throw new Error(
      `Failed to update payment as canceled: ${paymentError.message}`,
    );
  }

  const { error: orderError } = await supabase
    .from("orders")
    .update({
      payment_status: "canceled",
      status: "canceled",
    })
    .eq("id", orderId);

  if (orderError) {
    throw new Error(
      `Failed to update order as canceled: ${orderError.message}`,
    );
  }
}

async function markPaymentAndOrderFailed({
  supabase,
  paymentId,
  orderId,
  message,
}: {
  supabase: ReturnType<typeof createClient>;
  paymentId: string;
  orderId: string;
  message: string;
}) {
  const { error: paymentError } = await supabase
    .from("payments")
    .update({
      status: "failed",
      gateway_message: message,
    })
    .eq("id", paymentId);

  if (paymentError) {
    throw new Error(
      `Failed to update payment as failed: ${paymentError.message}`,
    );
  }

  const { error: orderError } = await supabase
    .from("orders")
    .update({
      payment_status: "failed",
      status: "canceled",
    })
    .eq("id", orderId);

  if (orderError) {
    throw new Error(
      `Failed to update order as failed: ${orderError.message}`,
    );
  }
}

async function markPaymentAndOrderPaid({
  supabase,
  paymentId,
  orderId,
  refId,
  message,
}: {
  supabase: ReturnType<typeof createClient>;
  paymentId: string;
  orderId: string;
  refId: string | number;
  message: string;
}) {
  const { error: paymentError } = await supabase
    .from("payments")
    .update({
      status: "paid",
      ref_id: String(refId),
      gateway_message: message,
      paid_at: new Date().toISOString(),
    })
    .eq("id", paymentId);

  if (paymentError) {
    throw new Error(
      `Failed to update payment as paid: ${paymentError.message}`,
    );
  }

  const { error: orderError } = await supabase
    .from("orders")
    .update({
      payment_status: "paid",
      status: "processing",
    })
    .eq("id", orderId);

  if (orderError) {
    throw new Error(
      `Failed to update order as processing: ${orderError.message}`,
    );
  }
}

Deno.serve(async (req: Request) => {
  try {
    // ------------------------------------------------------------
    // ZarinPal callback must use GET.
    // ------------------------------------------------------------

    if (req.method !== "GET") {
      return new Response("Method Not Allowed", {
        status: 405,
        headers: {
          Allow: "GET",
          "Content-Type": "text/plain; charset=utf-8",
        },
      });
    }

    const requestUrl = new URL(req.url);

    const authority = requestUrl.searchParams.get("Authority");
    const status = requestUrl.searchParams.get("Status");

    console.log("ZarinPal callback received:", {
      status,
      hasAuthority: authority !== null && authority.trim().length > 0,
    });

    // ------------------------------------------------------------
    // Validate Authority
    // ------------------------------------------------------------

    if (!authority || authority.trim().length === 0) {
      return badRequest("Authority is missing.");
    }

    const normalizedAuthority = authority.trim();

    const normalizedStatus = (status ?? "")
      .trim()
      .toUpperCase();

    // ------------------------------------------------------------
    // Create admin client
    // ------------------------------------------------------------

    const supabase = getAdminClient();

    // ------------------------------------------------------------
    // Find payment
    // ------------------------------------------------------------

    const { data: payment, error: paymentLookupError } =
      await supabase
        .from("payments")
        .select(
          `
          id,
          order_id,
          amount,
          gateway,
          status,
          authority
          `,
        )
        .eq("authority", normalizedAuthority)
        .eq("gateway", "zarinpal")
        .maybeSingle();

    if (paymentLookupError) {
      console.error(
        "Payment lookup error:",
        paymentLookupError.message,
      );

      return serverError("Failed to find payment.");
    }

    if (!payment) {
      console.error(
        "Payment not found for authority.",
        {
          hasAuthority: true,
        },
      );

      return badRequest("Payment not found.");
    }

    const paymentId = payment.id;
    const orderId = payment.order_id;

    if (!paymentId || !orderId) {
      return serverError(
        "Payment or order ID is missing.",
      );
    }

    // ------------------------------------------------------------
    // Idempotency
    //
    // If payment is already paid, make sure the order
    // is also synchronized.
    // ------------------------------------------------------------

    if (payment.status === "paid") {
      console.log(
        "Payment is already paid:",
        paymentId,
      );

      const { error: orderRepairError } =
        await supabase
          .from("orders")
          .update({
            payment_status: "paid",
            status: "processing",
          })
          .eq("id", orderId);

      if (orderRepairError) {
        console.error(
          "Failed to repair already-paid order:",
          orderRepairError.message,
        );

        return serverError(
          "Failed to synchronize order status.",
        );
      }

      return redirectToApp({
        status: "success",
        orderId,
      });
    }

    // ------------------------------------------------------------
    // Validate payment amount
    //
    // Database:
    // TOMAN
    //
    // ZarinPal:
    // RIAL
    //
    // Therefore:
    // TOMAN * 10 = RIAL
    // ------------------------------------------------------------

    const amountInToman = Number(payment.amount);

    if (
      !Number.isFinite(amountInToman) ||
      amountInToman <= 0 ||
      !Number.isInteger(amountInToman)
    ) {
      console.error(
        "Invalid payment amount:",
        payment.amount,
      );

      return serverError(
        "Invalid payment amount.",
      );
    }

    const amountInRial =
      amountInToman * TOMAN_TO_RIAL;

    // ------------------------------------------------------------
    // User canceled payment on ZarinPal
    // ------------------------------------------------------------

    if (normalizedStatus !== "OK") {
      console.log(
        "ZarinPal payment canceled by user/gateway.",
      );

      await markPaymentAndOrderCanceled({
        supabase,
        paymentId,
        orderId,
        message:
          `ZarinPal callback status: ${
            normalizedStatus || "UNKNOWN"
          }`,
      });

      return redirectToApp({
        status: "canceled",
        orderId,
      });
    }

    // ------------------------------------------------------------
    // ZarinPal configuration
    // ------------------------------------------------------------

    const config = getZarinPalConfig();

    // ------------------------------------------------------------
    // Verify payment
    // ------------------------------------------------------------

    const verifyUrl =
      `${config.baseUrl}/pg/v4/payment/verify.json`;

    const verifyResponse = await fetch(
      verifyUrl,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          merchant_id: config.merchantId,
          amount: amountInRial,
          authority: normalizedAuthority,
        }),
      },
    );

    let verifyData: any = null;

    try {
      verifyData = await verifyResponse.json();
    } catch {
      verifyData = null;
    }

    console.log(
      "ZarinPal verify response:",
      {
        httpStatus: verifyResponse.status,
        code: verifyData?.data?.code ?? null,
        hasRefId:
          verifyData?.data?.ref_id !== undefined &&
          verifyData?.data?.ref_id !== null,
      },
    );

    // ------------------------------------------------------------
    // HTTP error from ZarinPal
    // ------------------------------------------------------------

    if (!verifyResponse.ok) {
      const gatewayMessage =
        verifyData?.errors?.message ??
        verifyData?.data?.message ??
        `ZarinPal verify HTTP error: ${verifyResponse.status}`;

      console.error(
        "ZarinPal verify HTTP error:",
        gatewayMessage,
      );

      await markPaymentAndOrderFailed({
        supabase,
        paymentId,
        orderId,
        message: String(gatewayMessage),
      });

      return redirectToApp({
        status: "failed",
        orderId,
      });
    }

    // ------------------------------------------------------------
    // Extract verification result
    // ------------------------------------------------------------

    const verifyCode =
      Number(verifyData?.data?.code);

    const refId =
      verifyData?.data?.ref_id;

    const verifyMessage =
      verifyData?.data?.message ??
      verifyData?.errors?.message ??
      "ZarinPal verification response received.";

    // ------------------------------------------------------------
    // Successful verification
    //
    // 100 = successful verification
    // 101 = already verified
    // ------------------------------------------------------------

    if (
      SUCCESS_VERIFY_CODES.includes(
        verifyCode,
      )
    ) {
      if (
        refId === undefined ||
        refId === null ||
        String(refId).trim().length === 0
      ) {
        console.error(
          "Successful verification without ref_id.",
        );

        await markPaymentAndOrderFailed({
          supabase,
          paymentId,
          orderId,
          message:
            "Successful verification returned without ref_id.",
        });

        return redirectToApp({
          status: "failed",
          orderId,
        });
      }

      await markPaymentAndOrderPaid({
        supabase,
        paymentId,
        orderId,
        refId,
        message: String(verifyMessage),
      });

      console.log(
        "Payment successfully verified:",
        {
          paymentId,
          orderId,
          refId: String(refId),
        },
      );

      return redirectToApp({
        status: "success",
        orderId,
        refId,
      });
    }

    // ------------------------------------------------------------
    // Verification failed
    // ------------------------------------------------------------

    const failureMessage =
      verifyData?.errors?.message ??
      verifyData?.data?.message ??
      `ZarinPal verification failed. Code: ${verifyCode}`;

    console.error(
      "ZarinPal verification failed:",
      {
        code: verifyCode,
        message: failureMessage,
      },
    );

    await markPaymentAndOrderFailed({
      supabase,
      paymentId,
      orderId,
      message: String(failureMessage),
    });

    return redirectToApp({
      status: "failed",
      orderId,
    });
  } catch (error) {
    console.error(
      "Payment callback unexpected error:",
      error,
    );

    return serverError(
      error instanceof Error
        ? error.message
        : "Unexpected payment callback error.",
    );
  }
});