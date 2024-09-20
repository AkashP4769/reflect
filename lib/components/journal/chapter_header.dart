import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reflect/models/chapter.dart';

class ChapterHeader extends StatelessWidget {
  final ChapterAdvanced chapter;
  final ThemeData themeData;
  const ChapterHeader({super.key, required this.chapter, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(chapter.imageUrl != null && chapter.imageUrl!.isNotEmpty) Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 4,
                  blurRadius: 7,
                  offset: const Offset(0, 3)
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(imageUrl: chapter.imageUrl![0] ?? "", width: double.infinity, height: 200, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          Text(chapter.title, style: themeData.textTheme.titleLarge?.copyWith(color: const Color(0xffFF9432),), textAlign: TextAlign.center,),
          const SizedBox(height: 10),
          Text(chapter.description, style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600,), textAlign: TextAlign.center,),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.book, color: themeData.colorScheme.onPrimary,),
                  const SizedBox(width: 5),
                  Text('Entries - ${chapter.entryCount}', style: themeData.textTheme.bodySmall?.copyWith(color: themeData.colorScheme.onPrimary, fontSize: 14),)
                ],
              ),
              Row(
                children: [
                  Icon(Icons.lock_clock, color: themeData.colorScheme.onPrimary,),
                  const SizedBox(width: 5),
                  Text('Created - ${DateFormat('dd/MM/yyyy').format(chapter.createdAt)}', style: themeData.textTheme.bodySmall?.copyWith(color: themeData.colorScheme.onPrimary, fontSize: 14),)
                ],
              )
            ],
          ),
          Divider(color: themeData.colorScheme.onPrimary, thickness: 1, height: 30),

        ],
      ),
    );
  }
}