import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/achievement/ach_card.dart';
import 'package:reflect/main.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:reflect/models/achievement.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/services/cache_service.dart';
import 'package:reflect/services/tag_service.dart';
import 'package:reflect/services/user_service.dart';

class AchievementPage extends ConsumerStatefulWidget {
  const AchievementPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<AchievementPage> {
  List<Achievement> achievements = [
    Achievement(title: "First Impressions", description: "Create your very first journal entry", icon: Icons.star, color: Colors.orange),

    Achievement(title: "The Collector", description: "Create 100 entries", icon: Icons.task, color: Colors.amber),
    Achievement(title: "The Chronicler", description: "Create 500 entries", icon: Icons.receipt_long, color: Colors.yellow),

    //Achievement(title: "Epic Chronicler", description: "Write 100,000 words in total.", icon: Icons.history_edu, color: Colors.yellow),
    //Achievement(title: "Master Chronicler", description: "Write 500,000 words in total.", icon: Icons.history_edu, color: Colors.white),
    Achievement(title: "New Journey", description: "Create your first chapter", icon: Icons.auto_stories, color: Colors.teal),
    Achievement(title: "Saga Creator", description: "Create 10 chapters", icon: Icons.history_edu, color: Colors.tealAccent),

    Achievement(title: "Taggy", description: "Create 10 tags", icon: Icons.sell, color: Colors.lightBlue),
    Achievement(title: "Tag Master", description: "Create 50 tags", icon: Icons.style, color: Colors.cyan),

    Achievement(title: "Favorites Fanatic", description: "Favorite 25 of your own entries", icon: Icons.favorite_outline, color: Colors.pink),
    Achievement(title: "Favorites Master", description: "Favorite 50 of your own entries", icon: Icons.favorite_rounded, color: Colors.pinkAccent),

    //Upload your first image achievement
    Achievement(title: "Picture Perfect", description: "Upload your first image", icon: Icons.photo_camera, color: Colors.blueAccent),
    Achievement(title: "Photographer", description: "Upload 10 images", icon: Icons.photo_album, color: Colors.cyan),

    Achievement(title: "Short and sweet", description: "Write an entry with fewer than 50 words.", icon: Icons.fiber_manual_record, color: Colors.purple),
    Achievement(title: "Long-winded", description: "Write an entry with more than 1000 words.", icon: Icons.circle, color: Colors.purpleAccent),
  ];

  List<String> statistics = [
    "Entries Written",
    "Chapters Created",
    "Tags forged",
    "Favorited entries",
    "Images Uploaded",
    "Shortest Entry",
    "Longest Entry",
    "Words Written"
  ];
  List<int> statisticsValue = [0, 0, 0, 0, 0, 0, 0, 0];

  List<bool> achievementStatus = List.generate(13, (index) => false);

  bool showMoreAchievement = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calculateAcheivements();
  }

