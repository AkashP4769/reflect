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
import 'package:reflect/components/common/overlay_menu.dart';
import 'package:reflect/components/entry/favourite_heart.dart';
import 'package:reflect/components/entry/sliding_carousel.dart';
import 'package:reflect/components/entry/tag_alertbox.dart';
import 'package:reflect/components/entry/tag_card.dart';
import 'package:reflect/components/entry/tag_panel.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/models/tag.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/pages/image.dart';
import 'package:reflect/services/cache_service.dart';
import 'package:reflect/services/entryService.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:reflect/services/image_service.dart';
import 'package:reflect/services/user_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


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
  bool isDragging = false;

  late quill.QuillController activeQuillController;
  List<quill.QuillController> quillControllers = [];
  List<DateTime> subsectionDates = [];

  late TextEditingController titleController;
  //late SlidingUpPanelController panelController;
  List<ScrollController> scrollControllers = [];
  //late DateTime date;
  late bool isFavourite;

  late FocusNode titleFocusNode;
  List<FocusNode> focusNodes = [];

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
    //panelController = SlidingUpPanelController();
    screenshotController = ScreenshotController();

    getUserSetting();

    // print("widget.entry.title: ${widget.entry.title}");
    // print("widget.entry.content: ${widget.entry.content}");
    // print("widget.entry.subsections: ${widget.entry.subsections}");

    if(widget.entry.tags != null){
      for(var tag in widget.entry.tags!) {
        entryTags.add(Tag(name: tag['name'], color: tag['color']));
      }
    }

    // if(widget.entry.id == null) date = widget.entry.date;
    // else {
    //   int timezone = widget.entry.date.toLocal().timeZoneOffset.inMinutes;
    //   bool isPositive = timezone >= 0 ? true : false;

    //   if(isPositive) date = widget.entry.date.toLocal().subtract(Duration(minutes: timezone));
    //   else date = widget.entry.date.toLocal().add(Duration(minutes: -1 * timezone));
    // }

    isFavourite = widget.entry.favourite ?? false;
    imageUrl = widget.entry!.imageUrl ?? [];
    if(imageUrl.isNotEmpty) imageType = 'url';


    if(widget.entry.subsections == null || widget.entry.subsections!.isEmpty){
      DateTime date = DateTime.now().toLocal();
      quillControllers.add(quill.QuillController.basic());
      subsectionDates.add(date);
      scrollControllers = [ScrollController()];
      focusNodes = [addFocusListener(FocusNode(), 0)];
    }
    else {
      for(var subsection in widget.entry.subsections!) {
        quillControllers.add(quill.QuillController(
          document: subsection.getContentAsQuill(),
          selection: const TextSelection.collapsed(offset: 0),
        ));
        subsectionDates.add(subsection.date.toLocal());
        scrollControllers.add(ScrollController());
        focusNodes.add(addFocusListener(FocusNode(), focusNodes.length));
      }
    }

    activeQuillController = quillControllers.first;
    quillControllers.last.document.changes.listen((_) => _scrollToBottom());

    titleController.addListener(() {
      if(!isTitleEdited && titleController.text != widget.entry.title) {
        isTitleEdited = true;
        if(mounted) setState(() {});
      }
      else if(isTitleEdited && titleController.text == widget.entry.title) {
        isTitleEdited = false;
        if(mounted) setState(() {});
      }
    });

    // quillControllers.last.addListener((){
    //   String quillContent = quillControllers.last.document.toPlainText();
    //   String entryContent = widget.entry.getContentAsQuill().toPlainText();
    //   if(!isContentEdited && quillContent != entryContent) {
    //     isContentEdited = true;
    //     setState(() {});
    //   }
    //   else if(isContentEdited && quillContent == entryContent) {
    //     isContentEdited = false;
    //     setState(() {});
    //   }
    // });

    for(int i=0; i<quillControllers.length; i++){
      quillControllers[i].addListener((){
        String quillContent = quillControllers[i].document.toPlainText();
        String entryContent = "";
        //String entryContent = widget.entry.subsections != null && widget.entry.subsections!.length > i && widget.entry.subsections![i].content!.isEmpty ? quill.Document.fromJson(widget.entry.subsections![i].content ?? []).toPlainText() : "";
        if(!isContentEdited && quillContent != entryContent) {
          isContentEdited = true;
          if(mounted) setState(() {});
        }
        else if(isContentEdited && quillContent == entryContent) {
          isContentEdited = false;
          if(mounted) setState(() {});
        }
      });
    }
  }

  void getUserSetting() async {
    UserSetting? _userSetting = await UserService().getUserSettingFromCache();
    if(_userSetting == null) _userSetting = await UserService().getUserSetting();
    userSetting = _userSetting;
    if(mounted) setState(() {});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentOffset = quillControllers.last.selection.base.offset;
      //print("currentOffset: $currentOffset | length: ${quillControllers.last.document.length}");
      if (scrollControllers.last.hasClients && currentOffset > quillControllers.last.document.length - 200) {
        //print("scrolling");
        scrollControllers.last.animateTo(
          scrollControllers.last.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void addEntry() async {
    final newImageUrl = await uploadImage();
    final entryTagList = entryTags.map((tag) => tag.toMap()).toList();

    List<Subsection> subsections = [];
    for(int i=0; i<quillControllers.length; i++){
      subsections.add(Subsection.fromQuill(quillControllers[i].document, subsectionDates[i]));
    }

    final entry = Entry.fromSubsections(titleController.text, subsections, subsectionDates.first, entryTagList, widget.entry.chapterId!, null, false, isFavourite, newImageUrl);
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

    List<Subsection> subsections = [];
    for(int i=0; i<quillControllers.length; i++){
      subsections.add(Subsection.fromQuill(quillControllers[i].document, subsectionDates[i]));
    }

    final entry = Entry.fromSubsections(titleController.text, subsections, subsectionDates.first, entryTagList, widget.entry.chapterId!, widget.entry.id, false, isFavourite, newImageUrl);
    bool result;

    //print("Updating entry: ${entry.toMap()}");

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

  Future<DateTime?> showDatePickerr(int index) async {
    return showDatePicker(
      context: context,
      initialDate: subsectionDates[index],
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((selectedDate){
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(subsectionDates[index]),
        ).then((selectedTime) {
          if (selectedTime != null) {
            DateTime selectedDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            ).toLocal();
            setState(() {
              subsectionDates[index] = selectedDateTime;
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
      if(mounted) setState(() {});
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

    if(mounted) setState(() {});
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
      if(mounted) setState(() {});
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
      if(mounted) setState(() {});

    } catch (e) {
      print('Error picking image: $e');
      SnackBar snackBar = const SnackBar(content: Text("Error picking image"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      imageType = 'null';
      if(mounted) setState(() {});
    }
  }

  void removeSelectedPhoto(){
    image = null;
    imageType = 'null';
    imageUrl = [];
    isImageEdited = true;
    if(mounted) setState(() {});
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

  FocusNode addFocusListener(FocusNode node, int index){
    print("Adding focus listener to node $index");
    node.addListener(() {
      if(node.hasFocus){
        setState(() {
          activeQuillController = quillControllers[index];
        });
      }
    });
    return node;
  }

  void addSubsection(){
    subsectionDates.add(DateTime.now().toLocal());
    scrollControllers.add(ScrollController());
    focusNodes.add(addFocusListener(FocusNode(), focusNodes.length));
    quillControllers.add(quill.QuillController.basic());
    quillControllers.last.document.changes.listen((_) => _scrollToBottom());
    if(mounted) setState(() {});
  }

  void removeSubsection(int index){
    if(quillControllers.length > index){
      subsectionDates.removeAt(index);
      quillControllers[index].dispose();

      quillControllers.removeAt(index);

      scrollControllers[index].dispose();
      scrollControllers.removeAt(index);

      focusNodes[index].dispose();
      focusNodes.removeAt(index);
      if(mounted) setState(() {});
    }
  }

  void reorderSubsection(int oldIndex, int newIndex){
    if(quillControllers.length < 2) return;
    print("oldIndex: $oldIndex, newIndex: $newIndex");
    print("quillControllers length: ${quillControllers.length}");
    if(oldIndex < newIndex) newIndex--;

    final _quillcontroller = quillControllers.removeAt(oldIndex);
    final _subsectiondate = subsectionDates.removeAt(oldIndex);
    final _focusNode = focusNodes.removeAt(oldIndex);
    final _scrollController = scrollControllers.removeAt(oldIndex);

    if(newIndex != quillControllers.length + 1){
      quillControllers.insert(newIndex, _quillcontroller);
      subsectionDates.insert(newIndex, _subsectiondate);
      focusNodes.insert(newIndex, _focusNode);
      scrollControllers.insert(newIndex, _scrollController);

      for(int i=0; i<focusNodes.length; i++){
        focusNodes[i].removeListener((){});
        focusNodes[i] = addFocusListener(focusNodes[i], i);
      }
    }

    isDateEdited = true;

    if(mounted) setState(() {});
  }

  void toggleDragging(){
    isDragging = !isDragging;
    setState(() {});
  }
  
  @override
  void dispose() {
    titleController.dispose();
    quillControllers.forEach((controller) => controller.dispose());
    titleFocusNode.dispose();
    focusNodes.forEach((controller) => controller.dispose());
    //panelController.dispose();
    scrollControllers.forEach((controller) => controller.dispose());
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    final width = MediaQuery.of(context).size.width;
    final columnCount = width < 720 ? 1 : 2;
    double fontsize = columnCount == 1 ? 16 : 20;
    bool imageExists = (imageUrl != null && imageUrl!.isNotEmpty) || (imageType =='file' && image != null);

    print("columnCount: $columnCount");

    final List<Widget> gridWidgets = [
      if(imageExists) Container(
        height: columnCount == 1 ? 200 : 300,
        width: columnCount == 1 ? MediaQuery.of(context).size.width - 40 : (MediaQuery.of(context).size.width / 2) - (MediaQuery.of(context).size.width / 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if(imageType == 'url' && imageUrl.isNotEmpty) GestureDetector(onTap: () => setState(() => isImageEditing = !isImageEditing), child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePage(imageUrl: imageUrl[0], heroTag: "image-${imageUrl[0]}",)));
                },
                child: Hero(tag: "image-${imageUrl[0]}", child: CachedNetworkImage(imageUrl: imageUrl[0], width: double.infinity, height: 200, fit: BoxFit.cover, errorWidget: (context, url, error) => ErrorNetworkImage(error: error.toString()),))),
              ),
              if(imageType =='file' && image != null) GestureDetector(onTap: () => setState(() => isImageEditing = !isImageEditing), child: Image.file(image!, fit: BoxFit.cover, height: 200,)),
            
              if(isImageEditing && imageExists) Align(
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
        //height: 140,
        padding: EdgeInsets.only(top: columnCount == 1 ? 20 : 0, bottom: columnCount == 1 ? 10 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){ showDatePickerr(0); },
                  child: Text(DateFormat("dd MMM yyyy | hh:mm a").format(subsectionDates.first), style: themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: columnCount == 1 ? 14 : 18)),
                ),
                if (!isHiddenForSS || isFavourite) Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: FavouriteHeart(isFav: isFavourite, toggleIsFav: toggleFavourite)
                ),
              ],
            ),

            if(columnCount != 1) TextField(
              controller: titleController,
              focusNode: titleFocusNode,
              style: themeData.textTheme.titleLarge?.copyWith(fontSize: columnCount == 1 ? 20 : 32, color: themeData.colorScheme.primary, decoration: TextDecoration.none, decorationThickness: 0,),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Title...",
                hintStyle: themeData.textTheme.titleLarge?.copyWith(color: themeData.colorScheme.primary.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                isDense: true,
              ),
              maxLines: null,
            ),

            if(entryTags.isNotEmpty || (entryTags.isEmpty && !isHiddenForSS)) SlidingCarousel(tags: entryTags, themeData: themeData, showTagDialog: showTagSelection, shouldWrap: true && imageExists, columnCount: columnCount,),
            SizedBox(height: 5,),

            if(columnCount == 1) TextField(
              controller: titleController,
              focusNode: titleFocusNode,
              style: themeData.textTheme.titleLarge?.copyWith(fontSize: columnCount == 1 ? 20 : 32, color: themeData.colorScheme.primary, decoration: TextDecoration.none, decorationThickness: 0,),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Title...",
                hintStyle: themeData.textTheme.titleLarge?.copyWith(color: themeData.colorScheme.primary.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                isDense: true,
              ),
              maxLines: null,
            ),
            

            
          ],
        ),
      ),
    ];

    print("Is Android and multiple Quill controllers: ${TargetPlatform.android == defaultTargetPlatform && quillControllers.length > 1}");

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
                colors: [themeData.colorScheme.secondary, themeData.colorScheme.onTertiary]
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      if(!isHiddenForSS) EntryAppbar(themeData: themeData, deleteEntry: deleteEntry, showDelete: widget.entry.id == null ? false : true, imageType: imageType, addImage: getRandomImage, screenshotAndShare: screenshotAndShare, isHiddenForSS: isHiddenForSS, addSubsection: addSubsection,),

                      if(columnCount > 1 || imageExists) const SizedBox(height: 20),
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
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: gridWidgets[index],
                          );
                        },
                      ) : ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 0),
                        shrinkWrap: true,
                        itemCount: gridWidgets.length,
                        itemBuilder: (context, index) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: gridWidgets[index],
                          ),
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                      ),
                          
                      
                       
                      ReorderableListView.builder(
                        onReorder: reorderSubsection,
                        proxyDecorator: (Widget child, int index, Animation<double> animation) {
                          return Material(
                            elevation: 6.0,
                            color: Colors.transparent,
                            shadowColor: Colors.black54,
                            child: Container(
                              decoration: BoxDecoration(
                                color: themeData.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8.0,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                          );
                        },
                        buildDefaultDragHandles: false,
                        padding: EdgeInsets.symmetric(vertical: 0),
                        itemCount: quillControllers.length + 1,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                      
                        onReorderStart: (int index) {setState(() {isDragging = true;});},
                        onReorderEnd: (int index) {setState(() {isDragging = false;});},
                      
                        itemBuilder: (context, index) => ReorderableDelayedDragStartListener(
                          enabled: quillControllers.length < 2 ? false : true,
                          index: index,
                          key: ValueKey("subsection_$index"),
                          child: (index < quillControllers.length) ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(index != 0) SizedBox(height: 10,),
                                if(index != 0) Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: GestureDetector(
                                      onTap: () => showDatePickerr(index),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10, bottom: 0),
                                        child: Text(DateFormat(subsectionDates[index-1].day == subsectionDates[index].day ? "hh:mm a" : "dd MMM yyyy | hh:mm a").format(subsectionDates[index]), style: themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: columnCount == 1 ? 14 : 18, color: themeData.colorScheme.onPrimary.withValues(alpha: 0.5)),),
                                      ),
                                    ),
                                ),
  
                                quill.QuillEditor(
                                  focusNode: focusNodes[index],
                                  controller: quillControllers[index],
                                  scrollController: scrollControllers[index],
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
                                SizedBox(height: 10,),
                              ],
                            ),
                             
                          ) : 
                          (isDragging && quillControllers.length > 1) ? Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.redAccent.withValues(alpha: 0.3),
                                  Colors.redAccent.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.redAccent, width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.redAccent,),
                                SizedBox(width: 5,),
                                Text("Drag below to delete subsection", textAlign: TextAlign.center, style: themeData.textTheme.bodyMedium?.copyWith(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.redAccent.withValues(alpha: 0.5))),
                              ],
                            ),
                          ) : SizedBox(
                            height: 0,
                            width: 0,
                          ),
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
                controller: activeQuillController,
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
              columnCount == 1 ? IconButton(
                onPressed: () => setState(() => extendedToolbar = !extendedToolbar), icon: Icon(Icons.more_vert, color: themeData.colorScheme.onPrimary,),
              ) : Container(width: 0, height: 0,),
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


