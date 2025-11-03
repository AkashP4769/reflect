import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/achievement/ach_card.dart';
import 'package:reflect/components/entrylist/grid_or_column.dart';
import 'package:reflect/main.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:reflect/models/achievement.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/services/cache_service.dart';
import 'package:reflect/services/tag_service.dart';
import 'package:reflect/services/user_service.dart';
import 'package:collection/collection.dart';


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
  bool frequencyCalculating = false;
  int nGramValue = 3;
  int kFrequency = 10;
  int minWordLength = 1;

  Map<String, int> topKWords = {};
  List<int> usageHours = List.filled(24, 0);
  int highestUsageHour = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calculateAcheivements();
  }

  /// Calculate word frequencies for m-word combinations (n-grams)
  void calculateWordFrequencies(
    quill.Document delta,
    Map<String, int> frequencyMap,
    int m,
    int k,
    int minWordLength
  ) {
    final words = delta
        .toPlainText()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (words.length < m) return;

    for (int i = 0; i <= words.length - m; i++) {
      final combo = words.sublist(i, i + m).join(' ');
      frequencyMap[combo] = (frequencyMap[combo] ?? 0) + 1;
    }

    topKWords = calculateTopKWords(frequencyMap, k, minWordLength);
    setState(() {});
  }

  /// Returns the top K most frequent m-word combinations
  Map<String, int> calculateTopKWords(Map<String, int> frequencyMap, int k, int minWordLength) {
    final pq = PriorityQueue<MapEntry<String, int>>(
      (a, b) => a.value.compareTo(b.value),
    );

    for (var entry in frequencyMap.entries) {
      if (entry.key.length >= minWordLength) {
        pq.add(entry);
      }
      if (pq.length > k) pq.removeFirst();
    }

    final topK = <String, int>{};
    while (pq.isNotEmpty) {
      final e = pq.removeFirst();
      topK[e.key] = e.value;
    }

    // Reverse so highest frequencies come first
    return Map.fromEntries(topK.entries.toList().reversed);
  }


  void calculateAcheivements({bool frequencyCalculating = false}) async {
    final cacheService = CacheService();
    final userSetting = UserService().getUserSettingFromCache();
    final chapterDetails = await cacheService.exportFromCache(userSetting.uid);
    final allTags = TagService().getAllTags();
    final Map<String, int> wordFrequencyMap = {};

    usageHours = List.filled(24, 0);
    highestUsageHour = 0;

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

          if(entry['content'] != null && (entry['content'] as List).isNotEmpty || (entry['subsections'] != null && (entry['subsections'] as List).isNotEmpty)){
            int textLength = 0;

            if(entry['content'] != null && (entry['content'] as List).isNotEmpty){
              final delta = quill.Document.fromJson(entry['content']);
              textLength += delta.toPlainText().split(" ").length;

              //calculate word frequency
              if(frequencyCalculating) calculateWordFrequencies(delta, wordFrequencyMap, nGramValue, kFrequency, minWordLength);

              DateTime entryDate = DateTime.parse(entry['date']).toLocal();
              usageHours[entryDate.hour] += 1;
            }

            else if(entry['subsections'] != null && (entry['subsections'] as List).isNotEmpty){
              for(var subsection in List<Map<dynamic, dynamic>>.from(entry['subsections'] ?? [])){
                if(subsection['content'] != null && subsection['content'] != ''){
                  final delta = quill.Document.fromJson(subsection['content']);
                  textLength += delta.toPlainText().split(" ").length;

                  //calculate word frequency
                  if(frequencyCalculating) calculateWordFrequencies(delta, wordFrequencyMap, nGramValue, kFrequency, minWordLength);

                  DateTime entryDate = DateTime.parse(entry['date']).toLocal();
                  usageHours[entryDate.hour] += 1;
                }
              }
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

    
    if(frequencyCalculating) topKWords = calculateTopKWords(wordFrequencyMap, kFrequency, minWordLength);
    print("Word Frequencies: $topKWords");

    print("Usage Hours:");
    for(int i = 0; i < usageHours.length; i++){
      print("Hour $i: ${usageHours[i]} entries");
    }
    highestUsageHour = usageHours.reduce(max);
    print("Highest Usage Hour: $highestUsageHour");
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
   
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(child: Text("Your achievements", style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 18), textAlign: TextAlign.left,), alignment: Alignment.centerLeft,),
              ),
              _achievementBuilder(achievementsColumnCount, finalAchievements, completedAchievements, themeData),
      
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
      
              Align(alignment: Alignment.centerLeft,child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("Statistics", style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 18), textAlign: TextAlign.left,),
              ),),
              const SizedBox(height: 10,),
              
              //display stats in grid of 2 columns
              _statisticsBuilder(statColumnCount, themeData),
              const SizedBox(height: 20,),
              Align(alignment: Alignment.centerLeft,child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("Usage Time", style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 18), textAlign: TextAlign.left,),
              ),),

              _usageTimeBuilder(themeData),


              const SizedBox(height: 0,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text("Word Frequencies", style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 18), textAlign: TextAlign.left,),
                    const SizedBox(width: 10,),
                    Checkbox(
                      value: frequencyCalculating, 
                      onChanged: (value){
                        setState(() {
                          frequencyCalculating = value ?? true;
                        });
                        calculateAcheivements(frequencyCalculating: frequencyCalculating);
                      }
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20,),

              if(frequencyCalculating) _wordFreqConfigBuilder(themeData),

              const SizedBox(height: 20,),

              if(frequencyCalculating) _wordFreqBuilder(achievementsColumnCount, themeData),

              const SizedBox(height: 20,),
            ],
          )
        ),
      ),
    );
  }

  GridView _wordFreqBuilder(int achievementsColumnCount, ThemeData themeData) {
    return GridView.builder(
              shrinkWrap: true,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: achievementsColumnCount, 
                crossAxisSpacing: 10, 
                mainAxisSpacing: 10, 
                childAspectRatio: 6, 
                mainAxisExtent: 60
              ),
              itemCount: topKWords.length,
              itemBuilder: (BuildContext context, int index){
                return Container(

                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  //margin: const EdgeInsets.symmetric(vertical: 10),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(topKWords.keys.elementAt(index), style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontSize: 16, overflow: TextOverflow.clip), textAlign: TextAlign.center,),
                      const SizedBox(height: 10,),
                      Align(child: Text(topKWords.values.elementAt(index).toString(), style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 18), textAlign: TextAlign.center,)),
                    ],
                  ),
                );
              }
            );
  }

  Row _wordFreqConfigBuilder(ThemeData themeData) {
    return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("N-gram Value: ", style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontSize: 16),),
                    const SizedBox(width: 10,),
                    DropdownButton<int>(
                      value: nGramValue,
                      items: [1, 2, 3, 4, 5].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString(), style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontSize: 16),),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          nGramValue = newValue ?? 1;
                          if (nGramValue == 1) {
                            minWordLength = 1;
                          }
                        });
                        calculateAcheivements(frequencyCalculating: frequencyCalculating);
                      },
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Top K Words: ", style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontSize: 16),),
                    const SizedBox(width: 10,),
                    DropdownButton<int>(
                      value: kFrequency,
                      items: [5, 10, 15, 20, 25, 30].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString(), style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontSize: 16),),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          kFrequency = newValue ?? 10;
                        });
                        calculateAcheivements(frequencyCalculating: frequencyCalculating);
                      },
                    ),
                  ],
                ),

                if(nGramValue == 1) Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Min Word Length: ", style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontSize: 16),),
                    const SizedBox(width: 10,),
                    DropdownButton<int>(
                      value: minWordLength,
                      items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString(), style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary, fontSize: 16),),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          minWordLength = newValue ?? 1;
                        });
                        calculateAcheivements(frequencyCalculating: frequencyCalculating);
                      },
                    ),
                  ],
                ),
              ],
            );
  }

  SizedBox _usageTimeBuilder(ThemeData themeData) {
    return SizedBox(
              width: double.infinity,
              height: 320,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth - 40; // padding
                  final barCount = usageHours.length;
                  final spacing = 8.0;
                  final totalSpacing = spacing * (barCount - 1);
                  final barWidth = (availableWidth - totalSpacing) / barCount;

                  // Dynamically decide how many hour labels to show
                  final screenWidth = constraints.maxWidth;
                  int labelStep;

                  if(screenWidth < 200) {
                    labelStep = 12; // show 2–3 labels
                  } else if (screenWidth < 300) {
                    labelStep = 9; 
                  } else if (screenWidth < 400) {
                    labelStep = 6; // show 4–5 labels
                  } else if (screenWidth < 600) {
                    labelStep = 3; // show 8 labels
                  } else if (screenWidth < 900) {
                    labelStep = 2; // show 12 labels
                  } else {
                    labelStep = 1; // show all 24 labels
                  }

                  final hourLabels = List.generate(25, (i) => i)
                      .where((i) => i % labelStep == 0)
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Y-axis labels
                                Text(
                                  highestUsageHour.toString(),
                                  style: themeData.textTheme.bodyMedium!.copyWith(
                                    color: themeData.colorScheme.onPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  (highestUsageHour / 3 * 2).floor().toString(),
                                  style: themeData.textTheme.bodyMedium!.copyWith(
                                    color: themeData.colorScheme.onPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  (highestUsageHour / 3 * 1).floor().toString(),
                                  style: themeData.textTheme.bodyMedium!.copyWith(
                                    color: themeData.colorScheme.onPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 50),
                                  child: Text(
                                    "0",
                                    style: themeData.textTheme.bodyMedium!.copyWith(
                                      color: themeData.colorScheme.onPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),// Extra space for alignment
                              ],
                            ),

                            Transform.translate(
                              offset: const Offset(0, -25),
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Text(
                                  "Entries",
                                  style: themeData.textTheme.bodyMedium!.copyWith(
                                    color: themeData.colorScheme.onPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 5),

                        Expanded(
                          child: Column(
                            children: [
                              // Histogram bars
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(barCount, (index) {
                                  final heightRatio = (highestUsageHour == 0)
                                      ? 0
                                      : (usageHours[index] / highestUsageHour).clamp(0.0, 1.0);
                          
                                  return Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                        width: barWidth,
                                        height: 250,
                                        decoration: BoxDecoration(
                                          color: themeData.colorScheme.secondary.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      Container(
                                        width: barWidth,
                                        height: 250 * heightRatio.toDouble(),
                                        decoration: BoxDecoration(
                                          color: themeData.colorScheme.primary,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                          
                              const SizedBox(height: 10),
                          
                              // Dynamic hour labels
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: hourLabels.map((hour) {
                                  return Text(
                                    "$hour:00",
                                    style: themeData.textTheme.bodyMedium!.copyWith(
                                      color: themeData.colorScheme.onPrimary,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                }).toList(),
                              ),
                          
                              Text(
                                "Usage hour", 
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
  }

  GridView _statisticsBuilder(int statColumnCount, ThemeData themeData) {
    return GridView.builder(
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
            );
  }

  GridView _achievementBuilder(int achievementsColumnCount, List<Achievement> finalAchievements, List<Achievement> completedAchievements, ThemeData themeData) {
    return GridView.builder(
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
            );
  }}