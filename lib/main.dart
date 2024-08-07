
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thebear/providers/user_provider.dart';
import 'package:thebear/resource/auth.dart';
import 'package:thebear/resource/firestore_methods.dart';
import 'package:thebear/utils/utils.dart';
import 'package:thebear/veiw/go_live_screen.dart';
import 'package:thebear/veiw/login_screen.dart';
import 'package:thebear/veiw/no_live_vedio_page.dart';
import 'package:thebear/widgets/loading_indicator.dart';
import 'package:thebear/models/user.dart' as model;

import 'boadCosting/broadcast_page.dart';
import 'models/livestream.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyA_M9L_KbbX9vOBbqEUydRpgdfOl0ENtNM",
          authDomain: "yescheffood07.firebaseapp.com",
          projectId: "yescheffood07",
          storageBucket: "yescheffood07.appspot.com",
          messagingSenderId: "218457485221",
          appId: "1:218457485221:web:8cda93ce9ea90b47b2824c",
          measurementId: "G-KJE29H8SRK"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      home:  FutureBuilder(
        future: AuthMethods()
            .getCurrentUser(FirebaseAuth.instance.currentUser != null
            ? FirebaseAuth.instance.currentUser!.uid
            : null)
            .then((value) {
          if (value != null) {
            Provider.of<UserProvider>(context, listen: false).setUser(
              model.User.fromMap(value),
            );
          }
          return value;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasData) {
            final user = model.User.fromMap(snapshot.data as Map<String, dynamic>);
            if (user.userType==false) {
              // If userType is true, navigate to the AdminPage
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('livestream').snapshots(),
                builder: (context, streamSnapshot) {
                  if (streamSnapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingIndicator();
                  }

                  if (streamSnapshot.hasData && streamSnapshot.data!.docs.isNotEmpty) {
                    var firstDoc = streamSnapshot.data!.docs.first;
                    var data = firstDoc.data() as Map<String, dynamic>;
                    LiveStream post = LiveStream.fromMap(data);


                    return BroadcastPage(
                      channelId: post.channelId,
                      isBroadcaster: false,
                      channelName: 'bear',
                      userName: user.username,
                    );
                  }
                  return LiveStreamingPage();
                },
              );
            } else {
              showSnackBar(context, 'Login is not correct');

            }
          }
          // If userType is false, navigate to the HomeScreen

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('livestream').snapshots(),
            builder: (context, streamSnapshot) {
              if (streamSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              }

              if (streamSnapshot.hasData && streamSnapshot.data!.docs.isNotEmpty) {
                var firstDoc = streamSnapshot.data!.docs.first;
                var data = firstDoc.data() as Map<String, dynamic>;
                LiveStream post = LiveStream.fromMap(data);
                //FirestoreMethods().updateViewCount(post.channelId, true);

                return BroadcastPage(
                  channelId: post.channelId,
                  isBroadcaster: false,
                  channelName: 'bear',
                  userName: '',
                );
              }
              return LiveStreamingPage();
            },


          );
        },
      ),

    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('heello')),
    );
  }
}
