import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../boadCosting/broadcast_page.dart';
import '../providers/user_provider.dart';
import '../resource/firestore_methods.dart';
import '../responsive/responsive.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/custom_button.dart';


class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({Key? key}) : super(key: key);

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final TextEditingController _titleController = TextEditingController();
  Uint8List? image;

  bool _isBroadcaster = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  goLiveStream() async {
    setState(() {
      _isLoading = true;
    });

    final user = Provider.of<UserProvider>(context, listen: false);

    if(_isBroadcaster==true){
      String channelId = await FirestoreMethods().startLiveStream(context, _titleController.text,);
      if (channelId.isNotEmpty) {
        showSnackBar(context, 'Livestream has started successfully!');
        Navigator.of(context).push(


          MaterialPageRoute(
            builder: (context) => BroadcastPage(
              channelId: channelId,
              isBroadcaster: _isBroadcaster,
              channelName:'bear', userName: user.user.username.toString() ,
            ),
          ),
        );
      }
    } else{

    }


    setState(() {
      _isLoading = false;
    });




  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Responsive(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          // Uint8List? pickedImage = await pickImage();
                          // if (pickedImage != null) {
                          //   setState(() {
                          //     image = pickedImage;
                          //   });
                          // }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22.0,
                            vertical: 20.0,
                          ),
                          child: image != null
                              ? SizedBox(
                                  height: 300,
                                  child: Image.memory(image!),
                                )
                              : DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(10),
                                  dashPattern: const [10, 4],
                                  strokeCap: StrokeCap.round,
                                  color: Colors.black54,
                                  child: Container(
                                    width: double.infinity,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.black54.withOpacity(.05),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.folder_open,
                                          color: buttonColor,
                                          size: 40,
                                        ),
                                        const SizedBox(height: 15),
                                        Text(
                                          'Select your thumbnail',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),

                    ],
                  ),

                  // Container(
                  //   width: MediaQuery.of(context).size.width * 0.65,
                  //   padding: EdgeInsets.symmetric(vertical: 10),
                  //   child: SwitchListTile(
                  //       title:
                  //            Text('Broadcaster'),
                  //
                  //       value: _isBroadcaster,
                  //       activeColor: Colors.black54,
                  //       secondary: _isBroadcaster
                  //           ? Icon(
                  //         Icons.account_circle,
                  //         color: Colors.black54.withOpacity(.05),
                  //       )
                  //           : Icon(Icons.account_circle),
                  //       onChanged: (value) {
                  //
                  //       }),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: _isLoading ? CircularProgressIndicator():CustomButton(
                      text: 'Go Live!',
                      onTap: goLiveStream,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
