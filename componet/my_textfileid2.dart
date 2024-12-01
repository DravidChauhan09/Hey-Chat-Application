import 'package:flutter/material.dart';

class MyTextField2 extends StatelessWidget {
  final String hintText;
  final bool obscure;
  final TextEditingController controller ;
  final FocusNode? focusNode ;
  final bool? enabled ;
  final int? maxline ;

  const MyTextField2({
    super.key,
    required this.hintText,
    required this.obscure,
    required this.controller,
    this.focusNode,
    this.enabled,
    this.maxline
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: obscure,
        controller: controller,
        maxLines: maxline ,
        enabled: enabled,
        focusNode: focusNode,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          // Outline InputBorder
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          // Outline InputBorder
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,

          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
