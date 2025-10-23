import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Bg_Splash extends StatefulWidget {
  const Bg_Splash({super.key});

  @override
  State<Bg_Splash> createState() => _Bg_SplashState();
}

class _Bg_SplashState extends State<Bg_Splash> {
  late VideoPlayerController _controller;
  //ChewieController? _chewieController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeControllers();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    //_chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializeControllers() async {
    _controller = VideoPlayerController.asset("assets/splash_bg.mp4");

    _controller.setLooping(true);

    _controller.initialize().then((value) async {
      if (_controller.value.isInitialized) {
        setState(() {});
        await _controller.play();
        setState(() {});
      } else {
        print("video file load failed");
      }
    }).catchError((e) {
      print("controller.initialize() error occurs: $e");
    });

    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      
        child: Stack(
          children: [
            Container(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    //child: Chewie(controller: _chewieController!)
                    child: _controller.value.isInitialized ? VideoPlayer(_controller) : Image.asset("assets/splash_bg.png", fit: BoxFit.cover,),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}