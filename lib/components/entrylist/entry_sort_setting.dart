import 'package:flutter/material.dart';
import 'package:reflect/components/entrylist/entrylist_sliding_carousel.dart';
import 'package:reflect/models/tag.dart';

class EntrySortSetting extends StatelessWidget {
  final String sortMethod;
  final bool isAscending;
  final bool isGroupedEntries;
  final List<Tag> tags;
  final List<bool> selectedTags;
  final void Function(String sortMethod, bool isAscending) onSort;
  final void Function() toggleGroupEntries;
  final void Function(int index) toggleTagSelection;
  final ThemeData themeData; 
  const EntrySortSetting({super.key, required this.sortMethod, required this.isAscending, required this.isGroupedEntries, required this.onSort, required this.toggleGroupEntries, required this.themeData, required this.tags, required this.selectedTags, required this.toggleTagSelection});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      //padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 5),
      decoration: BoxDecoration(
        color: themeData.colorScheme.secondary,
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: (){ onSort(sortMethod, true); }, icon: Icon(Icons.keyboard_double_arrow_up, size: 26, color: isAscending ? themeData.colorScheme.primaryFixed : themeData.colorScheme.onPrimary,)),
              IconButton(onPressed: (){ onSort(sortMethod, false); }, icon: Icon(Icons.keyboard_double_arrow_down, size: 26, color: !isAscending ? themeData.colorScheme.primaryFixed : themeData.colorScheme.onPrimary,)),
              Container(width: 2, height: 40, color: themeData.colorScheme.onPrimary.withOpacity(0.6),),
              IconButton(onPressed: (){ onSort("time", isAscending); }, icon: Icon(Icons.schedule, size: 26, color: sortMethod == 'time' ? themeData.colorScheme.primaryFixed : themeData.colorScheme.onPrimary,)),
              IconButton(onPressed: (){ onSort("alpha", isAscending); }, icon: Icon(Icons.sort_by_alpha, size: 26, color: sortMethod == 'alpha' ? themeData.colorScheme.primaryFixed : themeData.colorScheme.onPrimary,)),
              IconButton(onPressed: (){ onSort("length", isAscending); }, icon: Icon(Icons.stacked_bar_chart, size: 26, color: sortMethod == 'length' ? themeData.colorScheme.primaryFixed : themeData.colorScheme.onPrimary,)),
              Container(width: 2, height: 40, color: themeData.colorScheme.onPrimary.withOpacity(0.6),),
              IconButton(onPressed: (){ toggleGroupEntries(); }, icon: Icon(Icons.calendar_month, size: 26, color: isGroupedEntries ? themeData.colorScheme.primaryFixed : themeData.colorScheme.onPrimary,)),
            ],
          ),
          Divider(indent:10, endIndent: 10, color: themeData.colorScheme.onPrimary.withOpacity(0.6),),
          EntryListSlidingCarousel(tags: tags, themeData: themeData, selectedTags: selectedTags, toggleTagSelection: toggleTagSelection,),
          SizedBox(height: 10,)
        ],
      ),
    );
  }
}