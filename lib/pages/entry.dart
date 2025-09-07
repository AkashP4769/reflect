import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reflect/components/common/error_network_image.dart';
import 'package:reflect/components/entry/favourite_heart.dart';
import 'package:reflect/components/entry/sliding_carousel.dart';
import 'package:reflect/components/entry/tag_alertbox.dart';
import 'package:reflect/components/entry/tag_card.dart';
import 'package:reflect/components/entry/tag_panel.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/models/tag.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/services/cache_service.dart';
import 'package:reflect/services/entryService.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:reflect/services/image_service.dart';
import 'package:reflect/services/user_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';


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
  bool isTagsEdited = false;
  bool isFavouriteEdited = false;
  bool isImageEdited = false;

  bool isImageEditing = false;
  bool extendedToolbar = false;
  bool isHiddenForSS = false;

  late quill.QuillController quillController;
  late TextEditingController titleController;
  //late SlidingUpPanelController panelController;
  late ScrollController scrollController;
  late DateTime date;
  late bool isFavourite;

  late FocusNode titleFocusNode;
  late FocusNode contentFocusNode;

  EntryService entryService = EntryService();
  CacheService cacheService = CacheService();
  late UserSetting userSetting;
  List<Tag> entryTags = [];

  final ImagePicker _picker = ImagePicker();
  File? image;
  String imageType = 'null';
  late List<String> imageUrl;

  late ScreenshotController screenshotController;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titleController = TextEditingController(text: widget.entry.title);
    titleFocusNode = FocusNode();
    contentFocusNode = FocusNode();
    //panelController = SlidingUpPanelController();
    scrollController = ScrollController();
    screenshotController = ScreenshotController();

    getUserSetting();

    if(widget.entry.tags != null){
      for(var tag in widget.entry.tags!) {
        entryTags.add(Tag(name: tag['name'], color: tag['color']));
      }
    }
    //entryTags.add(Tag(name: "Optimistic", color: 0xfff0bb2b));
    //entryTags.add(Tag(name: "Pessimistic", color: 0xff592bf0));
    
    //panelController.hide();
    //print("date: ${widget.entry.date}");
    //print("timezone: ${widget.entry.date.toLocal().timeZoneOffset.inMinutes}");
  

    if(widget.entry.id == null) date = widget.entry.date;
    else {
      int timezone = widget.entry.date.toLocal().timeZoneOffset.inMinutes;
      bool isPositive = timezone >= 0 ? true : false;

      if(isPositive) date = widget.entry.date.toLocal().subtract(Duration(minutes: timezone));
      else date = widget.entry.date.toLocal().add(Duration(minutes: -1 * timezone));
    }

    isFavourite = widget.entry.favourite ?? false;
    imageUrl = widget.entry!.imageUrl ?? [];
    if(imageUrl.isNotEmpty) imageType = 'url';

    //imageUrl.add("https://img.freepik.com/free-photo/digital-art-style-river-nature-landscape_23-2151825792.jpg?t=st=1727633824~exp=1727637424~hmac=9414f70adc8deaa8fbfcb76720166319533a01c3aab771afb83d9d2da258f80c&w=900");

    if(widget.entry.content == null || widget.entry.content!.isEmpty) quillController = quill.QuillController.basic(/*editorFocusNode: contentFocusNode*/);
    else {
      quillController = quill.QuillController.basic(
        /*document: quill.Document.fromJson(widget.entry.content ?? []),
        selection: const TextSelection.collapsed(offset: 0),
        /*editorFocusNode: contentFocusNode,*/
        config: quill.QuillControllerConfigurations()*/
        config: quill.QuillControllerConfig(
          clipboardConfig: quill.QuillClipboardConfig()
          //editorFocusNode: contentFocusNode,
        )
      );
      quillController.document = quill.Document.fromJson(widget.entry.getContentAsQuill().toDelta().toJson());
    }

    quillController.document.changes.listen((_) => _scrollToBottom());

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

  void getUserSetting() async {
    UserSetting? _userSetting = await UserService().getUserSettingFromCache();
    if(_userSetting == null) _userSetting = await UserService().getUserSetting();
    userSetting = _userSetting;
    if(mounted) setState(() {});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentOffset = quillController.selection.base.offset;
      //print("currentOffset: $currentOffset | length: ${quillController.document.length}");
      if (scrollController.hasClients && currentOffset > quillController.document.length - 200) {
        //print("scrolling");
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void addEntry() async {
    final newImageUrl = await uploadImage();
    final entryTagList = entryTags.map((tag) => tag.toMap()).toList();
    final entry = Entry.fromQuill(titleController.text, quillController.document, date, entryTagList, widget.entry.chapterId!, null, false, isFavourite, newImageUrl);
    final bool result;
    
    if(userSetting.encryptionMode == 'local') result = await cacheService.addOneEntryToCache(entry.toMap(), entry.chapterId!);
    else result = await entryService.createEntry(entry.toMap());

    if(result) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry added successfully')));
      Navigator.pop(context, 'entry_added');
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add entry')));
    }
  }

  void updateEntry() async {
    final newImageUrl = await uploadImage();
    final entryTagList = entryTags.map((tag) => tag.toMap()).toList();
    final entry = Entry.fromQuill(titleController.text, quillController.document, date, entryTagList, widget.entry.chapterId!, widget.entry.id, false, isFavourite, newImageUrl);
    bool result;

    if(userSetting.encryptionMode == 'local') result = await cacheService.updateOneEntryInCache(entry.id!, entry.toMap(), entry.chapterId!);
    else result = await entryService.updateEntry(entry.toMap());

    if(result) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry updated successfully')));
      Navigator.pop(context, 'entry_updated');
    }
    else {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update entry')));
    }
  }

  void deleteEntry() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delet this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              bool result;
              if(userSetting.encryptionMode == 'local') result = await cacheService.deleteOneEntryFromCache(widget.entry.id!, widget.entry.chapterId!);
              else result = await entryService.deleteEntry(widget.entry.chapterId!, widget.entry.id!);

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
              print("selectedDate: ${selectedDateTime.toString()}");
              isDateEdited = true;
            }); // You can use the selectedDateTime as needed.
          }
        });
      }
    });
  }

  void showTagSelection(ThemeData themeData) async {
    List<Tag>? newEntryTags = await showDialog(
      context: context, 
      builder: (context) => TagSelectionBox(themeData: themeData, tags: entryTags),
    );
    //print(newEntryTags.toString());
    if(newEntryTags != null) {
      entryTags = newEntryTags;
      isTagsEdited = true;
      setState(() {});
    }
  }

  void toggleFavourite(bool? isFav) {
    if(isFav != null){
      if(isFav != isFavourite){
        isFavourite = isFav;
        isFavouriteEdited = !isFavouriteEdited;
      } 
    }
    else {
      isFavourite = !isFavourite;
      isFavouriteEdited = !isFavouriteEdited;
    }

    setState(() {});
  }

  Future<bool> _onWillPop() async {
    if (isTitleEdited || isContentEdited || isDateEdited || isTagsEdited || isFavouriteEdited || isImageEdited) {
      // Show the alert dialog
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unsaved Changes'),
          content: Text('You have unsaved changes. Do you really want to leave?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Stay on the page
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Leave the page
              child: Text('Leave'),
            ),
          ],
        ),
      );
    }
    // If pageEdited is false, allow the pop without any dialog
    return true;
  }

  Future<List<String>> uploadImage() async {
    String? newImageUrl = null;
    if(imageType == 'file'){
      newImageUrl = await ImageService().uploadImage(image!);
      if(newImageUrl == null) return [];
      imageUrl = [newImageUrl];
      setState(() {});
    }
    else if(imageType == 'url'){
      newImageUrl = imageUrl[0];
    }
    return newImageUrl == null ? [] : [newImageUrl];
  }

  void getRandomImage() => setState((){
    imageUrl = [ImageService().getRandomImage()];
    imageType = 'url';
    isImageEdited = true;
  });

  void onEditImage() async {
    await _pickImage(ImageSource.gallery);

  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
          image = File(pickedFile.path);
          imageType = 'file';
          isImageEdited = true;
      } else {
        print('No image selected.');
      }
      setState(() {});

    } catch (e) {
      print('Error picking image: $e');
      SnackBar snackBar = const SnackBar(content: Text("Error picking image"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      imageType = 'null';
      setState(() {});
    }
  }

  void removeSelectedPhoto(){
    image = null;
    imageType = 'null';
    imageUrl = [];
    isImageEdited = true;
    setState(() {});
  }

  void screenshotAndShare() async {
    setState(() {isHiddenForSS = true;});
    await screenshotController.capture(
      pixelRatio: 3.0,
      delay: const Duration(milliseconds: 100)).then((Uint8List? image) async {
      {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/${titleController.text.trim().split(' ').join('-')}.png').create();
        if(image != null) {
          await imagePath.writeAsBytes(image);
          final result = await Share.shareXFiles([XFile(imagePath.path)]);

          /*if(result.status == ShareResultStatus.success) {
            ScaffoldMessengerState().showSnackBar(const SnackBar(content: Text('Shared successfully')));
          }
          else {
            ScaffoldMessengerState().showSnackBar(const SnackBar(content: Text('Sharing failed')));
        }*/
      }
    }});
    setState(() {isHiddenForSS = false;});
  }
  
  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    //panelController.dispose();
    scrollController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    final width = MediaQuery.of(context).size.width;
    final columnCount = width < 720 ? 1 : 2;
    double fontsize = columnCount == 1 ? 16 : 20;

    print("columnCount: $columnCount");

    final gridWidgets = [
      if((imageUrl != null && imageUrl!.isNotEmpty) || (imageType =='file' && image != null)) Container(
        height: columnCount == 1 ? 200 : 300,
        width: columnCount == 1 ? MediaQuery.of(context).size.width - 40 : (MediaQuery.of(context).size.width / 2) - (MediaQuery.of(context).size.width / 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if(imageType == 'url' && imageUrl.isNotEmpty) GestureDetector(onTap: () => setState(() => isImageEditing = !isImageEditing), child: CachedNetworkImage(imageUrl: imageUrl[0], width: double.infinity, height: 200, fit: BoxFit.cover, errorWidget: (context, url, error) => ErrorNetworkImage(),),),
              if(imageType =='file' && image != null) GestureDetector(onTap: () => setState(() => isImageEditing = !isImageEditing), child: Image.file(image!, fit: BoxFit.cover, height: 200,)),
            
              if(isImageEditing && ((imageType == 'url' && imageUrl != null) || (imageType =='file' && image != null))) Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: removeSelectedPhoto, 
                      icon: const DecoratedIcon(icon: Icon(Icons.close, color: Colors.white,), decoration: IconDecoration(border: IconBorder(width: 1)),),
                    ),
                    IconButton(
                      onPressed: getRandomImage,
                      icon: const DecoratedIcon(icon: Icon(Icons.shuffle, color: Colors.white), decoration: IconDecoration(border: IconBorder(width: 1)),),
                    ),
                    IconButton(
                      onPressed: onEditImage,
                      icon: const DecoratedIcon(icon: Icon(Icons.edit, color: Colors.white), decoration: IconDecoration(border: IconBorder(width: 1)),),
                    ),
                  ]
                )
              ),
            ],
          ),
        ),
      ),
          
    
      Container(
        //color: Colors.lightGreen
        padding: EdgeInsets.symmetric(vertical: columnCount == 1 ? 20 : 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: showDatePickerr,
                  child: Text(DateFormat("dd MMM yyyy | hh:mm a").format(date), style: themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: columnCount == 1 ? 14 : 18)),
                ),
                if (!isHiddenForSS || isFavourite) Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: FavouriteHeart(isFav: isFavourite, toggleIsFav: toggleFavourite)
                ),
              ],
            ),
        
            TextField(
              controller: titleController,
              focusNode: titleFocusNode,
              style: themeData.textTheme.titleLarge?.copyWith(fontSize: columnCount == 1 ? 20 : 32, color: const Color(0xffFF9432), decoration: TextDecoration.none, decorationThickness: 0,),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Title...",
                hintStyle: themeData.textTheme.titleLarge?.copyWith(color: const Color(0xffFF9432).withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                isDense: true,
              ),
              maxLines: null,
            ),
            SizedBox(height: 5,),
              
            if(entryTags.isNotEmpty || (entryTags.isEmpty && !isHiddenForSS)) SlidingCarousel(tags: entryTags, themeData: themeData, showTagDialog: showTagSelection),
          ],
        ),
      ),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            //height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(horizontal: columnCount == 1 ? 0 : 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: themeData.brightness == Brightness.dark ? Alignment.topCenter : Alignment.bottomCenter,
                end: themeData.brightness == Brightness.dark ? Alignment.bottomCenter : Alignment.topCenter,
                colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
              )
            ),
            
            child: SingleChildScrollView(
              //controller: scrollController, 
              clipBehavior: Clip.none,
              scrollDirection: Axis.vertical,
              physics: const ScrollPhysics(),
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: (isHiddenForSS) ? BoxDecoration(
                    gradient: LinearGradient(
                      begin: themeData.brightness == Brightness.dark ? Alignment.topCenter : Alignment.bottomCenter,
                      end: themeData.brightness == Brightness.dark ? Alignment.bottomCenter : Alignment.topCenter,
                      colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
                    )
                  ) : null,
                  
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  
                    children: [
                      if(!isHiddenForSS) const SizedBox(height: 40),     
                      if(!isHiddenForSS) EntryAppbar(themeData: themeData, deleteEntry: deleteEntry, showDelete: widget.entry.id == null ? false : true, imageType: imageType, addImage: getRandomImage, screenshotAndShare: screenshotAndShare, isHiddenForSS: isHiddenForSS,),

                      const SizedBox(height: 20),
                      (gridWidgets.length == 2 && columnCount == 2) ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnCount,
                          childAspectRatio: 1.0,
                          mainAxisExtent: columnCount == 1 ? 200 : 240,
                          crossAxisSpacing: 40,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20),
                        shrinkWrap: true,
                        clipBehavior: Clip.hardEdge,
                        itemCount: gridWidgets.length,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return gridWidgets[index];
                        },
                      ) :
                      Column(
                        children: gridWidgets,
                      ),
                          
                      
                      const SizedBox(height: 20),

                      quill.QuillEditor(
                        focusNode: contentFocusNode,
                        controller: quillController,
                        scrollController: scrollController,
                        config: quill.QuillEditorConfig(
                          scrollable: true,
                          placeholder: "Start writing here...",
                          keyboardAppearance: themeData.brightness,
                          onPerformAction: (TextInputAction action) {
                            //print(action.toString());
                          },
                          
                          customStyles: quill.DefaultStyles(
                            paragraph: quill.DefaultTextBlockStyle(
                              themeData.textTheme.bodyMedium?.copyWith(fontSize: fontsize) ?? const TextStyle(),
                              const quill.HorizontalSpacing(0, 0),
                              const quill.VerticalSpacing(0, 0),
                              quill.VerticalSpacing.zero,
                              null
                            ),
                            placeHolder: quill.DefaultTextBlockStyle(
                              themeData.textTheme.bodyMedium?.copyWith(fontSize: fontsize, color: themeData.colorScheme.onPrimary.withOpacity(0.5)) ?? const TextStyle(),
                              const quill.HorizontalSpacing(0, 0),
                              const quill.VerticalSpacing(0, 0),
                              quill.VerticalSpacing.zero,
                              null
                            ),
                          )
                        ),
                      ),     
                      
                      Container(height: 80,),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomSheet: (!isHiddenForSS) ? Container(
          color: themeData.colorScheme.tertiary,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisSize: columnCount == 1 ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.end,
            children: [
              quill.QuillSimpleToolbar(
                controller: quillController,
                config: quill.QuillSimpleToolbarConfig(
                  showBoldButton: columnCount == 2 ? true : (extendedToolbar ? false : true),
                  showItalicButton: columnCount == 2 ? true : (extendedToolbar ? false : true),
                  showUnderLineButton: columnCount == 2 ? true : (extendedToolbar ? false : true),
                  showStrikeThrough: false, //
                  showColorButton: columnCount == 2 ? true : (extendedToolbar ? true : false), //
                  showBackgroundColorButton: false,
                  showClearFormat: false, //
                  showHeaderStyle: false,
                  showListNumbers: columnCount == 2 ? true : (extendedToolbar ? true : false),
                  showListBullets: columnCount == 2 ? true : (extendedToolbar ? true : false),
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
                  showRedo: columnCount == 2 ? true : (extendedToolbar ? true :  false), //
                  showUndo: columnCount == 2 ? true : (extendedToolbar ? false : true),
                )
              ),
              IconButton(
                onPressed: () => setState(() => extendedToolbar = !extendedToolbar), icon: Icon(Icons.more_vert, color: themeData.colorScheme.onPrimary,),
              ),
              SizedBox(
                width: columnCount == 1 ? 120 : 150,
                child: ElevatedButton(
                  onPressed: isTitleEdited || isContentEdited || isDateEdited || isTagsEdited || isFavouriteEdited || isImageEdited ? (){
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
        ) : null,
      ),
    );
  }
}

