import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../data/intro_data.dart';
import '../providers/intro_provider.dart';
import '../widgets/intro_item.dart';



class IntroPage extends StatelessWidget {

  const IntroPage({super.key});


  @override
  Widget build(BuildContext context) {


    final provider =
    context.watch<IntroProvider>();


    return Scaffold(

      body: SafeArea(

        child: Column(

          children: [


            Expanded(

              child: PageView.builder(

                controller:
                provider.pageController,


                itemCount:
                introList.length,


                onPageChanged:
                provider.changePage,


                itemBuilder:(context,index){

                  final item =
                  introList[index];


                  return IntroItem(
                    image:item.image,
                    title:item.title,
                    description:item.description,
                  );


                },


              ),

            ),



            SmoothPageIndicator(

              controller:
              provider.pageController,

              count:introList.length,

              effect:ExpandingDotsEffect(

                dotHeight:8.h,
                dotWidth:8.w,

              ),


            ),


            SizedBox(height:30.h),



            Padding(

              padding:
              EdgeInsets.symmetric(
                  horizontal:20.w
              ),


              child:SizedBox(

                width:double.infinity,

                height:50.h,


                child:ElevatedButton(

                  onPressed:() async{


                    if(provider.currentPage ==
                        introList.length-1){


                      await provider.completeIntro();


                      if(context.mounted){

                        context.go('/auth');

                      }


                    }else{


                      provider.pageController.nextPage(

                        duration:
                        const Duration(milliseconds:300),

                        curve:
                        Curves.ease,

                      );


                    }


                  },


                  child:Text(

                    provider.currentPage ==
                        introList.length-1

                        ?
                    "شروع کنید"

                        :
                    "بعدی",

                  ),


                ),

              ),

            ),


            SizedBox(height:20.h),



          ],


        ),

      ),


    );


  }

}