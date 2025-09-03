import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reflect/components/entrylist/editing_chapter_header.dart';
import 'package:reflect/components/entrylist/entry_sort_setting.dart';
import 'package:reflect/components/entrylist/entrylist_appbar.dart';
import 'package:reflect/components/entrylist/grouped_entry_builder.dart';
import 'package:reflect/components/entrylist/ungrouped_entry_builder.dart';
import 'package:reflect/components/journal/chapter_header.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/chapter.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/models/tag.dart';
import 'package:reflect/pages/entry.dart';
import 'package:reflect/services/cache_service.dart';
import 'package:reflect/services/chapter_service.dart';
import 'package:reflect/services/conversion_service.dart';
import 'package:reflect/services/encryption_service.dart';
import 'package:reflect/services/entryService.dart';
import 'package:reflect/services/entrylist_service.dart';
import 'package:reflect/services/image_service.dart';
import 'package:reflect/services/tag_service.dart';
import 'package:reflect/services/timestamp_service.dart';
import 'package:reflect/services/user_service.dart';

class EntryListPage extends ConsumerStatefulWidget {
  final Chapter? chapter;
  const EntryListPage({super.key, this.chapter});

  @override
  ConsumerState<EntryListPage> createState() => _EntryListPageState();
}

class _EntryListPageState extends ConsumerState<EntryListPage> {
  late Chapter chapter = widget.chapter!;
  List<Entry> entries = [];

  List<Tag> tags = [];
  List<bool> selectedTags = [];

  List<bool> visibleMap = List.generate(100, (index) => true);

  late TextEditingController searchController;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime chapterDate;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  bool isTyping = false;
  bool isEditing = false;
  bool haveUpdated = false;
  bool isGroupedEntries = true;
  bool isTaggingEnabled = false;

  //Sort Setting
  bool isSortSettingVisible = false;
  String sortMethod = 'time';
  bool isAscending = false;

  final ImagePicker _picker = ImagePicker();
  File? _image;
  String imageType = 'url';
  late List<String> imageUrl = widget.chapter!.imageUrl ?? [];


  final chapterService = ChapterService();
  final chapterBox = Hive.box("chapters");

  final entryService = EntryService();
  final entryBox = Hive.box("entries");

  final timestampService = TimestampService();
  final entrylistService = EntrylistService();
  final conversionService = ConversionService();
  final cacheService = CacheService();
  final tagService = TagService();
  final userSetting = UserService().getUserSettingFromCache();

  void updateHaveUpdated(bool value) => setState(() => haveUpdated = value);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //chapter.updateEntries(entries);
    searchController = TextEditingController();
    titleController = TextEditingController(text: widget.chapter!.title);
    descriptionController = TextEditingController(text: widget.chapter!.description);
    chapterDate = widget.chapter!.createdAt;
    
    loadSortSetting();

    fetchEntries(false);

