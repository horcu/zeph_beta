library cool_stepper;
import 'package:flutter/material.dart';
import 'package:zeph_beta/helpers/parts_builder.dart';
import 'package:zeph_beta/stepper/widgets/zeph_stepper_view.dart';
import 'models/zeph_step.dart';
import 'models/zeph_stepper_config.dart';


class ZephStepper extends StatelessWidget {
  /// The steps of the stepper whose titles, subtitles, content always get shown.
  ///
  /// The length of [steps] must not change.
  final List<ZephStep> steps;

  /// Actions to take when the final stepper is passed
  final VoidCallback onCompleted;

  /// Padding for the content inside the stepper
  final EdgeInsetsGeometry contentPadding;

  /// CoolStepper config
  final ZephStepperConfig config;

  /// This determines if or not a snackbar displays your error message if validation fails
  ///
  /// default is false
  final bool showErrorSnackbar;

  // state object for the stepper
  final ChangeNotifier notifier;

  late final  PageController _controller =  PageController();
  late int currentStep = 0;

  late dynamic state;

   ZephStepper({super.key,
    required this.notifier,
    required this.steps,
    required this.onCompleted,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.config = const ZephStepperConfig(),
    this.showErrorSnackbar = false
  }) {
    state = notifier; //as OnboardingStepperState;
   }


  // @override
  // void dispose() {
  //   _controller!.dispose();
  //   _controller = null;
  //
  // }

  Future<void>? switchToPage(int page) {
    _controller!.animateToPage(
      page,
      duration: const Duration(milliseconds: 800),
      curve: Curves.fastLinearToSlowEaseIn,
    );
    return null;
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return steps.length - 1 == index;
  }

  Future<void> onStepNext() async {

    final validation = await steps[state.currentStep.index].validation!();

    /// [validation] is null, no validation rule
    if (validation == null) {
      if (!_isLast(state.currentStep.index)) {
        var currIndex = state.currentStep.index;
        currIndex++;
        var currStep = steps[currIndex];

        state.setCurrentStep(currStep);
        state.setCurrentStepIndex(currStep.index);

        switchToPage(state.currentStep.index);
      } else {
        onCompleted();
      }
    } else {
      /// [showErrorSnackbar] is true, Show error snackbar rule
      if (showErrorSnackbar) {

      }
    }
  }

  void onStepBack() {
    if (!_isFirst(state.currentStep.index)) {
      var currStepIndex = steps[state.currentStep.index].index;
      currStepIndex--;

      var currentStep = steps[currStepIndex];

      state.setCurrentStep(currentStep);
      state.setCurrentStepIndex(currStepIndex);

      switchToPage(currStepIndex);
    }
  }

  void onActionOne(Function cb){cb();}

  void onActionTwo(Function cb){cb();}

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: MediaQuery.of(context).size.height,
      child: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: steps.map((step) {
          return ZephStepperView(
            step: step,
            actionOne: step.actionOne,
            actionTwo: step.actionTwo,
            contentPadding: contentPadding,
            config: config,
          );
        }).toList(),
      ),
    );

    Widget getNextButtonWidget() {
      Widget nextLabel;
      if (_isLast(currentStep)) {
        nextLabel = config.finalText ?? Container();
      } else {
        if (config.nextTextList != null) {
          nextLabel = config.nextTextList![currentStep] as Widget;
        } else {
          nextLabel = (config.continueWidget ?? Container());
        }
      }
      return nextLabel;
    }

    Widget getBackButtonWidget() {
      Widget? backLabel;
      if (_isFirst(currentStep)) {
        backLabel = Container();
      } else {
        if (config.backTextList != null) {
          backLabel = config.backTextList![currentStep - 1];
        } else {
          backLabel = (config.backWidget ?? Container());
        }
      }
      return backLabel;
    }

    final buttonBack = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextButton(
          onPressed: onStepBack,
          child: getBackButtonWidget(),
        ),
      ],
    );

    final buttonForward = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Spacer(),
        TextButton(
          onPressed: onStepNext,
          child: getNextButtonWidget(),
        ),
      ],
    );

    final actionButtonOne = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Spacer(),
        PartsBuilder.buildButton(20, Colors.yellow, Colors.green, "Action one",  (){}, false, const SizedBox.shrink())
      ],
    );

    final actionButtonTwo = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Spacer(),
        PartsBuilder.buildButton(20, Colors.yellow, Colors.green, "Action two",  (){},false, const SizedBox.shrink())
      ],
    );

    return Stack(
      children: [
        content,
        Align(
            alignment: Alignment.topLeft,
       child: SizedBox(height: 30,
        child: Visibility(
        replacement: const SizedBox(height: 30,),
        visible: steps[state.currentStep.index].showBackButton,
          child: buttonBack))),

    Align(
     alignment: Alignment.bottomRight,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 150),
      child:  SizedBox(height: 30,
    child: Visibility(
            replacement: const SizedBox(height: 30,),
            visible: steps[state.currentStep.index].showContinueButton,
            child: buttonForward))))
      ],
    );
  }

  void moveForward() {
     onStepNext();
  }
  void moveBackward() {
     onStepBack();
  }
}
