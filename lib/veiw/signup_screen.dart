
import 'package:flutter/material.dart';

import '../boadCosting/broadcast_page.dart';
import '../models/livestream.dart';
import '../providers/user_provider.dart';
import '../resource/auth.dart';
import '../resource/firestore_methods.dart';
import '../responsive/responsive.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/loading_indicator.dart';

import 'go_live_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'no_live_vedio_page.dart';



class SignupScreen extends StatefulWidget {
  static const String routeName = '/signup';
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  bool _isLoading = false;

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    bool res = await _authMethods.signUpUser(
      context,
      _emailController.text,
      _usernameController.text,
      _passwordController.text,
    );
    setState(() {
      _isLoading = false;
    });
    if (res) {

      final userData= Provider.of<UserProvider>(context, listen: false);
      if(userData.user.userType==true){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>GoLiveScreen()));
      } else{
        Stream<QuerySnapshot> stream = FirebaseFirestore.instance.collection('livestream').snapshots();
        await for (var snapshot in stream) {
          if (snapshot.docs.isNotEmpty) {
            var firstDoc = snapshot.docs.first;
            var data = firstDoc.data() as Map<String, dynamic>;  // Cast to non-nullable Map<String, dynamic>
            LiveStream post = LiveStream.fromMap(data);
           // await FirestoreMethods().updateViewCount(post.channelId, true);

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BroadcastPage(
                  channelId: post.channelId,
                  isBroadcaster: false,
                  channelName: 'bear',
                  userName: userData.user.userType.toString(),
                ),
              ),
            );
            break; // Exit the loop after processing the first document
          }else{
            Navigator.push(context, MaterialPageRoute(builder: (context)=>LiveStreamingPage()));
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : Responsive(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.1),
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomTextField(
                          controller: _emailController,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Username',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomTextField(
                          controller: _usernameController,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomTextField(
                          controller: _passwordController,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomButton(onTap: signUpUser, text: 'Sign Up'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
