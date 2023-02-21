import 'package:flutter/widgets.dart';

class ZephStep {
  final Widget content;
  final Future<String?>? Function()? validation;
  final String? Function()? actionOne;
  final String? Function()? actionTwo;
  final bool isHeaderEnabled;
  final Color color;
  final bool showBackButton;
  final bool showContinueButton;
  int index;

  ZephStep(
      {required this.content,
      required this.validation,
      required this.actionOne,
      required this.actionTwo,
      this.isHeaderEnabled = true,
      required String name,
      required this.color,
      required this.showBackButton,
      required this.showContinueButton,
      required this.index});
}
