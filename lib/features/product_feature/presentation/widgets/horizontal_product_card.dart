import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/price_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product_entity.dart';


class HorizontalProductCard extends StatelessWidget {

  const HorizontalProductCard({
    super.key,
    required this.product,
    this.onTap,
  });


  final ProductEntity product;

  final VoidCallback? onTap;



  @override
  Widget build(BuildContext context) {

    return InkWell(

      onTap: onTap,

      borderRadius: BorderRadius.circular(16.r),

      child: Container(

        width: 170.w,


        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(16.r),

          border: Border.all(
            color: Colors.grey.shade200,
          ),

        ),


        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children: [


            ClipRRect(

              borderRadius:
              BorderRadius.vertical(
                top: Radius.circular(16.r),
              ),


              child: SizedBox(

                height: 150.h,


                width: double.infinity,


                child: CachedNetworkImage(

                  imageUrl: product.thumbnail,

                  fit: BoxFit.cover,


                  placeholder: (_,__) =>
                  const Center(
                    child: CircularProgressIndicator(),
                  ),


                  errorWidget: (_,__,___)=>
                  const Icon(
                    Icons.image_not_supported,
                  ),

                ),

              ),

            ),



            Padding(

              padding: EdgeInsets.all(10.w),


              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,


                children: [


                  Text(

                    product.title,


                    maxLines: 2,

                    overflow:
                    TextOverflow.ellipsis,


                    style:
                    AppTextStyles.productCard,

                  ),



                  SizedBox(
                    height: 8.h,
                  ),



                  Text(

                    PriceFormatter.format(
                      product.finalPrice,
                    ),


                    style:
                    AppTextStyles.product_prize.copyWith(

                      color: AppColors.price,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),


                ],

              ),

            ),


          ],

        ),

      ),

    );

  }

}