import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/components/comment.dart';
import 'package:my_chat_app/components/comment_button.dart';
import 'package:my_chat_app/components/delete_button.dart';
import 'package:my_chat_app/components/like_button.dart';
import 'package:my_chat_app/helper/helper.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  final String imageUrl;

  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.time,
    required this.postId,
    required this.likes,
    required this.imageUrl,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  //comment text controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.displayName);
  }

  //tonggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // Access the document is firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.postId);

    if (isLiked) {
      // If the post is now liked, add the user's name to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.displayName])
      });
    } else {
      // If the post is now unliked, remove the user's name from the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.displayName])
      });
    }
  }

  // add a comment
  void addComment(String commentText) {
    //write the comment to firestore under the comments collection for this post
    FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.displayName,
      "CommentTime": Timestamp.now() // remember to format this when displaying
    });
  }

//show a dialog box for adding comment
  void showCommentDiaLog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: InputDecoration(hintText: "Write a comment..."),
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //clear controller
              _commentTextController.clear();
            },
            child: Text("Cancel"),
          ),
          // post button
          TextButton(
            onPressed: () {
              //add comment
              addComment(_commentTextController.text);

              //pop box
              Navigator.pop(context);

              //clear controller
              _commentTextController.clear();
            },
            child: Text("Post"),
          ),
        ],
      ),
    );
  }

  void deletePost() {
    // show a dialog box asking for confirmation before deleting the post
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          // Delete button
          TextButton(
            onPressed: () async {
              // delete the comments from firestore first
              // if u only delete the post, the comments will be stored in firestore
              final commentDocs = await FirebaseFirestore.instance
                  .collection("posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .get();

              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection("posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }

              // then delete the post
              FirebaseFirestore.instance
                  .collection("posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("post deleted"))
                  .catchError(
                      (error) => print("failed to delete post: $error"));

              // dismiss the dialog
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // wallpost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // group of text (message + username)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // message
                  Text(widget.message),

                  const SizedBox(height: 5),

                  // Display image if available
                  if (widget.imageUrl.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      constraints: BoxConstraints(
                          maxHeight: 410), // Adjust the maxHeight as needed
                      child: Center(
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  // user
                  Row(
                    children: [
                      Text(
                        widget.user,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        ".",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        widget.time,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],
              ),

              // delete button
              if (widget.user == currentUser.displayName)
                DeleteButton(onTap: deletePost),
            ],
          ),

          const SizedBox(height: 20),

          // Button
          Row(
            children: [
              Column(
                children: [
                  //like button
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),
                  const SizedBox(height: 5),

                  //like count
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              // Comment
              Column(
                children: [
                  //comment button
                  CommentButton(
                    onTap: showCommentDiaLog,
                  ),
                  const SizedBox(height: 5),

                  //comment count
                  Text(
                    '',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // comments under the post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              // show loading circle if no data yet
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView(
                shrinkWrap: true, // for nested lists
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  //get the comment
                  final commentData = doc.data() as Map<String, dynamic>;

                  //return the comment
                  return Comment(
                    text: commentData["CommentText"],
                    user: commentData["CommentedBy"],
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
