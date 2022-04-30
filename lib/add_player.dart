import 'package:flutter/material.dart';
import 'game_event.dart';

class AddPlayerButton extends StatelessWidget {
  final Future<void> Function(BuildContext) onPressedCallback;
  final void Function(GameEvent) onEventCallback;

  const AddPlayerButton(this.onPressedCallback, this.onEventCallback, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => {onPressedCallback(context)}, child: const Icon(Icons.add));
  }
}
