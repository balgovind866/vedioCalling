import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thebear/veiw/login_screen.dart';

import '../boadCosting/broadcast_page.dart';
import '../models/livestream.dart';
import '../resource/auth.dart';
import '../resource/firestore_methods.dart';
import '../veiw/go_live_screen.dart';
import '../veiw/no_live_vedio_page.dart';
import 'loading_indicator.dart';
import '../providers/user_provider.dart';

import 'custom_textfield.dart';
import 'loading_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class Chat extends StatefulWidget {
  final String channelId;
  const Chat({
    Key? key,
    required this.channelId,
  }) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _chatController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  bool _isLoading = false;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
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
        Stream<QuerySnapshot> stream = FirebaseFirestore.instance.collection('livestream').snapshots();

        await for (var snapshot in stream) {
          if (snapshot.docs.isNotEmpty) {
            var firstDoc = snapshot.docs.first;
            var data = firstDoc.data() as Map<String, dynamic>;
            LiveStream post = LiveStream.fromMap(data);
            //await FirestoreMethods().updateViewCount(post.channelId, true);

            Navigator.of(context).pushReplacement(
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LiveStreamingPage()),
            );
          }
        }
      }
    }
  }

  void _checkAuthenticationAndSendMessage(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user.username == "" && userProvider.user.email=="") {
      // User is not authenticated
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Not Participated'),
          content: Text('You need to be signed in to send messages.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                signInWithGoogle();
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              },
              child: Text('Sign In/ Sign Up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      // User is authenticated
      if (_chatController.text.trim().isNotEmpty) {
        FirestoreMethods().chat(
          _chatController.text,
          widget.channelId,
          context,
        );
        // setState(() {
        //
        // });
        _chatController.text = "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('livestream').doc(widget.channelId).collection('comments').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    // if (snapshot.connectionState == ConnectionState.waiting) {
                    //   return const LoadingIndicator();
                    // }

                    if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No messages yet'));
                    }

                    return ListView.builder(
                      reverse: true, // To display the newest message at the bottom
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var messageData = snapshot.data!.docs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                '${messageData['username']} :',
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    color: messageData['uid'] == userProvider.user.uid ? Colors.blue : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  messageData['message'],
                                  style: GoogleFonts.roboto(
                                    textStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              CustomTextField2(
                controller: _chatController,
                onTap: (val) => _checkAuthenticationAndSendMessage(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//
// class Chat extends StatefulWidget {
//   final String channelId;
//   const Chat({
//     Key? key,
//     required this.channelId,
//   }) : super(key: key);
//
//   @override
//   State<Chat> createState() => _ChatState();
// }
//
// class _ChatState extends State<Chat> {
//   final TextEditingController _chatController = TextEditingController();
//
//   @override
//   void dispose() {
//     _chatController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context);
//     final size = MediaQuery.of(context).size;
//
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SizedBox(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('livestream')
//                       .doc(widget.channelId)
//                       .collection('comments')
//                       .orderBy('createdAt', descending: true)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const LoadingIndicator();
//                     }
//
//                     if (snapshot.hasError) {
//                       return Center(child: Text('Something went wrong'));
//                     }
//
//                     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                       return Center(child: Text('No messages yet'));
//                     }
//
//                     return ListView.builder(
//                       reverse: true, // To display the newest message at the bottom
//                       itemCount: snapshot.data!.docs.length,
//                       itemBuilder: (context, index) {
//                         var messageData = snapshot.data!.docs[index];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: Row(
//                             children: [
//                               Text(
//                                 '${messageData['username']} :',
//                                 style: GoogleFonts.roboto(
//                                   textStyle: TextStyle(
//                                     color: messageData['uid'] == userProvider.user.uid ? Colors.blue : Colors.black,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 2),
//                               Flexible(
//                                 child: Text(
//                                   messageData['message'],
//                                   style: GoogleFonts.roboto(
//                                     textStyle: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.normal,
//                                     ),
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//               CustomTextField2(
//                 controller: _chatController,
//                 onTap: (val) {
//                   if (_chatController.text.trim().isNotEmpty) {
//                     FirestoreMethods().chat(
//                       _chatController.text,
//                       widget.channelId,
//                       context,
//                     );
//                     setState(() {
//                       _chatController.text = "";
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