class MyListView extends StatelessWidget {
  final List<quill.QuillController> quillControllers;
  final Widget child;
  const MyListView({super.key, required this.child, required this.quillControllers});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 0),
      itemCount: quillControllers.length + 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
    
      itemBuilder: (context, index) => ReorderableDragStartListener(
        index: index,
        key: ValueKey("subsection_$index"),
        child: child
      )
    );
  }
}

class MyReordarableList extends StatelessWidget {
  final List<quill.QuillController> quillControllers;
  final void Function() toggleDragging;
  final ReorderCallback reorderSubsection;
  final Widget child;
  final ThemeData themeData;
  const MyReordarableList({super.key, required this.child, required this.quillControllers, required this.toggleDragging, required this.reorderSubsection, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      onReorder: reorderSubsection,
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        return Material(
          elevation: 6.0,
          color: Colors.transparent,
          shadowColor: Colors.black54,
          child: Container(
            decoration: BoxDecoration(
              color: themeData.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      buildDefaultDragHandles: true,
      padding: EdgeInsets.symmetric(vertical: 0),
      itemCount: quillControllers.length + 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
    
      onReorderStart: (int index) {toggleDragging();},
      onReorderEnd: (int index) {toggleDragging();},
    
      itemBuilder: (context, index) => ReorderableDragStartListener(
        index: index,
        key: ValueKey("subsection_$index"),
        child: child
      )
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
    required this.isHiddenForSS,
    required this.addSubsection,
  });

  final ThemeData themeData;
  final void Function()? deleteEntry;
  final bool showDelete;
  final String imageType;
  final void Function()? addImage;
  final void Function()? screenshotAndShare;
  final void Function()? addSubsection;
  final bool isHiddenForSS;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  onPressed: addSubsection, 
                  icon: Icon(Icons.add, color: themeData.colorScheme.onPrimary,),
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