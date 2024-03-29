import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget outlineTextFromField(
    {ValueChanged<String>? onChanged,
    EdgeInsetsGeometry? contentPadding,
    String? label,
    Key? key,
    String? hintText,
    int? minLines,
    int? maxLines,
    FocusNode? focusNode,
    FormFieldValidator? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    TextEditingController? controller,
    String? initialValue,
    bool obscureText = false,
    Widget? suffix,
    Widget? suffixIcon}) {
  return TextFormField(
    key: key,
    minLines: minLines ?? 1,
    maxLines: maxLines ?? 1,
    obscureText: obscureText,
    focusNode: focusNode,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    initialValue: initialValue,
    decoration: InputDecoration(
      contentPadding:
          contentPadding ?? EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      hintText: hintText,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      suffixIcon: suffixIcon,
      suffix: suffix,
    ),
    validator: validator,
    onChanged: onChanged,
    inputFormatters: inputFormatters,
    keyboardType: keyboardType,
    cursorColor: Colors.grey,
    controller: controller,
  );
}
