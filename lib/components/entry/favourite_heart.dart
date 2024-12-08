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

    print("initsate");
    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.redAccent
    ).animate(_controller);

    if(widget.isFav){
      _controller.value = 1.0;
      setState((){});
    }

    _controller.addListener(() {
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        print("im clicking here ${widget.isFav}");
        if(widget.isFav){
          widget.toggleIsFav(false);
          _controller.reverse();
        } else {
          widget.toggleIsFav(true);
          _controller.forward();
        }
      },
      child: Icon(Icons.favorite, color: _colorAnimation.value, size: 25,),
    );
  }
}