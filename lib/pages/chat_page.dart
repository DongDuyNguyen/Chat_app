import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat_app/chat/chat_service.dart';
import 'package:my_chat_app/components/chat_bubble.dart';
import 'package:my_chat_app/components/text_field.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserName;
  final String receiverUserID;

  const ChatPage({
    super.key,
    required this.receiverUserName,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool isImageSelected = false;

  File? imageFile;

  // select image
  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        setState(() {
          isImageSelected = true;
        });
        uploadImage();
      }
    });
  }

  // Upload Image
  Future uploadImage() async {
    String fileName = Uuid().v1();

    var ref = FirebaseStorage.instance
        .ref()
        .child('imagesChat')
        .child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!);

    String imageUrl = await uploadTask.ref.getDownloadURL();

    await _chatService.sendImage(
      widget.receiverUserID,
      imageUrl,
    );

    setState(() {
      isImageSelected = false;
    });

    print(imageUrl);
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverUserID,
        _messageController.text,
      );
      _messageController.clear();
    }
  }

  Future<void> getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      uploadFile(file);
    }
  }

  Future<void> uploadFile(File file) async {
    String fileName = Uuid().v1();

    var ref = FirebaseStorage.instance
        .ref()
        .child('filesChat')
        .child("$fileName.${file.path.split('.').last}");

    var uploadTask = await ref.putFile(file);

    String fileUrl = await uploadTask.ref.getDownloadURL();

    await _chatService.sendFile(
      widget.receiverUserID,
      file,
    );

    print(fileUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.receiverUserName)), // Text(widget.receiverUserName) sau khi có user thì thêm phần này
      body: Column(
        children: [
          // messages
          Expanded(
            child: _buildMessageList(),
          ),

          // user input
          _buildMessageInput(),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  // Build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Align the messages to the right if the sender is the current user, otherwise to the left
    var alignment = (data['senderID'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    if (data['type'] == 'text') {
      return Container(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment:
                (data['senderID'] == _firebaseAuth.currentUser!.uid)
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            mainAxisAlignment:
                (data['senderID'] == _firebaseAuth.currentUser!.uid)
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              Text(data['senderDisplayName']),
              const SizedBox(
                height: 5,
              ),
              ChatBubble(message: data['message']),
            ],
          ),
        ),
      );
    } else if (data['type'] == 'img') {
      // Hiển thị hình ảnh
      return Container(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment:
                (data['senderID'] == _firebaseAuth.currentUser!.uid)
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            mainAxisAlignment:
                (data['senderID'] == _firebaseAuth.currentUser!.uid)
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              Text(data['senderDisplayName']),
              const SizedBox(
                height: 5,
              ),
              // Sử dụng widget mới để hiển thị hình ảnh nếu có
              isImage(data['type'])
                  ? GestureDetector(
                      onTap: () {
                        // Hiển thị hình ảnh toàn màn hình khi nhấn vào
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ShowImage(imageUrl: data['message']),
                          ),
                        );
                      },
                      child: Container(
                        height:
                            150, // Điều chỉnh kích thước hình ảnh theo ý muốn
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(data['message']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : ChatBubble(message: data['message']),
            ],
          ),
        ),
      );
    } else if (data['type'] == 'file') {
      return Container(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment:
                (data['senderID'] == _firebaseAuth.currentUser!.uid)
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            mainAxisAlignment:
                (data['senderID'] == _firebaseAuth.currentUser!.uid)
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              Text(data['senderDisplayName']),
              const SizedBox(
                height: 5,
              ),
              // Display a clickable link to open the file
              GestureDetector(
                onTap: () {
                  // Handle opening the file or navigate to a file viewer
                  // You can use the file path stored in data['message']
                  // Example: OpenFile.open(data['message']);
                },
                child: Text(
                  "File: ${data['message'].split('/').last}", // Display the file name
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container();
  }

  // Build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          // Thêm IconButton để chọn hình ảnh
          IconButton(
            onPressed: () => getImage(),
            icon: Icon(
              Icons.image,
              size: 30,
              color: isImageSelected ? Colors.blue : Colors.grey,
            ),
          ),

          // Add IconButton to pick a file
          IconButton(
            onPressed: () => getFile(),
            icon: Icon(
              Icons.attach_file,
              size: 30,
              color: isImageSelected ? Colors.blue : Colors.grey,
            ),
          ),

          // textfield
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: 'Enter message here..',
              obscureText: false,
            ),
          ),
          // send button
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}

bool isImage(String type) {
  // Kiểm tra nếu là hình ảnh
  return type == 'img';
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}
