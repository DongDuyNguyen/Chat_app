import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/auth/auth_service.dart';
import 'package:my_chat_app/pages/chat_page.dart';
import 'package:my_chat_app/pages/profile_page.dart';
import 'package:my_chat_app/widgets/chat_user_card.dart';
import 'package:provider/provider.dart';

import '../components/drawer.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({
    super.key,
  });

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signOut() {
    final authService = Provider.of<Authservice>(context, listen: false);
    authService.signOut();
  }

  void goToProfilePage() {
    // pop menu drawer
    Navigator.pop(context);

    // Go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSingOut: signOut,
      ),
      body: _buildUserList(),
    );
  }

  // Build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading..');
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  // build individual user list items
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (_auth.currentUser!.email != data['email']) {
      String? username = data['username'];

      if (username != null) {
        return UserCard(
          username: username,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverUserName: data['username'],
                  receiverUserID: data['uid'],
                ),
              ),
            );
          },
        );
      } else {
        // Handle the case where 'Username' is null.
        return Container();
      }
    } else {
      return Container();
    }
  }
}
