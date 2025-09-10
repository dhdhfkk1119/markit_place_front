import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../_core/constants/custom_widget.dart';

class WriteButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const WriteButton({super.key, required this.onTap, required this.title});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.plus,
                size: 20,
                color: Colors.deepPurpleAccent,
              ),
              const SizedBox(width: 8),
              CustomWidget.buildTitle('$title', color: Colors.deepPurpleAccent),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
