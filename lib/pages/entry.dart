import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/entry.dart';

class EntryPage extends ConsumerStatefulWidget {
  final Entry entry;
  const EntryPage({super.key, required this.entry});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryPage> {
  late quill.QuillController quillController;
  late TextEditingController titleController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titleController = TextEditingController(text: widget.entry.title);
    if(widget.entry.content == null) quillController = quill.QuillController.basic();
    else {
      quillController = quill.QuillController(
        document: quill.Document.fromJson(widget.entry.content ?? []),
        selection: TextSelection.collapsed(offset: 0),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [themeData.colorScheme.primary, themeData.colorScheme.onTertiary]
          )
        ),
        child: Column(
          children: [
            Text("Tf ain tworking"),
            quill.QuillToolbar.simple(
              controller: quillController,
              configurations: quill.QuillSimpleToolbarConfigurations(
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showColorButton: true,
                showBackgroundColorButton: true,
                showClearFormat: true,
                showHeaderStyle: true,
                showListNumbers: true,
                showListBullets: true,
                showCodeBlock: true,
                showQuote: true,
                showLink: true,
              )
            ),
            quill.QuillEditor.basic(
              controller: quillController,
              configurations: quill.QuillEditorConfigurations(
                //checkBoxReadOnly: true
              ),
            ),
          ],
        ),
      ),
    );
  }
}