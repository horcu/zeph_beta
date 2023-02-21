import 'package:flutter/widgets.dart';

class ZephStepperConfig {
  /// The text that should be displayed for the back button
  ///
  /// default is 'BACK'
  final Widget? backWidget;

  /// The text that should be displayed for the next button
  ///
  /// default is 'NEXT'
  final Widget? continueWidget;

  /// The text that describes the progress
  ///
  /// default is 'STEP'
  final Widget? stepText;

  /// The text that describes the progress
  ///
  /// default is 'OF'
  final Widget? ofText;

  /// This is the background color of the header
  final Color? headerColor;

  /// This is the color of the icon
  ///
  /// [This does not apply when icon is set]
  final Color? iconColor;

  /// This icon replaces the default icon
  final Icon? icon;

  /// This is the textStyle for the title text
  final TextStyle? titleTextStyle;

  /// This is the textStyle for the subtitle text
  final TextStyle? subtitleTextStyle;

  /// A List of string that when supplied will override 'backText'
  ///
  /// Must be one less than the number of steps since for the first step, the backText won't be visible
  final List<Widget>? backTextList;

  /// A List of string that when supplied will override 'nextText'
  ///
  /// Must be one less than the number of steps since the 'finalText' attribute is able to set the value for the final step's next button
  final List<String>? nextTextList;

  /// The text that should be displayed for the next button on the final step
  ///
  /// default is 'FINISH'
  final Widget? finalText;

  final bool isHeaderEnabled;

  const ZephStepperConfig({
    this.backWidget = const Text(""),
    this.continueWidget,
    this.stepText = const Text(""),
    this.ofText = const Text(""),
    this.headerColor,
    this.iconColor,
    this.icon,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.backTextList,
    this.nextTextList,
    this.finalText,
    this.isHeaderEnabled = true,
  });
}
