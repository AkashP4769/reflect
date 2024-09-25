import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/components/journal/chapter_header.dart';
import 'package:reflect/components/journal/entry_card.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/chapter.dart';
import 'package:intl/intl.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/pages/entry.dart';
import 'package:reflect/pages/journal.dart';
import 'package:reflect/services/chapter_service.dart';
import 'package:reflect/services/entryService.dart';

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

  bool isTyping = false;
  bool isEditing = false;
  bool haveUpdated = false;

  final chapterService = ChapterService();
  final chapterBox = Hive.box("chapters");

  final entryService = EntryService();
  final entryBox = Hive.box("entries");

  void deleteChapter() async {
    final status = await ChapterService().deleteChapter(chapter.id);
    if(status) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chapter deleted successfully')));
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    }
    else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting chapter')));
  }


  void toggleEdit() => setState(() => isEditing = !isEditing);



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //chapter.updateEntries(entries);
    searchController = TextEditingController();
    titleController = TextEditingController(text: widget.chapter!.title);
    descriptionController = TextEditingController(text: widget.chapter!.description);
    chapterDate = widget.chapter!.createdAt;
    
    entries = [ //Entry(title: 'Quiet Revelations', content: [{'insert':"As I sat by the window, watching the rain, I realized how much I’ve grown over the past year. It hasn’t been easy, but the small, quiet moments of realization...\n"},], chapterId: chapter.id),
                //Entry(title: "Reflections of the Past", content: [{'insert':  "Looking back, I can see how much I’ve changed. The things that once seemed so important don’t hold the same weight anymore. It’s funny how time and perspective can shift our understanding...\n"}], chapterId: chapter.id),
                //Entry(title: "Lost and Found", content: [{'insert': "I’ve been feeling lost lately, like I’m adrift in a sea of uncertainty. But in the midst of all the chaos, I’ve found moments of clarity and peace. It’s in these moments that I realize...\n"}], chapterId: chapter.id),
    ];
    
    fetchEntries();

    searchController.addListener(() {
      print(searchController.text);
      if(searchController.text.isNotEmpty) isTyping = true;
      else isTyping = false;
      setState(() {});
    });
  }

  void updateChapter() async {
    final newChapter = await chapterService.updateChapter(chapter.id, chapter.copyWith(title: titleController.text.trim(), description: descriptionController.text.trim()).toMap());
    if(newChapter["_id"] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chapter updated successfully')));
      haveUpdated = true;
      fetchChaptersAndUpdate();
    }
    else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating chapter')));
  }


  Future<void> fetchEntries() async {
    print("fetching entries");
    final List<Map<String, dynamic>> data = await entryService.getEntries(chapter.id);
    //print(data.toString());
    if(data.isNotEmpty) {
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      await entryBox.put(userId, { chapter.id : data });
      final cachedData = entryBox.get(userId)[chapter.id];
      print("cached data: $cachedData");
      if(cachedData != null){
        List<Map<String, dynamic>> entriesData = cachedData as List<Map<String, dynamic>>;
        List<Entry> entriesList = entriesData.map((entry) => Entry.fromMap(entry)).toList();;
        entries = entriesList;
      }
      fetchChaptersAndUpdate();
    }
    else {
      entries = [];
      chapter = chapter.copyWith(entryCount: 0);
    }
    setState(() {});
  }


  Future<void> fetchChaptersAndUpdate() async {
    final List<Map<String, dynamic>> data = await chapterService.getChapters();
    if(data.isNotEmpty) {
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      chapterBox.put(userId, {"chapters": data});
    }
    
    data.forEach((chapter){
      if(chapter["_id"] == widget.chapter!.id) {
        this.chapter = Chapter.fromMap(chapter);
      }
    });
    if(mounted) setState(() {});
  }

  Future<DateTime?> showDatePickerr() async {
    //show date and time picker
    return showDatePicker(
      context: context,
      initialDate: chapterDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((selectedDate){
      print("Selected Date: $selectedDate");
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
              //isDateEdited = true;
            }); // You can use the selectedDateTime as needed.
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
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    List<Entry> validEntries = entries == null ? [] : entries!.reversed.toList();
    if(isTyping) validEntries = entries.where((element) => element.title!.toLowerCase().contains(searchController.text.toLowerCase()) || element.getContentAsQuill().toPlainText().toLowerCase().contains(searchController.text.toLowerCase())).toList().reversed.toList();

    Map<String, List<Entry>> groupedEntries = {};
    validEntries.forEach((entry){
      final date = DateFormat('MMM yyyy').format(entry.date);
      if(groupedEntries[date] == null) groupedEntries[date] = [entry];
      else groupedEntries[date]!.add(entry);
    });

    print("visibleMap: $visibleMap");
    
    return WillPopScope(
      onWillPop: () async {
        // Intercept back button press and pop with the result 'haveUpdated'
        print('haveUpdated: $haveUpdated');
        popScreenWithUpdate();
        return false; // Prevent the default pop behavior
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40,),
                EntryListAppbar(themeData: themeData, searchController: searchController, deleteChapter: deleteChapter, toggleEdit: toggleEdit, popScreenWithUpdate: popScreenWithUpdate,),
            
                const SizedBox(height: 20),
                if(!isTyping) ChapterHeader(chapter: chapter, themeData: themeData, isEditing: isEditing, titleController: titleController, descriptionController: descriptionController, date: chapterDate, showDatePickerr: showDatePickerr,),
                if(isEditing) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: toggleEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeData.colorScheme.surface,
                            elevation: 10
                          ),
                          child: Icon(Icons.close, color: themeData.colorScheme.onPrimary,)
                        ),
                      ),
                      const SizedBox(width: 20,),
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 10,
                          ),
                          onPressed: (){
                            toggleEdit();
                            updateChapter();
                          },
                          child: Text("Save", style: themeData.textTheme.titleMedium?.copyWith(color: Colors.white),)
                        ),
                      )
                    ],
                  ),
                ),
                
                if(!isEditing && validEntries.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: groupedEntries.length,
                  clipBehavior: Clip.none,
                  physics: const ScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  itemBuilder: (context, index){
                    final date = groupedEntries.keys.elementAt(index);
                    final entries = groupedEntries[date];

  
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            children: [
                              Text(date, style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600),),
                              Container(
                                //color: Colors.green,
                                child: GestureDetector(
                                  onTap: (){
                                    visibleMap[index] = !visibleMap[index];
                                    setState(() {});
                                  },
                                  child: Icon(visibleMap[index] ? Icons.arrow_drop_down : Icons.arrow_right, color: themeData.colorScheme.onPrimary,)
                                ),
                              )
                            ],
                          ),
                        ),
                        if(visibleMap[index]) ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: entries!.length,
                          clipBehavior: Clip.none,
                          physics: const ScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryPage(entry: validEntries[index],)));
                                if(result == 'entry_updated') fetchEntries();
                                if(result == 'entry_deleted'){
                                  haveUpdated = true;
                                  fetchEntries();
                                }
                              },
                              child: EntryCard(entry: validEntries[index], themeData: themeData)
                            );
                          },
                        ),
                        SizedBox(height: 20,)
                      ],
                    );
                  }
                
                ) 
                    


                
                else if(!isEditing && validEntries.isEmpty) Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40,),
                    Center(child: Text('No entries found', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w500, fontSize: 18),)),
                    
                  ],
                ),
                SizedBox(height: 70,)
              ],
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
                fetchEntries(); 
              }
            }, 
            child: Text('Add Entry', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600),),
          ),
        ) : null
      ),
    );
  }
}

