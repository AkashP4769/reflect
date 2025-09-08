import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reflect/components/entrylist/grid_or_column.dart';
import 'package:reflect/components/journal/entry_card.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/pages/entry.dart';
import 'package:reflect/services/entrylist_service.dart';
import 'package:reflect/services/image_service.dart';

class GroupedEntryBuilder extends StatefulWidget {
  final List<Entry> entries;
  final List<bool> visibleMap;
  final ThemeData themeData;
  final String sortMethod;
  final bool isAscending;
  final void Function(bool explicit) fetchEntries;
  final void Function(bool value) updateHaveEdit;
  
  const GroupedEntryBuilder({super.key, required this.entries, required this.visibleMap, required this.themeData, required this.fetchEntries, required this.updateHaveEdit, required this.sortMethod, required this.isAscending});

  @override
  State<GroupedEntryBuilder> createState() => _GroupedEntryBuilderState();
}

class _GroupedEntryBuilderState extends State<GroupedEntryBuilder> {
  final EntrylistService entrylistService = EntrylistService();
  final Map<String, int> monthValue = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    final columnCount = min(3, max(1, (MediaQuery.of(context).size.width / 415).floor()));
    Map<String, List<Entry>> _groupedEntries = entrylistService.groupEntriesByDate(widget.entries);
    print(_groupedEntries.keys.toString());
    final groupedEntries = Map.fromEntries(_groupedEntries.entries.toList()..sort((a, b) => (int.parse(a.key.split(' ')[1]) * 100 + monthValue[a.key.split(' ')[0]]!).compareTo(int.parse(b.key.split(' ')[1]) * 100 + monthValue[b.key.split(' ')[0]]!)));
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: groupedEntries.length,
      clipBehavior: Clip.none,
      physics: const ScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemBuilder: (context, index){
        final date = groupedEntries.keys.elementAt(widget.isAscending && widget.sortMethod == 'time' ? index : groupedEntries.length - 1 - index);
        final _entries = groupedEntries[date];
        final validEntries = entrylistService.sortEntries(_entries!, widget.sortMethod, widget.isAscending);
        //final random = Random();

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal:columnCount == 1 ? 0 : 30),
              child: GestureDetector(
                onTap: (){
                  widget.visibleMap[index] = !widget.visibleMap[index];
                  setState(() {});
                },
                child: Row(
                  children: [
                    Text(date, style: widget.themeData.textTheme.bodyMedium?.copyWith(color: widget.themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600),),
                    Icon(widget.visibleMap[index] ? Icons.arrow_drop_down : Icons.arrow_right, color: widget.themeData.colorScheme.onPrimary,),
                  ],
                ),
              ),
            ),
            if(widget.visibleMap[index]) GridViewOrColumn(
              columnCount: columnCount, 
              itemCount: validEntries.length,
              children: validEntries.map((entry){
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryPage(entry: entry,)));
                    if(result == 'entry_updated') widget.fetchEntries(true);
                    if(result == 'entry_deleted'){
                      widget.updateHaveEdit(true);
                      widget.fetchEntries(true);
                    }
                  },
                  child: EntryCard(entry: entry, themeData: widget.themeData)
                );
              }).toList(), 
            ),
            SizedBox(height: 20,)
          ],
        );
      }
    
    );
  }
}


