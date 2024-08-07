import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../boadCosting/broadcast_page.dart';
import '../models/livestream.dart';
import '../providers/user_provider.dart';
import '../resource/auth.dart';
import '../veiw/no_live_vedio_page.dart';
import 'loading_indicator.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black54.withOpacity(.3),
      title: Row(
        children: [
          Image.asset(
            'assets/image 3.png',
            width: 200,
            height: 40,
          ),
          Spacer(),


          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              // Implement messages functionality
            },
          ),
          SizedBox(width: 10),
          Consumer<UserProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<int>(
                onSelected: (value)  async{
                  if (value == 0) {
                    // Implement log out functionality
                    bool success = await AuthMethods().signOut(context);
                    if (success) {
                      StreamBuilder<QuerySnapshot>(
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


                      ); // Navigate back to the previous page
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Text("Log Out"),
                  ),
                ],
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  backgroundImage: NetworkImage(
                      '${provider.user.profilePicture}'),
                ),
              );
            },
          ),
        ],
      ),
      actions: [],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