class EntryListAppbar extends StatelessWidget {
  const EntryListAppbar({
    super.key,
    required this.themeData,
    required this.searchController,
    this.deleteChapter,
    this.toggleEdit,
    this.popScreenWithUpdate
  });

  final ThemeData themeData;
  final TextEditingController searchController;
  final void Function()? deleteChapter;
  final void Function()? toggleEdit;
  final void Function()? popScreenWithUpdate;

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
              popScreenWithUpdate!();
            },
          ),
          //const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              height: 45,
              //width: double.infinity,
              child: SearchBar(
                controller: searchController,
                backgroundColor: WidgetStateProperty.all(themeData.colorScheme.secondaryContainer),
                elevation: WidgetStateProperty.all(0),
                trailing: [
                  IconButton(
                    onPressed: (){},
                    icon: const Icon(Icons.search),
                    color: themeData.colorScheme.onPrimary,
                  ),
                  
                ],
              ),
            ),
          ),
          PopupMenuButton(
            color: themeData.colorScheme.secondaryContainer,
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.edit, color: themeData.colorScheme.onPrimary,),
                  title: Text('Edit Chapter', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600),),
                  onTap: (){
                    Navigator.pop(context);
                    toggleEdit!();
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.delete, color: themeData.colorScheme.onPrimary,),
                  title: Text('Delete Chapter', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600),),
                  onTap: deleteChapter,
                ),
              ),
            ]
          )
        ],
      ),
    );
  }
}