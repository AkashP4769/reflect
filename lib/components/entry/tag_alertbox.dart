import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:reflect/services/tag_service.dart';

class TagSelectionBox extends StatefulWidget {
  final ThemeData themeData;

  const TagSelectionBox({super.key, required this.themeData});

  @override
  State<TagSelectionBox> createState() => _TagSelectionBoxState();
}

class _TagSelectionBoxState extends State<TagSelectionBox> {
  final tagService = TagService();
  int selectedColor = 0xFFFFAC5F;
  TextEditingController tagController = TextEditingController();

  @override
  void dispose() {
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          contentPadding: const EdgeInsets.only(left:20, right: 10, top: 20, bottom: 20),
          title: Text('Select new tags', style: widget.themeData.textTheme.bodyLarge!.copyWith(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 24),),
          content: IntrinsicHeight(
            child: Container(
              width: MediaQuery.of(context).size.width, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selected Tags', style: widget.themeData.textTheme.bodyMedium!.copyWith(fontFamily: "Poppins", fontSize: 18, color: const Color(0xffAFAFAF)),),
                  const SizedBox(height: 10,),
                  Text('Available Tags', style: widget.themeData.textTheme.bodyMedium!.copyWith(fontFamily: "Poppins", fontSize: 18, color: const Color(0xffAFAFAF)),),
                  const SizedBox(height: 10,),
                  Text('Create a Tag', style: widget.themeData.textTheme.bodyMedium!.copyWith(fontFamily: "Poppins", fontSize: 18, color: const Color(0xffAFAFAF)),),
                  Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
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
                      IconButton(onPressed: (){}, 
                        icon: Icon(Icons.check, color: widget.themeData.colorScheme.primary, size: 36,)
                      ),
                    ],
                  )
                ],
              ),
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
              pickerColor: const Color(0xff443a49),
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