import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/responsive.dart';

class MinimalTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;

  const MinimalTextField({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<MinimalTextField> createState() => _MinimalTextFieldState();
}

class _MinimalTextFieldState extends State<MinimalTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LaapakColors.surfaceVariant,
        borderRadius: BorderRadius.circular(Responsive.inputRadius),
        border: Border.all(
          color: _isFocused ? LaapakColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: LaapakColors.textSecondary),
            prefixIcon: widget.prefixIcon != null
                ? IconTheme(
                    data: IconThemeData(
                      color: _isFocused
                          ? LaapakColors.primary
                          : LaapakColors.textSecondary,
                    ),
                    child: widget.prefixIcon!,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}
