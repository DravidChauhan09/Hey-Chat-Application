import 'package:chatapp/componet/chat_buuble.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();

  FocusNode myFocusNode = FocusNode();
  bool _isUploading = false;

  get abc => null;

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
              () => scrollDown(),
        );
      }
    });

    String currentUserID = _authService.getCurrentUser()!.uid;
    _chatService.markMessagesAsRead(currentUserID, widget.receiverID);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the received message
      // Show a dialog or notification
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
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

  Future<void> sendMessage() async {

    if (_messageController.text.isNotEmpty) {
      String messageText = _messageController.text;
      _messageController.clear();

      try {
        await _chatService.sendMessage(widget.receiverID, messageText);
        scrollDown();
      } catch (e) {
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }


    }
  }

  Future<void> sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        await _chatService.sendImageMessage(
            widget.receiverID, File(pickedFile.path));
        setState(() {
          _isUploading = false;
        });
        scrollDown();
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to send image')));
      }
    }
  }

  Future<void> editMessage(String chatRoomID, String messageId, String newText) async {
    try {
      await _chatService.updateMessage(chatRoomID, messageId, newText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to edit message')),
      );
    }
  }

  Future<void> deleteMessage(String chatRoomID, String messageId) async {
    try {
      await _chatService.deleteMessage(chatRoomID, messageId);
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
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.receiverEmail),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
          if (_isUploading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessage(widget.receiverID, senderID),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading messages"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        return ListView.builder(
          controller: _scrollController,
          itemCount: snapshot.data?.docs.length ?? 0,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            return _buildMessageItem(doc);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    Timestamp? timestamp = data["timestamp"] as Timestamp?;
    DateTime dateTime = timestamp?.toDate() ?? DateTime.now();

    return GestureDetector(
      onLongPress: () {
        _showEditDeleteOptions(doc.id, data['message'], isCurrentUser);
      },
      child: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (data['imageUrl'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  constraints: const BoxConstraints(
                    maxWidth: 150,
                    maxHeight: 150,
                  ),
                  child: Image.network(
                    data['imageUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              ChatBuuble(
                message: data["message"],
                isCurrentUser: isCurrentUser,
                timestamp: dateTime,
              )
          ],
        ),
      ),
    );
  }

  void _showEditDeleteOptions(String messageId, String currentText, bool isCurrentUser) {
    String senderID = _authService.getCurrentUser()!.uid;
    List<String> ids = [senderID, widget.receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Options'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                if (isCurrentUser)
                  ListTile(
                    title: const Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      _showEditMessageDialog(chatRoomID, messageId, currentText);
                    },
                  ),
                ListTile(
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    deleteMessage(chatRoomID, messageId);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditMessageDialog(String chatRoomID, String messageId, String currentText) {
    final _editMessageController = TextEditingController(text: currentText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(
            controller: _editMessageController,
            decoration: const InputDecoration(hintText: 'Edit your message'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                editMessage(chatRoomID, messageId, _editMessageController.text);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: sendImage,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(30), // Circular border
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary, // Border color
                  width: 1.5, // Border width
                ),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: myFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}
