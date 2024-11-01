import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reflect/components/entry/tag_alertbox.dart';
import 'package:reflect/components/entry/tag_card.dart';
import 'package:reflect/components/entry/tag_panel.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/models/tag.dart';
import 'package:reflect/services/entryService.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';


class EntryPage extends ConsumerStatefulWidget {
  final Entry entry;
  const EntryPage({super.key, required this.entry});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryPage> {
  bool isTitleEdited = false;
  bool isContentEdited = false;
  bool isDateEdited = false;

  bool extendedToolbar = false;

  late quill.QuillController quillController;
  late TextEditingController titleController;
  late SlidingUpPanelController panelController;
  late ScrollController scrollController;
  late DateTime date;

  late FocusNode titleFocusNode;
  late FocusNode contentFocusNode;

  EntryService entryService = EntryService();
  List<Tag> selectedTags = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titleController = TextEditingController(text: widget.entry.title);
    titleFocusNode = FocusNode();
    contentFocusNode = FocusNode();
    panelController = SlidingUpPanelController();
    
    panelController.hide();
    date = widget.entry.date;

    if(widget.entry.content == null || widget.entry.content!.isEmpty) quillController = quill.QuillController.basic();
    else {
      quillController = quill.QuillController(
        document: quill.Document.fromJson(widget.entry.content ?? []),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.expand();
      } else if (scrollController.offset <=
              scrollController.position.minScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.anchor();
      } else {}
    });

    titleController.addListener(() {
      if(!isTitleEdited && titleController.text != widget.entry.title) {
        isTitleEdited = true;
        setState(() {});
      }
      else if(isTitleEdited && titleController.text == widget.entry.title) {
        isTitleEdited = false;
        setState(() {});
      }
    });

