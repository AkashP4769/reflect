import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/components/common/awesome_image.dart';
import 'package:reflect/main.dart';

class ImagePage extends ConsumerWidget {
  final String imageUrl;
  final String heroTag;
  const ImagePage({super.key, required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeManagerProvider);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
          gradient: LinearGradient(
            begin: themeData.brightness == Brightness.light ? Alignment.bottomCenter : Alignment.topCenter,
            end: themeData.brightness == Brightness.light ? Alignment.topCenter : Alignment.bottomCenter,
            colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
          )
        ),
        child: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Center(
            child: Hero(
              tag: heroTag,
              child: AwesomeImage(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.9,
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                borderRadius: 20,
              ),
            ),
          ),
        ),
      )
    ); 
  }
}