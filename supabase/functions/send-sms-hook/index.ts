Deno.serve(async (req: Request) => {
  try {
    const body = await req.json();

    const phone = body.user.phone;
    const otp = body.sms.otp;

    const apiKey = Deno.env.get("SMS_API_KEY")!;
    const templateId = Number(
      Deno.env.get("SMS_TEMPLATE_ID")
    );

    const response = await fetch(
      "https://api.sms.ir/v1/send/verify",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": apiKey,
        },
        body: JSON.stringify({
          mobile: phone,
          templateId: templateId,
          parameters: [
            {
              name: "Code",
              value: otp,
            },
          ],
        }),
      }
    );

    if (!response.ok) {
      const error = await response.text();

      console.error(error);

      return new Response(
        "SMS ارسال نشد",
        {
          status: 500,
        }
      );
    }

    return new Response(null, {
      status: 200,
    });

  } catch (e) {

    console.error(e);

    return new Response(
      "Internal Error",
      {
        status: 500,
      }
    );

  }
});