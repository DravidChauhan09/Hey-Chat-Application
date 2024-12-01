import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/componet/my_textfileid2.dart';

class UserProfilePage extends StatefulWidget {
  final String userID;
  final String userName;
  final String userEmail;
  final String userBio;

  const UserProfilePage({
    required this.userID,
    required this.userName,
    required this.userEmail,
    required this.userBio,
    super.key,
  });

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(widget.userID).get();
    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = userData['name'] ?? widget.userName;
        _emailController.text = userData['email'] ?? widget.userEmail;
        _bioController.text = userData['bio'] ?? widget.userBio;
        _phoneController.text = userData['phone'] ?? '';
        _profileImageUrl = userData['profileImageUrl'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              GestureDetector(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImageUrl.isNotEmpty
                      ? NetworkImage(_profileImageUrl)
                      : const AssetImage("assets/images/user.png") as ImageProvider,
                  backgroundColor: Colors.grey[200],
                ),
              ),

              const SizedBox(height: 16),

              // Name
              MyTextField2(
                hintText: "Name",
                obscure: false,
                controller: _nameController,
                enabled: false,
              ),
              const SizedBox(height: 8),

              // Email
              MyTextField2(
                hintText: 'Email',
                obscure: false,
                controller: _emailController,
                enabled: false,
              ),
              const SizedBox(height: 8),

              // Bio
              MyTextField2(
                hintText: "Add Bio",
                obscure: false,
                controller: _bioController,
                maxline: 2,
                enabled: false,
              ),
              const SizedBox(height: 8),

              // Phone Number
              MyTextField2(
                hintText: 'Phone Number',
                obscure: false,
                controller: _phoneController,
                enabled: false,
              ),
              const SizedBox(height: 24),
              // Save Button (if needed)
            ],
          ),
        ),
      ),
    );
  }
}

