import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/chapter.dart';
import 'package:intl/intl.dart';

class EntryListPage extends ConsumerStatefulWidget {
  final Chapter? chapter;
  const EntryListPage({super.key, this.chapter});

  @override
  ConsumerState<EntryListPage> createState() => _EntryListPageState();
}

class _EntryListPageState extends ConsumerState<EntryListPage> {
  late ChapterAdvanced chapter = ChapterAdvanced(chapter: widget.chapter!);

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Scaffold(
      body: Container(
        width: double.infinity,
        //padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
          )
        ),
        child: Column(
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

            const SizedBox(height: 20),
            ChapterHeader(chapter: chapter, themeData: themeData,),
            /*Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Entry $index'),
                    subtitle: Text('Content $index'),
                  );
                },
              ),
            ),*/
          ],
        ),
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
          

          if(chapter.imageUrl != null) ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(imageUrl: chapter.imageUrl ?? "", width: double.infinity, height: 200, fit: BoxFit.cover),
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