import 'package:flutter/material.dart';
import 'package:my_chat_app/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSingOut;
  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSingOut,
    });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Header
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 64,
                ),
              ),

              // Home list tile
              MyListTile(
                icon: Icons.home, 
                text: 'H O M E', 
                onTap: () => Navigator.pop(context),
              ),

              // profile list tile
              MyListTile(
                icon: Icons.person,
                text: 'P R O F I L E',
                onTap: onProfileTap,
              ),
            ],
          ),

          // logout list tile
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.logout,
              text: 'L O G O U T',
              onTap: onSingOut,
            ),
          ),

        ],
      ),
    );
  }
}