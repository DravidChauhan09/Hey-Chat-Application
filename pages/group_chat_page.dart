import 'dart:io';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/services/group/group_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GroupChatPage extends StatefulWidget {
  final String groupChatID;

  const GroupChatPage({super.key, required this.groupChatID});

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService();
  late final TextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();
  late Future<String> _groupNameFuture;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _groupNameFuture = _groupService.getGroupName(widget.groupChatID);

    // Listen for keyboard focus to scroll
    _messageController.addListener(() {
      if (_messageController.text.isNotEmpty) {
        Future.delayed(
          const Duration(milliseconds: 100),
              () => _scrollToBottom(),
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String messageText = _messageController.text;
      _messageController.clear();

      try {
        String senderID = getCurrentUserEmail();
        await _groupService.sendGroupMessage(widget.groupChatID, senderID, messageText);
        scrollDown();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    }
  }

  String getCurrentUserEmail() {
    var user = _authService.getCurrentUser();
    return user?.email ?? 'Unknown'; // Use a default value if null
  }

  Future<void> sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        scrollDown();
        await _groupService.sendGroupImageMessage(
            widget.groupChatID, File(pickedFile.path), getCurrentUserEmail());
        setState(() {
          _isUploading = false;
        });
        _scrollToBottom();
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to send image')));
      }
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await _groupService.deleteGroupMessage(widget.groupChatID, messageId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete message')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: FutureBuilder<String>(
          future: _groupNameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text('Group Chat');
            } else {
              return Text(snapshot.data!);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _groupService.getGroupMessagesStream(widget.groupChatID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages'));
                }

                var messages = snapshot.data!;
                messages = messages.reversed.toList(); // Reverse the messages

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    String messageId = message['id'] ?? 'Unknown';
                    String messageContent = message['message'] ?? '';
                    String senderID = message['senderID'] ?? 'Unknown';
                    String currentUserEmail = getCurrentUserEmail();
                    String imageUrl = message['imageUrl'] ?? ''; // Get the imageUrl if available

                    bool isCurrentUser = senderID == currentUserEmail;

                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Message'),
                            content: const Text('Are you sure you want to delete this message?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await _deleteMessage(messageId);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (imageUrl.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Image.network(
                                        imageUrl,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.error), // Handle image loading errors
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(
                                              child: CircularProgressIndicator());
                                        },
                                      ),
                                    ),
                                  Text(
                                    messageContent,
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Theme.of(context).colorScheme.primary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    senderID,
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.white70
                                          : Theme.of(context).colorScheme.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isUploading)
            const Center(child: CircularProgressIndicator()), // Show CircularProgressIndicator when uploading
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
