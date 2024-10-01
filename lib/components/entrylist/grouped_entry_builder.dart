import 'package:flutter/material.dart';
import 'package:reflect/components/journal/entry_card.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/pages/entry.dart';

class GroupedEntryBuilder extends StatefulWidget {
  final Map<String, List<Entry>> groupedEntries;
  final List<bool> visibleMap;
  final ThemeData themeData;
  final void Function(bool explicit) fetchEntries;
  final void Function(bool value) updateHaveEdit;
  
  const GroupedEntryBuilder({super.key, required this.groupedEntries, required this.visibleMap, required this.themeData, required this.fetchEntries, required this.updateHaveEdit});

  @override
  State<GroupedEntryBuilder> createState() => _GroupedEntryBuilderState();
}

class _GroupedEntryBuilderState extends State<GroupedEntryBuilder> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: widget.groupedEntries.length,
      clipBehavior: Clip.none,
      physics: const ScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemBuilder: (context, index){
        final date = widget.groupedEntries.keys.elementAt(index);
        final _entries = widget.groupedEntries[date];


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
              itemCount: _entries!.length,
              clipBehavior: Clip.none,
              physics: const ScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 0),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EntryPage(entry: _entries[index],)));
                    if(result == 'entry_updated') widget.fetchEntries(true);
                    if(result == 'entry_deleted'){
                      widget.updateHaveEdit(true);
                      widget.fetchEntries(true);
                    }
                  },
                  child: EntryCard(entry: _entries[index], themeData: widget.themeData)
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