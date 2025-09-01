import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeonTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final Color? neonColor;
  final double? width;

  const NeonTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.neonColor,
    this.width,
  });

  @override
  State<NeonTextField> createState() => _NeonTextFieldState();
}

class _NeonTextFieldState extends State<NeonTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_isFocused) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = widget.neonColor ?? AppTheme.neonGreen;
    final errorColor = AppTheme.neonOrange;

    return SizedBox(
      width: widget.width,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (_isFocused && !_hasError)
                  BoxShadow(
                    color: neonColor.withValues(
                      alpha: 0.3 * _glowAnimation.value,
                    ),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                if (_hasError)
                  BoxShadow(
                    color: errorColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              validator: (value) {
                final error = widget.validator?.call(value);
                setState(() {
                  _hasError = error != null;
                });
                return error;
              },
              onChanged: (value) {
                if (_hasError) {
                  setState(() {
                    _hasError = false;
                  });
                }
                widget.onChanged?.call(value);
              },
              onFieldSubmitted: widget.onSubmitted,
              style: const TextStyle(
                color: AppTheme.offWhite,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,
                prefixIcon: widget.prefixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                          color: _isFocused
                              ? neonColor
                              : _hasError
                              ? errorColor
                              : AppTheme.lightGrayText,
                        ),
                        child: widget.prefixIcon!,
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                          color: _isFocused
                              ? neonColor
                              : _hasError
                              ? errorColor
                              : AppTheme.lightGrayText,
                        ),
                        child: widget.suffixIcon!,
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.glassLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightGray.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: neonColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: errorColor, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: errorColor, width: 2),
                ),
                labelStyle: TextStyle(
                  color: _isFocused
                      ? neonColor
                      : _hasError
                      ? errorColor
                      : AppTheme.lightGrayText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                hintStyle: const TextStyle(
                  color: AppTheme.mediumGrayText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                errorStyle: const TextStyle(
                  color: AppTheme.neonOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
