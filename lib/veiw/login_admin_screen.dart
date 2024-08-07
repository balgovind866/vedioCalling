
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
import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

import '../widgets/loading_indicator.dart';
import 'go_live_screen.dart';

import 'no_live_vedio_page.dart';


class LoginAdminScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginAdminScreen({Key? key}) : super(key: key);

  @override
  State<LoginAdminScreen> createState() => _LoginAdminScreenState();
}

class _LoginAdminScreenState extends State<LoginAdminScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  bool _isLoading = false;

  loginUser() async {
    setState(() {
      _isLoading = true;
    });
    bool res = await _authMethods.loginUser(
      context,
      _emailController.text,
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
       showSnackBar(context, 'Please login with admin email and password');
       Navigator.pop(context);
     }

    }
  }

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
          : Responsive(
        child: SingleChildScrollView(
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
                CustomButton(onTap: loginUser, text: 'Log In'),
                // const SizedBox(
                //   height: 20,
                // ),
                // CustomButton2(
                //
                //   image: 'assets/google_logo-google_icongoogle-512.png',
                //    onTap: signInWithGoogle , text: 'Sign in/Sign Up with Google',
                //
                // ),
                // const SizedBox(
                //   height: 20,
                // ),
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
      ),
    );
  }
}
