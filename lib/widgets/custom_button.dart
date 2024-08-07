import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.onTap,
    required this.text,
  }) : super(key: key);
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black54,
        minimumSize: const Size(double.infinity, 40),
      ),
      onPressed: onTap,
      child: Text(text,style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),),
    );
  }
}

class CustomButton2 extends StatelessWidget {
  const CustomButton2({
    Key? key,
    required this.onTap,
    required this.text,
    this.icon,
    this.image,
  }) : super(key: key);
  final String? image;

  final String text;
  final VoidCallback onTap;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black54,
        minimumSize: const Size(double.infinity, 40),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 15,
              width: 20,
              child: Image.asset('${image}',)),
          SizedBox(width: 10,),
          Text(text,style: TextStyle(
            color: Colors.white,

            fontWeight: FontWeight.bold,
          ),),
        ],
      ),
    );
  }
}
