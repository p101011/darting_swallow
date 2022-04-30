import 'package:darting_swallow/hit_modifiers.dart';

class CanState {
  int hp = 3;

  CanState();

  // returns true on kill, false on survival
  bool hit(HitModifiers modifiers) {
    hp--;
    return modifiers.alwaysLethal || hp < 1;
  }
}
