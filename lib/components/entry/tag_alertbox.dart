import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:reflect/services/tag_service.dart';

class TagSelectionBox extends StatelessWidget {
  final ThemeData themeData;
  final tagService = TagService();
  TagSelectionBox({super.key, required this.themeData});

  String selectedColor = '0xFFFFAC5F';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          contentPadding: const EdgeInsets.only(left:20, right: 10, top: 20, bottom: 20),
          title: Text('Select new tags', style: themeData.textTheme.bodyLarge!.copyWith(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 24),),
          content: IntrinsicHeight(
            child: Container(
              width: MediaQuery.of(context).size.width, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selected Tags', style: themeData.textTheme.bodyMedium!.copyWith(fontFamily: "Poppins", fontSize: 18, color: const Color(0xffAFAFAF)),),
                  const SizedBox(height: 10,),
                  Text('Available Tags', style: themeData.textTheme.bodyMedium!.copyWith(fontFamily: "Poppins", fontSize: 18, color: const Color(0xffAFAFAF)),),
                  const SizedBox(height: 10,),
                  Text('Create a Tag', style: themeData.textTheme.bodyMedium!.copyWith(fontFamily: "Poppins", fontSize: 18, color: const Color(0xffAFAFAF)),),
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
                          backgroundColor: Color(int.parse(selectedColor)),
                        ),
                        onPressed: () {
                          showColorPicker(context);
                        },
                      ),
                      IconButton(onPressed: (){}, 
                        icon: Icon(Icons.check, color: themeData.colorScheme.primary, size: 36,)
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

  void showColorPicker(BuildContext context) {
    showDialog(
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
                print(color);
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}