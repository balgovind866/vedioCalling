import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';



import 'package:provider/provider.dart';

import 'package:thebear/models/user.dart' as model;


import '../providers/user_provider.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'dart:js' as js;

import '../utils/utils.dart';

class AuthMethods {
  final _userRef = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>?> getCurrentUser(String? uid) async {
    if (uid != null) {
      try {
        final snap = await _userRef.doc(uid).get();
        return snap.data();
      } catch (e) {
        print("Error fetching user data: $e");
        return null;
      }
    }
    return null;
  }



  Future<bool> signUpUser(
      BuildContext context,
      String email,
      String username,
      String password,
      ) async {
    bool res = false;
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (cred.user != null) {
        model.User user = model.User(
          userType: false,
          username: username.trim(),
          email: email.trim(),
          uid: cred.user!.uid,
          profilePicture: '',
        );
        await _userRef.doc(cred.user!.uid).set(user.toMap());
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return res;
  }

  Future<bool> loginUser(
      BuildContext context,
      String email,
      String password,
      ) async {
    bool res = false;
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        final userData = await getCurrentUser(cred.user!.uid);
        if (userData != null) {
          Provider.of<UserProvider>(context, listen: false).setUser(
            model.User.fromMap(userData),
          );
          res = true;
        } else {
          print("Failed to fetch user data");
        }
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return res;
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final userData = await getCurrentUser(userCredential.user!.uid);
        if (userData != null) {
          Provider.of<UserProvider>(context, listen: false).setUser(
            model.User.fromMap(userData),
          );
        } else {
          // Create a new user document if it doesn't exist
          model.User newUser = model.User(
            userType: false, // Set appropriate user type
            username: googleUser.displayName ?? googleUser.email.split('@')[0],
            email: googleUser.email,
            uid: userCredential.user!.uid,
            profilePicture: googleUser.photoUrl,

          );
          await _userRef.doc(userCredential.user!.uid).set(newUser.toMap());
          Provider.of<UserProvider>(context, listen: false).setUser(newUser);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing in with Google: $e');
      showSnackBar(context, 'Error signing in with Google: $e');
      return false;
    }


  }

  Future<bool> signOut(BuildContext context) async {


    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      Provider.of<UserProvider>(context, listen: false).resetUser();
      showSnackBar(context, 'Successfully signed out');
      return true;
    } catch (e) {
      print('Error signing out: $e');
      showSnackBar(context, 'Error signing out: $e');
      return false;
    }
  }



}


