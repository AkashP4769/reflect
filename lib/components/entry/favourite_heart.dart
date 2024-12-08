import 'package:flutter/material.dart';

class FavouriteHeart extends StatefulWidget {
  final bool isFav;
  final void Function(bool? isFav) toggleIsFav;
  const FavouriteHeart({super.key, required this.isFav, required this.toggleIsFav});

  @override
  State<FavouriteHeart> createState() => _FavouriteHeartState();
}

class _FavouriteHeartState extends State<FavouriteHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.redAccent
    ).animate(_controller);

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status){
      print("clicking");
      if(status == AnimationStatus.completed){
        widget.toggleIsFav(true);
      } else if(status == AnimationStatus.dismissed){
        widget.toggleIsFav(false);
      }
    });

  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        print("im clicking here ${widget.isFav}");
        widget.isFav ? _controller.reverse() : _controller.forward();
      },
      child: Icon(Icons.favorite, color: _colorAnimation.value, size: 25,),
    );
  }
}