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
            return EmptyChapters(themeData: themeData); 
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
    return const Placeholder();
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