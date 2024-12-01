import 'package:flutter/material.dart';

class Usertile extends StatelessWidget {

  final String text ;
  final void Function()? onTap;

  const Usertile({super.key , required this.onTap , required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(top: 4,bottom: 2,left: 7,right: 7),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // icons
            const Padding(
              padding: EdgeInsets.only(right: 5),
              child: Icon(Icons.person),
            ),

            // user name
            Text(text),

          ],
        ),
      ),
    );
  }
}
