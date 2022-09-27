import 'package:flutter/material.dart';
import 'package:whatsapp_clone/app/data/constants.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(
        text,
        style:  TextStyle(
          color: CustomColor.blackColor,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: CustomColor.tabColor,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}