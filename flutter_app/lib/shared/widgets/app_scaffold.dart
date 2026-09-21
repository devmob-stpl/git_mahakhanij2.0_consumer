import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? bottomActionButton;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    this.title,
    this.subtitle,
    required this.body,
    this.bottomNavigationBar,
    this.bottomActionButton,
    this.floatingActionButton,
    this.actions,
    this.showBackButton = false,
    this.onBack,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.canvas,
      floatingActionButton: floatingActionButton,
      appBar: title != null
          ? AppBar(
              title: subtitle != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    )
                  : Text(title!),
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: onBack ??
                          () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              try {
                                context.pop();
                              } catch (_) {}
                            }
                          },
                    )
                  : null,
              actions: actions,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: AppColors.line, height: 1),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            if (bottomActionButton != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.line, width: 1)),
                ),
                child: bottomActionButton!,
              ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
