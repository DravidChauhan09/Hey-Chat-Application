import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {

  final void Function()? onTap ;
  final String text ;

  const MyButton({super.key,required this.text , required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: Theme.of(context).colorScheme.secondary,
        ),
        child: Center(
          child: Text(text),
        ),
      ),
    );
  }
}
