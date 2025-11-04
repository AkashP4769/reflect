import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reflect/components/common/error_network_image.dart';
import 'package:reflect/components/common/loading.dart';
import 'package:reflect/components/journal/chapter_card.dart';
import 'package:reflect/components/journal/chapter_sort_setting.dart';
import 'package:reflect/components/journal/image_stack.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/chapter.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/pages/entrylist.dart';
import 'package:reflect/services/cache_service.dart';
import 'package:reflect/services/chapter_service.dart';
import 'package:reflect/services/conversion_service.dart';
import 'package:reflect/services/image_service.dart';
import 'package:reflect/services/timestamp_service.dart';
import 'package:reflect/services/user_service.dart';

class JournalPage extends ConsumerStatefulWidget {
  final String? searchQuery;
  const JournalPage({super.key, this.searchQuery});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<JournalPage> {

  bool isCreate = false;
  bool isFetching = false;

  final chapterBox = Hive.box("chapters");
  final ChapterService chapterService = ChapterService();
  final TimestampService timestampService = TimestampService();
  final CacheService cacheService = CacheService();
  final ConversionService conversionService = ConversionService();
  UserSetting userSetting = UserService().getUserSettingFromCache();

  List<Chapter> chapters = [];

  bool isEditingSort = false;
  String sortMethod = 'time';
  bool isAscending = false;

  void loadSortSettings() async {
    final sortSettings = await conversionService.getChapterSort();
    if(sortSettings != null) {
      sortMethod = sortSettings['sortMethod'];
      isAscending = sortSettings['isAscending'];
    }
  }

  void onSort(String sortMethod, bool isAscending){
    this.sortMethod = sortMethod;
    this.isAscending = isAscending;

    chapters = conversionService.sortChapters(chapters, sortMethod, isAscending);
    setState(() {});
  }

  void createChapter(String title, String description, List<String>? images, DateTime date) async {
    final chapter = {
      "title": title,
      "description": description,
      "imageUrl": images ?? [],
      "entryCount": 0,
      "createdAt": date.toIso8601String(),
    };

    bool status;
    SnackBar snackBar;

    if(userSetting!.encryptionMode == 'local') status = await cacheService.addOneChapterToCache(chapter);
    else status = await chapterService.createChapter(chapter);
    
    if(status) {
      fetchChapters(true);
      toggleCreate();
      snackBar = const SnackBar(content: Text("Chapter created successfully"));
    }
    else snackBar = const SnackBar(content: Text("Error creating chapter"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> loadChaptersFromCache() async {
    final _entries = cacheService.loadChaptersFromCache();
    if(_entries != null) {
      loadSortSettings();
      chapters = conversionService.sortChapters(_entries, sortMethod, isAscending);
      if(mounted) setState(() {});
    }
  }

  Future<void> fetchChapters(bool explicit) async {
    loadChaptersFromCache();
    if(userSetting!.encryptionMode == 'local'){
      return;
    }

    final List<Map<String, dynamic>>? data = await chapterService.getChapters(explicit);

    if(data == null) return;
    else if (data.isNotEmpty) {
      cacheService.addChaptersToCache(data);
      loadChaptersFromCache();
    }

    if(mounted) setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadChaptersFromCache();
    fetchChapters(false);
  }

  void toggleCreate() => setState(() => isCreate = !isCreate);

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    final _chapters = chapters;
    final width = MediaQuery.of(context).size.width;
    final columnCount = min(3, max(1, (MediaQuery.of(context).size.width / 415).floor()));
    print(width);

    return RefreshIndicator(
      onRefresh: () async {
        await fetchChapters(true);
      },
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        height: MediaQuery.of(context).size.height,
        
        
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: isCreate ? 0 : 1, end: isCreate ? 1 : 0), 
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic, 
          builder: (context, value, child){
            if(isFetching) {
              return Center(
                child: SpinKitCircle(
                  color: themeData.colorScheme.onPrimary,
                  size: 50.0,
                ),
              );
            }
            if(isCreate) return Opacity(opacity: value, child: NewChapter(toggleCreate: toggleCreate, tween: value, addChapter: createChapter));
            if(_chapters.isEmpty) return Opacity(opacity: 1-value, child: Align(alignment: Alignment.center, child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: EmptyChapters(themeData: themeData, toggleCreate: toggleCreate, tween: value))));
            
            return Opacity(
              opacity: 1-value,
              child: Scaffold(
                backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                body: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  clipBehavior: Clip.none,
                  child: Column(
                    
                    children: [
                      const SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: IconButton(
                              onPressed: () async {
                                await fetchChapters(true);
                              },
                              icon: Icon(userSetting.encryptionMode == 'local' ? Icons.cloud_off : Icons.cloud_outlined, color: themeData.colorScheme.onPrimary.withOpacity(0.7),)
                            ),
                          ),),
                          Align(child: Text("Chapters", style: themeData.textTheme.titleLarge,), alignment: Alignment.center,),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => setState(() => isEditingSort = !isEditingSort), 
                              icon: Icon(Icons.sort, color: isEditingSort ? themeData.colorScheme.primaryFixed : themeData.colorScheme.onPrimary,)
                            ),
                          )
                        ],
                      ),
                      if(isEditingSort) const SizedBox(height: 10),
                      if(isEditingSort) ChapterSortSetting(sortMethod: sortMethod, isAscending: isAscending, onSort: onSort, themeData: themeData,),
              
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: _chapters.length.toDouble()),
                        duration: const Duration(milliseconds:  1000),
                        curve: Curves.easeInOutCirc,
                        builder: (context, value, child) => GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columnCount,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 30,
                            childAspectRatio: 2.3,
                            mainAxisExtent: columnCount == 1 ? 210 : 210,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          clipBehavior: Clip.none,
                          itemCount: _chapters.length,
                          physics: const ScrollPhysics(),
                          itemBuilder: (context, index){
                            if(widget.searchQuery == null || widget.searchQuery!.isEmpty) {
                              return Opacity(
                                opacity: min(max(0, value - index), 1),
                                child: GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryListPage(chapter: _chapters[index])));
                                    if(result != null && result == true) fetchChapters(true);
                                  },
                                  child: ChapterCard(chapter: _chapters[index], themeData: themeData, tween: value / _chapters.length.toDouble(), index: index,)
                                ),
                              );
                            }
                            else if(_chapters[index].title!.toLowerCase().contains(widget.searchQuery!.toLowerCase()) || _chapters[index].description!.toLowerCase().contains(widget.searchQuery!.toLowerCase())) {
                              return Opacity(
                                opacity: min(max(0, value - index), 1),
                                child: GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryListPage(chapter: _chapters[index])));
                                    if(result != null && result == true) fetchChapters(true);
                                      
                                  },
                                  child: ChapterCard(chapter: _chapters[index], themeData: themeData, tween: value / _chapters.length.toDouble(), index: index,)
                                ),
                              );
                            }
                            else return Container();
                          }
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: toggleCreate,
                  child: Icon(Icons.add, color: themeData.colorScheme.onPrimary,),
                  backgroundColor: themeData.colorScheme.primary,
                ),
              ),
            );
          }
        )
      ),
    );
  }
}

