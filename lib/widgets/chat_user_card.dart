import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String username;
  final VoidCallback onTap;

  const UserCard({
    required this.username,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          // Add logic to display user avatar (e.g., from network or local assets)
          child: Icon(Icons.person),
        ),
        title: Text(username),
        subtitle: const Text('Online'), // Add online status or other details
        onTap: onTap,
        // Add any other customization you need for the user card
      ),
    );
  }
}
