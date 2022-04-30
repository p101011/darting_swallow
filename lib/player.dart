import 'package:flutter/material.dart';

enum PlayerSelectionState { unselected, active, target }

class Player extends StatefulWidget {
  final String name;
  final PlayerSelectionState Function(Player) onPressedCB;
  final ValueNotifier<Player?> activePlayer;
  final ValueNotifier<Player?> target;

  Player(this.name, this.onPressedCB, this.activePlayer, this.target, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<Player> createState() => _PlayerState(activePlayer, target);
}

class _PlayerState extends State<Player> {
  PlayerSelectionState playerSelectionState = PlayerSelectionState.unselected;
  final ValueNotifier<Player?> activePlayer;
  final ValueNotifier<Player?> target;

  _PlayerState(this.activePlayer, this.target) {
    activePlayer.addListener(onGamePlayerSelectionChange);
    target.addListener(onGamePlayerSelectionChange);
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    switch (playerSelectionState) {
      case PlayerSelectionState.active:
        borderColor = Colors.green[300]!;
        break;
      case PlayerSelectionState.target:
        borderColor = Colors.red[300]!;
        break;
      default:
        borderColor = Colors.black;
        break;
    }
    Border? containerBorder =
        playerSelectionState != PlayerSelectionState.unselected ? Border.all(color: borderColor, width: 4.0) : null;
    return Container(
        child: ElevatedButton(onPressed: () => {onPressed()}, child: Text(widget.name)),
        decoration: BoxDecoration(border: containerBorder, borderRadius: BorderRadius.circular(8)));
  }

  void onPressed() {
    widget.onPressedCB(widget);
  }

  void onGamePlayerSelectionChange() {
    setState(() {
      if (widget.activePlayer.value == widget) {
        playerSelectionState = PlayerSelectionState.active;
      } else if (widget.target.value == widget) {
        playerSelectionState = PlayerSelectionState.target;
      } else {
        playerSelectionState = PlayerSelectionState.unselected;
      }
    });
  }
}
