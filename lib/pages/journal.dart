import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:reflect/components/common/loading.dart';
import 'package:reflect/components/journal/chapter_card.dart';
import 'package:reflect/components/journal/image_stack.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/chapter.dart';
import 'package:reflect/pages/entrylist.dart';
import 'package:reflect/services/chapter_service.dart';
import 'package:reflect/services/timestamp_service.dart';

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

  List<Chapter> chapters = [];

  //final RefreshController refreshController = RefreshController(initialRefresh: false);

  void createChapter(String title, String description, List<String>? images, DateTime date) async {
    final chapter = {
      "title": title,
      "description": description,
      "imageUrl": images ?? [],
      "entryCount": 0,
      "createdAt": date.toIso8601String(),
    };
    final bool status = await chapterService.createChapter(chapter);
    //timestampService.updateChapterTimestamp();
    SnackBar snackBar;
    if(status) {
      fetchChapters(true);
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
      chapters = chapters.reversed.toList();
      if(mounted) setState(() {});
    }
  }

  Future<void> fetchChapters(bool explicit) async {
    final chapterTimestamp = timestampService.getChapterTimestamp();
    final List<Map<String, dynamic>>? data = await chapterService.getChapters(explicit);
    if(data == null) return;
    else if (data.isNotEmpty) {
      print("adding data to  cache");
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      chapterBox.put(userId, {"chapters": data});
      //timestampService.updateChapterTimestamp();
      loadChaptersFromCache();
    }
    //isFetching = false;
    //
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

    return RefreshIndicator(
      onRefresh: () async {
        await fetchChapters(true);
      },
      child: Container(
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
            if(chapters.isEmpty) return Align(alignment: Alignment.center, child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: EmptyChapters(themeData: themeData, toggleCreate: toggleCreate, tween: value)));
            return Scaffold(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              body: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                              //print("pushing chapter ${chapters[index].title}");
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryListPage(chapter: chapters[index])));
                              //print(result);
                              if(result != null && result == true) fetchChapters(true);
                              //else if(result != null && result == 'updated') fetchChapters();
                                
                            },
                            
                            child: ChapterCard(chapter: chapters[index], themeData: themeData)
                          );
                        }
                        else if(chapters[index].title!.toLowerCase().contains(widget.searchQuery!.toLowerCase()) || chapters[index].description!.toLowerCase().contains(widget.searchQuery!.toLowerCase())) {
                          return GestureDetector(
                            onTap: () async {
                              //print("pushing chapter ${chapters[index].title}");
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryListPage(chapter: chapters[index])));
                              //print(result);
                              if(result != null && result == true) fetchChapters(true);
                              //else if(result != null && result == 'updated') fetchChapters();
                                
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
  late String randomImage;

  final possibleImages = [
      /*"https://cdn.pixabay.com/photo/2012/08/27/14/19/mountains-55067_640.png",
      "https://cdn.pixabay.com/photo/2024/02/23/21/25/landscape-8592826_1280.jpg",
      "https://cdn.pixabay.com/photo/2023/09/29/11/19/sunrays-8283601_1280.jpg",
      "https://cdn.pixabay.com/photo/2023/10/27/12/13/vineyard-8345243_960_720.jpg",
      "https://cdn.pixabay.com/photo/2023/10/26/08/24/autumn-8342089_960_720.jpg",

      "https://cdn.pixabay.com/photo/2022/12/13/18/00/autumn-7653897_960_720.jpg",
      "https://cdn.pixabay.com/photo/2016/05/25/18/02/maple-1415541_960_720.jpg",
      "https://cdn.pixabay.com/photo/2023/03/15/20/55/sunbeam-7855454_1280.jpg",
      "https://cdn.pixabay.com/photo/2020/06/23/19/23/fog-5333546_1280.jpg",
      "https://cdn.pixabay.com/photo/2020/12/06/17/58/trees-5809559_1280.jpg",
      "https://cdn.pixabay.com/photo/2024/09/19/22/21/ai-generated-9059933_1280.jpg",
      "https://cdn.pixabay.com/photo/2023/10/24/08/24/sailboats-8337698_1280.jpg",*/

      "https://img.freepik.com/free-photo/illustrated-watercolor-city_23-2151768998.jpg?t=st=1727633578~exp=1727637178~hmac=832056e2b0796154ecbbf6286f56bc84df55788d580704eb4f71e5c6d9f26e82&w=360",
      "https://img.freepik.com/free-photo/illustrated-watercolor-city_23-2151768901.jpg?t=st=1727633716~exp=1727637316~hmac=644795bb3ddf25f6331676148838424d51dec7b937627ef939704813bd5e9f0d&w=360",
      "https://img.freepik.com/free-photo/watercolor-city-illustrated_23-2151768980.jpg?t=st=1727633749~exp=1727637349~hmac=f394b698e1714f7ab8e0e61bf45887de2029b17f8c93b265f169769f74f5e541&w=1380",
      "https://img.freepik.com/free-photo/illustrated-watercolor-city_23-2151768902.jpg?t=st=1727633766~exp=1727637366~hmac=d5516bcf667fbb03619a863dd29c37d9bae17f759c6b198aa473812f096c2106&w=360",
      "https://img.freepik.com/free-photo/watercolor-moon-illustration_23-2151641645.jpg?t=st=1727633779~exp=1727637379~hmac=5e27e94c0d1bf13770bafa8a506423e0ae3c0dfd30833efa7198d6b98c15e602&w=360",
      "https://img.freepik.com/free-photo/illustrated-watercolor-city_23-2151768952.jpg?t=st=1727633799~exp=1727637399~hmac=369b593f289ab87e2d219a02170d9d19a811a0233916c25cf25374fbdbd3c79f&w=996",
      "https://img.freepik.com/free-photo/digital-art-fruit-illustration_23-2151773075.jpg?t=st=1727633827~exp=1727637427~hmac=69736165963480c8056db404cc01fcf6d0f7b90dd91d2f4048462cb7d2a20a0e&w=360",
      "https://img.freepik.com/free-photo/digital-art-style-river-nature-landscape_23-2151825792.jpg?t=st=1727633824~exp=1727637424~hmac=9414f70adc8deaa8fbfcb76720166319533a01c3aab771afb83d9d2da258f80c&w=900",
      "https://img.freepik.com/free-photo/watercolor-eyes-illustration_23-2151678436.jpg?t=st=1727633925~exp=1727637525~hmac=3652924254f93a463cb33eb07e8dcf48e4957ab99719105257e8ace56dbaa4f1&w=900",
      "https://img.freepik.com/free-photo/adorable-watercolor-cat-illustration_23-2151510050.jpg?t=st=1727633926~exp=1727637526~hmac=59372c4a1f4738df2e814af6f42041dc165a7ff4f5031a4b84f5b2d6eb0fe3c2&w=360",
      "https://img.freepik.com/free-photo/watercolor-eyes-illustration_23-2151678475.jpg?t=st=1727633928~exp=1727637528~hmac=a9ccbea04e0bcde8b4e65c7ad6b5a28b2988b85693523788a46b05ba2a64f497&w=900",
      
      "https://img.freepik.com/free-photo/watercolor-moon-illustration_23-2151641655.jpg?t=st=1727633974~exp=1727637574~hmac=3364c273654dec516e3b07af5d1dac0b4d20f93ecf3210dfc6df6b36bb6626ae&w=360",
      "https://img.freepik.com/free-photo/anime-moon-landscape_23-2151645879.jpg?t=st=1727633954~exp=1727637554~hmac=245eefddffc7aef46c63e78d2ad471ed9dfcfeff3b71003ca2ea945e57c09cd5&w=900",
      "https://img.freepik.com/free-photo/watercolor-moon-illustration_23-2151641604.jpg?t=st=1727633976~exp=1727637576~hmac=080db3c25fdc64da64931b0537d4ba6e6647c2282469b462e290ae08a50734f7&w=360",

      "https://img.freepik.com/free-photo/digital-art-style-illustration-mental-health-day-awareness_23-2151813358.jpg?t=st=1727633974~exp=1727637574~hmac=935f9dba2611770e351d1cc349e022942e5ec582cb59a1bd4458eba516e7ecd6&w=360",

      "https://img.freepik.com/free-photo/digital-art-flower-landscape-painting_23-2151596809.jpg?t=st=1727634053~exp=1727637653~hmac=f227d3ff675dea5dea557791242240d5b39dbc9b9d501d40a2976d7553c04048&w=900",
      "https://img.freepik.com/free-photo/farm-lifestyle-digital-art_23-2151551086.jpg?t=st=1727634052~exp=1727637652~hmac=4eb8e0b1b6afe0b6599eea0e3aca1bc504cb3493436a463d5a6e14709c92e6ca&w=360",
      "https://img.freepik.com/free-photo/digital-art-style-river-nature-landscape_23-2151825665.jpg?t=st=1727634051~exp=1727637651~hmac=ada1008e289adecbe01360d677e67675772c308bc90f29f68d295ebe4b134cbf&w=360",
      "https://img.freepik.com/free-photo/lifestyle-summer-scene-with-cartoon-design_23-2151068402.jpg?t=st=1727634050~exp=1727637650~hmac=21d920849060f5615131364db563f716198a64e141d7c8ae08ec61828c187b52&w=900",
  ];



  
  void _addChapter() {
    if(titleController.text.isEmpty || descriptionController.text.isEmpty) return;
    widget.addChapter(titleController.text.trim(), descriptionController.text.trim(), [randomImage], DateTime.now());
    titleController.clear();
    descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
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
                          child: CachedNetworkImage(imageUrl: randomImage, fit: BoxFit.cover,),
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
    randomImage = possibleImages[DateTime.now().microsecond % possibleImages.length];
  }

  @override
  void dispose(){
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}