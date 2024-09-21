import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/components/common/loading.dart';
import 'package:reflect/components/journal/chapter_card.dart';
import 'package:reflect/components/journal/image_stack.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/chapter.dart';
import 'package:reflect/pages/entrylist.dart';
import 'package:reflect/services/chapter_service.dart';

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



  List<Chapter> chapters = [
    //Chapter(title: "A New Begining", description: "it marks the start of a new phase in life, where every step feels like an adventure into the unknown.", entryCount: 16, imageUrl: "https://cdn.pixabay.com/photo/2012/08/27/14/19/mountains-55067_640.png"),
    //Chapter(title: "Embracing the Unknown.", description: "A time of stepping into uncertainty with courage. trusting the process and allowing life to unfold in unexpected ways.", entryCount: 2, imageUrl: "https://cdn.pixabay.com/photo/2024/02/23/21/25/landscape-8592826_1280.jpg"),
    //Chapter(title: "A New Begining", description: "it marks the start of a new phase in life, where every step feels like an adventure into the unknown.", entryCount: 2)
  ];

  void createChapter(String title, String description) async {
    final chapter = {
      "title": title,
      "description": description,
      "imageUrl": [],
      "entryCount": 0,
    };
    final bool status = await chapterService.createChapter(chapter);
    SnackBar snackBar;
    if(status) {
      fetchChapters();
      toggleCreate();
      snackBar = SnackBar(content: Text("Chapter created successfully"));
    }
    else snackBar = SnackBar(content: Text("Error creating chapter"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> loadChaptersFromCache() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final cachedData = chapterBox.get(userId);
    print("cachedData $cachedData");
    if(cachedData == null) return;
    final cachedChapters = cachedData["chapters"] ?? [];
    if(cachedChapters.isNotEmpty) {
      chapters.clear();
      for (var chapter in cachedChapters) {
        final Map<String, dynamic> chapterMap = Map<String, dynamic>.from(chapter as Map<dynamic, dynamic>);
        chapters.add(Chapter.fromMap(chapterMap));
      }
      setState(() {});
    }
  }

  Future<void> fetchChapters() async {
    isFetching = true;
    setState(() {});
    final List<Map<String, dynamic>> data = await chapterService.getChapters();
    if(data.isNotEmpty) {
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      //chapterBox.delete(userId);
      chapterBox.put(userId, {"chapters": data});
      //chapters = data.map((e) => ChapterAdvanced.fromMap(e)).toList();
    }
    isFetching = false;
    loadChaptersFromCache();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chapterBox.clear();
    loadChaptersFromCache();
    fetchChapters();
  }

  void toggleCreate() => setState(() => isCreate = !isCreate);

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
        )
      ),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 1.0), 
        duration: const Duration(milliseconds: 1000), 
        builder: (context, value, child){
          if(isFetching) {
            return Center(
              child: SpinKitCircle(
                color: themeData.colorScheme.onPrimary,
                size: 50.0,
              ),
            );
          }
          if(isCreate) return NewChapter(toggleCreate: toggleCreate, tween: value, addChapter: createChapter);
          if(chapters.isEmpty) return EmptyChapters(themeData: themeData, toggleCreate: toggleCreate, tween: value);
          return Scaffold(
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
            body: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Column(
                //mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text("Chapters", style: themeData.textTheme.titleLarge,),
                  const SizedBox(height: 10),
                  /*ElevatedButton(
                    onPressed: () => setState((){}), 
                    child: Text("Refresh")
                  ),*/
                  ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    clipBehavior: Clip.none,
                    itemCount: chapters.length,
                    physics: const ScrollPhysics(),
                    itemBuilder: (context, index){
                      if(widget.searchQuery == null || widget.searchQuery!.isEmpty) {
                        return GestureDetector(
                          onTap: () async {
                            /*Future<void> recursivePush() async {
                              print("pushing chapter ${chapters[index].title}");
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryListPage(chapter: chapters[index])));
                              print(result);
                              if(result != null && result == 'deleted') fetchChapters();
                              else if(result != null && result == 'updated') {
                                await fetchChapters();
                              }
                            }
                            recursivePush();*/
                            print("pushing chapter ${chapters[index].title}");
                            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryListPage(chapter: chapters[index])));
                            print(result);
                            if(result != null && result == 'deleted') fetchChapters();
                            else if(result != null && result == 'updated') fetchChapters();
                              
                          },
                          
                          child: ChapterCard(chapter: chapters[index], themeData: themeData)
                        );
                      }
                      else if(chapters[index].title!.toLowerCase().contains(widget.searchQuery!.toLowerCase()) || chapters[index].description!.toLowerCase().contains(widget.searchQuery!.toLowerCase())) {
                        return GestureDetector(
                          onTap: () async {
                            void recursivePush() async {
                              print("pushing chapter ${chapters[index].title}");
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryListPage(chapter: chapters[index])));
                              print(result);
                              if(result != null && result == 'deleted') fetchChapters();
                              if(result != null && result == 'updated') {
                                await fetchChapters();
                                print('recursivePush');
                                if (mounted) {
                                // Delay pushing the updated chapter to avoid immediate re-push
                                  Future.delayed(const Duration(milliseconds: 100), () {
                                    recursivePush(); // Call the function recursively after fetching
                                  });
                                }
                              }
                            }

                            recursivePush();
                          },
                          child: ChapterCard(chapter: chapters[index], themeData: themeData)
                        );
                      }
                      else return Container();
                    }
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: toggleCreate,
              child: Icon(Icons.add, color: themeData.colorScheme.onPrimary,),
              backgroundColor: themeData.colorScheme.primary,
            ),
          );
        }
      )
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
  final void Function(String title, String description) addChapter;
  final double tween;
  const NewChapter({super.key, required this.toggleCreate, required this.addChapter, required this.tween});

  @override
  ConsumerState<NewChapter> createState() => _NewChapterState();
}

class _NewChapterState extends ConsumerState<NewChapter> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  void _addChapter() {
    if(titleController.text.isEmpty || descriptionController.text.isEmpty) return;
    widget.addChapter(titleController.text.trim(), descriptionController.text.trim());
    titleController.clear();
    descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Chapters", style: themeData.textTheme.titleLarge,),
              const SizedBox(height: 50),
              Stack(
                children: [
                  const ImageStack(height: 450, width: 320, offset: Offset(3, 0), rotation: -7,),
                  const ImageStack(height: 450, width: 320, offset: Offset(0, 7), rotation: 7,),
                  ImageStack(height: 450, width: 320, 
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          height: 300,
                          width: 300,
                          color: Colors.white,
                          child: CachedNetworkImage(imageUrl: "https://cdn.pixabay.com/photo/2012/08/27/14/19/mountains-55067_640.png", fit: BoxFit.cover,),
                        ),
                        TextField(
                          controller: titleController,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(color: Color(0xffFF9432), fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.w600, decoration: TextDecoration.none, decorationThickness: 0, height: 1.1),   
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                            labelStyle: TextStyle(color: Colors.white),
                            label: Center(child: Text("Title", style: TextStyle(color: Color(0xffFF9432), fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.w600))),
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
              const SizedBox(height: 60,),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: widget.toggleCreate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeData.colorScheme.surface,
                        elevation: 10
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
                      ),
                      onPressed: _addChapter,
                      child: Text("Create", style: themeData.textTheme.titleMedium?.copyWith(color: Colors.white),)
                    ),
                  )
                ],
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
  }

  @override
  void dispose(){
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}