import 'package:chatapp/componet/my_botttom_appbar.dart';
import 'package:chatapp/pages/call_page.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/three_page.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/group/group_service.dart';
import 'package:chatapp/pages/group_chat_page.dart';

class GroupHomePage extends StatefulWidget {
  const GroupHomePage({super.key});

  @override
  _GroupHomePageState createState() => _GroupHomePageState();
}

class _GroupHomePageState extends State<GroupHomePage> {
  final GroupService _groupService = GroupService();
  final Set<String> _selectedGroups = {}; // Track selected groups
  bool _isEditing = false; // Track edit mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      appBar: AppBar(
        title: const Text('Groups'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedGroups,
            ),
          IconButton(
            icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _groupService.getAllGroupsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No groups available'));
          }

          final groups = snapshot.data!;
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              var group = groups[index];
              String groupId = group['id'] as String; // Default value if null
              String groupName = group['name'] ?? 'Unnamed Group'; // Default value if n

              return Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(top: 5, bottom: 0, left: 8, right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: ListTile(
                  leading: _isEditing
                      ? Checkbox(
                    value: _selectedGroups.contains(groupId),
                    onChanged: (selected) {
                      setState(() {
                        if (selected ?? false) {
                          _selectedGroups.add(groupId);
                        } else {
                          _selectedGroups.remove(groupId);
                        }
                      });
                    },
                  )
                      : null,
                  title: Text(groupName, style: const TextStyle(fontSize: 20)),
                  onTap: () {
                    if (_isEditing) {
                      setState(() {
                        if (_selectedGroups.contains(groupId)) {
                          _selectedGroups.remove(groupId);
                        } else {
                          _selectedGroups.add(groupId);
                        }
                      });
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupChatPage(groupChatID: groupId),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      // bottomNavigationBar: CustomBottomAppBar(
      //   selectedIndex: 2,
      //   onItemSelected: (index) {
      //     _navigateToPage(context, index);
      //   },
      // ),
    );
  }


  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => CallPage()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const GroupHomePage()));
        break;
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      _selectedGroups.clear(); // Clear selection on mode change
    });
  }

  void _deleteSelectedGroups() async {
    if (_selectedGroups.isEmpty) return;

    // Perform the delete operation
    await _groupService.deleteGroups(_selectedGroups.toList());

    setState(() {
      _selectedGroups.clear();
      _isEditing = false;
    });
  }
}
