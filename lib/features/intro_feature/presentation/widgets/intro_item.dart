
import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class IntroItem extends StatelessWidget {
final String image;
final String title;
final String description;

const IntroItem({
super.key,
required this.image,
required this.title,
required this.description,
});

@override
Widget build(BuildContext context) {
return LayoutBuilder(
builder: (context, constraints) {
final screenWidth = MediaQuery.of(context).size.width;
final screenHeight = MediaQuery.of(context).size.height;

// RESPONSIVE BREAKPOINTS

final isMobile = screenWidth < 600;
final isTablet = screenWidth >= 600 && screenWidth < 1024;
final isDesktop = screenWidth >= 1024;

// RESPONSIVE IMAGE SIZE

final double imageHeight = isMobile
? (screenHeight * 0.34).clamp(160.0, 280.0)
    : isTablet
? (screenHeight * 0.40).clamp(220.0, 360.0)
    : (screenHeight * 0.43).clamp(260.0, 400.0);

// RESPONSIVE FONT SIZE

final double titleFontSize = isMobile
? 22
    : isTablet
? 28
    : 32;

final double descriptionFontSize = isMobile
? 14
    : isTablet
? 17
    : 19;

// RESPONSIVE SPACING

final double imageTextSpacing = isMobile
? 24
    : isTablet
? 32
    : 36;

final double titleDescriptionSpacing = isMobile ? 12 : 16;

final double horizontalPadding = isMobile
? 8
    : isTablet
? 24
    : 32;

return Padding(
padding: EdgeInsets.symmetric(
horizontal: horizontalPadding,
vertical: 12,
),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 850,
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
mainAxisSize: MainAxisSize.min,
children: [
// INTRO IMAGE

Flexible(
child: Image.asset(
image,
height: imageHeight,
width: double.infinity,
fit: BoxFit.contain,
filterQuality: FilterQuality.high,
),
),

SizedBox(height: imageTextSpacing),

// TITLE

Text(
title,
textAlign: TextAlign.center,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: AppTextStyles.titleLarge.copyWith(
fontSize: titleFontSize,
height: 1.5,
),
),

SizedBox(height: titleDescriptionSpacing),

// DESCRIPTION

ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 650,
),
child: Text(
description,
textAlign: TextAlign.center,
style: AppTextStyles.body.copyWith(
fontSize: descriptionFontSize,
height: 1.8,
),
),
),
],
),
),
),
);
},
);
}
}
