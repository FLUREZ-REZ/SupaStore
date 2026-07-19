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
    image: "assets/images/intro1.png",
    title: "خرید آسان و سریع",
    description:
    "محصولات مورد علاقه خود را به راحتی پیدا کنید",
  ),

  IntroModel(
    image: "assets/images/intro2.png",
    title: "ارسال سریع محصولات",
    description:
    "سفارش شما در کوتاه‌ترین زمان ارسال می‌شود",
  ),

  IntroModel(
    image: "assets/images/intro3.png",
    title: "تجربه خرید بهتر",
    description:
    "یک فروشگاه مدرن همیشه همراه شما",
  ),

];