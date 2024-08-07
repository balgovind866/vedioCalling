import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_provider.dart';
import '../resource/firestore_methods.dart';
import '../widgets/app_bar.dart';
import '../widgets/chat.dart';
import 'meassaging_page.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'package:google_fonts/google_fonts.dart';




import 'package:provider/provider.dart';

class BroadcastPage extends StatefulWidget {
  final String channelName;
  final String userName;
  final bool isBroadcaster;
  final String channelId;

  const BroadcastPage({
    Key? key,
    required this.channelName,
    required this.userName,
    required this.isBroadcaster, required this.channelId,
  }) : super(key: key);

  @override
  _BroadcastPageState createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<BroadcastPage> {
  final List<int> _users = [];
  final List<String> _infoStrings = [];
  late RtcEngine _engine;
  bool muted = false;
  String hostUrl = '';
  double _volume = 0.5;
  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.release();

    super.dispose();
  }

  @override
  void initState() {

    super.initState();
    hostUrl = 'https://agora-node-tokenserver-master.onrender.com/rtc/${widget.channelName}/publisher/uid/0';
    initAgora();



  }
  bool Loading=false;

  Future<void> getToken() async {
    final res = await http.get(
      Uri.parse(hostUrl),
    );

    if (res.statusCode == 200) {
      final responseBody = jsonDecode(res.body);

      String  rtcToken = responseBody['rtcToken'];
      if (widget.isBroadcaster){
      await _engine.joinChannel(
        token: rtcToken,
        channelId: widget.channelName,
        uid: 0,
        options:  ChannelMediaOptions(),
      );}
      else{
        await _engine.joinChannel(
          token: rtcToken,
          channelId: widget.channelName,
          uid: 0,
          options: ChannelMediaOptions(
          publishCameraTrack: false,
          publishMicrophoneTrack: false,

          clientRoleType: ClientRoleType.clientRoleAudience,
          audienceLatencyLevel: AudienceLatencyLevelType.audienceLatencyLevelLowLatency,
        ),
        );
      }
      //initAgora(rtcToken, uiid);
    } else {
      debugPrint('Failed to fetch the token');
    }
  }



  Future<void> initAgora() async {

    _engine = createAgoraRtcEngine();



    await _engine.initialize(

    RtcEngineContext(

      appId: '58d24cbe9a3a44c5bbf79f26d41db4f7',
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,



    ));
    // if(widget.isBroadcaster==false) {
    //   await _engine.disableAudio();
    // }


    _addAgoraEventHandlers();
    if (widget.isBroadcaster) {
       await [Permission.microphone, Permission.camera].request();
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
       await _engine.enableVideo();
       await _engine.startPreview();
       getToken();

    } else {

      await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
      await _engine.enableAudio();
      await _engine.enableVideo();
      getToken();


    }





  }
  bool _isFullScreen = false;


