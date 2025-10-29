import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/components/setting/setting_container.dart';
import 'package:reflect/main.dart';

class ThemeSetting extends ConsumerStatefulWidget {
  final ThemeData themeData;
  const ThemeSetting({super.key, required this.themeData});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ThemeSettingState();
}

class _ThemeSettingState extends ConsumerState<ThemeSetting> {

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);

    return SettingContainer(
          themeData: widget.themeData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• Theme Settings", style: widget.themeData.textTheme.titleMedium!.copyWith(color:widget.themeData.colorScheme.primary)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Reset Theme"),
                  const SizedBox(width: 5,),
                  IconButton(onPressed: (){
                    ref.read(themeManagerProvider.notifier).setThemeColor(Color(0xffFFAC5F));
                    }, icon: Icon(Icons.refresh), color: themeData.colorScheme.onPrimary,
                  ),
                ],
              ),
              
              Row(
                children: [
                  Text("Theme Color"),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ColorPickerSlider(
                        TrackType.hue, 
                        HSVColor.fromColor(widget.themeData.colorScheme.primary), 
                        (color) {
                          ref.read(themeManagerProvider.notifier).setThemeColor(color.toColor());
                        }
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Text("Theme Value"),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ColorPickerSlider(
                        TrackType.value, 
                        HSVColor.fromColor(widget.themeData.colorScheme.primary), 
                        (color) {
                          ref.read(themeManagerProvider.notifier).setThemeColor(color.toColor());
                        }
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        );
  }
}

/*children: [
          Text("• Theme Settings", style: widget.themeData.textTheme.titleMedium!.copyWith(color:widget.themeData.colorScheme.primary)),
          const SizedBox(height: 10),
          Text("Theme settings can be changed from the main settings page.", style: widget.themeData.textTheme.bodyMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              Text("Theme Color"),
              const SizedBox(width: 5,),
              ColorPickerSlider(
                TrackType.hue, 
                HSVColor.fromColor(widget.themeData.colorScheme.primary), 
                (color) {
                  ref.read(themeManagerProvider.notifier).setThemeColor(color.toColor());
                }
              )
            ],
          )
        ],
      ),
      */