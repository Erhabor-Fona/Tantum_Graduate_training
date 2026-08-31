import 'package:flutter/material.dart';

import '../app/app_colors.dart';

/// App bar variants used across the designs.
enum TatumAppBarStyle { plain, brand }

/// Screen shell with the two app bar treatments in the designs:
/// a plain white bar, and the yellow brand bar used on Transaction Details,
/// Buy Airtime and the purchase result screens.
class TatumScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final TatumAppBarStyle style;
  final List<Widget> actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? leading;

  const TatumScaffold({
    super.key,
    required this.body,
    this.title,
    this.style = TatumAppBarStyle.plain,
    this.actions = const [],
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showBack = true,
    this.onBack,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final isBrand = style == TatumAppBarStyle.brand;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      appBar: title == null
          ? null
          : AppBar(
              backgroundColor: isBrand
                  ? AppColors.primary
                  : (isDark ? AppColors.darkBackground : AppColors.white),
              foregroundColor: isBrand ? AppColors.navy : null,
              titleTextStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isBrand ? AppColors.navy : (isDark ? AppColors.white : AppColors.navy),
              ),
              title: Text(title!),
              leading: leading ??
                  (showBack && Navigator.canPop(context)
                      ? IconButton(
                          icon: isBrand
                              ? Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(
                                    color: Color(0x1A001F3F),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_back, size: 18),
                                )
                              : const Icon(Icons.arrow_back),
                          onPressed: onBack ?? () => Navigator.pop(context),
                        )
                      : null),
              actions: actions,
            ),
      body: SafeArea(top: title == null, child: body),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
