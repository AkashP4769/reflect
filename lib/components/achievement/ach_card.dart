import 'package:flutter/material.dart';
import 'package:reflect/models/achievement.dart';

class AchievementCard extends StatefulWidget {
  final Achievement achievement;
  final bool achieved;
  final ThemeData themeData;
  const AchievementCard({super.key, required this.achievement, required this.achieved, required this.themeData});

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Duration for a full cycle
    )..repeat(); // Loop the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value; // Current animation value (0.0 to 1.0)
        return Container(
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: widget.achieved ? null : Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.achieved ? widget.achievement.color : Colors.black.withOpacity(0.1),
              width: 1,
            ),
            gradient: widget.achieved
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.achievement.color.withOpacity(0.5),
                    widget.achievement.color.withOpacity(0.8),
                    widget.achievement.color.withOpacity(0.2),
                  ],
                  stops: [
                      (0.0), // Dynamically calculated stops
                      (value),
                      (1),
                    ],
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5)
            )
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.achievement.title, style: widget.themeData.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w700, fontSize: 16), textAlign: TextAlign.center,),
                Text(widget.achievement.description, style: widget.themeData.textTheme.bodyMedium!.copyWith(color: widget.themeData.colorScheme.onPrimary.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12), textAlign: TextAlign.center,),
              ],
            ),
            Icon(widget.achievement.icon, color: widget.achieved ? widget.achievement.color : Colors.grey, size: 32,),
            
          ],
        ),
      );

      }
    );
  }
}