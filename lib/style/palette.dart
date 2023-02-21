// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// A palette of colors to be used in the game.
///
/// The reason we're not going with something like Material Design's
/// `Theme` is simply that this is simpler to work with and yet gives
/// us everything we need for a game.
///
/// Games generally have more radical color palettes than apps. For example,
/// every level of a game can have radically different colors.
/// At the same time, games rarely support dark mode.
///
/// Colors taken from this fun palette:
/// https://lospec.com/palette-list/crayola84
///
/// Colors here are implemented as getters so that hot reloading works.
/// In practice, we could just as easily implement the colors
/// as `static const`. But this way the palette is more malleable:
/// we could allow players to customize colors, for example,
/// or even get the colors from the network.
class Palette {
  Color get white => const Color(0xffffffff);
  Color get forest => const Color(0xff275242);
  Color get mint => const Color(0xff1FB282);
  Color get offWhite => const Color(0xffFCFAF2);
  Color get lime => const Color(0xffD6FF33);
  Color get magenta => const Color(0xff9A1776);
  Color get sky => const Color(0xff6BA3D6);
  Color get orange => const Color(0xffF4763B);
  Color get black => const Color(0xff2A2A2A);
  Color get background => const Color(0xff999999);
}
