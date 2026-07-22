class IntroModel {
  final String image;
  final String title;
  final String description;

  IntroModel({
    required this.image,
    required this.title,
    required this.description,
  });
}


final introList = [

  IntroModel(
    image: "assets/intro/bag.svg",
    title: "خرید آسان و سریع",
    description:
    "محصولات مورد علاقه خود را به راحتی پیدا کنید",
  ),

  IntroModel(
    image: "assets/intro/bagnoline.svg",
    title: "ارسال سریع محصولات",
    description:
    "سفارش شما در کوتاه‌ترین زمان ارسال می‌شود",
  ),

  IntroModel(
    image: "assets/lottie/offerhand.json",
    title: "تجربه خرید بهتر",
    description:
    "یک فروشگاه آنلاین همیشه همراه شما",
  ),

];