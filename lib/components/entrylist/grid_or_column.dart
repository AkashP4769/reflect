

import 'package:flutter/material.dart';

class GridViewOrColumn extends StatelessWidget {
  const GridViewOrColumn({super.key, required this.children, required this.columnCount, required this.itemCount});
  final List<Widget> children;
  final int columnCount;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    if (columnCount == 1) {
      return Column(
        children: children,
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: itemCount,
        clipBehavior: Clip.none,
        physics: const ScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 0,),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          childAspectRatio: 1,
          mainAxisExtent: 180,
        ),
        itemBuilder: (context, index) {
          return children[index];
        },
      );
    }
  }
}