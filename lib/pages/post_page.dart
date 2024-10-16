import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat_app/auth/auth_service.dart';
import 'package:my_chat_app/components/drawer.dart';
import 'package:my_chat_app/components/text_field.dart';
import 'package:my_chat_app/components/wall_posts.dart';
import 'package:my_chat_app/helper/helper.dart';
import 'package:my_chat_app/pages/profile_page.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostpageState();
}

class _PostpageState extends State<PostPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final textController = TextEditingController();
  File? selectedImage;

  // Post message
  void postMessage() async {
    String postText = textController.text;
    String imageUrl = ""; // Default empty string for text-only posts

    if (selectedImage != null) {
      // If an image is selected, upload it to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance
          .ref()
          .child('postsImage')
          .child('image_$timestamp.jpg');

      await ref.putFile(selectedImage!);
      imageUrl = await ref.getDownloadURL();
    }

    // Store post details in Firestore
    FirebaseFirestore.instance.collection("posts").add({
      'UserName': currentUser.displayName,
      'Message': postText,
      'Timestamp': Timestamp.now(),
      'Likes': [],
      'ImageUrl': imageUrl,
    });

    // Clear text input and selected image after posting
    textController.clear();
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
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

  void signOut() {
    final authService = Provider.of<Authservice>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSingOut: signOut,
      ),
      backgroundColor: Colors.grey.shade300,
      body: Center(
        child: Column(
          children: [
            //
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final username = userData['username'];
                  return Text("Logged in as: $username");
                } else {
                  return Text("Logged in as: Loading...");
                }
              },
            ),
            //
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  // Image picker button
                  IconButton(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                  ),
                  Expanded(
                    child: MyTextField(
                      controller: textController,
                      hintText: 'Write your post..',
                      obscureText: false,
                    ),
                  ),
                  // post button
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(Icons.arrow_circle_right_outlined),
                  )
                ],
              ),
            ),
            //
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .orderBy(
                      "Timestamp",
                      descending: false,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        return WallPost(
                          message: post['Message'],
                          user: post['UserName'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['Timestamp']),
                          imageUrl: post['ImageUrl'] ?? "",
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error:${snapshot.error}'),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
