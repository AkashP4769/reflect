import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:reflect/components/entry/tag_card.dart';
import 'package:reflect/components/entry/tag_textfield.dart';
import 'package:reflect/models/tag.dart';

class TagPanel extends StatelessWidget {
  final SlidingUpPanelController panelController;
  final ScrollController scrollController;
  final ThemeData themeData;
  TagPanel({super.key, required this.panelController, required this.scrollController, required this.themeData});

  final List<Tag> allTags = [
    Tag(name: 'tag1', color: 0xFF452659),
    Tag(name: 'tag2', color: 0xFF595635),
    Tag(name: 'tag3', color: 0xFF556889),
    Tag(name: 'tag4', color: 0xFF454569),
    Tag(name: 'tag5', color: 0xFF262635),
    Tag(name: 'tag6', color: 0xFF452365),
    Tag(name: 'tag7', color: 0xFF565632),
    Tag(name: 'tag8', color: 0xFF785623),
    Tag(name: 'tag9', color: 0xFFA45563),
  ];

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanelWidget(
          panelController: panelController,
          controlHeight: 50,
          anchor: 0.4,
          panelStatus: SlidingUpPanelStatus.hidden,
          onTap: (){
            if (SlidingUpPanelStatus.expanded == panelController.status) {
              panelController.hide();
            } else {
              panelController.anchor();
            }
          },
          enableOnTap: true,
          onStatusChanged: (status){
            if (status == SlidingUpPanelStatus.collapsed) {
              panelController.hide();
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15.0),
            decoration: ShapeDecoration(
              color: themeData.colorScheme.secondary,
              shadows: [
                const BoxShadow(
                    blurRadius: 5.0,
                    spreadRadius: 2.0,
                    color: Color(0x11000000))
              ],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.menu,
                        size: 30,
                      ),
                      SizedBox(width: 10.0),
                      Text('click or drag',)
                    ],
                  ),
                ),
                Divider(
                  height: 0.5,
                  color: Colors.grey[300],
                ),
                Flexible(
                  child: Container(
                    color: themeData.colorScheme.secondary,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Create a new Tag", style: themeData.textTheme.bodyMedium!.copyWith(fontSize: 16, fontWeight: FontWeight.w600),),
                          ),
                          TagTextField(themeData: themeData,),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Selected Tags", style: themeData.textTheme.bodyMedium!.copyWith(fontSize: 16, fontWeight: FontWeight.w600),),
                          ),
                          Wrap(
                            children: [
                              ...allTags.map((tag) => TagCard(tag: tag, themeData: themeData, selected: true, deleteBit: false,)).toList()
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Available Tags", style: themeData.textTheme.bodyMedium!.copyWith(fontSize: 16, fontWeight: FontWeight.w600),),
                          ),
                          Wrap(
                            children: [
                              ...allTags.map((tag) => TagCard(tag: tag, themeData: themeData, selected: false, deleteBit: false,))
                            ],
                          ),
                        ],
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
        );
  }
}