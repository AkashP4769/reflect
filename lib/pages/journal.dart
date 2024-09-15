import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reflect/main.dart';

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<JournalPage> {
  List chapters = [];

  Future<void> fetchChapters() async {}

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
          else if(chapters.isEmpty){
            //return EmptyChapters(themeData: themeData); 
            return NewChapter();
          }
          return ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index){
              return const ListTile(
                title: Text("Title"),
                subtitle: Text("Description"),
              );
            }
          );
        }
      )
    );
  }
}

class EmptyChapters extends StatelessWidget {
  final ThemeData themeData;
  const EmptyChapters({super.key, required this.themeData});

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
          onPressed: (){}, 
          child: Text("Create", style: themeData.textTheme.titleMedium?.copyWith(color: Colors.white)),
        )
      ],
    );
  }
}

class NewChapter extends StatefulWidget {

  NewChapter({super.key});

  @override
  State<NewChapter> createState() => _NewChapterState();
}

class _NewChapterState extends State<NewChapter> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(3, 0),
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
                  child: Image.network("https://cdn.pixabay.com/photo/2012/08/27/14/19/mountains-55067_640.png", fit: BoxFit.cover,),
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
                  maxLines: 2,
                  style: const TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 16, fontWeight: FontWeight.w400),   
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    labelStyle: TextStyle(color: Colors.white),
                    label: Center(child: Text("Description", style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.w400, decoration: TextDecoration.none, decorationThickness: 0, height: 0.7))),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    alignLabelWithHint: true
                  ),
                ),
                /*ElevatedButton(
                  onPressed: (){}, 
                  child: const Text("Create")
                )*/
              ],
            ),
          ),
        ],
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