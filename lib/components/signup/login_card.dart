import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:reflect/components/common/loading.dart';
import 'package:reflect/components/signup/signup_icon_btn.dart';
import 'package:reflect/components/signup/signup_passfield.dart';
import 'package:reflect/components/signup/signup_textfield.dart';
import 'package:reflect/constants/colors.dart';
import 'package:reflect/main.dart';
import 'package:reflect/services/auth_service.dart';
import 'package:reflect/theme/theme_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginCard extends ConsumerStatefulWidget {
  final void Function() togglePage;
  final void Function(Color) signInwWithGoogle;
  final void Function(Color) signInWithApple;
  final void Function(String, String, Color) signInWithEmailAndPass;
  final String errorMsg;
  const LoginCard({super.key, required this.togglePage, required this.signInwWithGoogle, required this.signInWithApple, required this.signInWithEmailAndPass, required this.errorMsg});

  @override
  ConsumerState<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends ConsumerState<LoginCard> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider); 
    return Container(
      height: 600,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: themeData.brightness == Brightness.dark ? themeData.colorScheme.surface.withOpacity(0.8) : themeData.colorScheme.surface.withOpacity(0.6),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
      ),
      child: SingleChildScrollView(
        child: Stack( //wrap with scrollable
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome back!", style: themeData.textTheme.titleMedium,),
                Text("Enter your credentials to continue", style: themeData.textTheme.bodyMedium,),
                const SizedBox(height: 20,),
                SignUpTextField(text: "Email", controller: emailController, themeData: themeData,),
                SignUpPassField(text: "Password", controller: passwordController, themeData: themeData,),
                
                if(widget.errorMsg != '') Row(
                  children: [
                    const Icon(Icons.error, color: Colors.redAccent, size: 16,),
                    const SizedBox(width: 5,),
                    Text(widget.errorMsg!, style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontFamily: "Poppins", fontWeight: FontWeight.w400),)
                  ],
                ),
                SizedBox(height: widget.errorMsg != '' ? 5 : 20,),
                
            
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () => widget.signInWithEmailAndPass(emailController.text, passwordController.text, themeData.colorScheme.primary), 
                    style: themeData.elevatedButtonTheme.style,
                    child: Text("Login", style: themeData.textTheme.titleMedium),
                  ),
                ),
        
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: (){},
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(vertical: 0)
                    ),
                    child: Text("Forgot Password?", style: themeData.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: "Poppins"),)
                  ),
                ),
            
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider(color: Colors.grey, thickness: 2, endIndent: 10,)),
                    Text("Or", style: TextStyle(color: Colors.grey, fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.w400),),
                    Expanded(child: Divider(color: Colors.grey, thickness: 2, indent: 10,)),
                  ],
                ),
                const SizedBox(height: 5,),
        
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => widget.signInwWithGoogle(themeData.colorScheme.primary),
                        child: SignUpIconButton(imgSrc: 'google'),
                      ),
                      GestureDetector(
                        onTap: () => widget.signInWithApple(themeData.colorScheme.primary),
                        child: SignUpIconButton(imgSrc: 'apple'),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't register?", style: themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),),
                    const SizedBox(width: 5,),
                    TextButton(
                      onPressed: widget.togglePage,
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(vertical: 0)
                      ),
                      child: const Text("Sign up", style: TextStyle(color: Colors.orangeAccent, fontSize: 14, fontFamily: "Poppins", fontWeight: FontWeight.w600),)
                    )
                  ],
                ),

                /*Switch(value: themeData.brightness == Brightness.dark, onChanged: (value){
                  ref.read(themeManagerProvider.notifier).toggleTheme(value);
                }),
                Text(themeData.brightness == Brightness.dark ? "Dark Mode" : "Light Mode", style: TextStyle(color: grey, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w400),),          
            
                */
            
              ],
            ),
          ],
        ),
      ),
    
    );
  }
}