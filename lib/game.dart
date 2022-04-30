import 'package:darting_swallow/hit_description_dialog.dart';
import 'package:darting_swallow/hit_modifiers.dart';
import 'package:darting_swallow/player_game_state.dart';
import 'package:darting_swallow/player_game_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:circle_list/circle_list.dart';
import 'add_player.dart';
import 'player.dart';
import 'game_event.dart';

enum activePlayerIntent { throwing, barnyarding, leaving, stacking, boneyarding, stabbing, undefined }

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  List<Player> playerWidgets = [];
  // Player? activePlayer;
  // Player? target;
  final activePlayer = ValueNotifier<Player?>(null);
  final target = ValueNotifier<Player?>(null);
  activePlayerIntent currentIntent = activePlayerIntent.undefined;

  late final PlayerGameStateManager gameStateManager;
  List<GameEvent> gameHistory = [];

  TextEditingController _textFieldController = TextEditingController(text: "");
  String newPlayerTextField = "";

  _GameState() {
    gameStateManager = PlayerGameStateManager(_onEvent);
    // TODO: these are for debug purposes
    for (var name in ["jacob", "peter", "nolan"]) {
      Player player = Player(name, onPlayerTapped, activePlayer, target);
      playerWidgets.add(player);
      gameStateManager.addPlayer(player);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> renderWidgets = [];
    for (var player in playerWidgets) {
      if (gameStateManager.isPlayerInGame(player)) {
        renderWidgets.add(player);
        renderWidgets.add(AddPlayerButton(_onAddPlayer, _onEvent));
      }
    }
    if (renderWidgets.isEmpty) {
      return Center(child: AddPlayerButton(_onAddPlayer, _onEvent));
    }
    return CircleList(
      origin: const Offset(0, 0),
      children: renderWidgets,
    );
  }

  PlayerSelectionState onPlayerTapped(Player player) {
    if (activePlayer.value == null) {
      activePlayer.value = player;
    } else {
      if (activePlayer.value == player) {
        activePlayer.value = null;
      } else {
        if (target.value == player) {
          target.value = null;
        } else {
          target.value ??= player;
        }
      }
    }
    _onPlayerSelection();
    if (activePlayer.value == player) {
      return PlayerSelectionState.active;
    } else if (target.value == player) {
      return PlayerSelectionState.target;
    }
    return PlayerSelectionState.unselected;
  }

  void _onPlayerSelection() async {
    // if no players are selected, something went wrong
    if (activePlayer.value == null) {
      return;
    }

    // only one player selected
    if (target.value == null) {
      currentIntent = (await _displaySelectionIntent())!;
      switch (currentIntent) {
        case activePlayerIntent.leaving:
          gameStateManager.onPlayerLeave(activePlayer.value!);
          activePlayer.value = null;
          target.value = null;
          setState(() {
            playerWidgets.remove(activePlayer);
          });
          break;
        case activePlayerIntent.stacking:
          gameStateManager.onPlayerStacking(activePlayer.value!);
          activePlayer.value = null;
          target.value = null;
          break;
        case activePlayerIntent.barnyarding: // in these cases, we are waiting for a target
        case activePlayerIntent.boneyarding:
        case activePlayerIntent.throwing:
        default: // *should* never get here... maybe throw an error?
          break;
      }
      return;
    }

    // have two players selected
    switch (currentIntent) {
      case activePlayerIntent.throwing:
        _onPlayerHit(true);
        break;
      case activePlayerIntent.stabbing:
        _onPlayerHit(false);
        break;
      case activePlayerIntent.barnyarding:
        gameStateManager.onSuccessfulBarnyard(activePlayer.value!, target.value!);
        activePlayer.value = null;
        target.value = null;
        break;
      case activePlayerIntent.boneyarding:
        gameStateManager.onSuccessfulBoneyard(activePlayer.value!, target.value!);
        activePlayer.value = null;
        target.value = null;
        break;
      case activePlayerIntent.leaving:
      case activePlayerIntent.stacking:
      case activePlayerIntent.undefined:
        assert(false);
        return; // this is an error case...
    }
  }

  void _onPlayerHit(bool dartThrown) async {
    if (activePlayer.value == null || target.value == null) {
      // error
      return;
    }
    if (!dartThrown) {
      gameStateManager.onStabbedCan(activePlayer.value!, target.value!);
      activePlayer.value = null;
      target.value = null;
      return;
    }
    List<String>? hitModifiers = await _displayThrowResults();
    if (hitModifiers == null) {
      // not sure what this case means - probably the user backed out of the dialog?
      return;
    }
    // if (hitModifiers.contains("swap")) {
    //   // TODO: track a user's position in this game state
    //   // this logic would need to happen here
    // }
    HitModifiers mods = HitModifiers.fromStringList(hitModifiers);
    gameStateManager.onHit(activePlayer.value!, target.value!, mods);
    activePlayer.value = null;
    target.value = null;
  }

  // this function utilizes *activePlayer* field - guaranteed not-null
  Future<activePlayerIntent?> _displaySelectionIntent() {
    return showDialog<activePlayerIntent?>(
        context: context,
        builder: (context) {
          return SimpleDialog(title: const Text('Player Action'), children: <Widget>[
            SimpleDialogOption(
                child: const Text("Leaving"), onPressed: () => {Navigator.pop(context, activePlayerIntent.leaving)}),
            SimpleDialogOption(
                child: const Text("Stacking"), onPressed: () => {Navigator.pop(context, activePlayerIntent.stacking)}),
            SimpleDialogOption(
                child: const Text("Barnyarding"),
                onPressed: () => {Navigator.pop(context, activePlayerIntent.barnyarding)}),
            SimpleDialogOption(
                child: const Text("Throwing"), onPressed: () => {Navigator.pop(context, activePlayerIntent.throwing)}),
          ]);
        });
  }

  Future<List<String>?> _displayThrowResults() {
    return showDialog<List<String>?>(
        context: context,
        builder: (context) {
          return MultiSelectDialog(
              const ["swap", "through", "catastrophic", "top", "bottom"], const Text("Hit Options"));
        });
  }

  Future<void> _onAddPlayer(BuildContext context) async {
    _textFieldController = TextEditingController(text: "");
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Player Name'),
            content: TextField(
              onChanged: (value) => {newPlayerTextField = value},
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: ""),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  setState(() {
                    newPlayerTextField = "";
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    Player player = Player(newPlayerTextField, onPlayerTapped, activePlayer, target);
                    playerWidgets.add(player);
                    gameStateManager.addPlayer(player);
                    newPlayerTextField = "";
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  void _onEvent(GameEvent event) {
    gameHistory.add(event);
  }
}
