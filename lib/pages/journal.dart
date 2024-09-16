import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/journal/chapterCard.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/chapter.dart';

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<JournalPage> {
  bool isCreate = false;
  late List<Chapter> chapters = [
    Chapter(title: "A New Begining", description: "it marks the start of a new phase in life, where every step feels like an adventure into the unknown.", entryCount: 16),
    Chapter(title: "Embracing the Unknown", description: "A time of stepping into uncertainty with courage. trusting the process and allowing life to unfold in unexpected ways.", entryCount: 12)
  ];

  //List<Chapter> chapters = [];

  void addChapter(String title, String description) {
    setState(() {
      chapters.add(Chapter(title: title, description: description, entryCount: 0));
      isCreate = false;
    });
  }

  
  Future<void> fetchChapters() async {}

  void toggleCreate() => setState(() => isCreate = !isCreate);

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
        )
      ),
      child: FutureBuilder(
        future: fetchChapters(), 
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const CircularProgressIndicator();
          }
          else if(snapshot.hasError){
            return const Text("Error");
          }
          else {
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0), 
              duration: const Duration(milliseconds: 1000), 
              builder: (context, value, child){
                if(isCreate) return NewChapter(toggleCreate: toggleCreate, tween: value, addChapter: addChapter);
                if(chapters.isEmpty) return EmptyChapters(themeData: themeData, toggleCreate: toggleCreate, tween: value);
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: chapters.length,
                  itemBuilder: (context, index){
                    return ChapterCard(chapter: chapters[index], themeData: themeData);
                  }
                );
              }
            );
          }
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
        )
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
                  Transform.translate(
                    offset: const Offset(3, 0),
                    child: Transform(
                      transform: Matrix4.identity()..rotateZ(-7 * 3.1415927 / 180),
                      alignment: FractionalOffset.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        height: 450,
                        width: 320,
                        decoration: BoxDecoration(
                          color: const Color(0xffEAEAEA),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3)
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, 7),
                    child: Transform(
                      transform: Matrix4.identity()..rotateZ(7 * 3.1415927 / 180),
                      alignment: FractionalOffset.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        height: 450,
                        width: 320,
                        decoration: BoxDecoration(
                          color: const Color(0xffEAEAEA),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3)
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 450,
                    width: 320,
                    decoration: BoxDecoration(
                      color: const Color(0xffEAEAEA),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3)
                        )
                      ],
                    ),
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
                        TextFormField(
                          controller: titleController,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(color: Color(0xffFF9432), fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.w600, decoration: TextDecoration.none, decorationThickness: 0, height: 1),   
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
                        TextFormField(
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
                      onPressed: _addChapter,
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
                      onPressed: () => widget.addChapter(titleController.text, descriptionController.text),
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