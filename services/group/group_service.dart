import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> createGroupChat(List<String> userIDs, String groupName) async {
    DocumentReference groupRef = _firestore.collection('groups').doc();
    await groupRef.set({
      'name': groupName,
      'members': userIDs,
      'createdAt': FieldValue.serverTimestamp(),
    });
    for (String userID in userIDs) {
      await _firestore.collection('users').doc(userID).collection('groups').doc(groupRef.id).set({
        'groupName': groupName,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
    return groupRef.id;
  }

  Future<List<Map<String, dynamic>>> getAllGroups() async {
    QuerySnapshot snapshot = await _firestore.collection('groups').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Stream<List<Map<String, dynamic>>> getAllGroupsStream() {
    return _firestore.collection('groups').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Ensure this matches the Firestore document ID
          'name': doc.data()['name'] ?? 'Unnamed Group',
        };
      }).toList();
    });
  }

  Future<void> sendGroupMessage(String groupChatID, String senderID, String message, {String? imageUrl}) async {
    try {
      String messageId = _firestore.collection('group_chat_room').doc(groupChatID).collection('messages').doc().id;

      Map<String, dynamic> messageData = {
        'senderID': senderID,
        'message': message,
        'imageUrl': imageUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('group_chat_room').doc(groupChatID).collection('messages').doc(messageId).set(messageData);
    } catch (e) {

      if (kDebugMode) {
        print('Error sending group message: $e');
      }
      throw Exception('Error sending group message');
    }
  }

  Future<String> getGroupName(String groupChatID) async {
    try {
      DocumentSnapshot groupSnapshot = await _firestore
          .collection('groups')
          .doc(groupChatID)
          .get();

      if (groupSnapshot.exists) {
        Map<String, dynamic>? groupData = groupSnapshot.data() as Map<String, dynamic>?;
        return groupData?['name'] ?? ' ';
      } else {
        return 'Group not found';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching group name: $e');
      }
      return 'Error fetching name';
    }
  }

  Stream<List<Map<String, dynamic>>> getGroupMessagesStream(String groupChatID) {
    return _firestore
        .collection('group_chat_room')
        .doc(groupChatID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> deleteGroupMessage(String groupChatID, String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('group_chat_room')
          .doc(groupChatID)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }


  Future<void> deleteGroups(List<String> groupIds) async {
    WriteBatch batch = _firestore.batch();

    for (String groupId in groupIds) {
      DocumentReference groupRef = _firestore.collection('groups').doc(groupId);
      batch.delete(groupRef);

      // Optionally, delete group messages if needed
      QuerySnapshot messagesSnapshot = await _firestore.collection('groups').doc(groupId).collection('messages').get();
      for (DocumentSnapshot messageDoc in messagesSnapshot.docs) {
        batch.delete(messageDoc.reference);
      }
    }

    await batch.commit();
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    DocumentReference groupRef = _firestore.collection('groups').doc(groupId);
    DocumentSnapshot groupDoc = await groupRef.get();
    List<dynamic> members = groupDoc['members'] ?? [];

    members.removeWhere((member) => member == userId);
    await groupRef.update({'members': members});
  }

  // Method to send an image message
  Future<String> sendGroupImageMessage(String groupChatID, File imageFile, String senderID) async {
    try {
      String fileName = basename(imageFile.path);
      Reference storageRef = _storage.ref().child('group_chat_images/$groupChatID/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Send the message with the image URL
      await sendGroupMessage(groupChatID, senderID, '', imageUrl: downloadUrl);

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending group image message: $e');
      }
      throw Exception('Error sending group image message');
    }
  }

}
