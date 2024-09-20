import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/journal/image_stack.dart';
import 'package:reflect/models/chapter.dart';

class ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final ThemeData themeData;
  const ChapterCard({super.key, required this.chapter, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 5),
      decoration: BoxDecoration(
        color: themeData.colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5)
          )
        ]
      ),
      child: Row(
        children: [
          if(chapter.imageUrl != null) Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                if(chapter.entryCount > 1) const ImageStack(height: 120, width: 120, offset: Offset(0, 3), rotation: -7,),
                if(chapter.entryCount > 2) const ImageStack(height: 120, width: 120, offset: Offset(0, -0), rotation: 7,),
                ImageStack(height: 120, width: 120, padding: 5,
                  child: CachedNetworkImage(imageUrl: chapter.imageUrl![0], fit: BoxFit.cover, width: 100, height: 100),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  Text(chapter.title, style: themeData.textTheme.titleMedium?.copyWith(color: const Color(0xffFF9432,), fontWeight: FontWeight.w700, fontSize: 18), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 2,),
                  const SizedBox(height: 10),
                  Text(chapter.description, style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center, overflow: TextOverflow.fade, maxLines: 4,),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, color: themeData.colorScheme.onSecondary.withOpacity(0.8),),
                      const SizedBox(width: 5),
                      Text("No. of entries - ${chapter.entryCount}", style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onSecondary,fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                    ],
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