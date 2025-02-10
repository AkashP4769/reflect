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

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
          )
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Reflect(value: 1)
            ],
          ),
        ),
      ),
    );
  }
}