import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';

class TagPanel extends StatelessWidget {
  final SlidingUpPanelController panelController;
  final ScrollController scrollController;
  final ThemeData themeData;
  const TagPanel({super.key, required this.panelController, required this.scrollController, required this.themeData});

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
                      Padding(
                        padding: EdgeInsets.only(
                          left: 8.0,
                        ),
                      ),
                      Text(
                        'click or drag',
                      )
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
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: 20,
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('list item $index'),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          height: 0.5,
                        );
                      },
                      
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}