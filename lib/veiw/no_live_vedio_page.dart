



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../boadCosting/broadcast_page.dart';
import '../models/livestream.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';
import 'login_screen.dart';

class LiveStreamingPage extends StatefulWidget {
  @override
  _LiveStreamingPageState createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage> {
  bool hasActiveStream = false; // This should be updated based on your stream status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Streaming'),
      ),
      body: Center(
        child: hasActiveStream ? _buildLiveStream() : _buildNoStreamMessage(),
      ),
    );
  }

  Widget _buildLiveStream() {
    // Replace with your live stream widget
    return Container(
      child: Text('Live Stream is active'),
    );
  }

  Widget _buildNoStreamMessage() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('There is no live stream, please wait...'),

        ],
      ),
    );
  }
}