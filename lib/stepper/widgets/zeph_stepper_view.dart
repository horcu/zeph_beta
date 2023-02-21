import 'package:flutter/material.dart';

import '../models/zeph_step.dart';
import '../models/zeph_stepper_config.dart';

class ZephStepperView extends StatelessWidget {
  final ZephStep step;
  final VoidCallback? onStepNext;
  final VoidCallback? onStepBack;
  final VoidCallback? actionOne;
  final VoidCallback? actionTwo;
  final EdgeInsetsGeometry? contentPadding;
  final ZephStepperConfig? config;

  const ZephStepperView({
    Key? key,
    required this.step,
    this.actionOne,
    this.actionTwo,
    this.onStepNext,
    this.onStepBack,
    this.contentPadding,
    required this.config,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final title = config!.isHeaderEnabled && step.isHeaderEnabled
        ? Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 0.0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: config!.headerColor ??
                  Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Visibility(
                        visible: config!.icon == null,
                        replacement: config!.icon ?? SizedBox(),
                        child: Icon(
                          Icons.help_outline,
                          size: 18,
                          color: config!.iconColor ?? Colors.black38,
                        ),
                      )
                    ]),
                const SizedBox(height: 5.0),
              ],
            ),
          )
        : SizedBox();

    final content = Expanded(
      child: SingleChildScrollView(
        padding: contentPadding,
        child: step.content,
      ),
    );

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, content],
      ),
    );
  }
}
