import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/components/entrylist/editing_chapter_header.dart';
import 'package:reflect/components/entrylist/entry_sort_setting.dart';
import 'package:reflect/components/entrylist/entrylist_appbar.dart';
import 'package:reflect/components/entrylist/grouped_entry_builder.dart';
import 'package:reflect/components/entrylist/ungrouped_entry_builder.dart';
import 'package:reflect/components/journal/chapter_header.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/chapter.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/pages/entry.dart';
import 'package:reflect/services/cache_service.dart';
import 'package:reflect/services/chapter_service.dart';
import 'package:reflect/services/conversion_service.dart';
import 'package:reflect/services/entryService.dart';
import 'package:reflect/services/entrylist_service.dart';
import 'package:reflect/services/timestamp_service.dart';

class EntryListPage extends ConsumerStatefulWidget {
  final Chapter? chapter;
  const EntryListPage({super.key, this.chapter});

  @override
  ConsumerState<EntryListPage> createState() => _EntryListPageState();
}

class _EntryListPageState extends ConsumerState<EntryListPage> {
  late Chapter chapter = widget.chapter!;
  List<Entry> entries = [];
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

  //Sort Setting
  bool isSortSettingVisible = false;
  String sortMethod = 'time';
  bool isAscending = false;


  final chapterService = ChapterService();
  final chapterBox = Hive.box("chapters");

  final entryService = EntryService();
  final entryBox = Hive.box("entries");

  final timestampService = TimestampService();
  final entrylistService = EntrylistService();
  final conversionService = ConversionService();
  final cacheService = CacheService();

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
  void toggleSortSetting() => setState(() => isSortSettingVisible = !isSortSettingVisible);
  void toggleGroupedEntries() => setState(() {
    isGroupedEntries = !isGroupedEntries;
    conversionService.saveEntrySort(sortMethod, isAscending, isGroupedEntries);
  });

  void loadSortSetting() async {
    final sortSetting = await conversionService.getEntrySort();
    if(sortSetting != null){
      sortMethod = sortSetting['sortMethod'];
      isAscending = sortSetting['isAscending'];
      isGroupedEntries = sortSetting['isGroupedEntries'];
    }
  }

  void onSort(String sortMethod, bool isAscending){
    this.sortMethod = sortMethod;
    this.isAscending = isAscending;
    conversionService.saveEntrySort(sortMethod, isAscending, isGroupedEntries);
    setState(() {});
  }

  void deleteChapter() async {
    final status = await ChapterService().deleteChapter(chapter.id);
    if(status) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chapter deleted successfully')));
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    }
    else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error deleting chapter')));
  }

  void updateChapter() async {
    final newChapter = await chapterService.updateChapter(chapter.id, chapter.copyWith(title: titleController.text.trim(), description: descriptionController.text.trim(), createdAt: chapterDate).toMap());
    if(newChapter["_id"] != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chapter updated successfully')));
      haveUpdated = true;
      fetchChaptersAndUpdate(true);
    }
    else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error updating chapter')));
  }


  Future<void> fetchEntries(bool explicit) async {
    await loadFromCache();
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
    if(newEntries != null){
      entries = newEntries;
      setState(() {});
    }
  }


  Future<void> fetchChaptersAndUpdate(bool explicit) async {
    final List<Map<String, dynamic>>? data = await chapterService.getChapters(explicit);
    if(data == null) print('load from cache');
    else if(data.isNotEmpty) {
      chapterBox.put(userId, {"chapters": data});

      data.forEach((chapter){
        if(chapter["_id"] == widget.chapter!.id) {
          this.chapter = Chapter.fromMap(chapter);
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
    List<Entry> validEntries = entries;

    if(isTyping) validEntries = entrylistService.applySearchFilter(entries, searchController.text);
    if(!isGroupedEntries) validEntries = entrylistService.sortEntries(validEntries, sortMethod, isAscending);
    
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
            //padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: themeData.brightness == Brightness.light ? Alignment.bottomCenter : Alignment.topCenter,
                end: themeData.brightness == Brightness.light ? Alignment.topCenter : Alignment.bottomCenter,
                colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
              )
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40,),
                  if(!isEditing) EntryListAppbar(themeData: themeData, searchController: searchController, deleteChapter: deleteChapter, toggleEdit: toggleEdit, popScreenWithUpdate: popScreenWithUpdate, toggleSortSetting: toggleSortSetting),
              
                  const SizedBox(height: 20),
                  if(!isTyping) ChapterHeader(chapter: chapter, themeData: themeData, isEditing: isEditing, titleController: titleController, descriptionController: descriptionController, date: chapterDate, showDatePickerr: showDatePickerr,),
                  if(isEditing) EditingChapterHeader(toggleEdit: toggleEdit, updateChapter: updateChapter, themeData: themeData),
                  
                  if(isSortSettingVisible) EntrySortSetting(sortMethod: sortMethod, isAscending: isAscending, isGroupedEntries: isGroupedEntries, onSort: onSort, toggleGroupEntries: toggleGroupedEntries, themeData: themeData),

                  if(!isEditing && validEntries.isNotEmpty) isGroupedEntries ?
                  GroupedEntryBuilder(entries: validEntries, visibleMap: visibleMap, themeData: themeData, fetchEntries: fetchEntries, updateHaveEdit: updateHaveUpdated, sortMethod: sortMethod, isAscending: isAscending,) :
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

