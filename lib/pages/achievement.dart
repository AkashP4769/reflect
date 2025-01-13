import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/achievement/ach_card.dart';
import 'package:reflect/main.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:reflect/models/achievement.dart';

class AchievementPage extends ConsumerStatefulWidget {
  const AchievementPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<AchievementPage> {
  List<Achievement> achievements = [
    Achievement(title: "First Impressions", description: "Create your very first journal entry", icon: Icons.star, color: Colors.orangeAccent),
    Achievement(title: "Epic Chronicler", description: "Write 100,000 words in total.", icon: Icons.history_edu, color: Colors.white),
    //Achievement(title: "Master Chronicler", description: "Write 500,000 words in total.", icon: Icons.history_edu, color: Colors.white),
    Achievement(title: "New Journey", description: "Create your first chapter", icon: Icons.history_edu, color: Colors.white),
    Achievement(title: "Saga Creator", description: "Create 10 chapters", icon: Icons.history_edu, color: Colors.white),

    Achievement(title: "Taggy", description: "Create 10 tags", icon: Icons.tag, color: Colors.lightBlueAccent),
    Achievement(title: "Tag Master", description: "Create 50 tags", icon: Icons.tag, color: Colors.lightBlueAccent),

    Achievement(title: "Favorites Fanatic", description: "Favorite 25 of your own entries", icon: Icons.favorite_outline, color: Colors.pinkAccent),
    Achievement(title: "Favorites Master", description: "Favorite 50 of your own entries", icon: Icons.favorite_rounded, color: Colors.pinkAccent),

    Achievement(title: "The Collector", description: "Create 100 entries", icon: Icons.collections, color: Colors.greenAccent),
    Achievement(title: "The Chronicler", description: "Create 500 entries", icon: Icons.collections, color: Colors.greenAccent),

    //Upload your first image achievement
    Achievement(title: "Picture Perfect", description: "Upload your first image", icon: Icons.image, color: Colors.blueAccent),
    Achievement(title: "Photographer", description: "Upload 10 images", icon: Icons.image, color: Colors.blueAccent),

    Achievement(title: "Short and sweet", description: "Write an entry with fewer than 50 words.", icon: Icons.text_fields, color: Colors.purpleAccent),
    Achievement(title: "Long-winded", description: "Write an entry with more than 1000 words.", icon: Icons.text_fields, color: Colors.purpleAccent),

  ];


  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
        )
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Achievements", style: themeData.textTheme.titleLarge,),
            SizedBox(height: 20,),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 16),
              itemBuilder: (BuildContext context, int index){
                return AchievementCard(achievement: achievements[index], achieved: true, themeData: themeData);
              }
            )
          ],
        ),
      ),
    );
  }}