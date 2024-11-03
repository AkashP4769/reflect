import 'package:flutter/material.dart';
import 'package:reflect/components/journal/entry_card.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/pages/entry.dart';
import 'package:reflect/services/entrylist_service.dart';

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
  late Map<String, List<Entry>> groupedEntries;
  final EntrylistService entrylistService = EntrylistService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    groupedEntries = entrylistService.groupEntriesByDate(widget.entries);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: groupedEntries.length,
      clipBehavior: Clip.none,
      physics: const ScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemBuilder: (context, index){
        final date = groupedEntries.keys.elementAt(widget.isAscending ? index : groupedEntries.length - 1 - index);
        final _entries = groupedEntries[date];
        final validEntries = entrylistService.sortEntries(_entries!, widget.sortMethod, widget.isAscending);

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Text(date, style: widget.themeData.textTheme.bodyMedium?.copyWith(color: widget.themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600),),
                  Container(
                    //color: Colors.green,
                    child: GestureDetector(
                      onTap: (){
                        widget.visibleMap[index] = !widget.visibleMap[index];
                        setState(() {});
                      },
                      child: Icon(widget.visibleMap[index] ? Icons.arrow_drop_down : Icons.arrow_right, color: widget.themeData.colorScheme.onPrimary,)
                    ),
                  )
                ],
              ),
            ),
            if(widget.visibleMap[index]) ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: validEntries!.length,
              clipBehavior: Clip.none,
              physics: const ScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 0),
              itemBuilder: (context, index) {
                
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryPage(entry: validEntries[index],)));
                    if(result == 'entry_updated') widget.fetchEntries(true);
                    if(result == 'entry_deleted'){
                      widget.updateHaveEdit(true);
                      widget.fetchEntries(true);
                    }
                  },
                  child: EntryCard(entry: validEntries[index], themeData: widget.themeData)
                );
              },
            ),
            SizedBox(height: 20,)
          ],
        );
      }
    
    );
  }
}