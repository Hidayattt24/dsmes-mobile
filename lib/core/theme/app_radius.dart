import 'package:flutter/material.dart';

/// DSMES Aceh Border Radius Tokens.
/// Cards use 24px, chips use full pill, buttons use 16px rounded.
abstract final class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  // Semantic shorthand
  static const BorderRadius card = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius cardMd = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius button = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius buttonPill = BorderRadius.all(Radius.circular(full));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(full));
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius tag = BorderRadius.all(Radius.circular(full));
}
