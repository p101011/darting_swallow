class HitModifiers {
  late final bool swap;
  late final bool through;
  late final bool catastrophic;
  late final bool top;
  late final bool bottom;
  late final bool alwaysLethal;

  HitModifiers(this.swap, this.through, this.catastrophic, this.top, this.bottom);
  HitModifiers.fromStringList(List<String> stringArgs) {
    swap = stringArgs.contains("swap");
    through = stringArgs.contains("through");
    catastrophic = stringArgs.contains("catastrophic");
    top = stringArgs.contains("top");
    bottom = stringArgs.contains("bottom");
    alwaysLethal = through || catastrophic || top || bottom;
  }
}
