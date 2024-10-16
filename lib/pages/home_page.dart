import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:my_chat_app/pages/post_page.dart';
import 'package:my_chat_app/pages/contact_page.dart';
import 'package:my_chat_app/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int currentIndex = 0;

  void goToPage(index) {
    setState(() {
      currentIndex = index;
    });
  }

  
  final List _pages = [
    const ContactPage(),
    const PostPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
        //title: Text('Chat App', style: TextStyle(color: Colors.white)),
        //backgroundColor: Colors.blue,
      //),
      body: _pages[currentIndex], // <-- Removed the parameter here
      bottomNavigationBar: Container(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          child: GNav(
            backgroundColor: Colors.blue,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.blue.shade200,
            gap: 8,
            onTabChange: (index) => goToPage(index),
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: Icons.message_outlined,
                text: 'Chat',
              ),
              GButton(
                icon: Icons.bookmark,
                text: 'Post',
              ),
              GButton(
                icon: Icons.account_circle_sharp,
                text: 'User Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
