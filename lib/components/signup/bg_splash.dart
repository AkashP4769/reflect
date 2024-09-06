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
  late ChewieController _chewieController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.asset("assets/splash_bg.mp4");
    _chewieController = ChewieController(videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
      showControls: false,
      showOptions: false
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
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
                    child: Chewie(controller: _chewieController)
                  ),
                ),
              ),
            ),
            /*Container(
              color: Colors.black.withOpacity(0.3),
            ),*/
            /*BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.grey.withOpacity(0.1),
                  alignment: Alignment.center,
                  /*child: Center(child: Text("Reflect", style: TextStyle(color: Colors.white, fontSize: 36),
                  ),
                ),*/
              )
            )*/
          ],
        ),
      ),
    );
  }
}