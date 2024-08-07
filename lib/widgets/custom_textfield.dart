import 'package:flutter/material.dart';


class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onTap;
  const CustomTextField({
    Key? key,
    required this.controller,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: onTap,
      controller: controller,
      decoration: const InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black87,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.brown,
            ),
          )),
    );
  }
}
class CustomTextField2 extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onTap;

  const CustomTextField2({
    Key? key,
    required this.controller,
    this.onTap,
  }) : super(key: key);

  void _sendMessage() {
    if (controller.text.isNotEmpty) {
      onTap?.call(controller.text);
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onSubmitted: onTap,
            controller: controller,
            decoration: const InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black87,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.brown,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: _sendMessage,
        ),
      ],
    );
  }
}