import 'dart:convert';

import 'package:darting_swallow/hit_modifiers.dart';
import 'package:darting_swallow/player.dart';

enum hitModifiers { swap, through, catastrophic, top, bottom }

abstract class GameEvent {
  late final DateTime _eventDate;
  final String eventName;

  GameEvent(this.eventName) {
    _eventDate = DateTime.now();
  }

  String toJsonString() {
    return jsonEncode(_toJsonInternal());
  }

  Map<String, dynamic> _toJsonInternal() {
    return {"date": _eventDate};
  }
}

abstract class SinglePlayerEvent extends GameEvent {
  final Player activePlayer;

  SinglePlayerEvent(this.activePlayer, eventName) : super(eventName);

  @override
  Map<String, dynamic> _toJsonInternal() {
    var parentMap = super._toJsonInternal();
    parentMap['active-player'] = activePlayer.name;
    return parentMap;
  }
}

abstract class DualPlayerEvent extends SinglePlayerEvent {
  final Player targetPlayer;

  DualPlayerEvent(activePlayer, this.targetPlayer, eventName) : super(activePlayer, eventName);

  @override
  Map<String, dynamic> _toJsonInternal() {
    var parentMap = super._toJsonInternal();
    parentMap['target-player'] = targetPlayer.name;
    return parentMap;
  }
}

class PlayerJoinEvent extends SinglePlayerEvent {
  PlayerJoinEvent(player) : super(player, "join");
}

class PlayerLeaveEvent extends SinglePlayerEvent {
  PlayerLeaveEvent(player) : super(player, "leave");
}

class PlayerStackEvent extends SinglePlayerEvent {
  PlayerStackEvent(player) : super(player, 'stack');
}

class PlayerBarnyardedEvent extends DualPlayerEvent {
  PlayerBarnyardedEvent(p1, p2) : super(p1, p2, 'barnyard');
}

class PlayerBoneyardedEvent extends DualPlayerEvent {
  PlayerBoneyardedEvent(p1, p2) : super(p1, p2, 'barnyard');
}

class PlayerHitEvent extends DualPlayerEvent {
  PlayerHitEvent(p1, p2, HitModifiers hit) : super(p1, p2, 'hit');
}

class PlayerStabbedEvent extends DualPlayerEvent {
  PlayerStabbedEvent(p1, p2) : super(p1, p2, 'stab');
}

class PlayerKilledEvent extends SinglePlayerEvent {
  PlayerKilledEvent(p1) : super(p1, 'kill');
}
