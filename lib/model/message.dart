import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String senderDisplayName;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String type;

  Message ({
    required this.senderID,
    required this.senderEmail,
    required this.senderDisplayName,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    required this.type,
  });

  // Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'senderDisplayName' : senderDisplayName,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'type': type,
    };
  }
}