import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:reflect/components/entry/tag_card.dart';
import 'package:reflect/models/tag.dart';
import 'package:reflect/services/tag_service.dart';
import 'package:collection/collection.dart';


class TagSelectionBox extends StatefulWidget {
  final ThemeData themeData;

  const TagSelectionBox({super.key, required this.themeData});

  @override
  State<TagSelectionBox> createState() => _TagSelectionBoxState();
}

class _TagSelectionBoxState extends State<TagSelectionBox> {
  final tagService = TagService();
  List<Tag> userTags = [];
  int selectedColor = 0xFFFFAC5F;
  bool tagDeleteState = false;
  TextEditingController textController = TextEditingController();

  List<bool> deleteBits = List.generate(100, (index) => false);

  @override
  void initState(){
    super.initState();
    userTags = tagService.getAllTags();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void loadTags(){
    userTags = tagService.getAllTags();
    setState(() {});
  }

  void addTag() async {
    print(textController.text);
    if(textController.text.isNotEmpty){
      userTags.add(Tag(name: textController.text.trim(), color: selectedColor));
      textController.clear();
      tagService.updateTags(userTags);
      loadTags();
    }
  }

  void deleteTags(){
    List<Tag> newTags = [];
    for (var i = 0; i < userTags.length; i++) {
      if(!deleteBits[i]){
        newTags.add(userTags[i]);
      }
    }
    tagService.updateTags(newTags);
    tagDeleteState = false;
    deleteBits = List.generate(100, (index) => false);
    loadTags();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          contentPadding: const EdgeInsets.only(left:20, right: 10, top: 20, bottom: 20),
          title: Text('Select new tags', style: widget.themeData.textTheme.bodyLarge!.copyWith(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 24),),
          content: Container(
            height: 400,
            width: MediaQuery.of(context).size.width, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected Tags', style: widget.themeData.textTheme.bodyMedium!.copyWith(fontFamily: "Poppins", fontSize: 18, color: const Color(0xffAFAFAF)),),
                const SizedBox(height: 10,),
                Text('Available Tags', style: widget.themeData.textTheme.bodyMedium!.copyWith(fontFamily: "Poppins", fontSize: 18, color: const Color(0xffAFAFAF)),),
                const SizedBox(height: 10,),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...userTags.mapIndexed((index, tag) => 
                      GestureDetector(
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
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
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