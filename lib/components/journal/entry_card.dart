import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:reflect/components/common/error_network_image.dart';
import 'package:reflect/models/entry.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:reflect/services/image_service.dart';

class EntryCard extends StatelessWidget {
  final Entry entry;
  final ThemeData themeData;
  const EntryCard({super.key, required this.entry, required this.themeData});

  @override
  Widget build(BuildContext context) {
    final quill.QuillController quillController = quill.QuillController(document: entry.getCombinedContentAsQuill(), selection: const TextSelection.collapsed(offset: 0));
    bool hasImage = entry.imageUrl != null && entry.imageUrl!.isNotEmpty;
    final columnCount = MediaQuery.of(context).size.width < 720 ? 1 : 2;

    return Container(
      width: double.infinity,
      height: hasImage ? 160 : null,
      margin: EdgeInsetsDirectional.symmetric(horizontal: columnCount == 1 ? 0 : 10, vertical: 10),
      
      decoration: BoxDecoration(
        color: hasImage ? Colors.transparent : themeData.colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 5,
            offset: const Offset(0, 5)
          )
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            

            if(hasImage) Container(
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: entry.imageUrl![0],
                fit: BoxFit.fitWidth,
                errorWidget: (context, url, error) => ErrorNetworkImage(error: error.toString()),
              ),
            ),

            if(hasImage) Positioned.fill(
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      themeData.brightness == Brightness.light ? Colors.grey.withOpacity(0.4) : Colors.black.withOpacity(0.2), // Fully transparent at the top
                      Colors.black.withOpacity(0.7), // Darker towards the bottom
                    ],
                  ),
                ),
              ),
            ),
        
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(entry.title ?? "", style: themeData.textTheme.titleMedium?.copyWith(color: themeData.colorScheme.primary, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis,)),
                      if(entry.favourite ?? false) Icon(Icons.favorite, color: Colors.redAccent,)
                    ],
                  ),
                  Text(DateFormat('E, dd MMM yyyy').format(entry.date), style: themeData.textTheme.bodySmall?.copyWith(color: hasImage ? Colors.white.withOpacity(0.8) : themeData.colorScheme.onPrimary.withOpacity(0.8), fontWeight: FontWeight.w500),),
                  SizedBox(height: 10,),
                  Text(quillController.document.toPlainText(), style: themeData.textTheme.bodyMedium?.copyWith(color: hasImage ? Colors.white : themeData.colorScheme.onPrimary, fontWeight: FontWeight.w500, fontSize: 14), maxLines: 3,),
                ],
              ),
            ),

            //if(hasImage) Text(entry.imageUrl![0].toString()),
          ],
        ),
      ),
    );
  }
}