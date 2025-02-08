import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:reflect/models/entry.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class EntryCard extends StatelessWidget {
  final Entry entry;
  final ThemeData themeData;
  const EntryCard({super.key, required this.entry, required this.themeData});

  @override
  Widget build(BuildContext context) {
    final quill.QuillController quillController = quill.QuillController(document: entry.getContentAsQuill(), selection: const TextSelection.collapsed(offset: 0));
    return Container(
      width: double.infinity,
      height: 160,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 10),
      
      decoration: BoxDecoration(
        color: themeData.colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
        //border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5)
          )
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            if(entry.imageUrl != null && entry.imageUrl!.isNotEmpty) 
            Container(
              width: double.infinity,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4), // Adjust the opacity to control the effect
                    BlendMode.dstATop, // Applies transparency without removing colors
                ),
                child: CachedNetworkImage(
                  imageUrl: entry.imageUrl![0],
                  fit: BoxFit.fitWidth,  
                ),
              ),
            ),

            /*if(entry.imageUrl != null && entry.imageUrl!.isNotEmpty)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4), // Darker at the top
                      Colors.black.withOpacity(0.9),             // Fade out at the bottom
                    ],
                  ),
                ),
              ),
            ),*/
        
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
                  Text(DateFormat('E, dd MMM yyyy').format(entry.date), style: themeData.textTheme.bodySmall?.copyWith(color: themeData.colorScheme.onPrimary.withOpacity(0.8), fontWeight: FontWeight.w500),),
                  SizedBox(height: 10,),
                  Text(quillController.document.toPlainText(), style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w500, fontSize: 14), maxLines: 3,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}