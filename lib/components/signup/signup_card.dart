import 'package:flutter/material.dart';
import 'package:reflect/components/signup/signup_icon_btn.dart';
import 'package:reflect/components/signup/signup_textfield.dart';
import 'package:reflect/constants/colors.dart';

class SignUpCard extends StatefulWidget {
  const SignUpCard({
    super.key,
  });

  @override
  State<SignUpCard> createState() => _SignUpCardState();
}

class _SignUpCardState extends State<SignUpCard> {
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
    return Container(
      height: 600,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's get to know you!", style: TextStyle(color: darkGrey, fontSize: 20, fontFamily: "Poppins", fontWeight: FontWeight.w600),),
          Text("Fill up the registration form to get started.", style: TextStyle(color: grey, fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.w400),),

          const SizedBox(height: 20,),
          SignUpTextField(text: "Name", controller: nameController),
          SignUpTextField(text: "Email", controller: emailController),
          SignUpTextField(text: "Password", controller: passwordController),
          SignUpTextField(text: "Confirm Password", controller: confirmPasswordController),
          const SizedBox(height: 20,),

          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: (){
            
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
              child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.w600),),
            ),
          ),
          const SizedBox(height: 10,),
          Align(
            alignment: Alignment.centerRight,
            child: Text("Forgot Password?", style: TextStyle(color: grey, fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.w400),),
          ),
          const SizedBox(height: 10,),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Divider(color: Colors.grey, thickness: 2, endIndent: 10,)),
              Text("Or", style: TextStyle(color: Colors.grey, fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.w400),),
              Expanded(child: Divider(color: Colors.grey, thickness: 2, indent: 10,)),
            ],
          ),
          SizedBox(height: 20,),

          Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: (){},
                          child: IntrinsicWidth(child: SignUpIconButton(imgSrc: 'google')),
                        ),
                        GestureDetector(
                          onTap: (){},
                          child: IntrinsicWidth(child: SignUpIconButton(imgSrc: 'apple')),
                        )
                      ],
                    ),
                  ),



        ],
      ),
    
    );
  }
}