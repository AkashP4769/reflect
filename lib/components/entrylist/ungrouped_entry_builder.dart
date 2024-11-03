import 'package:flutter/material.dart';
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
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: widget.entries.length,
      clipBehavior: Clip.none,
      physics: const ScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryPage(entry: widget.entries[index],)));
            if(result == 'entry_updated') widget.fetchEntries(true);
            if(result == 'entry_deleted'){
              widget.updateHaveEdit(true);
              widget.fetchEntries(true);
            }
          },
          child: EntryCard(entry: widget.entries[index], themeData: widget.themeData)
        );
      },
    );
  }
}