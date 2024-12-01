import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildBottomAppBarItem(
            icon: Icons.home,
            label: 'Home',
            index: 0,
          ),
          _buildBottomAppBarItem(
            icon: Icons.call,
            label: 'Call',
            index: 1,
          ),
          _buildBottomAppBarItem(
            icon: Icons.group,
            label: 'Group',
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAppBarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onItemSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0), // Reduced vertical padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 26.0, // Adjust icon size if needed
                color: selectedIndex == index ? Colors.black : Colors.grey,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.0, // Adjust text size if needed
                  color: selectedIndex == index ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
