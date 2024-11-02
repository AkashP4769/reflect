import 'package:flutter/material.dart';
import 'package:reflect/components/entry/tag_card.dart';
import 'package:reflect/models/tag.dart';

class SlidingCarousel extends StatelessWidget {
  final List<Tag> tags;
  final ThemeData themeData;
  final void Function(ThemeData themeData) showTagDialog;
  const SlidingCarousel({super.key, required this.tags, required this.themeData, required this.showTagDialog});

  @override
  Widget build(BuildContext context) {
    final List<Tag> entryTags = tags;
    return SizedBox(
      height: 40, // Adjust height to fit your items
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: entryTags.length + 1,
        itemBuilder: (context, index) {
          if(index == entryTags.length){
            return Padding(
              padding: EdgeInsets.only(right: 2),
              child: GestureDetector(child: TagCard(tag: Tag(name: index != 0 ? "+" : "Add Tag +", color: themeData.colorScheme.primary.value), themeData: themeData, selected: false, deleteBit: false), onTap: (){showTagDialog(themeData);},),
            );
          }
          return Center(
            child: Padding(
              padding: EdgeInsets.only(right: index == entryTags.length - 1 ? 0 : 2),
              child: GestureDetector(child: TagCard(tag: entryTags[index], themeData: themeData, selected: true, deleteBit: false),  onTap: (){showTagDialog(themeData);}),
            ),
          );
        },
      ),
    );
  }
}