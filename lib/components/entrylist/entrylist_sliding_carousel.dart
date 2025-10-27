import 'package:flutter/material.dart';
import 'package:reflect/components/entry/tag_card.dart';
import 'package:reflect/models/tag.dart';

class EntryListSlidingCarousel extends StatelessWidget {
  final List<Tag> tags;
  final List<bool> selectedTags;
  final void Function(int index) toggleTagSelection;
  final ThemeData themeData;
  const EntryListSlidingCarousel({super.key, required this.tags, required this.themeData, required this.selectedTags, required this.toggleTagSelection});

  @override
  Widget build(BuildContext context) {
    final List<Tag> entryTags = tags;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 40, // Adjust height to fit your items
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: entryTags.length,
          itemBuilder: (context, index) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: GestureDetector(child: TagCard(tag: entryTags[index], themeData: themeData, selected: selectedTags[index], deleteBit: false),  onTap: (){toggleTagSelection(index);}),
              ),
            );
          },
        ),
      ),
    );
  }
}