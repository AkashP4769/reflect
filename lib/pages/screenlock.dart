import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/components/common/reflect.dart';
import 'package:reflect/main.dart';

class ScreenLock extends ConsumerStatefulWidget {
  const ScreenLock({super.key});

  @override
  ConsumerState<ScreenLock> createState() => _ScreenLockState();
}

class _ScreenLockState extends ConsumerState<ScreenLock> {
  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    final List<String> pin = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "-1", "0", "-2"];

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
          )
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Reflect(value: 0),
            const SizedBox(height: 20),
            Text("Enter pincode", style: themeData.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: 28),),
            const SizedBox(height: 20),

            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5
              ),
              itemCount: 12,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index){
                return FilledButton(
                  onPressed: () => print(pin[index]),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(themeData.colorScheme.secondaryContainer),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    overlayColor: WidgetStateProperty.all(themeData.colorScheme.secondaryContainer.withOpacity(0.2))
                  ),
                  child: Center(
                    child: pin[index] == "-1" ? Icon(Icons.backspace_outlined, color: themeData.colorScheme.primary,) : pin[index] == "-2" ? Icon(Icons.check, color: themeData.colorScheme.primary, size: 32,) : 
                            Text(pin[index], style: themeData.textTheme.titleMedium!.copyWith(fontSize: 20, fontWeight: FontWeight.w600),),
                  ),
                );
              }
              
            )
            
          ],
        ),
      ),
    );
  }
}