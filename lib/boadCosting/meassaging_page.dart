import 'package:flutter/material.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtm/agora_rtm.dart';



// Replace with your actual Agora app ID


class RealTimeMessaging extends StatefulWidget {
  final String channelName;
  final String userName;
  final bool isBroadcaster;

  const RealTimeMessaging({
    Key? key,
    required this.channelName,
    required this.userName,
    required this.isBroadcaster,
  }) : super(key: key);

  @override
  _RealTimeMessagingState createState() => _RealTimeMessagingState();
}

class _RealTimeMessagingState extends State<RealTimeMessaging> {
  bool _isLogin = false;
  bool _isInChannel = false;

  final _channelMessageController = TextEditingController();
  final _infoStrings = <String>[];

  late AgoraRtmClient _client;
  AgoraRtmChannel? _channel; // Make the channel nullable

  @override
  void initState() {
    super.initState();
    _createClient();
  }

  Future<void> _createClient() async {
    try {
      _client = await AgoraRtmClient.createInstance('58d24cbe9a3a44c5bbf79f26d41db4f7');
      _client.onMessageReceived = (AgoraRtmMessage message, String peerId) {
        _logPeer(message.text);
      };
      _client.onConnectionStateChanged = (int state, int reason) {
        print('Connection state changed: $state, reason: $reason');
        if (state == 5) {
          _client.logout();
          print('Logout.');
          setState(() {
            _isLogin = false;
          });
        }
      };

      _toggleLogin();
    } catch (error) {
      print('Error creating RTM client: $error');
    }
  }

  void _logPeer(String message) {
    setState(() {
      _infoStrings.add('Peer message: $message');
    });
  }

  void _log(String info) {
    setState(() {
      _infoStrings.add(info);
    });
  }

  void _toggleLogin() async {
    if (!_isLogin) {
      try {
        await _client.login(null, widget.userName);
        print('Login success: ${widget.userName}');
        setState(() {
          _isLogin = true;
        });
        _toggleJoinChannel();
      } catch (errorCode) {
        print('Login error: $errorCode');
      }
    } else {
      await _client.logout();
      print('Logout success: ${widget.userName}');
      setState(() {
        _isLogin = false;
      });
    }
  }

  void _toggleJoinChannel() async {
    if (!_isInChannel) {
      try {
        _channel = await _client.createChannel(widget.channelName);
        await _channel?.join();
        print('Join channel success: ${widget.channelName}');
        setState(() {
          _isInChannel = true;
        });
        _channel?.onMessageReceived = (AgoraRtmMessage message, AgoraRtmMember member) {
          _log('Channel msg: ${message.text}, from: ${member.userId}');
        };
        _channel?.onMemberJoined = (AgoraRtmMember member) {
          _log('Member joined: ${member.userId}');
        };
        _channel?.onMemberLeft = (AgoraRtmMember member) {
          _log('Member left: ${member.userId}');
        };
      } catch (errorCode) {
        print('Join channel error: $errorCode');
      }
    } else {
      await _channel?.leave();
      print('Leave channel success: ${widget.channelName}');
      setState(() {
        _isInChannel = false;
      });
    }
  }

  void _sendMessage() async {
    String text = _channelMessageController.text;
    if (text.isEmpty) {
      return;
    }
    try {
      AgoraRtmMessage message = AgoraRtmMessage.fromText(text);
      await _channel?.sendMessage(message);
      _log('Send channel message: $text');
      _channelMessageController.clear();
    } catch (errorCode) {
      print('Send channel message error: $errorCode');
    }
  }

  Widget _buildInfoList() {
    return Flexible(
      child: ListView.builder(
        itemCount: _infoStrings.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_infoStrings[index]),
          );
        },
      ),
    );
  }

  Widget _buildSendChannelMessage() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _channelMessageController,
            decoration: InputDecoration(
              hintText: 'Enter message',
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: _sendMessage,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _channelMessageController.dispose();
    _client.logout();
    _client.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Agora RTM'),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInfoList(),
              Container(
                width: double.infinity,
                alignment: Alignment.bottomCenter,
                child: _buildSendChannelMessage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}