import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';

class CustomLogo extends StatelessWidget {
  final String title;
  final String mTitle;
  final String fontFamily;

  const CustomLogo(this.title, this.mTitle, this.fontFamily, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 40,
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: half,
        ),
        Text(
          mTitle,
          style: TextStyle(
              fontSize: 20,
              fontFamily: fontFamily,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: half),
        const Image(
          image: AssetImage('assets/logo.png'),
          width: 200,
        ),
        const SizedBox(height: half)
      ],
    );
  }
}
