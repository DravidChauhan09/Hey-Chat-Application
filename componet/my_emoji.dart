import 'package:flutter/material.dart';

class MyEmoji extends StatelessWidget {
  final Function(String) onImageSelected;

  // List of image assets. Include both JPEG and PNG images.
  final List<String> imagePaths = [
    'https://img.freepik.com/free-psd/emoji-element-isolated_23-2150355001.jpg?t=st=1723111056~exp=1723114656~hmac=7c07c0317305b9b4b92ce11c11294eb3b288ee81cb0ed0cb7213fd974d0fe75b&w=740',
    'https://img.freepik.com/free-psd/emoji-element-isolated_23-2150355004.jpg?t=st=1723111131~exp=1723114731~hmac=4c2f17cc7be31811cd3863c2f2666083dc2fe0fc3de1a553dfa601cda73d262b&w=740',
    'https://img.freepik.com/free-psd/emoji-element-isolated_23-2150354998.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878848.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878846.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878842.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878830.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878850.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-vector/mustache-emoji-illustration_23-2151063106.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-vector/gradient-wedding-emoji-illustration_23-2151330845.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878818.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-vector/gradient-mustache-emoji-illustration_52683-148490.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878838.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878816.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-vector/gradient-hungry-emoji-illustration_23-2151041567.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-vector/gradient-mustache-emoji-illustration_52683-148487.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878856.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-vector/wedding-emoji-illustration_23-2151298401.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878858.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878840.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878828.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-psd/3d-rendering-emoji-icon_23-2149878854.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    'https://img.freepik.com/free-photo/3d-rendering-emotions_23-2149081935.jpg?uid=R158088768&ga=GA1.1.1743594333.1720486136&semt=ais_hybrid',
    // Ensure that all items are valid URLs or remove them
  ];

  MyEmoji({super.key, required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      appBar: AppBar(
        title: const Text(' Gallery', ),
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context, imagePaths[index]); // Return selected image path
            },
            child: CircleAvatar(
              radius: 40,
              backgroundImage: imagePaths[index].isNotEmpty
                  ? NetworkImage(imagePaths[index])
                  : null,
              backgroundColor: Colors.grey[200],
            ),
          );
        },
      ),
    );
  }
}
