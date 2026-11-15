import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ResponsiveFrame extends StatelessWidget {
  final Widget child;

  const ResponsiveFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If width is greater than 500px (Desktop or Tablet Browser)
        if (constraints.maxWidth > 500) {
          return Scaffold(
            backgroundColor: const Color(0xFF1E2124),
            body: Center(
              child: Container(
                width: 430,
                height: constraints.maxHeight.clamp(600, 932),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF33383F),
                    width: 3,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            ),
          );
        }

        // Native mobile screen or small window
        return Container(
          color: AppColors.background,
          child: child,
        );
      },
    );
  }
}

