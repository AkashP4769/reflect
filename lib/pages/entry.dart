import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/main.dart';

class EntryPage extends ConsumerStatefulWidget {
  const EntryPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryPage> {

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
        )
      ),
    );
  }
}