  void calculateAcheivements() async {
    final cacheService = CacheService();
    final userSetting = UserService().getUserSettingFromCache();
    final chapterDetails = await cacheService.exportFromCache(userSetting.uid);
    final allTags = TagService().getAllTags();

    bool firstEntry = false;
    bool firstChapter = false;
    bool tenChapter = false;
    bool tenTags = false;
    bool fiftyTags = false;
    bool twentyFiveFav = false;
    bool fiftyFav = false;
    bool hundredEntries = false;
    bool fiveHundredEntries = false;
    bool firstImage = false;
    bool tenImages = false;
    bool shortEntry = false;
    bool longEntry = false;

    int totalEntries = 0;
    int totalFavs = 0;
    int totalImages = 0;
    int totalChapters = chapterDetails.length;
    int totalTags = allTags.length;
    int shortestLength = 0;
    int longestLength = 0;
    int totalWords = 0;

    if(chapterDetails.isNotEmpty){
      firstChapter = true; //4
      if(totalChapters >= 10) tenChapter = true; //5
      

      for(var chapter in chapterDetails){
        totalEntries += (List.from(chapter['entries'] ?? [])).length;
        totalImages += List.from(chapter['imageUrl'] ?? []).length;

        for(var entry in List<Map<dynamic, dynamic>>.from(chapter['entries'] ?? [])){
          if(entry['favourite'] ?? false) totalFavs++;

          totalImages += List.from(entry['imageUrl'] ?? []).length;

          if(entry['content'] != null){
            int textLength;
            if(entry['content'] == null || (entry['content'] as List).isEmpty) textLength = 0;
            else {
              final delta = quill.Document.fromJson(entry['content']);
              textLength = delta.toPlainText().split(" ").length;
            }

            shortestLength = shortestLength == 0 ? textLength : min(shortestLength, textLength);
            longestLength = max(longestLength, textLength);
            totalWords += textLength;

            if(textLength < 50) shortEntry = true;
            if(textLength > 1000) longEntry = true;
          }
        }
      }
    }

    if(totalEntries >= 1) firstEntry = true; //1
    if(totalEntries >= 100) hundredEntries = true; //2
    if(totalEntries >= 500) fiveHundredEntries = true; //3

    if(totalTags >= 10) tenTags = true; //6
    if(totalTags >= 50) fiftyTags = true; //7

    if(totalFavs >= 25) twentyFiveFav = true; //8
    if(totalFavs >= 50) fiftyFav = true; //9

    if(totalImages >= 1) firstImage = true; //10
    if(totalImages >= 10) tenImages = true; //11

    achievementStatus = [firstEntry, hundredEntries, fiveHundredEntries, firstChapter, tenChapter, tenTags, fiftyTags, twentyFiveFav, fiftyFav, firstImage, tenImages, shortEntry, longEntry];
    statisticsValue = [totalEntries, totalChapters, totalTags, totalFavs, totalImages, shortestLength, longestLength, totalWords];

    print("Achievement Status: $achievementStatus");
    print("Total Entries: $totalEntries, Total Chapters: $totalChapters, Total Tags: $totalTags, Total Favs: $totalFavs, Total Images: $totalImages, Shortest: $shortestLength, Longest: $longestLength, Total Words: $totalWords");
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    final statColumnCount = max(2, (MediaQuery.of(context).size.width / 360).floor());
    final achievementsColumnCount = max(1, (MediaQuery.of(context).size.width / 480).floor());

    List<Achievement> completedAchievements = [];
    List<Achievement> lockedAchievements = [];
    for(int i = 0; i < achievements.length; i++){
      if(achievementStatus[i]) completedAchievements.add(achievements[i]);
      else lockedAchievements.add(achievements[i]);
    }

    List<Achievement> finalAchievements = [...completedAchievements, ...lockedAchievements];

    return Theme(
      data: themeData,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 0, vertical: 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10,),
              Text("Achievements", style: themeData.textTheme.titleLarge,),
              const SizedBox(height: 10,),
              /*GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 16),
                itemBuilder: (BuildContext context, int index){
                  return AchievementCard(achievement: achievements[index], achieved: true, themeData: themeData);
                }
              )*/
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(child: Text("Your achievements", style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 18), textAlign: TextAlign.left,), alignment: Alignment.centerLeft,),
              ),
              GridView.builder(
                shrinkWrap: true,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: achievementsColumnCount, 
                  crossAxisSpacing: 10, 
                  mainAxisSpacing: 1, 
                  childAspectRatio: 6, 
                  mainAxisExtent: 120
                ),
                itemCount: showMoreAchievement ? finalAchievements.length : min(achievementsColumnCount * 3, finalAchievements.length),
                itemBuilder: (BuildContext context, int index){
                  return AchievementCard(achievement: finalAchievements[index], achieved: index >= completedAchievements.length ? false : true, themeData: themeData);
                }
              ),
      
              const SizedBox(height: 10,),
              InkWell(
                onTap: (){
                  setState(() {
                    showMoreAchievement = !showMoreAchievement;
                  });
                },
                
                child: Text(showMoreAchievement ? "Show Less" : "Show More", style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.primary, fontSize: 16), textAlign: TextAlign.center,),
              ),
              const SizedBox(height: 20,),
      
              Align(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("Statistics", style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 18), textAlign: TextAlign.left,),
              ), alignment: Alignment.centerLeft,),
              const SizedBox(height: 10,),
              
              //display stats in grid of 2 columns
              GridView.builder(
                shrinkWrap: true,
                clipBehavior: Clip.none,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: statistics.length,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: statColumnCount, crossAxisSpacing: 10, mainAxisSpacing: 16, childAspectRatio: 2.0, mainAxisExtent: 120),
                itemBuilder: (BuildContext context, int index){
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                    color: themeData.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5)
                      )
                    ]
                  ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(statistics[index], style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 16, overflow: TextOverflow.clip), textAlign: TextAlign.center,),
                        const SizedBox(height: 10,),
                        Align(child: Text(statisticsValue[index].toString(), style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 18), textAlign: TextAlign.center,)),
                      ],
                    ),
                  );
                }
              ),
              const SizedBox(height: 20,),
            ],
          )
        ),
      ),
    );
  }}