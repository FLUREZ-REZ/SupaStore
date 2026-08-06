import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_provider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/horizontal_product_card.dart';




class NewestProductsSection extends StatelessWidget {

  const NewestProductsSection({
    super.key,
    required this.onProductTap,
  });


  final Function(ProductEntity product) onProductTap;



  @override
  Widget build(BuildContext context) {


    return Consumer<ProductProvider>(

      builder: (context, provider, child) {


        if(provider.isLoading){

          return const Center(
            child: CircularProgressIndicator(),
          );

        }



        if(provider.products.isEmpty){

          return const SizedBox();

        }



        return SizedBox(

          height: 270.h,


          child: ListView.builder(

            scrollDirection:
            Axis.horizontal,


            padding:
            EdgeInsets.symmetric(
              horizontal: 16.w,
            ),


            itemCount:
            provider.products.length,


            itemBuilder: (context,index){


              final product =
              provider.products[index];



              return Padding(

                padding:
                EdgeInsets.only(
                  right: 12.w,
                ),


                child: HorizontalProductCard(

                  product: product,


                  onTap: (){

                    onProductTap(product);

                  },

                ),

              );

            },

          ),

        );


      },

    );

  }

}