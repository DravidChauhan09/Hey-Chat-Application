import 'dart:io';
import 'package:chatapp/componet/my_emoji.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/componet/my_textfileid2.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add this import for Firebase Storage

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  String? _profileImageUrl;
  bool _hasActiveStatus = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkActiveStatus();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _bioController.text = userData['bio'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _profileImageUrl = userData['profileImageUrl'] ?? '';
        });
      }
    }
  }

  Future<void> _checkActiveStatus() async {
    final now = DateTime.now();
    final statuses = await FirebaseFirestore.instance.collection('statuses').where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    for (var doc in statuses.docs) {
      final timestamp = doc['timestamp'] as Timestamp?;
      if (timestamp != null) {
        final timestampDate = timestamp.toDate();
        if (now.difference(timestampDate).inHours < 12) {
          setState(() {
            _hasActiveStatus = true;
          });
          break;
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final selectedImageUrl = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyEmoji(
          onImageSelected: (String imageUrl) {
            setState(() {
              _profileImageUrl = imageUrl;
            });
          },
        ),
      ),
    );

    if (selectedImageUrl != null && selectedImageUrl.isNotEmpty) {
      setState(() {
        _profileImageUrl = selectedImageUrl;
      });
    }
  }

  Future<void> _saveProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? profileImageUrl = _profileImageUrl;

      // If a new image is selected, upload it to Firebase Storage
      if (_image != null) {
        profileImageUrl = await _uploadImageToFirebase(_image!);
      }

      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'name': _nameController.text,
        'bio': _bioController.text,
        'profileImageUrl': profileImageUrl ?? '',
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Profile Saved'),
          content: const Text('Your profile has been updated.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Navigate to HomePage
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('profile_pictures/${FirebaseAuth.instance.currentUser!.uid}.jpg');
    await imageRef.putFile(imageFile);
    return await imageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : const NetworkImage("https://img.freepik.com/free-psd/emoji-element-isolated_23-2150354998.jpg?t=st=1723110820~exp=1723114420~hmac=36a81541dbf188e69e6d1b8b972c166d91bc51e733769dd113edae5635e203f2&w=740"),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // Change Profile Picture Button
              TextButton(
                onPressed: _pickImage,
                child: const Text('Change Profile Picture'),
              ),
              const SizedBox(height: 16),

              // Name
              MyTextField2(hintText: "Name", obscure: false, controller: _nameController),
              const SizedBox(height: 8),

              // Email
              MyTextField2(hintText: 'Email', obscure: false, controller: _emailController, enabled: false),
              const SizedBox(height: 8),

              // Bio
              MyTextField2(hintText: "Add Bio", obscure: false, controller: _bioController, maxline: 2),
              const SizedBox(height: 8),

              // Phone Number
              MyTextField2(hintText: 'Phone Number', obscure: false, controller: _phoneController, enabled: false),
              const SizedBox(height: 24),
              // Save Button
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}