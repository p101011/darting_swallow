import 'package:darting_swallow/can_state.dart';
import 'package:darting_swallow/hit_modifiers.dart';
import 'package:darting_swallow/player.dart';

class PlayerGameState {
  final Player owner;

  bool isActive = true;
  int cansFinished = 0;

  // this is ordered such that 0 = ground, inf = sky
  final List<CanState> playerCans = [];

  PlayerGameState(this.owner) {
    stackCan(); // starting can
  }

  // TODO: there should be a UI option which prompts for *where* the can went
  // presently, just assume that the fresh can goes on Bottom
  void stackCan() {
    playerCans.insert(0, CanState());
  }

  int finishCans() {
    int numFinished = playerCans.length;
    cansFinished += numFinished;
    playerCans.clear();
    stackCan();
    return numFinished;
  }

  bool hitCan(int canIndex, HitModifiers hit) {
    bool canKilled = playerCans[canIndex].hit(hit);
    if (canKilled) {
      playerCans.removeAt(canIndex);
      cansFinished++;
      if (playerCans.isEmpty) {
        stackCan();
      }
    }
    return canKilled;
  }
}
