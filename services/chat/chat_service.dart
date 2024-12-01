import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/models/message.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  Stream<List<Map<String, dynamic>>> getUsersStream() {
    final String currentUserID = _auth.currentUser!.uid;

    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) =>
      doc['uid'] != currentUserID) // Exclude the current user
          .map((doc) {
        final user = doc.data();
        return {
          'uid': user['uid'],
          'email': user['email'],
          'profileImageUrl': user['profileImageUrl'] ??
              'https://img.freepik.com/free-psd/emoji-element-isolated_23-2150355001.jpg?t=st=1723111056~exp=1723114656~hmac=7c07c0317305b9b4b92ce11c11294eb3b288ee81cb0ed0cb7213fd974d0fe75b&w=740',
        };
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add({
      ...newMessage.toMap(),
      'isRead': false,
      'timestamp': timestamp,
    });

    // Update interactions for both users
    await _firestore.collection("Users").doc(currentUserID).update({
      'interactions': FieldValue.arrayUnion([receiverID])
    });

    await _firestore.collection("Users").doc(receiverID).update({
      'interactions': FieldValue.arrayUnion([currentUserID])
    });
  }

  Stream<List<Map<String, dynamic>>> getUsersStreamWithInteractions(
      String currentUserID) {
    return _firestore
        .collection('Users')
        .where('interactions', arrayContains: currentUserID)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data())
            .toList());
  }

  Stream<QuerySnapshot> getMessage(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> markMessagesAsRead(String userID, String otherUserID) async {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    QuerySnapshot snapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .where('receiverID', isEqualTo: userID)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Stream<int> getUnreadMessageCount(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .where('receiverID', isEqualTo: userID)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> updateMessage(String chatRoomID, String messageId,
      String newText) async {
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .doc(messageId)
        .update({
      'message': newText,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMessage(String chatRoomID, String messageId) async {
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .doc(messageId)
        .delete();
  }

  Stream<Message?> getLastMessage(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return Message.fromMap(
            snapshot.docs.first.data());
      }
      return null;
    });
  }

  Future<void> deleteUsersAndMessages(String currentUserID,
      List<String> userIDs) async {
    // Delete messages and chats for the selected users
    for (String userID in userIDs) {
      List<String> ids = [currentUserID, userID];
      ids.sort();
      String chatRoomID = ids.join('_');

      // Delete messages in the chat room
      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // Optionally, you can delete the chat room itself
      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .delete();
    }

    // Delete users from interactions array
    await _firestore.collection("Users").doc(currentUserID).update({
      'interactions': FieldValue.arrayRemove(userIDs),
    });

    for (String userID in userIDs) {
      await _firestore.collection("Users").doc(userID).update({
        'interactions': FieldValue.arrayRemove([currentUserID]),
      });
    }
  }

  Stream<List<Map<String, dynamic>>> getAllUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data())
            .toList());
  }

  Future<String> uploadImageToFirebaseStorage(File file) async {
    final ref = _storage.ref().child('chat_images').child(
        '${DateTime.now()}.jpg');
    final uploadTask = ref.putFile(file);

    // Monitor upload progress
    uploadTask.snapshotEvents.listen((taskSnapshot) {
      // This will log the progress in the console
      if (kDebugMode) {
        print('Upload progress: ${taskSnapshot.bytesTransferred}/${taskSnapshot
          .totalBytes}');
      }
    });

    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> sendImageMessage(String receiverID, File imageFile) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String imageUrl = await uploadImageToFirebaseStorage(imageFile);

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: _auth.currentUser!.email!,
      receiverID: receiverID,
      message: '',
      timestamp: Timestamp.now(),
      imageUrl: imageUrl,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    DocumentReference messageRef = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add({
      ...newMessage.toMap(),
      'isRead': false,
      'status': 'sending', // Initial status is 'sending'
    });

    // Update the status to 'sent' after a delay or upon successful upload
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .doc(messageRef.id)
        .update({'status': 'sent'});
  }

  Stream<bool> getActiveStatus(String userID) {
    // Replace with actual implementation to get active status
    return FirebaseFirestore.instance
        .collection('statuses')
        .doc(userID)
        .snapshots()
        .map((snapshot) {
      final timestamp = snapshot['timestamp'] as Timestamp?;
      if (timestamp == null) return false;
      final statusDate = timestamp.toDate();
      final now = DateTime.now();
      return now
          .difference(statusDate)
          .inHours < 24; // Example: active if within the last 24 hours
    });
  }
}
