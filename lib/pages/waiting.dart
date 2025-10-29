import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/components/signup/signup_passfield.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/services/auth_service.dart';
import 'package:reflect/services/encryption_service.dart';
import 'package:reflect/services/user_service.dart';

class WaitingPage extends ConsumerStatefulWidget {
  const WaitingPage({super.key});

  @override
  ConsumerState<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends ConsumerState<WaitingPage> {
  late UserSetting userSetting;
  late TextEditingController passwordController;
  String errorMsg = '';
  bool isValid = false;

  void getUserSetting() async {
    userSetting = await UserService().getUserSetting();
    setState(() {});
  }

  void validate(){
    final password = passwordController.text;
    if(password.isEmpty){
      errorMsg = 'Password cannot be empty';
      setState(() {});
      return;
    }
    
    try{
        if(EncryptionService().validateSymmetricKey(password, userSetting.salt ?? '', userSetting.keyValidator ?? '')){
          isValid = true;
          errorMsg = '';
          setState(() {});
        }
        else{
          errorMsg = 'Invalid password';
          setState(() {});
        }
      } catch(e){
        errorMsg = 'Invalid password';
        setState(() {});
      }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserSetting();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Theme(
      data: themeData,
      child: Scaffold(
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
                Text(isValid ? "Password Validated" :'Enter your password', style: themeData.textTheme.titleLarge!.copyWith(color: themeData.colorScheme.primary), textAlign: TextAlign.center,),
                const SizedBox(height: 20,),
                if(!isValid) const Text('This password refers to the one you created while you enabled encryption', textAlign: TextAlign.center,),
                if(!isValid) const SizedBox(height: 20,),
                if(!isValid) SignUpPassField(text: "Password", controller: passwordController, themeData: themeData,),
                if(errorMsg != '') Row(
                  children: [
                    Icon(Icons.error, color: Colors.redAccent, size: 16,),
                    const SizedBox(width: 5,),
                    Text(errorMsg, style: TextStyle(color: Colors.redAccent, fontSize: 14, fontFamily: "Poppins", fontWeight: FontWeight.w400),)
                  ],
                ),
                const SizedBox(height: 20,),
                if(!isValid) Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(themeData.colorScheme.tertiary),
                        ),
                        onPressed: () {
                          AuthService.signOut();
                        }, 
                        child: Text('Go back', style: themeData.textTheme.bodyMedium,),
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: validate, 
                        child: Text('Validate', style: themeData.textTheme.bodyMedium,),
                      ),
                    ),
                  ],
                ),
      
                if(isValid) Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 28,),
                    const SizedBox(width: 5,),
                    Expanded(child: Text("Your password is validated. You can now re-login", style: themeData.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.left,)),
                  ],
                ),
                if(isValid) const SizedBox(height: 20,),
                if(isValid) ElevatedButton(
                  onPressed: () {
                    AuthService.signOut();
                  },
                  child: Text('Re-login', style: themeData.textTheme.bodyMedium,),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}