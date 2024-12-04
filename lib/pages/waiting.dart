import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/main.dart';
import 'package:reflect/services/auth_service.dart';

class WaitingPage extends ConsumerStatefulWidget {
  const WaitingPage({super.key});

  @override
  ConsumerState<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends ConsumerState<WaitingPage> {
  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Waiting for permissions', style: themeData.textTheme.titleLarge),
              const SizedBox(height: 20,),
              const Text('Please accept the permissions in your main device to continue', textAlign: TextAlign.center,),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  AuthService.signOut();
                },
                child: Text('Re-login', style: themeData.textTheme.bodyMedium,),
              ),
            ],
          ),
        )
      ),
    );
  }
}