    searchController.addListener(() {
      if(searchController.text.isNotEmpty) isTyping = true;
      else isTyping = false;
      setState(() {});
    });
  }

  void toggleEdit() => setState(() => isEditing = !isEditing);
  void toggleSortSetting() => setState(() {
    isSortSettingVisible = !isSortSettingVisible;
    Navigator.pop(context);
  });

  void toggleGroupedEntries() => setState(() {
    isGroupedEntries = !isGroupedEntries;
    print("saving grouped $isGroupedEntries");
    conversionService.saveEntrySort(sortMethod, isAscending, isGroupedEntries);
  });

  void toggleTagSelection(int index){
    selectedTags[index] = !selectedTags[index];
    bool isAnyTagSelected = selectedTags.any((element) => element);
    if(isAnyTagSelected) isTaggingEnabled = true;
    else isTaggingEnabled = false;
    setState(() {});
  }


  void loadSortSetting() async {
    tags = tagService.getAllTags();
    selectedTags = List.generate(tags.length, (index) => false);
    final sortSetting = await conversionService.getEntrySort();
    
    if(sortSetting != null){
      sortMethod = sortSetting['sortMethod'];
      isAscending = sortSetting['isAscending'];
      isGroupedEntries = sortSetting['isGroupedEntries'];
    }
    setState(() {});
    print('load Sorting $sortMethod $isAscending $isGroupedEntries');
  }

  void onSort(String sortMethod, bool isAscending){
    this.sortMethod = sortMethod;
    this.isAscending = isAscending;
    conversionService.saveEntrySort(sortMethod, isAscending, isGroupedEntries);
    setState(() {});
  }

  //needs change
  void deleteChapter() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chapter'),
        content: const Text('Are you sure you want to delete this chapter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              bool status;
              await ImageService().deleteImages(widget.chapter!.imageUrl ?? []);

              if(userSetting!.encryptionMode == 'local') status = await cacheService.deleteChapterFromCache(chapter.id);
              else status = await chapterService.deleteChapter(chapter.id);

              if(status) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chapter deleted successfully')));
                Navigator.pop(context, true); 
                Navigator.pop(context, true);
                Navigator.pop(context, true);
              }
              else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error deleting chapter')));
            },
            child: const Text('Delete'),
          ),
        ],
      )
    );
  }

  //needs change
  void updateChapter() async {
    bool status;

    final List<String> newImageUrl = await uploadImage();
    await ImageService().deleteImages(chapter.imageUrl ?? []);
    imageType = 'url';

    if(userSetting!.encryptionMode == 'local'){
      final Chapter newChapter = chapter.copyWith(title: titleController.text.trim(), description: descriptionController.text.trim(), createdAt: chapterDate, imageUrl: newImageUrl);
      status = await cacheService.updateChapterInCache(chapter.id, newChapter.toMap());
      chapter = newChapter;
    }
    else status = await chapterService.updateChapter(chapter.id, chapter.copyWith(title: titleController.text.trim(), description: descriptionController.text.trim(), createdAt: chapterDate, imageUrl: newImageUrl).toMap());

    if(status == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chapter updated successfully')));
      haveUpdated = true;
      if(userSetting!.encryptionMode != 'local') fetchChaptersAndUpdate(true);
    }
    else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error updating chapter')));
  }


  Future<void> fetchEntries(bool explicit) async {
    await loadFromCache();
    if(userSetting!.encryptionMode == 'local') return;

    final List<Map<String, dynamic>>? data = await entryService.getEntries(chapter.id, explicit);

    if(data == null){
      return;
    }

    else if(data.isNotEmpty) {
      cacheService.addEntryToCache(data, chapter.id);
      loadFromCache();
      fetchChaptersAndUpdate(explicit);
    }

    else {
      entries = [];
      chapter = chapter.copyWith(entryCount: 0);
    }

    if(mounted) setState(() {});
  }

  Future<void> loadFromCache() async {
    final newEntries = cacheService.loadEntriesFromCache(chapter.id);
    if(userSetting!.encryptionMode == 'local') setState(() {
      final updatedChapter = cacheService.loadOneChapterFromCache(chapter.id);
      if(updatedChapter != null) chapter = updatedChapter;
    });
    if(newEntries != null){
      entries = newEntries;
      //print('load from cache ${newEntries.toString()}');
      setState(() {});
    }
  }


  Future<void> fetchChaptersAndUpdate(bool explicit) async {
    final List<Map<String, dynamic>>? data =  await chapterService.getChapters(explicit);

    if(data == null) print('load from cache');
    else if(data.isNotEmpty) {
      cacheService.addChaptersToCache(data);

      data.forEach((chapter) async {
        if(chapter["_id"] == widget.chapter!.id) {
          if(chapter["encrypted"]){
            this.chapter = Chapter.fromMap(await EncryptionService().decryptChapter(chapter));
          }
          else this.chapter = Chapter.fromMap(chapter);
        }
      });
    }
    if(mounted) setState(() {});
  }

  Future<DateTime?> showDatePickerr() async {
    return showDatePicker(
      context: context,
      initialDate: chapterDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((selectedDate){
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(chapterDate),
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
              chapterDate = selectedDateTime;
            }); 
          }
        });
      }
    });
  } 

  Future<void> changeDate() async {
    return showDatePicker(
      context: context,
      initialDate: chapterDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((selectedDate){
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(chapterDate),
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
              chapterDate = selectedDateTime;
            }); 
          }
        });
      }
    });
  }

  Future<List<String>> uploadImage() async {
    String? newImageUrl = null;
    if(imageType == 'file'){
      newImageUrl = await ImageService().uploadImage(_image!);
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
    imageUrl = [];
    setState(() {});
  }


  @override
  void dispose() {
    // TODO: implement dispose
    searchController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void popScreenWithUpdate(){
    Navigator.pop(context, haveUpdated);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    final width = MediaQuery.of(context).size.width;
    List<Entry> validEntries = entries;

    if(isTyping) validEntries = entrylistService.applySearchFilter(entries, searchController.text);
    validEntries = entrylistService.sortEntries(validEntries, sortMethod, isAscending);
    if(isTaggingEnabled) validEntries = entrylistService.filterEntryByTags(validEntries, tags, selectedTags);
    
    return WillPopScope(
      onWillPop: () async {
        popScreenWithUpdate();
        return false; // Prevent the default pop behavior
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: () async {
            fetchEntries(true);
          },
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: themeData.brightness == Brightness.light ? Alignment.bottomCenter : Alignment.topCenter,
                end: themeData.brightness == Brightness.light ? Alignment.topCenter : Alignment.bottomCenter,
                colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
              )
            ),
            child: isEditing ? Center(
              child: ChapterHeader(chapter: chapter, themeData: themeData, isEditing: isEditing, titleController: titleController, descriptionController: descriptionController, date: chapterDate, showDatePickerr: showDatePickerr, toggleEdit: toggleEdit, updateChapter: updateChapter, imageType: imageType, imageUrl: imageUrl, image: _image,  getRandomImage: getRandomImage, onEditImage: onEditImage, removeSelectedPhoto: removeSelectedPhoto),
            ) :
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                //mainAxisSize: isEditing ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: isEditing ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 40,),
                  if(!isEditing) EntryListAppbar(themeData: themeData, searchController: searchController, deleteChapter: deleteChapter, toggleEdit: toggleEdit, popScreenWithUpdate: popScreenWithUpdate, toggleSortSetting: toggleSortSetting),
              
                  const SizedBox(height: 20),
                  if(!isTyping) Center(child: ChapterHeader(chapter: chapter, themeData: themeData, isEditing: isEditing, titleController: titleController, descriptionController: descriptionController, date: chapterDate, showDatePickerr: showDatePickerr, toggleEdit: toggleEdit, updateChapter: updateChapter, imageType: imageType, imageUrl: imageUrl, image: _image,  getRandomImage: getRandomImage, onEditImage: onEditImage, removeSelectedPhoto: removeSelectedPhoto)),
                  //if(isEditing) EditingChapterHeader(toggleEdit: toggleEdit, updateChapter: updateChapter, themeData: themeData),
                  if(!isEditing) Divider(color: themeData.colorScheme.onPrimary, thickness: 1, height: 30),
                  
                  if(!isEditing && isSortSettingVisible) EntrySortSetting(sortMethod: sortMethod, isAscending: isAscending, isGroupedEntries: isGroupedEntries, onSort: onSort, toggleGroupEntries: toggleGroupedEntries, themeData: themeData, tags: tags, selectedTags: selectedTags, toggleTagSelection: toggleTagSelection,),

                  if(!isEditing && validEntries.isNotEmpty && isGroupedEntries)
                  GroupedEntryBuilder(entries: validEntries, visibleMap: visibleMap, themeData: themeData, fetchEntries: fetchEntries, updateHaveEdit: updateHaveUpdated, sortMethod: sortMethod, isAscending: isAscending,)
                  
                  else if(!isEditing && validEntries.isNotEmpty && !isGroupedEntries)
                  UngroupedEntryBuilder(entries: validEntries, themeData: themeData, fetchEntries: fetchEntries, updateHaveEdit: updateHaveUpdated)

                  else if(!isEditing && validEntries.isEmpty) Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40,),
                      Center(child: Text('No entries found', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w500, fontSize: 18),)),
                      
                    ],
                  ),
                  const SizedBox(height: 70,)
                ],
              ),
            ),
          ),
        ),
        bottomSheet: (!isEditing) ? Container(
          color: Colors.transparent,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryPage(entry: Entry(title: "",content: [], chapterId: chapter.id),)));
              if(result == 'entry_added'){
                haveUpdated = true;
                fetchEntries(true); 
              }
            }, 
            child: Text('Add Entry', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600),),
          ),
        ) : null
      ),
    );
  }
}

