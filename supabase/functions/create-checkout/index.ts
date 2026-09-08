import { withSupabase } from "npm:@supabase/server";
import { createClient } from "npm:@supabase/supabase-js@2";

const TOMAN_TO_RIAL = 10;

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
    },
  });
}

function isValidUuid(value: unknown): value is string {
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

function getSupabaseAdmin() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");

  if (!supabaseUrl) {
    throw new Error("Missing SUPABASE_URL");
  }

  let secretKey: string | undefined;

  const secretKeysRaw = Deno.env.get(
    "SUPABASE_SECRET_KEYS",
  );

  if (secretKeysRaw) {
    try {
      const secretKeys = JSON.parse(secretKeysRaw);
      secretKey = secretKeys["default"];
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

function getZarinPalConfig() {


  
  const merchantId = Deno.env.get(
  "ZARINPAL_MERCHANT_ID",
);

console.log(
  "ZARINPAL_MERCHANT_ID length:",
  merchantId?.length,
);

console.log(
  "ZARINPAL_MERCHANT_ID value:",
  merchantId,
);

  const callbackUrl = Deno.env.get(
    "ZARINPAL_CALLBACK_URL",
  );

  const sandboxValue = Deno.env.get(
    "ZARINPAL_SANDBOX",
  );

console.log(
  "Merchant ID:",
  merchantId,
  "length:",
  merchantId?.length,
);

  const sandbox =
    sandboxValue?.toLowerCase() === "true";

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

Deno.serve(
  withSupabase(
    { auth: "user" },
    async (req: Request, ctx) => {
      try {
        if (req.method !== "POST") {
          return jsonResponse(
            {
              success: false,
              error: "Method not allowed",
            },
            405,
          );
        }

        // --------------------------------------------------------
        // AUTHENTICATION
        // --------------------------------------------------------

        const {
          data: { user },
          error: userError,
        } = await ctx.supabase.auth.getUser();

        if (userError) {
          console.error(
            "Auth getUser error:",
            userError,
          );

          return jsonResponse(
            {
              success: false,
              error: "Unauthorized",
            },
            401,
          );
        }

        if (!user) {
          console.error(
            "No authenticated user found",
          );

          return jsonResponse(
            {
              success: false,
              error: "Unauthorized",
            },
            401,
          );
        }

        const userId = user.id;

        console.log(
          "Authenticated user:",
          userId,
        );

        // --------------------------------------------------------
        // REQUEST BODY
        // --------------------------------------------------------

        let body: {
          address_id?: unknown;
          shipping_method_id?: unknown;
          payment_method?: unknown;
        };

        try {
          body = await req.json();
        } catch {
          return jsonResponse(
            {
              success: false,
              error: "Invalid JSON body",
            },
            400,
          );
        }

        const addressId = body.address_id;
        const shippingMethodId =
          body.shipping_method_id;
        const paymentMethod =
          body.payment_method;

        if (!isValidUuid(addressId)) {
          return jsonResponse(
            {
              success: false,
              error: "Invalid address_id",
            },
            400,
          );
        }

        if (!isValidUuid(shippingMethodId)) {
          return jsonResponse(
            {
              success: false,
              error:
                "Invalid shipping_method_id",
            },
            400,
          );
        }

        if (paymentMethod !== "online") {
          return jsonResponse(
            {
              success: false,
              error:
                "Only online payment is supported",
            },
            400,
          );
        }

        // --------------------------------------------------------
        // ADMIN CLIENT
        // --------------------------------------------------------

        const supabaseAdmin =
          getSupabaseAdmin();

        // --------------------------------------------------------
        // GET CART
        // --------------------------------------------------------

        const {
          data: cartItems,
          error: cartError,
        } = await supabaseAdmin
          .from("cart_items")
          .select(`
            id,
            user_id,
            product_id,
            quantity,
            products (
              id,
              title,
              price,
              discount_price,
              thumbnail
            )
          `)
          .eq("user_id", userId);

        if (cartError) {
          console.error(
            "Cart query error:",
            cartError,
          );

          return jsonResponse(
            {
              success: false,
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
              success: false,
              error: "Cart is empty",
            },
            400,
          );
        }

        // --------------------------------------------------------
        // CALCULATE ORDER
        // --------------------------------------------------------

        let subtotal = 0;
        let discount = 0;

        const orderItems: Array<{
          product_id: string;
          product_title: string;
          product_thumbnail: string | null;
          quantity: number;
          unit_price: number;
          discount_price: number;
          total_price: number;
        }> = [];

        for (const item of cartItems) {
          const quantity = item.quantity;

          if (
            !Number.isSafeInteger(quantity) ||
            quantity <= 0
          ) {
            return jsonResponse(
              {
                success: false,
                error:
                  "Invalid cart quantity",
              },
              400,
            );
          }

          const product =
            Array.isArray(item.products)
              ? item.products[0]
              : item.products;

          if (!product) {
            return jsonResponse(
              {
                success: false,
                error:
                  "One or more products no longer exist",
              },
              400,
            );
          }

          const price = product.price;

          const discountPrice =
            product.discount_price ??
            product.price;

          if (
            !isSafeNonNegativeInteger(price) ||
            !isSafeNonNegativeInteger(
              discountPrice,
            )
          ) {
            console.error(
              "Invalid product price:",
              product.id,
            );

            return jsonResponse(
              {
                success: false,
                error:
                  "Invalid product price",
              },
              500,
            );
          }

          if (discountPrice > price) {
            return jsonResponse(
              {
                success: false,
                error:
                  "Invalid product discount",
              },
              500,
            );
          }

          const itemSubtotal =
            price * quantity;

          const itemDiscount =
            (price - discountPrice) *
            quantity;

          const itemTotal =
            discountPrice * quantity;

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
                success: false,
                error:
                  "Order amount is too large",
              },
              400,
            );
          }

          subtotal += itemSubtotal;
          discount += itemDiscount;

          if (
            !Number.isSafeInteger(subtotal) ||
            !Number.isSafeInteger(discount)
          ) {
            return jsonResponse(
              {
                success: false,
                error:
                  "Order amount is too large",
              },
              400,
            );
          }

          orderItems.push({
            product_id: product.id,
            product_title: product.title,
            product_thumbnail:
              product.thumbnail ?? null,
            quantity,
            unit_price: price,
            discount_price:
              discountPrice,
            total_price: itemTotal,
          });
        }

        // --------------------------------------------------------
        // GET ADDRESS
        // --------------------------------------------------------

        const {
          data: address,
          error: addressError,
        } = await supabaseAdmin
          .from("addresses")
          .select(`
            id,
            user_id,
            title,
            receiver_name,
            phone,
            province,
            city,
            address,
            postal_code
          `)
          .eq("id", addressId)
          .eq("user_id", userId)
          .maybeSingle();

        if (addressError) {
          console.error(
            "Address query error:",
            addressError,
          );

          return jsonResponse(
            {
              success: false,
              error:
                "Failed to load address",
            },
            500,
          );
        }

        if (!address) {
          return jsonResponse(
            {
              success: false,
              error: "Address not found",
            },
            404,
          );
        }

        // --------------------------------------------------------
        // GET SHIPPING METHOD
        // --------------------------------------------------------

        const {
          data: shippingMethod,
          error: shippingError,
        } = await supabaseAdmin
          .from("shipping_methods")
          .select(`
            id,
            title,
            cost,
            is_active
          `)
          .eq("id", shippingMethodId)
          .eq("is_active", true)
          .maybeSingle();

        if (shippingError) {
          console.error(
            "Shipping method query error:",
            shippingError,
          );

          return jsonResponse(
            {
              success: false,
              error:
                "Failed to load shipping method",
            },
            500,
          );
        }

        if (!shippingMethod) {
          return jsonResponse(
            {
              success: false,
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
              success: false,
              error:
                "Invalid shipping cost",
            },
            500,
          );
        }

        // --------------------------------------------------------
        // FINAL TOTAL
        // --------------------------------------------------------

        const totalPrice =
          subtotal -
          discount +
          shippingCost;

        if (
          !Number.isSafeInteger(
            totalPrice,
          ) ||
          totalPrice <= 0
        ) {
          return jsonResponse(
            {
              success: false,
              error:
                "Invalid order amount",
            },
            400,
          );
        }

        // --------------------------------------------------------
        // TOMAN -> RIAL
        // --------------------------------------------------------

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
              success: false,
              error:
                "Order amount is too large",
            },
            400,
          );
        }

        // --------------------------------------------------------
        // CREATE ORDER
        // --------------------------------------------------------

        const shippingAddress = {
          id: address.id,
          title: address.title,
          receiver_name:
            address.receiver_name,
          phone: address.phone,
          province: address.province,
          city: address.city,
          address: address.address,
          postal_code:
            address.postal_code,
        };

        const {
          data: order,
          error: orderError,
        } = await supabaseAdmin
          .from("orders")
          .insert({
            user_id: userId,
            address_id: address.id,
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
          .select("id")
          .single();

        if (
          orderError ||
          !order
        ) {
          console.error(
            "Order creation error:",
            orderError,
          );

          return jsonResponse(
            {
              success: false,
              error:
                "Failed to create order",
            },
            500,
          );
        }

        // --------------------------------------------------------
        // CREATE ORDER ITEMS
        // --------------------------------------------------------

        const orderItemsForInsert =
          orderItems.map(
            (item) => ({
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
          error: orderItemsError,
        } = await supabaseAdmin
          .from("order_items")
          .insert(
            orderItemsForInsert,
          );

        if (orderItemsError) {
          console.error(
            "Order items error:",
            orderItemsError,
          );

          await supabaseAdmin
            .from("orders")
            .delete()
            .eq(
              "id",
              order.id,
            );

          return jsonResponse(
            {
              success: false,
              error:
                "Failed to create order items",
            },
            500,
          );
        }

        // --------------------------------------------------------
        // CREATE PAYMENT
        // --------------------------------------------------------

        const {
          data: payment,
          error: paymentError,
        } = await supabaseAdmin
          .from("payments")
          .insert({
            order_id:
              order.id,
            user_id:
              userId,
            amount:
              amountInToman,
            gateway:
              "zarinpal",
            status:
              "pending",
          })
          .select(`
            id,
            order_id,
            amount,
            gateway,
            status
          `)
          .single();

        if (
          paymentError ||
          !payment
        ) {
          console.error(
            "Payment creation error:",
            paymentError,
          );

          await supabaseAdmin
            .from("order_items")
            .delete()
            .eq(
              "order_id",
              order.id,
            );

          await supabaseAdmin
            .from("orders")
            .delete()
            .eq(
              "id",
              order.id,
            );

          return jsonResponse(
            {
              success: false,
              error:
                "Failed to create payment",
            },
            500,
          );
        }

        // --------------------------------------------------------
        // ZARINPAL CONFIGURATION
        // --------------------------------------------------------

        const {
          merchantId,
          callbackUrl,
          sandbox,
          requestUrl,
          startPayUrl,
        } = getZarinPalConfig();

        console.log(
          "ZarinPal environment:",
          sandbox
            ? "SANDBOX"
            : "PRODUCTION",
        );

        // --------------------------------------------------------
        // REQUEST PAYMENT
        // --------------------------------------------------------

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

        console.log(
          "ZarinPal request:",
          {
            order_id:
              order.id,
            payment_id:
              payment.id,
            amount_toman:
              amountInToman,
            amount_rial:
              amountInRial,
            sandbox,
          },
        );

        const zarinPalResponse =
          await fetch(
            requestUrl,
            {
              method: "POST",
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

        let zarinPalResult: any;

        try {
          zarinPalResult =
            await zarinPalResponse.json();
        } catch {
          zarinPalResult = null;
        }

        if (!zarinPalResponse.ok || !zarinPalResult) {
  console.error(
    "ZarinPal HTTP error:",
    {
      status: zarinPalResponse.status,
      statusText: zarinPalResponse.statusText,
      response: zarinPalResult,
    },
  );

  await supabaseAdmin
    .from("payments")
    .update({
      status: "failed",
      gateway_message: JSON.stringify({
        http_status: zarinPalResponse.status,
        status_text: zarinPalResponse.statusText,
        response: zarinPalResult,
      }),
    })
    .eq("id", payment.id);

  return jsonResponse(
    {
      success: false,
      error: "Payment gateway request failed",
      gateway_http_status: zarinPalResponse.status,
      gateway_response: zarinPalResult,
    },
    502,
  );
}

        const gatewayCode =
          zarinPalResult
            ?.data
            ?.code;

        const authority =
          zarinPalResult
            ?.data
            ?.authority;

        if (
          gatewayCode !== 100 ||
          typeof authority !==
            "string" ||
          authority.length === 0
        ) {
          console.error(
            "ZarinPal rejected payment request:",
            zarinPalResult,
          );

          await supabaseAdmin
            .from("payments")
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

          return jsonResponse(
            {
              success: false,
              error:
                "ZarinPal rejected payment request",
              gateway_code:
                gatewayCode ??
                null,
            },
            400,
          );
        }

        // --------------------------------------------------------
        // SAVE AUTHORITY
        // --------------------------------------------------------

        const {
          error: authorityError,
        } = await supabaseAdmin
          .from("payments")
          .update({
            authority,
          })
          .eq(
            "id",
            payment.id,
          );

        if (authorityError) {
          console.error(
            "Authority update error:",
            authorityError,
          );

          await supabaseAdmin
            .from("payments")
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

          return jsonResponse(
            {
              success: false,
              error:
                "Failed to save payment authority",
            },
            500,
          );
        }

        // --------------------------------------------------------
        // PAYMENT URL
        // --------------------------------------------------------

        const paymentUrl =
          `${startPayUrl}/${authority}`;

        // --------------------------------------------------------
        // SUCCESS
        // --------------------------------------------------------

        return jsonResponse({
          success: true,
          order_id:
            order.id,
          payment_id:
            payment.id,
          amount:
            amountInToman,
          currency:
            "TOMAN",
          authority,
          payment_url:
            paymentUrl,
          sandbox,
        });
      } catch (error) {
        console.error(
          "create-checkout error:",
          error,
        );

        return jsonResponse(
          {
            success: false,
            error:
              "Internal server error",
          },
          500,
        );
      }
    },
  ),
);