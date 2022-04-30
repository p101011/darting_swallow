import 'package:flutter/material.dart';

class ActionBar extends StatefulWidget {
  const ActionBar({Key? key}) : super(key: key);

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(shape: const CircularNotchedRectangle(), child: Container(height: 50.0));
  }
}
