import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final IconData? icon;
  final bool outlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.backgroundColor,
    this.textColor,
    this.height = 50,
    this.borderRadius = 12,
    this.isLoading = false,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: outlined ? null : (gradient ?? (backgroundColor != null ? null : AppTheme.primaryGradient)),
        color: outlined ? Colors.transparent : backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: outlined
            ? Border.all(
                color: gradient != null
                    ? AppTheme.primaryColor
                    : (backgroundColor ?? AppTheme.primaryColor),
                width: 1.5,
              )
            : null,
        boxShadow: outlined
            ? null
            : [
                BoxShadow(
                  color: (backgroundColor ?? AppTheme.primaryColor).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: textColor ?? (outlined ? AppTheme.primaryColor : Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (icon != null && !isLoading) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: textColor ?? (outlined ? AppTheme.primaryColor : Colors.white),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor ?? (outlined ? AppTheme.primaryColor : Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.iconSize = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(size / 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 4),
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}