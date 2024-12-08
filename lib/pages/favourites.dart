import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reflect/main.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class FavPage extends ConsumerStatefulWidget {
  const FavPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<FavPage> {
  //integrate flutter quill tookbox and editor


  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
        )
      ),
      child:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Fav Page'),
            quill.QuillEditor.basic(
              controller: quill.QuillController.basic(),
              focusNode: FocusNode(),
                        scrollController: ScrollController(),
        
                        configurations: quill.QuillEditorConfigurations(
                          //checkBoxReadOnly: true
                          scrollable: true,
                          placeholder: "Start writing here...",
                          keyboardAppearance: themeData.brightness,
                          //autoFocus: true,
                          //expands: true,
                          
                          customStyles: quill.DefaultStyles(
                            paragraph: quill.DefaultTextBlockStyle(
                              themeData.textTheme.bodyMedium?.copyWith(fontSize: 16) ?? const TextStyle(),
                              const quill.HorizontalSpacing(0, 0),
                              const quill.VerticalSpacing(0, 0),
                              quill.VerticalSpacing.zero,
                              null
                            ),
                            placeHolder: quill.DefaultTextBlockStyle(
                              themeData.textTheme.bodyMedium?.copyWith(fontSize: 16, color: themeData.colorScheme.onPrimary.withOpacity(0.5)) ?? const TextStyle(),
                              const quill.HorizontalSpacing(0, 0),
                              const quill.VerticalSpacing(0, 0),
                              quill.VerticalSpacing.zero,
                              null
                            ),
                          )
                            
                        ),
            ),
          ],
        ),
      ),
    );
  }}