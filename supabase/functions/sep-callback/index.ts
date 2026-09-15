import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const TOMAN_TO_RIAL = 10;

// ============================================================
// Types
// ============================================================

type SepCallbackData = {
  state: string;
  status: string;
  refNum: string | null;
  resNum: string | null;
  rrn: string | null;
  terminalId: string | null;
  amount: number | null;
  token: string | null;
};

type SupabaseClient = ReturnType<typeof createClient>;

type VerifyResult = {
  success: boolean;
  resultCode: number | null;
  resultDescription: string;
  verifiedAmount: number | null;
  verifiedRefNum: string;
  verifiedRrn: string | null;
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

function normalize(value: string | null | undefined): string {
  return (value ?? "").trim();
}

function isSuccessState(
  state: string,
  status: string,
): boolean {
  const normalizedState =
    state.trim().toUpperCase();

  const normalizedStatus =
    status.trim().toUpperCase();

  const stateSuccess =
    normalizedState === "OK" ||
    normalizedState === "SUCCESS" ||
    normalizedState === "SUCCESSFUL";

  const statusSuccess =
    normalizedStatus === "OK" ||
    normalizedStatus === "SUCCESS" ||
    normalizedStatus === "SUCCESSFUL";

  /*
   * برای callback موفق، یکی از نشانه‌های معتبر موفقیت
   * باید وجود داشته باشد و هیچ نشانه صریحی از لغو/شکست وجود نداشته باشد.
   */

  const explicitCanceled =
    normalizedState === "CANCELED" ||
    normalizedState === "CANCELLED" ||
    normalizedState === "FAILED" ||
    normalizedState === "ERROR" ||
    normalizedStatus === "CANCELED" ||
    normalizedStatus === "CANCELLED" ||
    normalizedStatus === "FAILED" ||
    normalizedStatus === "ERROR";

  if (explicitCanceled) {
    return false;
  }

  return stateSuccess || statusSuccess;
}

// ============================================================
// Supabase Admin Client
// ============================================================

function getAdminClient(): SupabaseClient {
  const supabaseUrl =
    getRequiredEnv("SUPABASE_URL");

  const secretKeysRaw =
    Deno.env.get("SUPABASE_SECRET_KEYS");

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
// Responses
// ============================================================

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

  url.searchParams.set(
    "gateway",
    "sep",
  );

  if (
    refId &&
    refId.trim().length > 0
  ) {
    url.searchParams.set(
      "ref_id",
      refId.trim(),
    );
  }

  console.log(
    "Redirecting to app:",
    {
      status,
      orderId,
      hasRefId:
        !!refId &&
        refId.trim().length > 0,
      gateway: "sep",
    },
  );

  return new Response(
    null,
    {
      status: 303,
      headers: {
        Location:
          url.toString(),
        "Cache-Control":
          "no-store",
      },
    },
  );
}

function badRequest(
  message: string,
): Response {
  return new Response(
    message,
    {
      status: 400,
      headers: {
        "Content-Type":
          "text/plain; charset=utf-8",
      },
    },
  );
}

function serverError(
  message: string,
): Response {
  return new Response(
    message,
    {
      status: 500,
      headers: {
        "Content-Type":
          "text/plain; charset=utf-8",
      },
    },
  );
}

// ============================================================
// Read SEP Callback
// ============================================================

async function readCallbackData(
  req: Request,
): Promise<SepCallbackData> {
  const url =
    new URL(req.url);

  let params =
    new URLSearchParams();

  // ----------------------------------------------------------
  // GET
  // ----------------------------------------------------------

  if (req.method === "GET") {
    params =
      new URLSearchParams(
        url.searchParams,
      );
  }

  // ----------------------------------------------------------
  // POST
  // ----------------------------------------------------------

  if (req.method === "POST") {
    const contentType =
      (
        req.headers.get(
          "content-type",
        ) ?? ""
      ).toLowerCase();

    // --------------------------------------------------------
    // application/x-www-form-urlencoded
    // --------------------------------------------------------

    if (
      contentType.includes(
        "application/x-www-form-urlencoded",
      )
    ) {
      const body =
        await req.text();

      params =
        new URLSearchParams(
          body,
        );
    }

    // --------------------------------------------------------
    // application/json
    // --------------------------------------------------------

    else if (
      contentType.includes(
        "application/json",
      )
    ) {
      const body =
        await req.json();

      params =
        new URLSearchParams();

      if (
        body &&
        typeof body === "object"
      ) {
        for (
          const [key, value]
          of Object.entries(body)
        ) {
          if (
            value !== null &&
            value !== undefined
          ) {
            params.set(
              key,
              String(value),
            );
          }
        }
      }
    }

    // --------------------------------------------------------
    // Fallback
    // --------------------------------------------------------

    else {
      const body =
        await req.text();

      params =
        new URLSearchParams(
          body,
        );
    }
  }

  // ==========================================================
  // Helper for case-insensitive lookup
  // ==========================================================

  function getParam(
    names: string[],
  ): string | null {
    for (
      const name of names
    ) {
      const direct =
        params.get(name);

      if (
        direct !== null
      ) {
        return direct;
      }
    }

    for (
      const [key, value]
      of params.entries()
    ) {
      const normalizedKey =
        key
          .trim()
          .toLowerCase();

      for (
        const name of names
      ) {
        if (
          normalizedKey ===
          name
            .trim()
            .toLowerCase()
        ) {
          return value;
        }
      }
    }

    return null;
  }

  // ----------------------------------------------------------
  // State
  // ----------------------------------------------------------

  const state =
    normalize(
      getParam([
        "State",
        "state",
      ]),
    );

  // ----------------------------------------------------------
  // Status
  // ----------------------------------------------------------

  const status =
    normalize(
      getParam([
        "Status",
        "status",
      ]),
    );

  // ----------------------------------------------------------
  // RefNum
  // ----------------------------------------------------------

  const refNum =
    normalize(
      getParam([
        "RefNum",
        "refnum",
        "refNum",
      ]),
    ) || null;

  // ----------------------------------------------------------
  // ResNum
  // ----------------------------------------------------------

  const resNum =
    normalize(
      getParam([
        "ResNum",
        "resnum",
        "resNum",
      ]),
    ) || null;

  // ----------------------------------------------------------
  // RRN
  // ----------------------------------------------------------

  const rrn =
    normalize(
      getParam([
        "RRN",
        "Rrn",
        "rrn",
      ]),
    ) || null;

  // ----------------------------------------------------------
  // Terminal ID
  // ----------------------------------------------------------

  const terminalId =
    normalize(
      getParam([
        "TerminalId",
        "TerminalID",
        "terminalnumber",
        "MID",
        "mid",
      ]),
    ) || null;

  // ----------------------------------------------------------
  // Amount
  // ----------------------------------------------------------

  const rawAmount =
    normalize(
      getParam([
        "Amount",
        "amount",
      ]),
    );

  const parsedAmount =
    rawAmount.length > 0
      ? Number(rawAmount)
      : null;

  // ----------------------------------------------------------
  // Token
  // ----------------------------------------------------------

  const token =
    normalize(
      getParam([
        "Token",
        "token",
        "TxnRandomSessionKey",
        "txnrAndomSessionKey",
        "TxnRandomSessionkey",
      ]),
    ) || null;

  // ----------------------------------------------------------
  // Debug
  // ----------------------------------------------------------

  console.log(
    "SEP CALLBACK PARSED DATA:",
    {
      state,
      status,
      refNum,
      resNum,
      rrn,
      terminalId,
      amount:
        parsedAmount,
      token,
    },
  );

  return {
    state,
    status,
    refNum,
    resNum,
    rrn,
    terminalId,
    amount:
      parsedAmount !== null &&
      Number.isFinite(
        parsedAmount,
      )
        ? parsedAmount
        : null,
    token,
  };
}

// ============================================================
// Payment State Helpers
// ============================================================

async function markCanceled({
  supabase,
  paymentId,
  orderId,
  message,
}: {
  supabase: SupabaseClient;
  paymentId: string;
  orderId: string;
  message: string;
}) {
  const {
    error:
      paymentError,
  } =
    await supabase
      .from("payments")
      .update({
        status:
          "canceled",
        gateway_message:
          message,
      })
      .eq(
        "id",
        paymentId,
      );

  if (paymentError) {
    throw new Error(
      `Failed to update payment as canceled: ${paymentError.message}`,
    );
  }

  const {
    error:
      orderError,
  } =
    await supabase
      .from("orders")
      .update({
        payment_status:
          "canceled",
        status:
          "canceled",
      })
      .eq(
        "id",
        orderId,
      );

  if (orderError) {
    throw new Error(
      `Failed to update order as canceled: ${orderError.message}`,
    );
  }
}

async function markFailed({
  supabase,
  paymentId,
  orderId,
  message,
}: {
  supabase: SupabaseClient;
  paymentId: string;
  orderId: string;
  message: string;
}) {
  const {
    error:
      paymentError,
  } =
    await supabase
      .from("payments")
      .update({
        status:
          "failed",
        gateway_message:
          message,
      })
      .eq(
        "id",
        paymentId,
      );

  if (paymentError) {
    throw new Error(
      `Failed to update payment as failed: ${paymentError.message}`,
    );
  }

  const {
    error:
      orderError,
  } =
    await supabase
      .from("orders")
      .update({
        payment_status:
          "failed",
        status:
          "canceled",
      })
      .eq(
        "id",
        orderId,
      );

  if (orderError) {
    throw new Error(
      `Failed to update order as failed: ${orderError.message}`,
    );
  }
}

async function markPaid({
  supabase,
  paymentId,
  orderId,
  refId,
  message,
}: {
  supabase: SupabaseClient;
  paymentId: string;
  orderId: string;
  refId: string;
  message: string;
}) {
  const {
    error:
      paymentError,
  } =
    await supabase
      .from("payments")
      .update({
        status:
          "paid",
        ref_id:
          refId,
        gateway_message:
          message,
        paid_at:
          new Date().toISOString(),
      })
      .eq(
        "id",
        paymentId,
      );

  if (paymentError) {
    throw new Error(
      `Failed to update payment as paid: ${paymentError.message}`,
    );
  }

  const {
    error:
      orderError,
  } =
    await supabase
      .from("orders")
      .update({
        payment_status:
          "paid",
        status:
          "processing",
      })
      .eq(
        "id",
        orderId,
      );

  if (orderError) {
    throw new Error(
      `Failed to update order as processing: ${orderError.message}`,
    );
  }
}

// ============================================================
// SEP REAL VERIFY
// ============================================================

async function verifySepTransaction({
  refNum,
}: {
  refNum: string;
}) {
  const terminalIdRaw =
    getRequiredEnv(
      "SEP_TERMINAL_ID",
    );

  const terminalNumber =
    Number(
      terminalIdRaw,
    );

  if (
    !Number.isSafeInteger(
      terminalNumber,
    ) ||
    terminalNumber <= 0
  ) {
    throw new Error(
      "SEP_TERMINAL_ID is not a valid numeric terminal number.",
    );
  }

  const verifyUrl =
    "https://sep.shaparak.ir/verifyTxnRandomSessionkey/ipg/VerifyTranscation";

  const response =
    await fetch(
      verifyUrl,
      {
        method:
          "POST",
        headers: {
          "Content-Type":
            "application/json",
        },
        body:
          JSON.stringify({
            terminalnumber:
              terminalNumber,
            refnum:
              refNum,
          }),
      },
    );

  let data: any =
    null;

  try {
    data =
      await response.json();
  } catch {
    data = null;
  }

  if (!response.ok) {
    throw new Error(
      `SEP verify HTTP error: ${response.status}`,
    );
  }

  const success =
    data?.Success === true ||
    data?.success === true;

  const resultCodeRaw =
    data?.ResultCode ??
    data?.resultCode ??
    data?.resultcode;

  const resultCode =
    resultCodeRaw !== undefined &&
    resultCodeRaw !== null
      ? Number(
          resultCodeRaw,
        )
      : null;

  const resultDescription =
    data?.ResultDescription ??
    data?.resultDescription ??
    data?.resultdescription ??
    "SEP verification response received.";

  const transactionDetail =
    data?.TransactionDetail ??
    data?.transactionDetail ??
    null;

  const verifiedAmountRaw =
    transactionDetail?.OrginalAmount ??
    transactionDetail?.OriginalAmount ??
    transactionDetail?.originalAmount ??
    transactionDetail?.orginalAmount ??
    null;

  const verifiedAmount =
    verifiedAmountRaw !== null &&
    verifiedAmountRaw !== undefined
      ? Number(
          verifiedAmountRaw,
        )
      : null;

  const verifiedRefNum =
    transactionDetail?.RefNum ??
    transactionDetail?.refNum ??
    refNum;

  const verifiedRrn =
    transactionDetail?.RRN ??
    transactionDetail?.Rrn ??
    transactionDetail?.rrn ??
    null;

  return {
    success,
    resultCode,
    resultDescription:
      String(
        resultDescription,
      ),
    transactionDetail,
    verifiedAmount,
    verifiedRefNum:
      String(
        verifiedRefNum,
      ),
    verifiedRrn:
      verifiedRrn !== null &&
      verifiedRrn !== undefined
        ? String(
            verifiedRrn,
          )
        : null,
  };
}

// ============================================================
// SEP MOCK VERIFY
// ============================================================

async function verifyMockTransaction({
  token,
  refNum,
  paymentAmountInToman,
}: {
  token: string;
  refNum: string;
  paymentAmountInToman: number;
}): Promise<VerifyResult> {
  // ----------------------------------------------------------
  // Validate mock token
  // ----------------------------------------------------------

  if (
    !token
      .trim()
      .startsWith("MOCK-")
  ) {
    return {
      success:
        false,
      resultCode:
        -1,
      resultDescription:
        "Invalid SEP mock token.",
      verifiedAmount:
        null,
      verifiedRefNum:
        refNum,
      verifiedRrn:
        null,
    };
  }

  // ----------------------------------------------------------
  // Expected mock reference number
  // ----------------------------------------------------------

  const expectedRefNum =
    `MOCK-${token}`;

  if (
    refNum !==
    expectedRefNum
  ) {
    console.error(
      "SEP MOCK REFNUM MISMATCH:",
      {
        received:
          refNum,
        expected:
          expectedRefNum,
        token,
      },
    );

    return {
      success:
        false,
      resultCode:
        -2,
      resultDescription:
        "Invalid SEP mock reference number.",
      verifiedAmount:
        null,
      verifiedRefNum:
        refNum,
      verifiedRrn:
        null,
    };
  }

  // ----------------------------------------------------------
  // Validate amount
  // ----------------------------------------------------------

  if (
    !Number.isFinite(
      paymentAmountInToman,
    ) ||
    paymentAmountInToman <= 0 ||
    !Number.isInteger(
      paymentAmountInToman,
    )
  ) {
    return {
      success:
        false,
      resultCode:
        -3,
      resultDescription:
        "Invalid SEP mock payment amount.",
      verifiedAmount:
        null,
      verifiedRefNum:
        refNum,
      verifiedRrn:
        null,
    };
  }

  // ----------------------------------------------------------
  // Successful Mock Verification
  // ----------------------------------------------------------

  return {
    success:
      true,
    resultCode:
      0,
    resultDescription:
      "SEP mock transaction verified successfully.",
    verifiedAmount:
      paymentAmountInToman *
      TOMAN_TO_RIAL,
    verifiedRefNum:
      refNum,
    verifiedRrn:
      `MOCK-RRN-${token}`,
  };
}

// ============================================================
// Main
// ============================================================

Deno.serve(
  async (
    req: Request,
  ) => {
    try {
      // --------------------------------------------------------
      // Method
      // --------------------------------------------------------

      if (
        req.method !==
          "POST" &&
        req.method !==
          "GET"
      ) {
        return new Response(
          "Method Not Allowed",
          {
            status:
              405,
            headers: {
              Allow:
                "POST, GET",
            },
          },
        );
      }

      // --------------------------------------------------------
      // Read callback
      // --------------------------------------------------------

      const callback =
        await readCallbackData(
          req,
        );

      console.log(
        "SEP CALLBACK RECEIVED:",
        {
          state:
            callback.state,
          status:
            callback.status,
          refNum:
            callback.refNum,
          resNum:
            callback.resNum,
          rrn:
            callback.rrn,
          terminalId:
            callback.terminalId,
          amount:
            callback.amount,
          token:
            callback.token,
        },
      );

      // --------------------------------------------------------
      // Order ID
      // --------------------------------------------------------

      if (
        !callback.resNum
      ) {
        return badRequest(
          "SEP ResNum is missing.",
        );
      }

      const orderId =
        callback.resNum;

      // --------------------------------------------------------
      // Supabase
      // --------------------------------------------------------

      const supabase =
        getAdminClient();

      // --------------------------------------------------------
      // Find payment
      // --------------------------------------------------------

      const {
        data:
          payment,
        error:
          paymentLookupError,
      } =
        await supabase
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
            ref_id,
            created_at
            `,
          )
          .eq(
            "order_id",
            orderId,
          )
          .eq(
            "gateway",
            "sep",
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
        paymentLookupError
      ) {
        console.error(
          "Payment lookup error:",
          paymentLookupError.message,
        );

        return serverError(
          "Failed to find SEP payment.",
        );
      }

      if (!payment) {
        console.error(
          "SEP payment not found:",
          {
            orderId,
          },
        );

        return badRequest(
          "SEP payment not found.",
        );
      }

      const paymentId =
        payment.id;

      // --------------------------------------------------------
      // Idempotency: already paid
      // --------------------------------------------------------

      if (
        payment.status ===
        "paid"
      ) {
        return redirectToApp({
          status:
            "success",
          orderId,
          refId:
            payment.ref_id ??
            callback.refNum,
        });
      }

      // --------------------------------------------------------
      // Determine callback result
      // --------------------------------------------------------

      const successfulCallback =
        isSuccessState(
          callback.state,
          callback.status,
        );

      console.log(
        "SEP CALLBACK RESULT:",
        {
          successfulCallback,
          state:
            callback.state,
          status:
            callback.status,
        },
      );

      // --------------------------------------------------------
      // User canceled / callback failed
      // --------------------------------------------------------

      if (
        !successfulCallback
      ) {
        const stateText =
          callback.state ||
          "UNKNOWN";

        const statusText =
          callback.status ||
          "UNKNOWN";

        await markCanceled({
          supabase,
          paymentId,
          orderId,
          message:
            `SEP callback state: ${stateText}, status: ${statusText}`,
        });

        return redirectToApp({
          status:
            "canceled",
          orderId,
          refId:
            callback.refNum,
        });
      }

      // --------------------------------------------------------
      // Successful callback must have RefNum
      // --------------------------------------------------------

      if (
        !callback.refNum
      ) {
        await markFailed({
          supabase,
          paymentId,
          orderId,
          message:
            "SEP successful callback did not contain RefNum.",
        });

        return redirectToApp({
          status:
            "failed",
          orderId,
        });
      }

      // --------------------------------------------------------
      // Payment amount from database
      // --------------------------------------------------------

      const expectedAmountInToman =
        Number(
          payment.amount,
        );

      if (
        !Number.isFinite(
          expectedAmountInToman,
        ) ||
        expectedAmountInToman <= 0 ||
        !Number.isInteger(
          expectedAmountInToman,
        )
      ) {
        await markFailed({
          supabase,
          paymentId,
          orderId,
          message:
            "Invalid payment amount stored in database.",
        });

        return redirectToApp({
          status:
            "failed",
          orderId,
          refId:
            callback.refNum,
        });
      }

      const expectedAmountInRial =
        expectedAmountInToman *
        TOMAN_TO_RIAL;

      // ========================================================
      // VERIFY
      // ========================================================

      let verify:
        VerifyResult;

      const mockEnabled =
        (
          Deno.env.get(
            "SEP_MOCK",
          ) ?? ""
        )
          .trim()
          .toLowerCase() ===
        "true";

      console.log(
        "SEP MOCK STATUS:",
        mockEnabled,
      );

      // --------------------------------------------------------
      // MOCK VERIFY
      // --------------------------------------------------------

      if (
        mockEnabled
      ) {
        console.log(
          "SEP Mock verification mode enabled.",
        );

        // ------------------------------------------------------
        // Token required
        // ------------------------------------------------------

        if (
          !callback.token
        ) {
          await markFailed({
            supabase,
            paymentId,
            orderId,
            message:
              "SEP mock token is missing.",
          });

          return redirectToApp({
            status:
              "failed",
            orderId,
            refId:
              callback.refNum,
          });
        }

        // ------------------------------------------------------
        // Validate token
        // ------------------------------------------------------

        if (
          !payment.authority ||
          payment.authority !==
            callback.token
        ) {
          console.error(
            "SEP MOCK TOKEN MISMATCH:",
            {
              databaseToken:
                payment.authority,
              callbackToken:
                callback.token,
            },
          );

          await markFailed({
            supabase,
            paymentId,
            orderId,
            message:
              "SEP mock token mismatch.",
          });

          return redirectToApp({
            status:
              "failed",
            orderId,
            refId:
              callback.refNum,
          });
        }

        // ------------------------------------------------------
        // Verify mock transaction
        // ------------------------------------------------------

        verify =
          await verifyMockTransaction({
            token:
              callback.token,
            refNum:
              callback.refNum,
            paymentAmountInToman:
              expectedAmountInToman,
          });
      }

      // --------------------------------------------------------
      // REAL SEP VERIFY
      // --------------------------------------------------------

      else {
        console.log(
          "SEP real verification mode.",
        );

        verify =
          await verifySepTransaction({
            refNum:
              callback.refNum,
          });
      }

      // --------------------------------------------------------
      // Log verify
      // --------------------------------------------------------

      console.log(
        "SEP VERIFY RESULT:",
        {
          success:
            verify.success,
          resultCode:
            verify.resultCode,
          resultDescription:
            verify.resultDescription,
          verifiedAmount:
            verify.verifiedAmount,
          verifiedRefNum:
            verify.verifiedRefNum,
          verifiedRrn:
            verify.verifiedRrn,
        },
      );

      // --------------------------------------------------------
      // Verify failed
      // --------------------------------------------------------

      if (
        !verify.success
      ) {
        await markFailed({
          supabase,
          paymentId,
          orderId,
          message:
            `SEP verification failed. Code: ${verify.resultCode ?? "UNKNOWN"}. ${verify.resultDescription}`,
        });

        return redirectToApp({
          status:
            "failed",
          orderId,
          refId:
            callback.refNum,
        });
      }

      // --------------------------------------------------------
      // Validate verified amount
      // --------------------------------------------------------

      if (
        verify.verifiedAmount ===
          null ||
        !Number.isFinite(
          verify.verifiedAmount,
        )
      ) {
        await markFailed({
          supabase,
          paymentId,
          orderId,
          message:
            "SEP verification did not return a valid transaction amount.",
        });

        return redirectToApp({
          status:
            "failed",
          orderId,
          refId:
            callback.refNum,
        });
      }

      // --------------------------------------------------------
      // Amount mismatch
      // --------------------------------------------------------

      if (
        verify.verifiedAmount !==
        expectedAmountInRial
      ) {
        console.error(
          "SEP AMOUNT MISMATCH:",
          {
            expectedAmountInRial,
            verifiedAmount:
              verify.verifiedAmount,
          },
        );

        await markFailed({
          supabase,
          paymentId,
          orderId,
          message:
            `SEP amount mismatch. Expected: ${expectedAmountInRial} IRR, received: ${verify.verifiedAmount} IRR.`,
        });

        return redirectToApp({
          status:
            "failed",
          orderId,
          refId:
            callback.refNum,
        });
      }

      // --------------------------------------------------------
      // Final Reference
      // --------------------------------------------------------

      const finalRefId =
        verify.verifiedRefNum ||
        callback.refNum;

      // --------------------------------------------------------
      // Success Message
      // --------------------------------------------------------

      const successMessage =
        [
          verify.resultDescription,
          verify.verifiedRrn
            ? `RRN: ${verify.verifiedRrn}`
            : null,
        ]
          .filter(
            (
              value,
            ): value is string =>
              value !==
              null,
          )
          .join(
            " | ",
          );

      // --------------------------------------------------------
      // Mark Paid
      // --------------------------------------------------------

      await markPaid({
        supabase,
        paymentId,
        orderId,
        refId:
          finalRefId,
        message:
          successMessage ||
          "SEP payment verified successfully.",
      });

      console.log(
        "SEP PAYMENT SUCCESSFULLY VERIFIED:",
        {
          paymentId,
          orderId,
          refId:
            finalRefId,
          rrn:
            verify.verifiedRrn,
          mock:
            mockEnabled,
        },
      );

      // --------------------------------------------------------
      // Redirect App
      // --------------------------------------------------------

      return redirectToApp({
        status:
          "success",
        orderId,
        refId:
          finalRefId,
      });
    } catch (error) {
      console.error(
        "SEP callback unexpected error:",
        error,
      );

      return serverError(
        error instanceof Error
          ? error.message
          : "Unexpected SEP callback error.",
      );
    }
  },
);