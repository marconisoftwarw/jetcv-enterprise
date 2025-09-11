import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EnterpriseTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsGeometry? contentPadding;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderRadius;
  final bool filled;
  final Color? fillColor;

  const EnterpriseTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.contentPadding,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.filled = true,
    this.fillColor,
  });

  @override
  State<EnterpriseTextField> createState() => _EnterpriseTextFieldState();
}

class _EnterpriseTextFieldState extends State<EnterpriseTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange(bool hasFocus) {
    setState(() => _isFocused = hasFocus);
    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.borderColor ?? AppTheme.borderGray;
    final focusedBorderColor =
        widget.focusedBorderColor ?? AppTheme.primaryBlue;
    final errorBorderColor = widget.errorBorderColor ?? AppTheme.errorRed;
    final borderRadius = widget.borderRadius ?? 12.0;
    final fillColor = widget.fillColor ?? AppTheme.pureWhite;

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Focus(
              onFocusChange: _onFocusChange,
              child: TextFormField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                onTap: widget.onTap,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                validator: widget.validator,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  helperText: widget.helperText,
                  errorText: widget.errorText,
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  filled: widget.filled,
                  fillColor: fillColor,
                  contentPadding:
                      widget.contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(color: borderColor, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(color: borderColor, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(color: focusedBorderColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(color: errorBorderColor, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(color: errorBorderColor, width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: AppTheme.borderGray.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  hintStyle: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppTheme.textGray),
                  helperStyle: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textGray),
                  errorStyle: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: errorBorderColor),
                  counterStyle: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textGray),
                ),
              ),
            ),
            if (_isFocused && widget.helperText != null) ...[
              const SizedBox(height: 8),
              AnimatedOpacity(
                opacity: _focusAnimation.value,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  widget.helperText!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textGray),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class EnterprisePasswordField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsGeometry? contentPadding;

  const EnterprisePasswordField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.contentPadding,
  });

  @override
  State<EnterprisePasswordField> createState() =>
      _EnterprisePasswordFieldState();
}

class _EnterprisePasswordFieldState extends State<EnterprisePasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return EnterpriseTextField(
      label: widget.label,
      hint: widget.hint,
      helperText: widget.helperText,
      errorText: widget.errorText,
      controller: widget.controller,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator,
      contentPadding: widget.contentPadding,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppTheme.textGray,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}
