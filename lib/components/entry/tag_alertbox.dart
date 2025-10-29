import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/components/entry/tag_card.dart';
import 'package:reflect/models/tag.dart';
import 'package:reflect/services/tag_service.dart';
import 'package:collection/collection.dart';


class TagSelectionBox extends StatefulWidget {
  final ThemeData themeData;
  final List<Tag> tags;

  const TagSelectionBox({super.key, required this.themeData, required this.tags});

  @override
  State<TagSelectionBox> createState() => _TagSelectionBoxState();
}

class _TagSelectionBoxState extends State<TagSelectionBox> {
  final tagService = TagService();
  Set<Tag> userTags = {};
  Set<Tag> entryTags = {};
  int selectedColor = 0xFFFFAC5F;
  bool tagDeleteState = false;
  TextEditingController textController = TextEditingController();

  List<bool> deleteBits = [];


  @override
  void initState(){
    super.initState();
    entryTags = widget.tags.toSet();
    userTags = tagService.getAllTags().toSet();
    //userTags.add(Tag(name: "Optimistic", color: 0xfff0bb2b));
    //userTags.add(Tag(name: "Pessimistic", color: 0xff592bf0));

    userTags = userTags.difference(entryTags);
    deleteBits = List.generate(userTags.length, (index) => false);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void loadTags(){
    userTags = tagService.getAllTags().toSet();
    userTags = userTags.difference(entryTags);
    deleteBits = List.generate(userTags.length, (index) => false);
    setState(() {});
  }

  void addTag() async {
    print(textController.text);
    if(textController.text.isNotEmpty){
      userTags.add(Tag(name: textController.text.trim(), color: selectedColor));
      textController.clear();
      tagService.updateTags(userTags.toList());
      loadTags();
    }
  }

  void deleteTags(){
    Set<Tag> newTags = {};
    List<Tag> userTagsList = userTags.toList();
    for (var i = 0; i < userTagsList.length; i++) {
      if(!deleteBits[i]){
        newTags.add(userTagsList[i]);
      }
    }
    tagService.updateTags(newTags.toList());
    tagDeleteState = false;
    loadTags();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          backgroundColor: widget.themeData.colorScheme.surface,
          contentPadding: const EdgeInsets.only(left:20, right: 10, top: 20, bottom: 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select new tags', style: widget.themeData.textTheme.bodyLarge!.copyWith(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 24),),
              IconButton(
                onPressed: () => Navigator.of(context).pop(), 
                icon: Icon(Icons.close)
              )
            ],
          ),
          content: IntrinsicHeight(
            child: Container(
              //color: Colors.green,
              width: MediaQuery.of(context).size.width, 
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(entryTags.isNotEmpty) Text('Selected Tags', style: widget.themeData.textTheme.bodyMedium!.copyWith(fontFamily: "Poppins", fontSize: 18, color: const Color(0xffAFAFAF)),),
                    if(entryTags.isNotEmpty) const SizedBox(height: 10,),
                
                    //entrytags
                    if(entryTags.isNotEmpty) Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 5,
                      children: <Widget>[
                        ...entryTags.mapIndexed((index, tag) => 
                          GestureDetector(
                            key: ValueKey(tag.name),
                            onTap: (){
                              entryTags.remove(tag);
                              userTags.add(tag);
                              deleteBits = List.generate(userTags.length, (index) => false);
                              setState(() {});
                            },
                            child: TagCard(tag: tag, themeData: widget.themeData, selected: true, deleteBit: false,)
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    if(userTags.isNotEmpty) Text('Available Tags', style: widget.themeData.textTheme.bodyMedium!.copyWith(fontFamily: "Poppins", fontSize: 18, color: const Color(0xffAFAFAF)),),
                    if(userTags.isNotEmpty) const SizedBox(height: 10,),
                
                    //usertags
                    if(userTags.isNotEmpty) Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 5,
                      children: <Widget>[
                        ...userTags.mapIndexed((index, tag) => 
                          GestureDetector(
                            key: ValueKey(tag.name),
                            onTap: (){
                              if(tagDeleteState){
                                deleteBits[index] = !deleteBits[index];
                                bool prevState = false;
                                for (var bit in deleteBits) {
                                  if(bit){
                                    prevState = true;
                                    break;
                                  }
                                }
                                tagDeleteState = prevState;
                                setState(() {});
                              }
                              else {
                                entryTags.add(tag);
                                userTags.remove(tag);
                                deleteBits = List.generate(userTags.length, (index) => false);
                                setState(() {});
                              }
                            },
                            onLongPress: () => {
                              setState(() {
                                tagDeleteState = true;
                                deleteBits[index] = !deleteBits[index];
                                print(deleteBits);
                              })
                            },
                            child: TagCard(tag: tag, themeData: widget.themeData, selected: false, deleteBit: deleteBits[index],)
                          )
                        ),
                        if(tagDeleteState) IconButton(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          onPressed: deleteTags, 
                          icon: Icon(Icons.delete_outline, color: Colors.redAccent,),
                        )
                            
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Text('Create a Tag', style: widget.themeData.textTheme.bodyMedium!.copyWith(fontFamily: "Poppins", fontSize: 18, color: const Color(0xffAFAFAF)),),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            decoration: const InputDecoration(
                              hintText: 'Add a tag',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.0),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: CircleAvatar(
                            radius: 15,
                            backgroundColor: Color(selectedColor),
                          ),
                          onPressed: () async {
                            int newsSelectedColor = await showColorPicker(context);
                            setState(() {
                              selectedColor = newsSelectedColor;
                            });
                          },
                        ),
                        IconButton(onPressed: addTag, 
                          icon: Icon(Icons.check, color: widget.themeData.colorScheme.primary, size: 36,)
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                final unionSet = entryTags.union(userTags);
                tagService.updateTags(unionSet.toList());
                Navigator.of(context).pop(entryTags.toList());
              },
              child: Text('Confirm', style: widget.themeData.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, color: widget.themeData.colorScheme.primary),),
            ),
          ],
    );
  }

  Future<int> showColorPicker(BuildContext context) async {
    int currentColor = 0xFFFFAC5F;
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              paletteType: PaletteType.hueWheel,
              pickerColor: const Color(0xFFFFAC5F),
              labelTypes: [],
              onColorChanged: (Color color) {
                currentColor = color.value;
              },
              
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it'),
              onPressed: () {
                selectedColor = currentColor;
                Navigator.of(context).pop(selectedColor);
              },
            ),
          ],
        );
      },
    ) as int?;
    if(result != null){
      return result;
    }
    return currentColor;
  }
}