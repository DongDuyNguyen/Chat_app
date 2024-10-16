import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authservice extends ChangeNotifier {
  // instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  final emailTextController = TextEditingController();
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();



  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Sign user in
  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    try {
      // sign in
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // add a new document for the user in users collection if it doesn't already exists
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return userCredential;
    }
    // catch any errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Create a new user
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password,
      {required String displayName}) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // cập nhật thông tin người dùng
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);

      // after creating the user, create a new document for the user in the user collection
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': displayName,
        'bio': 'Empty bio..'
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign user out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
