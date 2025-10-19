import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyHomePage extends StatefulWidget {
  final ScrollController controller;
  const MyHomePage({super.key, required this.controller});

  @override
  createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.controller,
      child: Container(
        alignment: Alignment.center,
        color: Colors.red,
        child: Column(children: [Text("Achiket")]),
      ),
    );
  }
}
