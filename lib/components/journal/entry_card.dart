import 'package:flutter/material.dart';
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
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: themeData.colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.title ?? "", style: themeData.textTheme.titleMedium?.copyWith(color: themeData.colorScheme.primary,),),
          Text(DateFormat('E, dd MMM yyyy').format(entry.date), style: themeData.textTheme.bodySmall?.copyWith(color: themeData.colorScheme.onPrimary.withOpacity(0.8), fontWeight: FontWeight.w500),),
          SizedBox(height: 10,),
          Text(quillController.document.toPlainText(), style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w500), maxLines: 3,),
        ],
      ),
    );
  }
}