import 'package:flutter/material.dart';
import 'game.dart';
import 'action_bar.dart';

void main() {
  runApp(const DartingSwallow());
}

class DartingSwallow extends StatelessWidget {
  const DartingSwallow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beer Darts Season 2022',
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Beer Darts Season 2022')),
        ),
        body: const Center(
          child: Game(),
        ),
        bottomNavigationBar: const ActionBar(),
      ),
    );
  }
}
