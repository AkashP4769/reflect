import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/chapter.dart';

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
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
          )
        ),
        child: Column(
          children: [
            ChapterHeader(chapter: chapter,),
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
  const ChapterHeader({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}