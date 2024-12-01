import 'package:chatapp/componet/my_botttom_appbar.dart';
import 'package:chatapp/pages/all_user.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/pages/call_page.dart';
import 'package:chatapp/pages/group_home_page.dart';
import 'package:chatapp/pages/user_profile_page.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/componet/my_drawer.dart';
import 'package:chatapp/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/models/message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final Set<String> _selectedUsers = {}; // Track selected users
  bool _isEditing = false; // Track edit mode

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _selectedUsers.clear(); // Clear selection when exiting edit mode
      }
    });
  }

  void _deleteSelectedUsers() async {
    String currentUserID = _authService.getCurrentUser()!.uid;
    await _chatService.deleteUsersAndMessages(
        currentUserID, _selectedUsers.toList());
    setState(() {
      _selectedUsers.clear();
      _isEditing = false;
    });
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CallPage()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const GroupHomePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Home Page',
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedUsers,
            ),
          IconButton(
            icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),

      drawer: const MyDrawer(),
      body: _buildUserList(),
      bottomNavigationBar: CustomBottomAppBar(
        selectedIndex: 0,
        onItemSelected: (index) {
          _navigateToPage(context, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const AllUser();
              },
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildUserList() {
    String currentUserID = _authService.getCurrentUser()!.uid;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUsersStreamWithInteractions(currentUserID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var users = snapshot.data!
            .where((user) => user['uid'] != currentUserID)
            .toList();

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            String userID = user['uid'];
            String userEmail = user['email'];
            String userName = user['name'] ?? '';
            String userBio = user['bio'] ?? '';
            String profileImageUrl = user['profileImageUrl'] ?? '';

            return FutureBuilder<bool>(
              builder: (context, statusSnapshot) {
                return StreamBuilder<int>(
                  stream:
                      _chatService.getUnreadMessageCount(currentUserID, userID),
                  builder: (context, unreadSnapshot) {
                    int unreadCount = unreadSnapshot.data ?? 0;

                    return StreamBuilder<Message?>(
                      stream:
                          _chatService.getLastMessage(currentUserID, userID),
                      builder: (context, lastMessageSnapshot) {
                        String lastMessage = '';
                        if (lastMessageSnapshot.hasData &&
                            lastMessageSnapshot.data != null) {
                          final message = lastMessageSnapshot.data!;
                          final isCurrentUserSender =
                              message.senderID == currentUserID;
                          lastMessage = isCurrentUserSender
                              ? 'Me: ${message.message}'
                              : '  ${message.message}';
                        }

                        return Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(
                              top: 5, bottom: 0, left: 8, right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          child: ListTile(
                            leading: _isEditing
                                ? Checkbox(
                                    value: _selectedUsers.contains(userID),
                                    onChanged: (bool? selected) {
                                      setState(() {
                                        if (selected == true) {
                                          _selectedUsers.add(userID);
                                        } else {
                                          _selectedUsers.remove(userID);
                                        }
                                      });
                                    },
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return UserProfilePage(
                                              userID: userID,
                                              userName: userName,
                                              userEmail: userEmail,
                                              userBio: userBio,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage: profileImageUrl
                                                  .isNotEmpty
                                              ? NetworkImage(profileImageUrl)
                                              : const AssetImage(
                                                      "assets/images/user.png")
                                                  as ImageProvider,
                                        ),
                                      ],
                                    ),
                                  ),
                            title: Text(userEmail),
                            subtitle: Text(lastMessage),
                            trailing: unreadCount > 0
                                ? CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black,
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  )
                                : null,
                            onTap: () {
                              if (!_isEditing) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ChatPage(
                                        receiverID: userID,
                                        receiverEmail: userEmail,
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
              future: null,
            );
          },
        );
      },
    );
  }
}

// bottom navigation appbar old code

//
// bottomNavigationBar: BottomNavigationBar(
// currentIndex: 0,
// items: [
// BottomNavigationBarItem(
// icon: Icon(Icons.home),
// label: 'Home',
// ),
// BottomNavigationBarItem(
// icon: Icon(Icons.call),
// label: 'Call',
// ),
// BottomNavigationBarItem(
// icon: Icon(Icons.group),
// label: 'Group',
// ),
// ],
// ),



//
// void _navigateToPage(BuildContext context, int index) {
//   switch (index) {
//     case 0:
//       Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
//       break;
//     case 1:
//       Navigator.push(context, MaterialPageRoute(builder: (context) => CallPage()));
//       break;
//     case 2:
//       Navigator.push(context, MaterialPageRoute(builder: (context) => GroupHomePage()));
//       break;
//   }
// }