import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/services/image_service.dart';

class ErrorNetworkImage extends StatelessWidget {
  ErrorNetworkImage({super.key, this.url, this.fit, this.width, this.height});

  final ImageService imageService = ImageService();
  final BoxFit? fit;
  final double? width;
  final double? height;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        
        CachedNetworkImage(
          imageUrl: url ?? imageService.getRandomImage(),
          fit: fit ?? BoxFit.cover,
          width: width ?? 100,
          height: height ?? 100,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Icon(Icons.shuffle, color: Theme.of(context).colorScheme.onPrimary, size: (width != null && height != null) ? (width! < height! ? width! * 0.2 : height! * 0.2) : 20,),
          ),
        ),
      ],
    );
  }
}