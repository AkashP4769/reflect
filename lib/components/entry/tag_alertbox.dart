import 'package:flutter/material.dart';

class TagSelectionBox extends StatelessWidget {
  final ThemeData themeData;
  const TagSelectionBox({super.key, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: AlertDialog(
          title: Text('Select new tags', style: themeData.textTheme.bodyLarge!.copyWith(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 24),),
          content: Container(
            width: MediaQuery.of(context).size.width + 20, 
            height: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selected Tags'),
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
        )
    );
  }
}