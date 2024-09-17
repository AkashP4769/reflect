import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/components/journal/chapter_header.dart';
import 'package:reflect/components/journal/entry_card.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/chapter.dart';
import 'package:intl/intl.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/pages/entry.dart';

class EntryListPage extends ConsumerStatefulWidget {
  final Chapter? chapter;
  const EntryListPage({super.key, this.chapter});

  @override
  ConsumerState<EntryListPage> createState() => _EntryListPageState();
}

class _EntryListPageState extends ConsumerState<EntryListPage> {
  late ChapterAdvanced chapter = ChapterAdvanced(chapter: widget.chapter!);
  List<Entry> entries = [
    //Entry(title: 'Quiet Revelations', content: 'As I sat by the window, watching the rain, I realized how much I’ve grown over the past year. It hasn’t been easy, but the small, quiet moments of realization...'),
    //Entry(title: "Reflections of the Past", content: "Looking back, I can see how much I’ve changed. The things that once seemed so important don’t hold the same weight anymore. It’s funny how time and perspective can shift our understanding..."),
    //Entry(title: "Lost and Found", content: "As I sat by the window, watching the rain, I realized how much I’ve grown over the past year. It hasn’t been easy, but the small, quiet moments of realization...")
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chapter.updateEntries(entries);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Scaffold(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40,),
            EntryListAppbar(themeData: themeData),
        
            const SizedBox(height: 20),
            ChapterHeader(chapter: chapter, themeData: themeData,),
            if(chapter.entries!.isNotEmpty) 
            ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: chapter.entryCount,
              clipBehavior: Clip.none,
              physics: const ScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 0),
              itemBuilder: (context, index) {
                return EntryCard(entry: chapter.entries![index], themeData: themeData);
              },
            )
            else Expanded(
              child: Container(
                //color: Colors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: Text('No entries found', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w500, fontSize: 18),)),
                    SizedBox(height: 80,),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ElevatedButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => EntryPage(entry: Entry(title: "",content: []),)));
          }, 
          child: Text('Add Entry', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600),),
        ),
      ),
    );
  }
}

class EntryListAppbar extends StatelessWidget {
  const EntryListAppbar({
    super.key,
    required this.themeData,
  });

  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: themeData.colorScheme.onPrimary,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        //const SizedBox(width: 10),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            height: 45,
            //width: double.infinity,
            child: SearchBar(
              backgroundColor: WidgetStateProperty.all(themeData.colorScheme.onTertiary),
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
        IconButton(
          onPressed: (){}, 
          icon: Icon(Icons.menu, color: themeData.colorScheme.onPrimary,),
        )
      ],
    );
  }
}