import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/common/error_network_image.dart';
import 'package:reflect/components/journal/image_stack.dart';
import 'package:reflect/models/chapter.dart';
import 'package:reflect/services/image_service.dart';

class ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final ThemeData themeData;
  final double tween;
  final int index;
  const ChapterCard({super.key, required this.chapter, required this.themeData, required this.tween, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      decoration: BoxDecoration(
        color: themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5)
          )
        ],
        /*gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeData.colorScheme.tertiary.withValues(alpha: 0.7), themeData.colorScheme.onTertiary.withValues(alpha: 0.7)]
        )*/
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(chapter.imageUrl!.isNotEmpty) Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                if(chapter.entryCount > 1) ImageStack(height: 120, width: 120, offset: const Offset(0,0), rotation: lerpDouble(20, -7, tween)),
                if(chapter.entryCount > 2) ImageStack(height: 120, width: 120, offset: const Offset(0,0), rotation: lerpDouble(30, 7, tween),),
                ImageStack(height: 120, width: 120, padding: 5, /*offset:  Offset(0, lerpDouble(30, 0, tween)!),*/ rotation: lerpDouble(10, 0, tween)!,
                  child: CachedNetworkImage(
                    imageUrl: chapter.imageUrl![0], 
                    fit: BoxFit.cover, 
                    width: 100, 
                    height: 100,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(),),
                    errorWidget: (context, url, error) => ErrorNetworkImage(url: ImageService().getRandomImage()),
                  )

                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: min(max(0, tween*3 - 0), 1),
                    child: Text(chapter.title, style: themeData.textTheme.titleMedium?.copyWith(color: const Color(0xffFF9432,), fontWeight: FontWeight.w700, fontSize: 18), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 2,)),
                  const SizedBox(height: 10),
                  Opacity(
                    opacity: min(max(0, tween*3 - 1), 1),
                    child: Text(chapter.description, style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center, overflow: TextOverflow.fade, maxLines: 3,)),
                  const SizedBox(height: 10),
                  Opacity(
                    opacity: min(max(0, tween*3 - 2), 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book, color: themeData.colorScheme.onSecondary.withOpacity(0.8),),
                        const SizedBox(width: 5),
                        Text("No. of entries - ${chapter.entryCount}", style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onSecondary,fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}