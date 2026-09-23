import { withSupabase } from "npm:@supabase/server";
import { createClient } from "npm:@supabase/supabase-js@2";

const TOMAN_TO_RIAL = 10;

const SEP_MOCK_PAYMENT_URL =
  "https://6aa999a6783a0e0595618afa--stupendous-cactus-df456a.netlify.app";

type PaymentGateway = "zarinpal" | "sep";

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
          "application/json; charset=utf-8",
        "Cache-Control":
          "no-store",
      },
    },
  );
}

function isValidUuid(
  value: unknown,
): value is string {
  if (typeof value !== "string") {
    return false;
  }

  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
    value,
  );
}

function isSafeNonNegativeInteger(
  value: unknown,
): value is number {
  return (
    typeof value === "number" &&
    Number.isSafeInteger(value) &&
    value >= 0
  );
}

// ============================================================
// Supabase Admin
// ============================================================

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
    | string
    | undefined;

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
        autoRefreshToken: false,
        persistSession: false,
      },
    },
  );
}

// ============================================================
// ZarinPal Config
// ============================================================

function getZarinPalConfig() {
  const merchantId =
    Deno.env.get(
      "ZARINPAL_MERCHANT_ID",
    );

  const callbackUrl =
    Deno.env.get(
      "ZARINPAL_CALLBACK_URL",
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

  if (!callbackUrl) {
    throw new Error(
      "Missing ZARINPAL_CALLBACK_URL",
    );
  }

  const baseUrl = sandbox
    ? "https://sandbox.zarinpal.com"
    : "https://payment.zarinpal.com";

  return {
    merchantId,
    callbackUrl,
    sandbox,
    requestUrl:
      `${baseUrl}/pg/v4/payment/request.json`,
    startPayUrl:
      `${baseUrl}/pg/StartPay`,
  };
}

// ============================================================
// SEP Config
// ============================================================

function getSepConfig() {
  const terminalId =
    Deno.env.get(
      "SEP_TERMINAL_ID",
    );

  const callbackUrl =
    Deno.env.get(
      "SEP_CALLBACK_URL",
    );

  const mock =
    Deno.env.get(
      "SEP_MOCK",
    )?.toLowerCase() ===
    "true";

  if (!mock && !terminalId) {
    throw new Error(
      "Missing SEP_TERMINAL_ID",
    );
  }

  if (!callbackUrl) {
    throw new Error(
      "Missing SEP_CALLBACK_URL",
    );
  }

  return {
    terminalId:
      terminalId ?? null,
    callbackUrl,
    mock,
  };
}

// ============================================================
// SEP Payment
// ============================================================

async function createSepPayment({
  orderId,
  amountInToman,
  userPhone,
}: {
  orderId: string;
  amountInToman: number;
  userPhone: string | null;
}) {
  const config =
    getSepConfig();

  // ==========================================================
  // SEP MOCK
  // ==========================================================

  if (config.mock) {
    const token =
      `MOCK-${crypto.randomUUID()}`;

    const paymentUrl =
      `${SEP_MOCK_PAYMENT_URL}/?` +
      `token=${encodeURIComponent(token)}` +
      `&order_id=${encodeURIComponent(orderId)}` +
      `&amount=${encodeURIComponent(String(amountInToman))}`;

    console.log(
      "SEP MOCK PAYMENT URL:",
      paymentUrl,
    );

    return {
      token,
      paymentUrl,
      mock: true,
    };
  }

  // ==========================================================
  // REAL SEP
  // ==========================================================

  const amountInRial =
    amountInToman *
    TOMAN_TO_RIAL;

  if (
    !Number.isSafeInteger(
      amountInRial,
    ) ||
    amountInRial <= 0
  ) {
    throw new Error(
      "Invalid SEP payment amount.",
    );
  }

  const tokenUrl =
    "https://sep.shaparak.ir/OnlinePG/OnlinePG";

  const response =
    await fetch(
      tokenUrl,
      {
        method: "POST",
        headers: {
          "Content-Type":
            "application/json",
          Accept:
            "application/json",
        },
        body:
          JSON.stringify({
            Action:
              "Token",
            TerminalId:
              config.terminalId,
            RedirectUrl:
              config.callbackUrl,
            ResNum:
              orderId,
            Amount:
              amountInRial,
            CellNumber:
              userPhone ??
              undefined,
          }),
      },
    );

  let data: any = null;

  try {
    data =
      await response.json();
  } catch {
    data = null;
  }

  if (!response.ok) {
    console.error(
      "SEP token HTTP error:",
      {
        status:
          response.status,
        statusText:
          response.statusText,
      },
    );

    throw new Error(
      `SEP token HTTP error: ${response.status}`,
    );
  }

  const status =
    Number(
      data?.status ??
        data?.Status ??
        data?.success,
    );

  const token =
    data?.token ??
    data?.Token;

  if (
    status !== 1 ||
    typeof token !==
      "string" ||
    token.trim()
      .length === 0
  ) {
    console.error(
      "SEP token rejected:",
      {
        status,
        errorCode:
          data?.errorCode ??
          data?.ErrorCode ??
          null,
        errorDescription:
          data?.errorDesc ??
          data?.ErrorDesc ??
          data?.message ??
          null,
      },
    );

    throw new Error(
      `SEP token request failed. Code: ${
        data?.errorCode ??
        data?.ErrorCode ??
        "UNKNOWN"
      }`,
    );
  }

  const supabaseUrl =
    Deno.env.get(
      "SUPABASE_URL",
    );

  if (!supabaseUrl) {
    throw new Error(
      "Missing SUPABASE_URL",
    );
  }

  const paymentUrl =
    `${supabaseUrl}/functions/v1/sep-redirect` +
    `?token=${encodeURIComponent(
      token.trim(),
    )}`;

  return {
    token:
      token.trim(),
    paymentUrl,
    mock: false,
  };
}

// ============================================================
// Main
// ============================================================

Deno.serve(
  withSupabase(
    { auth: "user" },
    async (
      req: Request,
      ctx,
    ) => {
      try {
        // ======================================================
        // METHOD
        // ======================================================

        if (req.method !== "POST") {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Method not allowed",
            },
            405,
          );
        }

        // ======================================================
        // AUTHENTICATION
        // ======================================================

        const {
          data: {
            user,
          },
          error:
            userError,
        } =
          await ctx.supabase.auth.getUser();

        if (userError) {
          console.error(
            "Auth getUser error:",
            userError.message,
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "Unauthorized",
            },
            401,
          );
        }

        if (!user) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Unauthorized",
            },
            401,
          );
        }

        const userId =
          user.id;

        // ======================================================
        // REQUEST BODY
        // ======================================================

        let body: {
          address_id?: unknown;
          shipping_method_id?: unknown;
          payment_method?: unknown;
          gateway?: unknown;
        };

        try {
          body =
            await req.json();
        } catch {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Invalid JSON body",
            },
            400,
          );
        }

        const addressId =
          body.address_id;

        const shippingMethodId =
          body.shipping_method_id;

        const paymentMethod =
          body.payment_method;

        const gatewayRaw =
          body.gateway;

        console.log(
          "CREATE CHECKOUT RECEIVED GATEWAY:",
          gatewayRaw,
        );

        // ======================================================
        // VALIDATION
        // ======================================================

        if (
          !isValidUuid(
            addressId,
          )
        ) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Invalid address_id",
            },
            400,
          );
        }

        if (
          !isValidUuid(
            shippingMethodId,
          )
        ) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Invalid shipping_method_id",
            },
            400,
          );
        }

        if (
          paymentMethod !==
          "online"
        ) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Only online payment is supported",
            },
            400,
          );
        }

        if (
          gatewayRaw !==
            "zarinpal" &&
          gatewayRaw !==
            "sep"
        ) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "درگاه پرداخت انتخاب‌شده پشتیبانی نمی‌شود.",
            },
            400,
          );
        }

        const gateway =
          gatewayRaw as PaymentGateway;

        // ======================================================
        // ADMIN CLIENT
        // ======================================================

        const supabaseAdmin =
          getSupabaseAdmin();

        // ======================================================
        // GENERAL SETTINGS
        // ======================================================

        const {
          data:
            generalSettings,
          error:
            generalSettingsError,
        } =
          await supabaseAdmin
            .from(
              "general_settings",
            )
            .select(
              `
              shopping_enabled,
              minimum_order_amount
              `,
            )
            .eq(
              "singleton",
              true,
            )
            .maybeSingle();

        if (
          generalSettingsError
        ) {
          console.error(
            "General settings query error:",
            generalSettingsError.message,
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "Failed to load general settings",
            },
            500,
          );
        }

        if (
          !generalSettings
        ) {
          console.error(
            "General settings not found.",
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "General settings are not configured",
            },
            500,
          );
        }

        // ======================================================
        // SHOPPING ENABLED
        // ======================================================

        if (
          generalSettings
            .shopping_enabled !==
          true
        ) {
          console.warn(
            "Checkout blocked because shopping is disabled:",
            {
              userId,
            },
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "ثبت سفارش در حال حاضر غیرفعال است.",
            },
            400,
          );
        }

        // ======================================================
        // MINIMUM ORDER AMOUNT SETTING
        // ======================================================

        const minimumOrderAmount =
          generalSettings
            .minimum_order_amount;

        if (
          !isSafeNonNegativeInteger(
            minimumOrderAmount,
          )
        ) {
          console.error(
            "Invalid minimum order amount setting:",
            minimumOrderAmount,
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "Invalid minimum order amount configuration",
            },
            500,
          );
        }

        // ======================================================
        // PAYMENT SETTINGS
        // ======================================================

        const {
          data:
            paymentSettings,
          error:
            paymentSettingsError,
        } =
          await supabaseAdmin
            .from(
              "payment_settings",
            )
            .select(
              `
              online_payment_enabled,
              zarinpal_enabled,
              sep_enabled,
              default_gateway
              `,
            )
            .eq(
              "singleton",
              true,
            )
            .maybeSingle();

        if (
          paymentSettingsError
        ) {
          console.error(
            "Payment settings query error:",
            paymentSettingsError.message,
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "Failed to load payment settings",
            },
            500,
          );
        }

        if (
          !paymentSettings
        ) {
          console.error(
            "Payment settings not found.",
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "Payment settings are not configured",
            },
            500,
          );
        }

        // ======================================================
        // ONLINE PAYMENT ENABLED
        // ======================================================

        if (
          paymentSettings
            .online_payment_enabled !==
          true
        ) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "پرداخت آنلاین در حال حاضر غیرفعال است.",
            },
            400,
          );
        }

        // ======================================================
        // SELECTED GATEWAY ENABLED
        // ======================================================

        if (
          gateway ===
            "zarinpal" &&
          paymentSettings
            .zarinpal_enabled !==
            true
        ) {
          console.warn(
            "Blocked disabled payment gateway:",
            {
              userId,
              gateway,
            },
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "درگاه زرین‌پال در حال حاضر غیرفعال است.",
            },
            400,
          );
        }

        if (
          gateway ===
            "sep" &&
          paymentSettings
            .sep_enabled !==
            true
        ) {
          console.warn(
            "Blocked disabled payment gateway:",
            {
              userId,
              gateway,
            },
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "درگاه سامان در حال حاضر غیرفعال است.",
            },
            400,
          );
        }

        // ======================================================
        // GET CART
        // ======================================================

        const {
          data:
            cartItems,
          error:
            cartError,
        } =
          await supabaseAdmin
            .from(
              "cart_items",
            )
            .select(
              `
              id,
              user_id,
              product_id,
              quantity,
              products (
                id,
                title,
                price,
                discount_price,
                thumbnail,
                is_available
              )
              `,
            )
            .eq(
              "user_id",
              userId,
            );

        if (cartError) {
          console.error(
            "Cart query error:",
            cartError.message,
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "Failed to load cart",
            },
            500,
          );
        }

        if (
          !cartItems ||
          cartItems.length === 0
        ) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Cart is empty",
            },
            400,
          );
        }

        // ======================================================
        // CALCULATE ORDER
        // ======================================================

        let subtotal = 0;
        let discount = 0;

        const orderItems:
          Array<{
            product_id:
              string;
            product_title:
              string;
            product_thumbnail:
              string | null;
            quantity:
              number;
            unit_price:
              number;
            discount_price:
              number;
            total_price:
              number;
          }> = [];

        for (
          const item of cartItems
        ) {
          const quantity =
            item.quantity;

          if (
            !Number.isSafeInteger(
              quantity,
            ) ||
            quantity <= 0
          ) {
            return jsonResponse(
              {
                success:
                  false,
                error:
                  "Invalid cart quantity",
              },
              400,
            );
          }

          const product =
            Array.isArray(
              item.products,
            )
              ? item.products[0]
              : item.products;

          if (!product) {
            return jsonResponse(
              {
                success:
                  false,
                error:
                  "One or more products no longer exist",
              },
              400,
            );
          }

          if (
            product.is_available ===
            false
          ) {
            return jsonResponse(
              {
                success:
                  false,
                error:
                  `Product "${product.title}" is no longer available`,
              },
              400,
            );
          }

          const price =
            product.price;

          const discountPrice =
            product.discount_price ??
            product.price;

          if (
            !isSafeNonNegativeInteger(
              price,
            ) ||
            !isSafeNonNegativeInteger(
              discountPrice,
            )
          ) {
            return jsonResponse(
              {
                success:
                  false,
                error:
                  "Invalid product price",
              },
              500,
            );
          }

          if (
            discountPrice >
            price
          ) {
            return jsonResponse(
              {
                success:
                  false,
                error:
                  "Invalid product discount",
              },
              500,
            );
          }

          const itemSubtotal =
            price *
            quantity;

          const itemDiscount =
            (price -
              discountPrice) *
            quantity;

          const itemTotal =
            discountPrice *
            quantity;

          if (
            !Number.isSafeInteger(
              itemSubtotal,
            ) ||
            !Number.isSafeInteger(
              itemDiscount,
            ) ||
            !Number.isSafeInteger(
              itemTotal,
            )
          ) {
            return jsonResponse(
              {
                success:
                  false,
                error:
                  "Order amount is too large",
              },
              400,
            );
          }

          subtotal +=
            itemSubtotal;

          discount +=
            itemDiscount;

          if (
            !Number.isSafeInteger(
              subtotal,
            ) ||
            !Number.isSafeInteger(
              discount,
            )
          ) {
            return jsonResponse(
              {
                success:
                  false,
                error:
                  "Order amount is too large",
              },
              400,
            );
          }

          orderItems.push({
            product_id:
              product.id,
            product_title:
              product.title,
            product_thumbnail:
              product.thumbnail ??
              null,
            quantity,
            unit_price:
              price,
            discount_price:
              discountPrice,
            total_price:
              itemTotal,
          });
        }

        // ======================================================
        // GET ADDRESS
        // ======================================================

        const {
          data:
            address,
          error:
            addressError,
        } =
          await supabaseAdmin
            .from(
              "addresses",
            )
            .select(
              `
              id,
              user_id,
              title,
              receiver_name,
              phone,
              province,
              city,
              address,
              postal_code
              `,
            )
            .eq(
              "id",
              addressId,
            )
            .eq(
              "user_id",
              userId,
            )
            .maybeSingle();

        if (addressError) {
          console.error(
            "Address query error:",
            addressError.message,
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "Failed to load address",
            },
            500,
          );
        }

        if (!address) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Address not found",
            },
            404,
          );
        }

        // ======================================================
        // GET SHIPPING METHOD
        // ======================================================

        const {
          data:
            shippingMethod,
          error:
            shippingError,
        } =
          await supabaseAdmin
            .from(
              "shipping_methods",
            )
            .select(
              `
              id,
              title,
              cost,
              is_active
              `,
            )
            .eq(
              "id",
              shippingMethodId,
            )
            .eq(
              "is_active",
              true,
            )
            .maybeSingle();

        if (shippingError) {
          console.error(
            "Shipping method query error:",
            shippingError.message,
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "Failed to load shipping method",
            },
            500,
          );
        }

        if (!shippingMethod) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Shipping method not found",
            },
            404,
          );
        }

        const shippingCost =
          shippingMethod.cost;

        if (
          !isSafeNonNegativeInteger(
            shippingCost,
          )
        ) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Invalid shipping cost",
            },
            500,
          );
        }

        // ======================================================
        // PAYABLE PRODUCT AMOUNT
        // ======================================================

        // Minimum order amount is calculated
        // after product discounts and before shipping.

        const payableProductAmount =
          subtotal -
          discount;

        if (
          !Number.isSafeInteger(
            payableProductAmount,
          ) ||
          payableProductAmount <= 0
        ) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Invalid product order amount",
            },
            400,
          );
        }

        // ======================================================
        // MINIMUM ORDER AMOUNT CHECK
        // ======================================================

        if (
          minimumOrderAmount > 0 &&
          payableProductAmount <
            minimumOrderAmount
        ) {
          console.warn(
            "Checkout blocked because order amount is below minimum:",
            {
              userId,
              payableProductAmount,
              minimumOrderAmount,
            },
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                `حداقل مبلغ سفارش ${minimumOrderAmount} تومان است.`,
              minimum_order_amount:
                minimumOrderAmount,
              current_order_amount:
                payableProductAmount,
            },
            400,
          );
        }

        // ======================================================
        // FINAL TOTAL
        // ======================================================

        const totalPrice =
          payableProductAmount +
          shippingCost;

        if (
          !Number.isSafeInteger(
            totalPrice,
          ) ||
          totalPrice <= 0
        ) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Invalid order amount",
            },
            400,
          );
        }

        const amountInToman =
          totalPrice;

        const amountInRial =
          amountInToman *
          TOMAN_TO_RIAL;

        if (
          !Number.isSafeInteger(
            amountInRial,
          ) ||
          amountInRial <= 0
        ) {
          return jsonResponse(
            {
              success:
                false,
              error:
                "Order amount is too large",
            },
            400,
          );
        }

        // ======================================================
        // CREATE ORDER
        // ======================================================

        const shippingAddress = {
          id:
            address.id,
          title:
            address.title,
          receiver_name:
            address.receiver_name,
          phone:
            address.phone,
          province:
            address.province,
          city:
            address.city,
          address:
            address.address,
          postal_code:
            address.postal_code,
        };

        const {
          data:
            order,
          error:
            orderError,
        } =
          await supabaseAdmin
            .from(
              "orders",
            )
            .insert({
              user_id:
                userId,
              address_id:
                address.id,
              subtotal,
              discount,
              shipping_cost:
                shippingCost,
              total_price:
                amountInToman,
              shipping_address:
                shippingAddress,
              payment_method:
                "online",
              payment_status:
                "pending",
              status:
                "pending",
            })
            .select(
              "id",
            )
            .single();

        if (
          orderError ||
          !order
        ) {
          console.error(
            "Order creation error:",
            orderError?.message,
          );

          return jsonResponse(
            {
              success:
                false,
              error:
                "Failed to create order",
            },
            500,
          );
        }

        // ======================================================
        // CREATE ORDER ITEMS
        // ======================================================

        const orderItemsForInsert =
          orderItems.map(
            (
              item,
            ) => ({
              order_id:
                order.id,
              product_id:
                item.product_id,
              product_title:
                item.product_title,
              product_thumbnail:
                item.product_thumbnail,
              quantity:
                item.quantity,
              unit_price:
                item.unit_price,
              discount_price:
                item.discount_price,
              total_price:
                item.total_price,
            }),
          );

        const {
          error:
            orderItemsError,
        } =
          await supabaseAdmin
            .from(
              "order_items",
            )
            .insert(
              orderItemsForInsert,
            );

        if (
          orderItemsError
        ) {
          console.error(
            "Order items error:",
            orderItemsError.message,
          );

          await supabaseAdmin
            .from(
              "orders",
            )
            .delete()
            .eq(
              "id",
              order.id,
            );

          return jsonResponse(
            {
              success:
                false,
              error:
                "Failed to create order items",
            },
            500,
          );
        }

        // ======================================================
        // CREATE PAYMENT
        // ======================================================

        const {
          data:
            payment,
          error:
            paymentError,
        } =
          await supabaseAdmin
            .from(
              "payments",
            )
            .insert({
              order_id:
                order.id,
              user_id:
                userId,
              amount:
                amountInToman,
              gateway:
                gateway,
              status:
                "pending",
            })
            .select(
              `
              id,
              order_id,
              amount,
              gateway,
              status
              `,
            )
            .single();

        if (
          paymentError ||
          !payment
        ) {
          console.error(
            "Payment creation error:",
            paymentError?.message,
          );

          await supabaseAdmin
            .from(
              "order_items",
            )
            .delete()
            .eq(
              "order_id",
              order.id,
            );

          await supabaseAdmin
            .from(
              "orders",
            )
            .delete()
            .eq(
              "id",
              order.id,
            );

          return jsonResponse(
            {
              success:
                false,
              error:
                "Failed to create payment",
            },
            500,
          );
        }

        // ======================================================
        // ZARINPAL
        // ======================================================

        if (
          gateway ===
          "zarinpal"
        ) {
          const {
            merchantId,
            callbackUrl,
            sandbox,
            requestUrl,
            startPayUrl,
          } =
            getZarinPalConfig();

          console.log(
            "ZarinPal environment:",
            sandbox
              ? "SANDBOX"
              : "PRODUCTION",
          );

          const zarinPalPayload = {
            merchant_id:
              merchantId,
            amount:
              amountInRial,
            currency:
              "IRR",
            description:
              `پرداخت سفارش ${order.id}`,
            callback_url:
              callbackUrl,
            metadata: {
              order_id:
                order.id,
              payment_id:
                payment.id,
              mobile:
                address.phone,
            },
          };

          const zarinPalResponse =
            await fetch(
              requestUrl,
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
                    zarinPalPayload,
                  ),
              },
            );

          let zarinPalResult:
            any = null;

          try {
            zarinPalResult =
              await zarinPalResponse.json();
          } catch {
            zarinPalResult =
              null;
          }

          if (
            !zarinPalResponse.ok ||
            !zarinPalResult
          ) {
            console.error(
              "ZarinPal HTTP error:",
              {
                status:
                  zarinPalResponse.status,
                statusText:
                  zarinPalResponse.statusText,
              },
            );

            await supabaseAdmin
              .from(
                "payments",
              )
              .update({
                status:
                  "failed",
                gateway_message:
                  JSON.stringify({
                    http_status:
                      zarinPalResponse.status,
                    status_text:
                      zarinPalResponse.statusText,
                    response:
                      zarinPalResult,
                  }),
              })
              .eq(
                "id",
                payment.id,
              );

            await supabaseAdmin
              .from(
                "orders",
              )
              .update({
                payment_status:
                  "failed",
                status:
                  "canceled",
              })
              .eq(
                "id",
                order.id,
              );

            return jsonResponse(
              {
                success:
                  false,
                error:
                  "Payment gateway request failed",
              },
              502,
            );
          }

          const gatewayCode =
            Number(
              zarinPalResult
                ?.data
                ?.code,
            );

          const authority =
            zarinPalResult
              ?.data
              ?.authority;

          if (
            gatewayCode !==
              100 ||
            typeof authority !==
              "string" ||
            authority.trim()
              .length === 0
          ) {
            console.error(
              "ZarinPal rejected payment request:",
              {
                code:
                  gatewayCode,
                errors:
                  zarinPalResult
                    ?.errors ??
                  null,
              },
            );

            await supabaseAdmin
              .from(
                "payments",
              )
              .update({
                status:
                  "failed",
                gateway_message:
                  JSON.stringify({
                    code:
                      gatewayCode ??
                      null,
                    errors:
                      zarinPalResult
                        ?.errors ??
                      null,
                  }),
              })
              .eq(
                "id",
                payment.id,
              );

            await supabaseAdmin
              .from(
                "orders",
              )
              .update({
                payment_status:
                  "failed",
                status:
                  "canceled",
              })
              .eq(
                "id",
                order.id,
              );

            return jsonResponse(
              {
                success:
                  false,
                error:
                  "ZarinPal rejected payment request",
                gateway_code:
                  gatewayCode ??
                  null,
              },
              400,
            );
          }

          const {
            error:
              authorityError,
          } =
            await supabaseAdmin
              .from(
                "payments",
              )
              .update({
                authority:
                  authority.trim(),
              })
              .eq(
                "id",
                payment.id,
              );

          if (
            authorityError
          ) {
            console.error(
              "Authority update error:",
              authorityError.message,
            );

            await supabaseAdmin
              .from(
                "payments",
              )
              .update({
                status:
                  "failed",
                gateway_message:
                  "Failed to save ZarinPal authority",
              })
              .eq(
                "id",
                payment.id,
              );

            await supabaseAdmin
              .from(
                "orders",
              )
              .update({
                payment_status:
                  "failed",
                status:
                  "canceled",
              })
              .eq(
                "id",
                order.id,
              );

            return jsonResponse(
              {
                success:
                  false,
                error:
                  "Failed to save payment authority",
              },
              500,
            );
          }

          const paymentUrl =
            `${startPayUrl}/${authority.trim()}`;

          return jsonResponse({
            success:
              true,
            order_id:
              order.id,
            payment_id:
              payment.id,
            amount:
              amountInToman,
            currency:
              "TOMAN",
            gateway:
              "zarinpal",
            gateway_reference:
              authority.trim(),
            authority:
              authority.trim(),
            payment_url:
              paymentUrl,
            sandbox,
          });
        }

        // ======================================================
        // SEP
        // ======================================================

        if (
          gateway ===
          "sep"
        ) {
          const sepResult =
            await createSepPayment({
              orderId:
                order.id,
              amountInToman:
                amountInToman,
              userPhone:
                address.phone ??
                null,
            });

          const {
            error:
              tokenError,
          } =
            await supabaseAdmin
              .from(
                "payments",
              )
              .update({
                authority:
                  sepResult.token,
              })
              .eq(
                "id",
                payment.id,
              );

          if (
            tokenError
          ) {
            console.error(
              "SEP token save error:",
              tokenError.message,
            );

            await supabaseAdmin
              .from(
                "payments",
              )
              .update({
                status:
                  "failed",
                gateway_message:
                  "Failed to save SEP token",
              })
              .eq(
                "id",
                payment.id,
              );

            await supabaseAdmin
              .from(
                "orders",
              )
              .update({
                payment_status:
                  "failed",
                status:
                  "canceled",
              })
              .eq(
                "id",
                order.id,
              );

            return jsonResponse(
              {
                success:
                  false,
                error:
                  "Failed to save SEP payment token",
              },
              500,
            );
          }

          return jsonResponse({
            success:
              true,
            order_id:
              order.id,
            payment_id:
              payment.id,
            amount:
              amountInToman,
            currency:
              "TOMAN",
            gateway:
              "sep",
            gateway_reference:
              sepResult.token,
            authority:
              sepResult.token,
            payment_url:
              sepResult.paymentUrl,
            sandbox:
              sepResult.mock,
          });
        }

        // ======================================================
        // UNKNOWN
        // ======================================================

        return jsonResponse(
          {
            success:
              false,
            error:
              "Unsupported payment gateway",
          },
          400,
        );
      } catch (error) {
        console.error(
          "create-checkout error:",
          error,
        );

        return jsonResponse(
          {
            success:
              false,
            error:
              error instanceof Error
                ? error.message
                : "Internal server error",
          },
          500,
        );
      }
    },
  ),
);