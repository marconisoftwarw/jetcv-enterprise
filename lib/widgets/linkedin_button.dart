import 'package:flutter/material.dart';
import '../config/app_theme.dart';

enum LinkedInButtonVariant { primary, secondary, outline, text, danger }

class LinkedInButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinkedInButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const LinkedInButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = LinkedInButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    Widget button;

    switch (variant) {
      case LinkedInButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDisabled
                ? AppTheme.neutralGrey
                : AppTheme.primaryBlue,
            foregroundColor: AppTheme.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 48),
          ),
          child: _buildButtonContent(),
        );
        break;

      case LinkedInButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDisabled
                ? AppTheme.lightGrey
                : AppTheme.lightBlue,
            foregroundColor: isDisabled
                ? AppTheme.textTertiary
                : AppTheme.primaryBlue,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 48),
          ),
          child: _buildButtonContent(),
        );
        break;

      case LinkedInButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: isDisabled
                ? AppTheme.textTertiary
                : AppTheme.primaryBlue,
            side: BorderSide(
              color: isDisabled ? AppTheme.borderGrey : AppTheme.primaryBlue,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 48),
          ),
          child: _buildButtonContent(),
        );
        break;

      case LinkedInButtonVariant.text:
        button = TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: isDisabled
                ? AppTheme.textTertiary
                : AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 48),
          ),
          child: _buildButtonContent(),
        );
        break;

      case LinkedInButtonVariant.danger:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDisabled
                ? AppTheme.neutralGrey
                : AppTheme.errorRed,
            foregroundColor: AppTheme.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 48),
          ),
          child: _buildButtonContent(),
        );
        break;
    }

    return button;
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == LinkedInButtonVariant.outline ||
                    variant == LinkedInButtonVariant.text
                ? AppTheme.primaryBlue
                : AppTheme.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text, style: AppTheme.button.copyWith(color: _getTextColor())),
        ],
      );
    }

    return Text(text, style: AppTheme.button.copyWith(color: _getTextColor()));
  }

  Color _getTextColor() {
    if (isLoading) return AppTheme.textTertiary;

    switch (variant) {
      case LinkedInButtonVariant.primary:
      case LinkedInButtonVariant.danger:
        return AppTheme.white;
      case LinkedInButtonVariant.secondary:
        return AppTheme.primaryBlue;
      case LinkedInButtonVariant.outline:
      case LinkedInButtonVariant.text:
        return AppTheme.primaryBlue;
    }
  }
}
