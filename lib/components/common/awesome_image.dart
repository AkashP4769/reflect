import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:reflect/services/image_service.dart';

class AwesomeImage extends StatefulWidget {
  final File? file;
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double borderRadius;

  const AwesomeImage({super.key, this.imageUrl, this.file, this.height, this.width, this.fit, this.borderRadius = 8});

  @override
  State<AwesomeImage> createState() => _AwesomeImageState();
}

class _AwesomeImageState extends State<AwesomeImage> {
  

  File? file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.imageUrl == null && widget.file == null) {
      throw Exception('Either imageUrl or file must be provided');
    }
  }


  @override
  Widget build(BuildContext context) {
   
    if(widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    } 

    if(widget.imageUrl!.startsWith('http:') || widget.imageUrl!.startsWith('https:')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl!,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
        ),
      );
    } else {
      if(file != null) {
        return Image.file(
        file!,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
      );
      } else {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }
    }
  }
}