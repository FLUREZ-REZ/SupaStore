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
    image: "assets/intro/offer.webp",
    title: "خرید آسان و سریع",
    description:
    "محصولات مورد علاقه خود را به راحتی پیدا کنید",
  ),

  IntroModel(
    image: "assets/intro/delivery.webp",
    title: "ارسال سریع محصولات",
    description:
    "سفارش شما در کوتاه‌ترین زمان ارسال می‌شود",
  ),

  IntroModel(
    image: "assets/intro/card.webp",
    title: "تجربه خرید بهتر",
    description:
    "یک فروشگاه آنلاین همیشه همراه شما",
  ),

];