class EmptyChapters extends StatelessWidget {
  final ThemeData themeData;
  final void Function() toggleCreate;
  final double tween;
  
  const EmptyChapters({super.key, required this.themeData, required this.toggleCreate, required this.tween});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Chapters", style: themeData.textTheme.titleLarge,),
          const SizedBox(height: 10),
          Text("Each chapter represents a unique phase of your journey, capturing the moments and milestones that shape your life. Reflect on your experiences and cherish the lessons learned along the way.", style: themeData.textTheme.bodyMedium, textAlign: TextAlign.center,),
          const SizedBox(height: 40),
          Text("Create your first chapter", style: themeData.textTheme.titleLarge?.copyWith(fontSize: 20),),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: toggleCreate, 
            child: Text("Create", style: themeData.textTheme.titleMedium?.copyWith(color: Colors.white)),
          ),
        ],
    );
  }
}

class NewChapter extends ConsumerStatefulWidget {
  final void Function() toggleCreate;
  final void Function(String title, String description, List<String>? images, DateTime time) addChapter;
  final double tween;
  const NewChapter({super.key, required this.toggleCreate, required this.addChapter, required this.tween});

  @override
  ConsumerState<NewChapter> createState() => _NewChapterState();
}

class _NewChapterState extends ConsumerState<NewChapter> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController imageUrlController;

  bool flipDirection = false;
  String? imageUrl = ImageService().getRandomImage();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  String imageType = 'url';

  
  void _addChapter() async {
    if(titleController.text.isEmpty || descriptionController.text.isEmpty) return;

    String? newImageUrl;
    if(imageType == 'file'){
      newImageUrl = await ImageService().uploadImage(_image!);
      if(newImageUrl == null) return;
      imageUrl = newImageUrl;
      setState(() {});
    }

    widget.addChapter(titleController.text.trim(), descriptionController.text.trim(), imageUrl != null ? [imageUrl!] : null, DateTime.now());
    titleController.clear();
    descriptionController.clear();
  }

  //void toggleFlipDirection() => setState(() => flipDirection = !flipDirection);

  void getRandomImage() => setState((){
    imageUrl = ImageService().getRandomImage();
    imageType = 'url';
    print("Random image URL: $imageUrl");
  });

  void onEditImage() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
          _image = File(pickedFile.path);
          imageType = 'file';
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
    _image = null;
    imageType = 'null';
    imageUrl = null;
    setState(() {});
  }

  void uploadImage() async {
    if(imageType == 'file' && _image != null){
      String? newUrl = await ImageService().uploadImage(_image!);
      if(newUrl != null) {
        print("new Image url: "+ newUrl);
    }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    final width = MediaQuery.of(context).size.width;
    final bool isSmall = width < 720;


    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Chapters", style: themeData.textTheme.titleLarge,),
              const SizedBox(height: 50),
              Stack(
                children: [
                  ImageStack(height: isSmall ? 450 : 360, width: isSmall ? 320 : 640, offset: Offset(lerpDouble(-30, 3, widget.tween)!, lerpDouble(-20, 0, widget.tween)!), rotation: lerpDouble(20, -7, widget.tween)),
                  ImageStack(height: isSmall ? 450 : 360, width: isSmall ? 320 : 640, offset: Offset(lerpDouble(-20, 0, widget.tween)!, lerpDouble(-40, 7, widget.tween)!), rotation: lerpDouble(30, 7, widget.tween),),
                  ImageStack(height: isSmall ? 450 : 360, width: isSmall ? 320 : 640, offset: Offset(0, lerpDouble(30, 0, widget.tween)!), rotation: lerpDouble(10, 0, widget.tween),
                      child: ColumnRow(
                        isSmall: isSmall,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: isSmall ? 20 : 0),
                            height: 300,
                            width: 300,
                            color:  Colors.white,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if(imageType == 'url' && imageUrl != null) CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover,errorWidget: (context, url, error) => ErrorNetworkImage(error: error.toString()),),
                                if(imageType =='file' && _image != null) Image.file(_image!, fit: BoxFit.cover),
                                
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if(imageType != 'null') IconButton(
                                        onPressed: removeSelectedPhoto, 
                                        icon: const DecoratedIcon(icon: Icon(Icons.close, color: Colors.white,), decoration: IconDecoration(border: IconBorder(width: 1)),),
                                      ),
                                      IconButton(
                                        onPressed: getRandomImage,
                                        icon: const DecoratedIcon(icon: Icon(Icons.shuffle, color: Colors.white), decoration: IconDecoration(border: IconBorder(width: 1)),),
                                      ),
                                      IconButton(
                                        onPressed: onEditImage,
                                        icon: DecoratedIcon(icon: Icon(imageType == 'null' ? Icons.add_photo_alternate_outlined : Icons.edit, color: Colors.white), decoration: IconDecoration(border: IconBorder(width: 1)),),
                                      ),
                                    ]
                                  )
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: titleController,
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: TextStyle(color: themeData.colorScheme.primary, fontFamily: "Poppins", fontSize: 24, fontWeight: FontWeight.w600, decoration: TextDecoration.none, decorationThickness: 0, height: 1.1),   
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                    labelStyle: TextStyle(color: Colors.white),
                                    label: Center(child: Text("Title", style: TextStyle(color: themeData.colorScheme.primary.withValues(alpha: 0.5), fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.w600))),
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    alignLabelWithHint: true
                                  ),
                                ),
                                TextField(
                                  controller: descriptionController,
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  maxLines: 3,
                                  style: const TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 12, fontWeight: FontWeight.w400),   
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                    labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                                    label: Center(child: Text("Description", style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.w400, decoration: TextDecoration.none, decorationThickness: 0, height: 0.7))),
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    alignLabelWithHint: true
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    
                ],
              ),
              SizedBox(height: isSmall ? 60 : 100,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmall ? 0 : 200),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: widget.toggleCreate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeData.colorScheme.surface,
                          elevation: 10,
                          fixedSize: Size(isSmall ? 100 : 150, 60)
                        ),
                        child: Icon(Icons.arrow_back, color: themeData.colorScheme.onPrimary,)
                      ),
                    ),
                    const SizedBox(width: 20,),
                    Expanded(
                      flex: 4,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          fixedSize: Size(isSmall ? 100 : 150, 60),
                          
                        ),
                        onPressed: (titleController.text.isEmpty || descriptionController.text.isEmpty) ? null : _addChapter,
                        child: Text("Create", style: themeData.textTheme.titleMedium?.copyWith(color: Colors.white),)
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState(){
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    imageUrlController = TextEditingController();

    titleController.addListener((){
      setState(() {});
    });

    descriptionController.addListener((){
      setState(() {});
    });

    imageUrlController.addListener((){
      imageUrl = imageUrlController.text;
      setState(() {});
    });
  }

  @override
  void dispose(){
    titleController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }
}

class ColumnRow extends StatelessWidget {
  const ColumnRow({super.key, required this.children, required this.isSmall});

  final List<Widget> children;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return isSmall ? Column(mainAxisSize: MainAxisSize.min, children: children) : Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}