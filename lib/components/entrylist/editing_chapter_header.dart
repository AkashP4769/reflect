import 'package:flutter/material.dart';

class EditingChapterHeader extends StatelessWidget {
  final Function() toggleEdit;
  final Function() updateChapter;
  final ThemeData themeData;
  const EditingChapterHeader({super.key, required this.toggleEdit, required this.updateChapter, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: toggleEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeData.colorScheme.surface,
                  elevation: 10
                ),
                child: Icon(Icons.close, color: themeData.colorScheme.onPrimary,)
              ),
            ),
            const SizedBox(width: 20,),
            Expanded(
              flex: 4,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                ),
                onPressed: (){
                  toggleEdit();
                  updateChapter();
                },
                child: Text("Save", style: themeData.textTheme.titleMedium?.copyWith(color: Colors.white),)
              ),
            )
          ],
        ),
      ),
    );
  }
}