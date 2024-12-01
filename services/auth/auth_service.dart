import 'package:chatapp/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'login_or_register.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure user info is updated if it doesn't already exist
      DocumentReference userDoc = _firestore.collection("Users").doc(userCredential.user!.uid);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        await userDoc.set({
          'uid': userCredential.user!.uid,
          'email': email,
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign up
  Future<UserCredential> signUpWithEmailPassword(String email, String password, String phoneNumber) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user info to Firestore
      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'phone': phoneNumber, // Save phone number
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign out
  // Sign out from Firebase and other services
  Future<void> signOut() async {
    try {
      await _auth.signOut(); // Sign out from Firebase

      // Sign out from Google if using Google Sign-In
      // await GoogleSignIn().signOut();

      // Sign out from Facebook if using Facebook login
      // await FacebookAuth.instance.logOut();
      
    } catch (e) {
      print('Error during sign out :::::::::::::::::::::::::::::::::::: $e');
    }
  }

}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AuthService {
//   // instance of auth and fireftore
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // get current user
//   User? getCurrentUser(){
//     return _auth.currentUser;
//   }
//
//   // sign in
//   Future<UserCredential> signInWithEmailPassword(String email, password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//
//       // save user info to if it dosn`t already exist
//       _firestore.collection("Users").doc(userCredential.user!.uid).set({
//         'uid': userCredential.user!.uid,
//         'email' : email ,
//       });
//
//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.code);
//     }
//   }
//
//   // sign up
//   Future<UserCredential> signUpWithEmailPassword(String email, password, String text) async {
//     try {
//       UserCredential userCredential = await _auth
//           .createUserWithEmailAndPassword(email: email, password: password,);
//
//       // save user info to seperate document
//       _firestore.collection("Users").doc(userCredential.user!.uid).set({
//         'uid': userCredential.user!.uid,
//         'email' : email ,
//       });
//
//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.code);
//     }
//   }
//
//   // sign out
//   Future<void> signOut() async {
//     return await _auth.signOut();
//   }
//
// //error
// }
