
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thebear/veiw/signup_screen.dart';
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

import 'no_live_vedio_page.dart';


class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  bool _isLoading = false;

  // loginUser() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   bool res = await _authMethods.loginUser(
  //     context,
  //     _emailController.text,
  //     _passwordController.text,
  //   );
  //   setState(() {
  //     _isLoading = false;
  //   });
  //   if (res) {
  //    final userData= Provider.of<UserProvider>(context, listen: false);
  //    if(userData.user.userType==true){
  //      Navigator.push(context, MaterialPageRoute(builder: (context)=>GoLiveScreen()));
  //    } else{
  //      Stream<QuerySnapshot> stream = FirebaseFirestore.instance.collection('livestream').snapshots();
  //      await for (var snapshot in stream) {
  //        if (snapshot.docs.isNotEmpty) {
  //          var firstDoc = snapshot.docs.first;
  //          var data = firstDoc.data() as Map<String, dynamic>;  // Cast to non-nullable Map<String, dynamic>
  //          LiveStream post = LiveStream.fromMap(data);
  //         // await FirestoreMethods().updateViewCount(post.channelId, true);
  //
  //          Navigator.of(context).push(
  //            MaterialPageRoute(
  //              builder: (context) => BroadcastPage(
  //                channelId: post.channelId,
  //                isBroadcaster: false,
  //                channelName: 'bear',
  //                userName: userData.user.userType.toString(),
  //              ),
  //            ),
  //          );
  //          break; // Exit the loop after processing the first document
  //        }else{
  //          Navigator.push(context, MaterialPageRoute(builder: (context)=>LiveStreamingPage()));
  //        }
  //      }
  //    }
  //
  //   }
  // }

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    bool res = await _authMethods.signInWithGoogle(context);

    setState(() {
      _isLoading = false;
    });

    if (res) {
      final userData = Provider.of<UserProvider>(context, listen: false);
      if (userData.user.userType == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GoLiveScreen()),
        );
      } else {
        Stream<QuerySnapshot> stream = FirebaseFirestore.instance.collection('livestream').snapshots();

        await for (var snapshot in stream) {
          if (snapshot.docs.isNotEmpty) {
            var firstDoc = snapshot.docs.first;
            var data = firstDoc.data() as Map<String, dynamic>;
            LiveStream post = LiveStream.fromMap(data);
            //await FirestoreMethods().updateViewCount(post.channelId, true);

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
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LiveStreamingPage()),
            );
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xffAAAAAA),
      appBar: AppBar(
        // title: const Text(
        //   'Login',
        // ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Center(
                    child: Container(

                    height: 150,


                      child:Image.asset(
                        'assets/image 3.png',

                      ),

                    ),
                  ),
                  SizedBox(height: 30),

                  CustomButton2(

                    image: 'assets/google_logo-google_icongoogle-512.png',
                     onTap: signInWithGoogle , text: 'Sign in/Sign Up with Google',

                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //
                  // CustomButton(
                  //     onTap: () {
                  //       Navigator.push(context, MaterialPageRoute(builder: (context)=>SignupScreen()));
                  //     },
                  //     text: 'Sign Up'),
                ],
              ),
            ),
          ),
    );
  }
}
