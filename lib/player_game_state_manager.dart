import 'package:darting_swallow/hit_modifiers.dart';
import 'package:darting_swallow/player.dart';
import 'package:darting_swallow/player_game_state.dart';

import 'game_event.dart';

// TODO - these should be error cases, not return null

class PlayerGameStateManager {
  final Map<Player, PlayerGameState> playerStates = {};
  void Function(GameEvent) onEventCallback;

  PlayerGameStateManager(this.onEventCallback);

  void addPlayer(Player p) {
    _ensurePlayerStateExists(p);
    onEventCallback(PlayerJoinEvent(p));
  }

  bool isPlayerInGame(Player p) {
    return playerStates.containsKey(p) && playerStates[p]!.isActive;
  }

  void _ensurePlayerStateExists(Player p) {
    if (!playerStates.containsKey(p)) {
      playerStates[p] = PlayerGameState(p);
    }
  }

  bool _validatePlayerStates(Player p1, {Player? p2}) {
    PlayerGameState? s1 = playerStates[p1];
    if (s1 == null) {
      return false;
    }
    if (p2 == null) {
      return true;
    }
    PlayerGameState? s2 = playerStates[p2];
    return s2 != null;
  }

  void onPlayerLeave(Player p) {
    if (_validatePlayerStates(p)) {
      onEventCallback(PlayerLeaveEvent(p));
    }
  }

  void onPlayerStacking(Player p) {
    if (_validatePlayerStates(p)) {
      playerStates[p]!.stackCan();
      onEventCallback(PlayerStackEvent(p));
    }
  }

  void onSuccessfulBarnyard(Player active, Player victim) {
    if (_validatePlayerStates(active, p2: victim)) {
      onEventCallback(PlayerBarnyardedEvent(active, victim));
    }
  }

  void onSuccessfulBoneyard(Player active, Player victim) {
    if (_validatePlayerStates(active, p2: victim)) {
      int numFinished = playerStates[victim]!.finishCans();
      onEventCallback(PlayerBoneyardedEvent(active, victim));
      for (var i = 0; i < numFinished; i++) {
        onEventCallback(PlayerKilledEvent(victim));
      }
    }
  }

  void onStabbedCan(Player active, Player victim) {
    if (_validatePlayerStates(active, p2: victim)) {
      int numFinished = playerStates[victim]!.finishCans();
      onEventCallback(PlayerBoneyardedEvent(active, victim));
      for (var i = 0; i < numFinished; i++) {
        onEventCallback(PlayerKilledEvent(victim));
      }
    }
  }

  void onHit(Player active, Player victim, HitModifiers modifiers) {
    if (_validatePlayerStates(active, p2: victim)) {
      // TODO: we care about which can is hit...
      bool kill = playerStates[victim]!.hitCan(0, modifiers);
      onEventCallback(PlayerHitEvent(active, victim, modifiers));
      if (kill) {
        onEventCallback(PlayerKilledEvent(victim));
      }
    }
  }
}
