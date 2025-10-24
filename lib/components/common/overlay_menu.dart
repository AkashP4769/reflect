import 'package:flutter/material.dart';

class OverlayMenu extends StatefulWidget {
  final Widget child;
  final List<OverlayMenuItems> items;
  final VoidCallback onTap;

  OverlayMenu({super.key, required this.child, required this.items, required this.onTap});
  @override
  State<OverlayMenu> createState() => _OverlayMenuState();
}

class _OverlayMenuState extends State<OverlayMenu> {
  //final VoidCallback? onLongPress;
  bool displayMenu = false;

  void toggleMenu(){
    displayMenu = !displayMenu;
    print("toggling menu to $displayMenu");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (displayMenu) {
          toggleMenu();
        } else {
          widget.onTap();
        }
      },
      onLongPressStart: (details) {
        toggleMenu();
      },

      child: Container(
        child: Stack(
          children: [
            widget.child,

            if(displayMenu) Positioned(
              right: 0,
              top: 0,
              child: Text("Menu here")
            ),
            
            // if(displayMenu) Container(
            //   padding: EdgeInsets.all(4),
            //   color: Colors.amber,
            //   child: Align(
            //     alignment: Alignment.topRight,
            //     child: Row(
            //       children: <Widget>[Text("Hello")],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class OverlayMenuItems extends StatelessWidget {
  final Icon icon;
  final void Function() onTap;

  const OverlayMenuItems({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: icon
    );
  }
}