    quillController.addListener((){
      String quillContent = quillController.document.toPlainText();
      String entryContent = widget.entry.getContentAsQuill().toPlainText();
      if(!isContentEdited && quillContent != entryContent) {
        isContentEdited = true;
        setState(() {});
      }
      else if(isContentEdited && quillContent == entryContent) {
        isContentEdited = false;
        setState(() {});
      }
    });
  }

  void addEntry() async {
    final entry = Entry.fromQuill(titleController.text, quillController.document, date, [], widget.entry.chapterId!, null);
    final result = await entryService.createEntry(entry.toMap());
    if(result) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry added successfully')));
      Navigator.pop(context, 'entry_added');
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add entry')));
    }
  }

  void updateEntry() async {
    final entry = Entry.fromQuill(titleController.text, quillController.document, date, [], widget.entry.chapterId!, widget.entry.id);
    final result = await entryService.updateEntry(entry.toMap());
    if(result) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry updated successfully')));
      Navigator.pop(context, 'entry_updated');
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update entry')));
    }
  }

  void deleteEntry() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final result = await entryService.deleteEntry(widget.entry.chapterId!, widget.entry.id!);
              if(result) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry deleted successfully')));
                Navigator.pop(context);
                Navigator.pop(context, 'entry_deleted');
              }
              else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete entry')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      )
    );
  }

  Future<DateTime?> showDatePickerr() async {
    return showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((selectedDate){
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(date),
        ).then((selectedTime) {
          if (selectedTime != null) {
            DateTime selectedDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            setState(() {
              date = selectedDateTime;
              isDateEdited = true;
            }); // You can use the selectedDateTime as needed.
          }
        });
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    panelController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            clipBehavior: Clip.none,
            scrollDirection: Axis.vertical,
            physics: const ScrollPhysics(),
              
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                //height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: themeData.brightness == Brightness.dark ? Alignment.topCenter : Alignment.bottomCenter,
                    end: themeData.brightness == Brightness.dark ? Alignment.bottomCenter : Alignment.topCenter,
                    colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
                  )
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    EntryAppbar(themeData: themeData),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: showDatePickerr,
                          child: Text(DateFormat("dd MMM yyyy | hh:mm a").format(date), style: themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))
                        ),
                        GestureDetector(
                          onTap: deleteEntry,
                          child: const Icon(Icons.delete_outline, color: Colors.red,),
                        ),
                      ],
                    ),
                    
                    TextField(
                      controller: titleController,
                      focusNode: titleFocusNode,
                      style: themeData.textTheme.titleLarge?.copyWith(color: const Color(0xffFF9432), decoration: TextDecoration.none, decorationThickness: 0,),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: "Title...",
                        hintStyle: themeData.textTheme.titleLarge?.copyWith(color: const Color(0xffFF9432).withOpacity(0.5)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        
                      ),
                      maxLines: null,
                    ),
                    
                    
                    Wrap(
                      children: [
                        ...selectedTags.map((tag) => TagCard(tag: tag, themeData: themeData, selected: true)),
                        GestureDetector(
                          onTap: () => showDialog(context: context, builder: (context) => TagSelectionBox(themeData: themeData)),
                          child: TagCard(tag: Tag(name: selectedTags.isEmpty ? "Add tag +" : "+", color: const Color(0xffFF9432).value), themeData: themeData, selected: false)
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    quill.QuillEditor.basic(
                          controller: quillController,
                          focusNode: contentFocusNode,
                          scrollController: ScrollController(),
                          configurations: quill.QuillEditorConfigurations(
                            //checkBoxReadOnly: true
                            placeholder: "Start writing here...",
                            keyboardAppearance: themeData.brightness,
                            customStyles: quill.DefaultStyles(
                              paragraph: quill.DefaultTextBlockStyle(
                                themeData.textTheme.bodyMedium?.copyWith(fontSize: 18) ?? const TextStyle(),
                                const quill.HorizontalSpacing(0, 0),
                                const quill.VerticalSpacing(0, 0),
                                quill.VerticalSpacing.zero,
                                null
                              ),
                              placeHolder: quill.DefaultTextBlockStyle(
                                themeData.textTheme.bodyMedium?.copyWith(fontSize: 18, color: themeData.colorScheme.onPrimary.withOpacity(0.5)) ?? const TextStyle(),
                                const quill.HorizontalSpacing(0, 0),
                                const quill.VerticalSpacing(0, 0),
                                quill.VerticalSpacing.zero,
                                null
                              ),
                            )
                              
                          ),
                        ),      
                    const SizedBox(height: 80,)
                  ],
                ),
              ),
            ),
          ),
          bottomSheet: Container(
            color: themeData.colorScheme.tertiary,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: quill.QuillToolbar.simple(
                        controller: quillController,
                        configurations: quill.QuillSimpleToolbarConfigurations(
                          showBoldButton: extendedToolbar ? false : true,
                          showItalicButton: extendedToolbar ? false : true,
                          showUnderLineButton: extendedToolbar ? false : true,
                          showStrikeThrough: false, //
                          showColorButton: extendedToolbar ? true :  false, //
                          showBackgroundColorButton: false,
                          showClearFormat: false, //
                          showHeaderStyle: false,
                          showListNumbers: extendedToolbar ? true :  false, //
                          showListBullets: extendedToolbar ? true :  false, //
                          showCodeBlock: false,
                          showQuote: false, //
                          showLink: false,
                          showSubscript: false,
                          showSuperscript: false,
                          showAlignmentButtons: false,
                          showClipboardCopy: false,
                          showClipboardCut: false,
                          showClipboardPaste: false,
                          showDividers: false,
                          showListCheck: false,
                          showIndent: false,
                          showFontFamily: false,
                          showFontSize: false,
                          showSearchButton: false, //
                          showInlineCode: false, //
                          showRedo: extendedToolbar ? true :  false, //
                          showUndo: extendedToolbar ? false : true,
                        )
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => extendedToolbar = !extendedToolbar), icon: Icon(Icons.more_vert, color: themeData.colorScheme.onPrimary,),
                    ),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: isTitleEdited || isContentEdited || isDateEdited ? (){
                          if(widget.entry.id == null) addEntry();
                          else updateEntry();
                        } : null,
                      
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: Colors.grey,
                          backgroundColor: const Color(0xffFF9432),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          )
                        ),
                        child: Text('Save', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600),),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        TagPanel(panelController: panelController, scrollController: scrollController, themeData: themeData,)
      ],
    );
  }
}

class EntryAppbar extends StatelessWidget {
  const EntryAppbar({
    super.key,
    required this.themeData,
  });

  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: themeData.colorScheme.onPrimary,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          //const SizedBox(width: 10),
          
          IconButton(
            onPressed: (){}, 
            icon: Icon(Icons.menu, color: themeData.colorScheme.onPrimary,),
          )
        ],
      ),
    );
  }
}