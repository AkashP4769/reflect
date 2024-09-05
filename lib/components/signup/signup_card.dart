import 'package:flutter/material.dart';
import 'package:reflect/constants/colors.dart';

class SignUpCard extends StatelessWidget {
  const SignUpCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's get to know you!", style: TextStyle(color: darkGrey, fontSize: 20, fontFamily: "Poppins", fontWeight: FontWeight.w600),),
          Text("Fill up the registration form to get started.", style: TextStyle(color: grey, fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.w400),),
        ],
      ),
    
    );
  }
}