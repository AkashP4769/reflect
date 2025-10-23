import 'package:intl/intl.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/models/tag.dart';

class EntrylistService {
  List<Entry> applySearchFilter(List<Entry> entries, String filterText){
    return entries.where((element) => element.title!.toLowerCase().contains(filterText.toLowerCase()) || element.getCombinedContentAsQuill().toPlainText().toLowerCase().contains(filterText.toLowerCase())).toList();
  }

  List<Entry> sortEntries(List<Entry> entries, String method, bool isAscending){
    switch(method){
      case 'time':
        entries.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'alpha':
        entries.sort((a, b) => a.title!.toLowerCase().compareTo(b.title!.toLowerCase()));
        break;
      case 'length':
        entries.sort((a, b) => a.getCombinedContentAsQuill().toPlainText().length.compareTo(b.getCombinedContentAsQuill().toPlainText().length));
        break;
    }
    if (!isAscending) entries = entries.reversed.toList();
    return entries;
  }

  Map<String, List<Entry>> groupEntriesByDate(List<Entry> validEntries){
    final Map<String, List<Entry>> groupedEntries = {};
    validEntries.forEach((entry){
      final date = DateFormat('MMM yyyy').format(entry.date);
      if(groupedEntries[date] == null) groupedEntries[date] = [entry];
      else groupedEntries[date]!.add(entry);
    });
    return groupedEntries;
  }

  List<Entry> filterEntryByTags(List<Entry> entries,List<Tag> tags,  List<bool> selectedTags){
    List<Entry> filteredEntries = [];
    Set<Tag> selectedTagSet = {};
    for(int i = 0; i < tags.length; i++){
      if(selectedTags[i]) selectedTagSet.add(tags[i]);
    }

    for(var entry in entries){
      Set<Tag> entryTagSet = {};
      for(var tag in entry.tags!){
        entryTagSet.add(Tag.fromMap(tag));
      }
      if(selectedTagSet.intersection(entryTagSet).isNotEmpty){
        filteredEntries.add(entry);
      }
    }
    return filteredEntries;
  }
}