  void _addAgoraEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            final info = 'onJoinChannel: ${connection.channelId}, uid: ${connection.localUid}';
            _infoStrings.add(info);
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          setState(() {
            _infoStrings.add('onLeaveChannel');
            _users.clear();
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            final info = 'userJoined: $remoteUid';
            _infoStrings.add(info);
            _users.add(remoteUid);
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            final info = 'userOffline: $remoteUid';
            _infoStrings.add(info);
            _users.remove(remoteUid);
          });
        },
      ),
    );
  }

  Future<void> _onCallEnd(BuildContext context) async {
    // Check if the user is the broadcaster
    if (widget.isBroadcaster) {
      await FirestoreMethods().endLiveStream(widget.channelId);
    } else {
     // await FirestoreMethods().updateViewCount(widget.channelId, false);
    }

    await _engine.leaveChannel();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(


      onWillPop: () async {
        if (widget.isBroadcaster) {
          final shouldEnd = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('End Broadcast'),
              content: Text('Do you want to end the broadcast?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Yes'),
                ),
              ],
            ),
          );
          if (shouldEnd == true) {
            await _onCallEnd(context);
          }
        } else {
          await _onCallEnd(context);
        }
        return true;
      },

      child: Scaffold(
        appBar: _isFullScreen ? null : CustomAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: constraints.maxWidth > 600 || _isFullScreen
                        ? Row(
                      children: <Widget>[
                        // Web layout or full screen
                        Expanded(
                          flex: 2, // 2/3 of the screen
                          child: Stack(
                            children: <Widget>[
                              _viewRows(),
                              if (!widget.isBroadcaster)
                                Positioned(
                                  top: 7,
                                  right: 15,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Live',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (widget.isBroadcaster) _toolbar(),
                              if (!widget.isBroadcaster)
                                Positioned(
                                  left: 0,
                                  bottom: 0,
                                  child: _toolbarOdiance(),
                                ),
                              Positioned(
                                bottom: 2,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isFullScreen = !_isFullScreen;
                                    });
                                  },
                                  child: Icon(
                                    _isFullScreen
                                        ? Icons.fullscreen_exit
                                        : Icons.fullscreen,
                                    color: Colors.black,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!_isFullScreen)
                          Flexible(
                            flex: 1, // 1/3 of the screen
                            child: Container(
                              color: Colors.grey[200],
                              child: _messageSection(),
                            ),
                          ),
                      ],
                    )
                        : Column(
                      children: <Widget>[
                        // Phone layout
                        Expanded(
                          flex: 2, // 2/3 of the screen
                          child: Stack(
                            children: <Widget>[
                              _viewRows(),
                              if (widget.isBroadcaster) _toolbar(),
                              Positioned(
                                top: 7,
                                left: 7,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isFullScreen = !_isFullScreen;
                                    });
                                  },
                                  child: Icon(
                                    _isFullScreen
                                        ? Icons.fullscreen_exit
                                        : Icons.fullscreen,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1, // 1/3 of the screen
                          child: Container(
                            color: Colors.grey[200],
                            child: _messageSection(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isFullScreen) SizedBox(height: 10),
                  if (!_isFullScreen)
                  // Advertisement box at the bottom
                    Container(
                      height: 50, // Height for the advertisement box
                      color: Colors.black.withOpacity(.3), // Background color for the advertisement box
                      child: Center(
                        child: Text(
                          'Advertisement',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _messageSection() {
    return Column(
      children: <Widget>[
        // Add widgets for the message section
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'STREAM CHAT',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(color: Colors.black87, fontSize: 15,fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
         // child:  Container(),
          child: Chat(channelId: widget.channelId),
        ),
      ],
    );
  }

  Widget _toolbarOdiance() {
    return Row(
      children: [
        Icon(
          _volume == 0 ? Icons.volume_off : Icons.volume_up,
          color: Colors.black,
          size: 20.0,
        ),
        Container(
          width: 200, // Width of the volume slider container
          child: Stack(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  valueIndicatorColor: Colors.black38,
                  activeTrackColor: Colors.black,
                  inactiveTrackColor: Colors.black.withOpacity(0.3),
                  thumbColor: Colors.black,
                  overlayColor: Colors.black.withOpacity(0.2),
                ),
                child: Slider(
                  value: _volume,
                  onChanged: (value) {
                    setState(() {
                      _volume = value;
                    });
                  },
                  min: 0,
                  max: 1,
                  divisions: 100,
                  label: (_volume * 100).round().toString(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: _goToChatPage,
            child: Icon(
              Icons.message_rounded,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
        ],
      ),
    );
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.isBroadcaster) {
      list.add(AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      ));
    }
    _users.forEach((int uid) => list.add(AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: uid),
        connection: RtcConnection(channelId: widget.channelName),
      ),
    )));
    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
          child: Column(
            children: <Widget>[_videoView(views[0])],
          ),
        );
      case 2:
        return Container(
          child: Column(
            children: <Widget>[
              _expandedVideoRow([views[0]]),
              _expandedVideoRow([views[1]]),
            ],
          ),
        );
      case 3:
        return Container(
          child: Column(
            children: <Widget>[
              _expandedVideoRow(views.sublist(0, 2)),
              _expandedVideoRow(views.sublist(2, 3)),
            ],
          ),
        );
      case 4:
        return Container(
          child: Column(
            children: <Widget>[
              _expandedVideoRow(views.sublist(0, 2)),
              _expandedVideoRow(views.sublist(2, 4)),
            ],
          ),
        );
      default:
        return Container();
    }
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  // Future<void> _onCallEnd(BuildContext context) async {
  //   await _engine.leaveChannel();
  //   if ('${Provider.of<UserProvider>(context, listen: false).user.uid}${Provider.of<UserProvider>(context, listen: false).user.username}' ==
  //       widget.channelId) {
  //     await FirestoreMethods().endLiveStream(widget.channelId);
  //   } else {
  //     await FirestoreMethods().updateViewCount(widget.channelId, false);
  //   }
  //   Navigator.pop(context);
  // }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _goToChatPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RealTimeMessaging(
          channelName: widget.channelName,
          userName: widget.userName,
          isBroadcaster: widget.isBroadcaster,
        ),
      ),
    );
  }



  void _onDecreaseVolume() {
    // Decrease volume by setting volume level (0 to 100)
    _engine.adjustPlaybackSignalVolume(50); // Adjust this value as needed
  }

  void _onIncreaseVolume() {
    // Increase volume by setting volume level (0 to 100)
    _engine.adjustPlaybackSignalVolume(100); // Adjust this value as needed
  }




  }