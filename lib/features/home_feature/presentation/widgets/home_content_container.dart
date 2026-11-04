
import 'package:flutter/material.dart';

class HomeContentContainer extends StatelessWidget {
  const HomeContentContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: SizedBox(
          width: double.infinity,
          child: child,
        ),
      ),
    );
  }
}
