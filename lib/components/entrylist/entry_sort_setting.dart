import 'package:flutter/material.dart';

class EntrySortSetting extends StatelessWidget {
  final String sortMethod;
  final bool isAscending;
  final bool isGroupedEntries;
  final void Function(String sortMethod, bool isAscending) onSort;
  final void Function() toggleGroupEntries;
  final ThemeData themeData; 
  const EntrySortSetting({super.key, required this.sortMethod, required this.isAscending, required this.isGroupedEntries, required this.onSort, required this.toggleGroupEntries, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(onPressed: (){ onSort(sortMethod, true); }, icon: Icon(Icons.keyboard_double_arrow_up, size: 26, color: isAscending ? themeData.colorScheme.primary : themeData.colorScheme.onPrimary,)),
          IconButton(onPressed: (){ onSort(sortMethod, false); }, icon: Icon(Icons.keyboard_double_arrow_down, size: 26, color: !isAscending ? themeData.colorScheme.primary : themeData.colorScheme.onPrimary,)),
          Container(width: 2, height: 40, color: themeData.colorScheme.onPrimary.withOpacity(0.6),),
          IconButton(onPressed: (){ onSort("time", isAscending); }, icon: Icon(Icons.schedule, size: 26, color: sortMethod == 'time' ? themeData.colorScheme.primary : themeData.colorScheme.onPrimary,)),
          IconButton(onPressed: (){ onSort("alpha", isAscending); }, icon: Icon(Icons.sort_by_alpha, size: 26, color: sortMethod == 'alpha' ? themeData.colorScheme.primary : themeData.colorScheme.onPrimary,)),
          IconButton(onPressed: (){ onSort("count", isAscending); }, icon: Icon(Icons.stacked_bar_chart, size: 26, color: sortMethod == 'count' ? themeData.colorScheme.primary : themeData.colorScheme.onPrimary,)),
          Container(width: 2, height: 40, color: themeData.colorScheme.onPrimary.withOpacity(0.6),),
          IconButton(onPressed: (){ toggleGroupEntries(); }, icon: Icon(Icons.calendar_month, size: 26, color: isGroupedEntries ? themeData.colorScheme.primary : themeData.colorScheme.onPrimary,)),
        ],
      ),
    );
  }
}