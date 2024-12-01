import 'package:flutter/material.dart';

class MyBottomAppbar extends StatelessWidget {
  const MyBottomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      bottomNavigationBar: BottomAppBar(
        notchMargin: 2,
        shape: CircularNotchedRectangle(),
        height: 70.0,
        elevation: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Icon(Icons.home),
                Text(
                  "Home",
                ),
              ],
            ),
            Column(
              children: [
                Icon(Icons.shopping_cart_checkout_outlined),
                Text("Shope"),
              ],
            ),
            Column(
              children: [
                Icon(Icons.favorite_border),
                Text("Favo"),
              ],
            ),
            Column(
              children: [
                Icon(Icons.settings),
                Text("Setting"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
