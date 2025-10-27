import 'package:flutter/material.dart';
import 'package:reflect/components/entry/tag_card.dart';
import 'package:reflect/models/tag.dart';

class SlidingCarousel extends StatelessWidget {
  final List<Tag> tags;
  final ThemeData themeData;
  final void Function(ThemeData themeData) showTagDialog;
  final bool? shouldWrap;
  final int columnCount;
  final bool initialPadding;
  const SlidingCarousel({super.key, required this.tags, required this.themeData, required this.showTagDialog, this.shouldWrap = false, required this.columnCount, this.initialPadding = true});

  @override
  Widget build(BuildContext context) {
    final List<Tag> entryTags = tags;
    if(shouldWrap == true && columnCount > 1){
      return Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: ScrollPhysics(),
          child: Wrap(
            spacing: 4,
            runSpacing: 0,
            children: [
              GestureDetector(child: TagCard(tag: Tag(name: entryTags.length == 0 ? "Add tag" : "+", color: themeData.colorScheme.primary.value), themeData: themeData, selected: false, deleteBit: false), onTap: (){showTagDialog(themeData);}),
              ...entryTags.map((tag) => GestureDetector(child: TagCard(tag: tag, themeData: themeData, selected: true, deleteBit: false), onTap: (){showTagDialog(themeData);})).toList(),
              
            ],
          ),
        ),
      );
    }

    return Container(
      //color: Colors.amber,
      margin: EdgeInsets.only(bottom: columnCount == 2 ? 10 : 0),
      height: 45, // Adjust height to fit your items
      child: ListView.builder(
        padding: EdgeInsets.only(left: initialPadding ? 0 : 0),
        scrollDirection: Axis.horizontal,
        itemCount: entryTags.length + 1,
        
        itemBuilder: (context, index) {
          if(index == entryTags.length){
            return Padding(
              padding: EdgeInsets.only(right: 5,),
              child: GestureDetector(child: TagCard(tag: Tag(name: index != 0 ? "+" : "Add Tag +", color: themeData.colorScheme.primary.value), themeData: themeData, selected: false, deleteBit: false), onTap: (){showTagDialog(themeData);},),
            );
          }
          return Center(
            child: Padding(
              padding: EdgeInsets.only(right: 5),
              child: GestureDetector(child: TagCard(tag: entryTags[index], themeData: themeData, selected: true, deleteBit: false),  onTap: (){showTagDialog(themeData);}),
            ),
          );
        },
      ),
    );
  }
}