import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void showLoading(BuildContext context, Color? color) {
  showDialog(context: context, builder: (context){
      return Center(
          child: SpinKitCircle(
            color: color ?? Colors.white,
            size: 50.0,
          ),
        );
    });
}