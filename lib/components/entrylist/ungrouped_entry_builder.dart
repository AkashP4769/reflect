import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reflect/components/entrylist/grid_or_column.dart';
import 'package:reflect/components/journal/entry_card.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/pages/entry.dart';

class UngroupedEntryBuilder extends StatefulWidget {
  final List<Entry> entries;
  final ThemeData themeData;
  final void Function(bool explicit) fetchEntries;
  final void Function(bool value) updateHaveEdit;
  
  const UngroupedEntryBuilder({super.key, required this.entries, required this.themeData, required this.fetchEntries, required this.updateHaveEdit});

  @override
  State<UngroupedEntryBuilder> createState() => _UngroupedEntryBuilderState();
}

class _UngroupedEntryBuilderState extends State<UngroupedEntryBuilder> {
  
  @override
  Widget build(BuildContext context) {
    final columnCount = min(3, max(1, (MediaQuery.of(context).size.width / 420).floor()));
    return GridViewOrColumn(
      columnCount: columnCount, 
      itemCount: widget.entries.length,
      children: widget.entries.map((entry){
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
    );
  }
}