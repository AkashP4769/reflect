import 'package:flutter/material.dart';

class OverlayMenu extends StatefulWidget {
  final Widget child;
  final List<OverlayMenuItems> items;
  final VoidCallback onTap;
  final ThemeData themeData;

  const OverlayMenu({super.key, required this.child, required this.items, required this.onTap, required this.themeData});
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
              right: 40,
              top: 0,
              
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOutCirc,
                builder: (BuildContext context, double value, Widget? child) {
                  return Opacity(
                    opacity: value,
                    
                    child: Container(
                      width: 65 * value,
                      height: 40 * value,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      
                      decoration: BoxDecoration(
                        color: widget.themeData.colorScheme.secondary.withValues(),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 5,
                            offset: const Offset(0, 5)
                          )
                        ]
                      ),
                      
                      child: Row(
                        children: [
                          ...widget.items,
                        ],
                      ),
                    ),
                  );
                },
              ),
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