import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/chapter.dart';
import 'package:intl/intl.dart';
import 'package:reflect/models/entry.dart';

class EntryListPage extends ConsumerStatefulWidget {
  final Chapter? chapter;
  const EntryListPage({super.key, this.chapter});

  @override
  ConsumerState<EntryListPage> createState() => _EntryListPageState();
}

class _EntryListPageState extends ConsumerState<EntryListPage> {
  late ChapterAdvanced chapter = ChapterAdvanced(chapter: widget.chapter!);
  List<Entry> entries = [
    Entry(title: 'Quiet Revelations', content: 'As I sat by the window, watching the rain, I realized how much I’ve grown over the past year. It hasn’t been easy, but the small, quiet moments of realization...'),
    Entry(title: "Reflections of the Past", content: "Looking back, I can see how much I’ve changed. The things that once seemed so important don’t hold the same weight anymore. It’s funny how time and perspective can shift our understanding..."),
    Entry(title: "Lost and Found", content: "As I sat by the window, watching the rain, I realized how much I’ve grown over the past year. It hasn’t been easy, but the small, quiet moments of realization...")
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
              SizedBox(height: 30,),
              Row(
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
                        backgroundColor: WidgetStateProperty.all(themeData.colorScheme.tertiary),
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
              ),
          
              const SizedBox(height: 10),
              ChapterHeader(chapter: chapter, themeData: themeData,),
              if(chapter.entries != null || chapter.entries!.isNotEmpty) ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: chapter.entryCount,
                clipBehavior: Clip.none,
                physics: const ScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 0),
                itemBuilder: (context, index) {
                  return EntryCard(entry: chapter.entries![index], themeData: themeData);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class EntryCard extends StatelessWidget {
  final Entry entry;
  final ThemeData themeData;
  const EntryCard({super.key, required this.entry, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: themeData.colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.title, style: themeData.textTheme.titleMedium?.copyWith(color: themeData.colorScheme.primary),),
          Text(DateFormat('dd MMM yyyy').format(entry.date), style: themeData.textTheme.bodySmall?.copyWith(color: themeData.colorScheme.onPrimary),),
          SizedBox(height: 10,),
          Text(entry.content, style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary), maxLines: 3,),
        ],
      ),
    );
  }
}


class ChapterHeader extends StatelessWidget {
  final ChapterAdvanced chapter;
  final ThemeData themeData;
  const ChapterHeader({super.key, required this.chapter, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(chapter.imageUrl != null) Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 4,
                  blurRadius: 7,
                  offset: const Offset(0, 3)
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(imageUrl: chapter.imageUrl ?? "", width: double.infinity, height: 200, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          Text(chapter.title, style: themeData.textTheme.titleLarge?.copyWith(color: const Color(0xffFF9432),),),
          const SizedBox(height: 10),
          Text(chapter.description, style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600,), textAlign: TextAlign.center,),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.book, color: themeData.colorScheme.onPrimary,),
                  const SizedBox(width: 5),
                  Text('No. of entries - ${chapter.entryCount}', style: themeData.textTheme.bodySmall?.copyWith(color: themeData.colorScheme.onPrimary),)
                ],
              ),
              Row(
                children: [
                  Icon(Icons.lock_clock, color: themeData.colorScheme.onPrimary,),
                  const SizedBox(width: 5),
                  Text('Created on - ${DateFormat('dd/MM/yyyy').format(chapter.createdOn)}', style: themeData.textTheme.bodySmall?.copyWith(color: themeData.colorScheme.onPrimary),)
                ],
              )
            ],
          ),
          Divider(color: themeData.colorScheme.onPrimary, thickness: 1, height: 30),

        ],
      ),
    );
  }
}