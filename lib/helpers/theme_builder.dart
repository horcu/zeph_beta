import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeph_beta/style/palette.dart';

class ThemeBuilder {

  static textStyle(double? size, Color? clr, [FontWeight? fw, FontStyle? fs]) {
    return GoogleFonts.raleway(
        fontWeight: fw ?? FontWeight.normal,
        fontStyle: fs ?? FontStyle.normal,
        fontSize: size ?? 20,
        color: clr ?? textColor());
  }

  static mainBgColor() {
    return Palette().mint;
  }

  static textColor() {
    return Palette().white;
  }

  static mainForegroundColor() {
    return Palette().white;
  }

  static get mint =>  Palette().mint;

  static get offwhite =>  Palette().offWhite;

  static get forest =>  Palette().forest;
  static get black =>  Palette().black;
  static get trueWhite => Palette().white;
  static Color get lime => Palette().lime;


}
