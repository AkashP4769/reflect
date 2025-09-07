import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/journal/chapter_card.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/chapter.dart';
import 'package:reflect/pages/screenlock.dart';
import 'package:reflect/services/auth_service.dart';
import 'package:reflect/services/cache_service.dart';

class HomePage extends ConsumerStatefulWidget {
  final void Function() goToJournalPage;
  const HomePage({super.key, required this.goToJournalPage});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final datetime = DateTime.now();
  final List<String> quotes = [
    "Don't let a bad day make you feel like you have a bad life",
    "The only way to do great work is to love what you do",
    "The best way to predict the future is to create it",
    "The only limit to our realization of tomorrow will be our doubts of today",
    "The only thing standing between you and your goal is the story you keep telling yourself as to why you can't achieve it",
    "The only person you are destined to become is the person you decide to be",
    "The only way to achieve the impossible is to believe it is possible",
    "The only way to get started is to quit talking and begin doing",
    "The only way to make sense out of change is to plunge into it, move with it, and join the dance",
    "The only way to discover the limits of the possible is to go beyond them into the impossible",
  ];

  final CacheService cacheService = CacheService();
  List<Chapter> chapters = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadChaptersFromCache();
  }

  void loadChaptersFromCache(){
    chapters = cacheService.loadChaptersFromCache() ?? [];
    chapters.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        /*gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
        )*/
      ),
      child: SingleChildScrollView(
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: 0, end: 4),
          builder: (context, value, child) {
            return Opacity(
              opacity: 1,
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(opacity: min(value, 1), child: Align(child: Text("Reflect", style: themeData.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600, fontSize: 28),), alignment: Alignment.center,)),
                const SizedBox(height: 30,),
                Opacity(
                  opacity: min(max(0, value - 1), 1),
                  child: Row(
                    children: [
                      Text((datetime.hour < 12 && datetime.hour > 6 ? "Good Morning" : datetime.hour < 18 ? "Good Afternoon" : "Good Evening"), style: themeData.textTheme.titleMedium!.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: themeData.colorScheme.primary),),
                      const SizedBox(width: 10,),
                      Icon((datetime.hour < 12 && datetime.hour > 6 ? Icons.wb_sunny : datetime.hour < 18 ? Icons.brightness_5 : Icons.brightness_3), color: datetime.hour < 6 && datetime.hour > 18 ? Colors.white : themeData.colorScheme.primary, size: 30,),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                Opacity(
                  opacity: min(max(0, value - 2), 1),
                  child: Text(quotes[datetime.day % quotes.length], style: themeData.textTheme.bodyMedium!.copyWith(fontSize: 16),)
                ),
                const SizedBox(height: 30,),
            
                if(chapters.isNotEmpty) Opacity(
                  opacity: min(max(0, value - 3), 1),
                  child: _buildChapterIntro(chapters, themeData, widget.goToJournalPage)
                )
                else Opacity(
                  opacity: min(max(0, value - 3), 1),
                  child: _buildEmptyChapterIntro(themeData)
                ),
                
                SizedBox(height: 30,),    
              ],
              ),
            );
          },
          ),
        ),
    );
  }
}

Widget _buildChapterIntro(List<Chapter> chapters, ThemeData themeData, void Function() goToJournalPage){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("The chapters of your life", style: themeData.textTheme.titleMedium!.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: themeData.colorScheme.primary),),
      const SizedBox(height: 10,),
      TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1000),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, value, child) => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: min(2, chapters.length),
            itemBuilder: (BuildContext context, int index){
              return GestureDetector(
                onTap: () => goToJournalPage(),
                child: ChapterCard(chapter: chapters[index], themeData: themeData, tween: value, index: 0,)
              );
            }
          ),
        
      ),
      const SizedBox(height: 10,),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Go to ", style: themeData.textTheme.bodyMedium,),
          InkWell(
            onTap: () => goToJournalPage(),
            child: Text("Journal", style: themeData.textTheme.bodyMedium!.copyWith( color: themeData.colorScheme.primary, fontWeight: FontWeight.w600),),
          ),
          Text(" for more chapters", style: themeData.textTheme.bodyMedium,),
        ],
      ),
    ],
  );
}

Widget _buildEmptyChapterIntro(ThemeData themeData){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20,),
      Text("Looks like you're new here", style: themeData.textTheme.titleMedium!.copyWith(fontSize: 24, fontWeight: FontWeight.w600, color: themeData.colorScheme.primary),), 
      const SizedBox(height: 10,),

      Text("Go on, explore the app and start your journey of self-reflection. You can create chapters, add entries, and track your progress.", style: themeData.textTheme.bodyMedium!.copyWith(fontSize: 16),),
      const SizedBox(height: 10,),

      Text("I'll be adding more features soon, so stay tuned!", style: themeData.textTheme.bodyMedium!.copyWith(fontSize: 16),),
      const SizedBox(height: 10,),
    ],
  );
}