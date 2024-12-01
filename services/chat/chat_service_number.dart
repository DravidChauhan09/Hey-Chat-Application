import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get stream of users
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection('Users').snapshots();
  }
}
