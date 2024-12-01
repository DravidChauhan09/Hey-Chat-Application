import 'package:flutter/material.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/pages/group_chat_page.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/services/group/group_service.dart';
import 'package:chatapp/services/chat/chat_service.dart';

class AllUser extends StatefulWidget {
  const AllUser({super.key});

  @override
  _AllUserState createState() => _AllUserState();
}

class _AllUserState extends State<AllUser> {
  final GroupService _groupService = GroupService();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final Set<String> _selectedUsers = {};
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('All Users'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: _createGroup,
            ),
          IconButton(
            icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _buildUserList(),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _selectedUsers.clear();
      }
    });
  }

  void _createGroup() async {
    List<String> selectedUserIDs = _selectedUsers.toList();

    if (selectedUserIDs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No users selected')),
      );
      return;
    }

    String? groupName = await showDialog<String>(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Group Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Group Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (groupName == null || groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name cannot be empty')),
      );
      return;
    }

    try {
      String groupId = await _groupService.createGroupChat(selectedUserIDs, groupName);

      setState(() {
        _selectedUsers.clear();
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created')),
      );

      // List<String> selectedUserEmails = await Future.wait(
      //   selectedUserIDs.map((id) async => await _groupService.getUserEmail(id)),
      // );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChatPage(

            groupChatID: groupId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $e')),
      );
    }
  }

  Widget _buildUserList() {

    String currentUserID = _authService.getCurrentUser()!.uid;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getAllUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users available'));
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
            String profileImageUrl = user['profileImageUrl'] ?? '';

            return Padding(
              padding: const EdgeInsets.only(left: 3,right: 3,top: 5,bottom: 5),
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
                    : CircleAvatar(
                  radius: 25,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : const AssetImage("assets/images/user.png")
                  as ImageProvider,
                ),
                title: Text(userEmail),
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
  }
}
