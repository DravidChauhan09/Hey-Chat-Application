import 'package:chatapp/componet/my_botttom_appbar.dart';
import 'package:chatapp/pages/group_home_page.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/services/chat/chat_service_number.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class CallPage extends StatelessWidget {
  CallPage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Call Users'),
      ),
      body: _buildUserList(),
      // bottomNavigationBar: CustomBottomAppBar(
      //   selectedIndex: 1,
      //   onItemSelected: (index) {
      //     _navigateToPage(context, index);
      //   },
      // ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pop();
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => CallPage()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const GroupHomePage()));
        break;
    }
  }

  // Build a list of users except for the current logged-in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        // Handle error
        if (snapshot.hasError) {
          return const Center(child: Text("Error fetching users"));
        }

        // Show loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle empty data
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        // Build the list of users
        var users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var userData = users[index].data() as Map<String, dynamic>;

            // Ensure userData contains required fields
            if (userData["phone"] is String && userData["email"] is String) {
              return _buildUserListItem(userData, context);
            } else {
              return const SizedBox.shrink(); // Or return an empty container
            }
          },
        );
      },
    );
  }

  // Build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // Display all users except the current user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return GestureDetector(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(top: 4, bottom: 2, left: 7, right: 7),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Call icon
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.call, size: 30,color: Theme.of(context).colorScheme.primary,),
              ),

              // User details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData["phone"] ?? 'No phone number',
                      style: const TextStyle(fontSize: 20,),
                    ),
                    Text(
                      userData["email"] ?? 'No email',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () async {
          String phoneNumber = userData["phone"] ?? '';
          if (phoneNumber.isNotEmpty) {
            await FlutterPhoneDirectCaller.callNumber(phoneNumber);
          } else {
            // Handle case where phone number is empty
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No phone number available')),
            );
          }
        },
      );
    } else {
      return Container(); // Skip current user
    }
  }
}