class EntryAppbar extends StatelessWidget {
  const EntryAppbar({
    super.key,
    required this.themeData,
    required this.deleteEntry,
    required this.showDelete,
    required this.imageType,
    required this.addImage,
    required this.screenshotAndShare,
    required this.isHiddenForSS
  });

  final ThemeData themeData;
  final void Function()? deleteEntry;
  final bool showDelete;
  final String imageType;
  final void Function()? addImage;
  final void Function()? screenshotAndShare;
  final bool isHiddenForSS;

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
              Navigator.maybePop(context);
            },
          ),
          //const SizedBox(width: 10),
          Container(
            child: Row(
              children: [
                if(showDelete) IconButton(
                  onPressed: deleteEntry, 
                  icon: Icon(Icons.delete, color: themeData.colorScheme.onPrimary,),
                ),

                if(imageType == 'null') Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: IconButton(
                    onPressed: addImage, 
                    icon: Icon(Icons.add_a_photo_rounded, color: themeData.colorScheme.onPrimary, size: 24,),
                  ),
                ),

                IconButton(
                  onPressed: screenshotAndShare, 
                  icon: Icon(Icons.share, color: themeData.colorScheme.onPrimary,),
                ),
            
                
                
              ],
            ),
          )
        ],
      ),
    );
  }
}