import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/model/message.dart';

class ChatService extends ChangeNotifier {
  // Get instance of auth and firebstore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send Message
  Future<void> sendMessage(String receiverId, String message) async {
    // get current user info
    final String currentUserID = _firebaseAuth.currentUser!.uid;
    final String currentUserName = _firebaseAuth.currentUser!.displayName.toString();
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID, 
      senderEmail: currentUserEmail,
      senderDisplayName: currentUserName,
      receiverID: receiverId, 
      message: message, 
      timestamp: timestamp,
      type: 'text',
      );

    // construct chat room id from current user id and receiver id (sort to ensure uniquess)
    List<String> ids = [currentUserID, receiverId];
    ids.sort(); // sort the ids (this ensure the chat room id is always the same for any pair of people)
    String chatRoomId = ids.join("_"); // combine the ids into a single string to use as a chatroomID

    // add new message to database
    await _firestore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .add(newMessage.toMap());
  }

  Future<void> sendImage(String receiverId, String imageUrl) async {
    final String currentUserID = _firebaseAuth.currentUser!.uid;
    final String currentUserName =
        _firebaseAuth.currentUser!.displayName.toString();
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    Message newImageMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      senderDisplayName: currentUserName,
      receiverID: receiverId,
      message: imageUrl,
      timestamp: timestamp,
      type: 'img',
    );

    List<String> ids = [currentUserID, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newImageMessage.toMap());
  }

  Future<void> sendFile(String receiverId, File file) async {
    final String currentUserID = _firebaseAuth.currentUser!.uid;
    final String currentUserName =
        _firebaseAuth.currentUser!.displayName.toString();
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    Message newFileMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      senderDisplayName: currentUserName,
      receiverID: receiverId,
      message:
          file.path, // Store the file path as the message for identification
      timestamp: timestamp,
      type: 'file',
    );

    List<String> ids = [currentUserID, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newFileMessage.toMap());
  }

  // Get message
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // construct chat room id from user ids (sorted to ensure it matches the id used when sending messages)
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots();
  }
}