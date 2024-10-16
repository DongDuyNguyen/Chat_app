
import 'package:flutter/material.dart';
import 'package:my_chat_app/auth/auth_service.dart';
import 'package:provider/provider.dart';

import '../components/button.dart';
import '../components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // sign up user
  void signUp() async {
    if (passwordTextController.text != confirmPasswordTextController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords don't match!"),
        ),
      );
      return ; 
    }

    // get auth service
    final authService = Provider.of<Authservice>(context, listen: false);

    try {
      // create the user
      await authService.signUpWithEmailAndPassword(
        emailTextController.text,
        passwordTextController.text,
        displayName: usernameTextController.text,
      );

    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString()
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                const Icon(
                  Icons.message,
                  size: 100,
                ),

                const SizedBox(height: 25),

                //Wellcome Back Message
                Text(
                  "Let's create an account for you",
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 25),

                
                //email textField
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Thêm một TextField cho tên người dùng
                MyTextField(
                  controller: usernameTextController,
                  hintText: 'Username',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //password textFiled
                MyTextField(
                  controller: passwordTextController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //confirm password textFiled
                MyTextField(
                  controller: confirmPasswordTextController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                //sign up button
                MyButton(
                  onTap: signUp,
                  text: 'Sign Up',
                ),
                const SizedBox(height: 15),
                //go to register page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        " Login now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
