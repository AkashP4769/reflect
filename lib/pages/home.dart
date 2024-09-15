import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reflect/main.dart';
import 'package:reflect/services/auth_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
        )
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Home Page'),

            ElevatedButton(
              
              onPressed: () {
                AuthService.signOut();
              },
              child: Text('Logout', style: themeData.textTheme.bodyMedium,),
            ),

            Switch(value: themeData.brightness == Brightness.dark, onChanged: (value){
                  ref.read(themeManagerProvider.notifier).toggleTheme(value);
                }),
                Text(themeData.brightness == Brightness.dark ? "Dark Mode" : "Light Mode", style: TextStyle(color: Colors.grey, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w400),),          
          ],
        ),
      ),
    );
  }
}