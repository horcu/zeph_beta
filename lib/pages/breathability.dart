import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:zeph_beta/stepper/models/zeph_step.dart';

import '../app_lifecycle/app_lifecycle.dart';
import '../helpers/parts_builder.dart';
import '../helpers/theme_builder.dart';
import '../state/breathe_stepper_state.dart';
import '../stepper/models/zeph_stepper_config.dart';
import '../stepper/zeph_stepper.dart';
import '../user/local_storage_user_state_persistence.dart';
import '../user/user_state.dart';

class Breathability extends StatefulWidget {
  const Breathability({Key? key}) : super(key: key);

  @override
  State<Breathability> createState() => _BreathabilityState();
}

class _BreathabilityState extends State<Breathability> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late ZephStepper stepper = ZephStepper(
      notifier: BreatheStepperState(), steps: const [], onCompleted: () {});

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    });

    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late BreatheStepperState settings;

    void onFinish() {

    }

    return AppLifecycleObserver(
        child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) {
                  return UserState(LocalStorageUserAuthPersistence());
                },
              ),
              ChangeNotifierProvider(
                create: (context) {
                  return BreatheStepperState();
                },
              ),
            ],
            child: FutureBuilder(
              //future: ()=>{},
                builder: (context, snapshot) {
                  if (snapshot.hasError || snapshot.data == null) {
                    settings = context.watch<BreatheStepperState>();

                    buildStepper(context, settings, onFinish);

                    if(settings.stepIndex == -1) {
                      settings.setCurrentStep(stepper.steps[0]);
                      settings.setCurrentStepIndex(0);
                    }

                    return Scaffold(
                        backgroundColor: settings.currentStep.color,
                        appBar: AppBar(elevation: 0, backgroundColor: settings.currentStep.color),
                        body: Container(
                          height: MediaQuery.of(context).size.height,
                          color: settings.currentStep.color,
                          child: stepper,
                        ));
                  } else {
                    return SpinKitThreeBounce();
                  }
                })));

  }

  void buildStepper(BuildContext context, BreatheStepperState settings, void Function() onFinish) {

    List<ZephStep> steps = [
      buildBreathabilityTestStep(context, settings),
      buildCheckBreathabilityScoreStep(context, settings),
      buildStartLungTestStep(context, settings),
      buildFitnessStep(context, settings)
    ];

    stepper = ZephStepper(
      notifier: settings,
      showErrorSnackbar: false,
      // isHeaderEnabled: false,
      onCompleted: onFinish,
      contentPadding: const EdgeInsets.all(0),
      config: ZephStepperConfig(
          isHeaderEnabled: false,
          titleTextStyle: ThemeBuilder.textStyle(10, Colors.white),
          backWidget: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Row(
                children: [
                  const Icon(Icons.chevron_left,
                      color: Colors.black45),
                  Text("BACK",
                      style:
                      ThemeBuilder.textStyle(14, Colors.black)),
                ],
              )),
          continueWidget: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Row(
                children: [
                  Text("CONTINUE",
                      style:
                      ThemeBuilder.textStyle(14, Colors.black)),
                  const Icon(Icons.chevron_right,
                      color: Colors.black45)
                ],
              )),
          stepText: null,
          ofText: null),
      steps: steps,
    );
  }

  ZephStep buildBreathabilityTestStep(
      BuildContext context, BreatheStepperState settings) {
    return ZephStep(
      index: 0,
      validation: () {
        return null;
      },
      showBackButton: false,
      showContinueButton: false,
      name: 'step3_breath',
      content: Container(
          padding: const EdgeInsets.all(48),
          margin: const EdgeInsets.all(0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: ThemeBuilder.mainBgColor(),
          child: SizedBox(
              child: Column(
                children: [
                  // welcome text
                  Align(
                      alignment: Alignment.center,
                      child: Text(
                          'Take a \r\nbreathability test anytime to know \r\nyour lung health \r\nand build better \r\nhabits.',
                          style: ThemeBuilder.textStyle(
                              30, Colors.white, FontWeight.bold))),

                  // spacer
                  const SizedBox(height: 10),

                  // Image
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 260,
                      child: Stack(
                        children: const [
                          Align(
                              alignment: Alignment.bottomLeft,
                              child: Image(
                                  width: 200,
                                  height: 240,
                                  image: AssetImage("assets/images/screen_a.png"))),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: Image(
                                  width: 200,
                                  height: 240,
                                  image: AssetImage("assets/images/screen_b.png"))),
                          Align(
                              alignment: Alignment.topCenter,
                              child: Image(
                                  width: 200,
                                  height: 240,
                                  image: AssetImage("assets/images/screen_c.png"))),
                        ],
                      )),

                  // spacer
                  const SizedBox(height: 20),

                  // connect device link
                  PartsBuilder.buildButton(
                      14,
                      Colors.yellow,
                      Colors.green,
                      "Take a test".toUpperCase(),
                      (){
                        stepper.moveForward();
                      },
                      false,
                      MediaQuery.of(context).size.width,
                      50,
                      12),

                  const SizedBox(
                    height: 10,
                  ),

                  // connect later link
                  PartsBuilder.buildNoBgButton(
                      12, Colors.white, "Skip Intro".toUpperCase(), (){
                    stepper.moveForward();
                  }, 300, 50)
                ],
              ))), color: ThemeBuilder.mainBgColor(), actionOne: () {  }, actionTwo: () {  },
    );
  }

  ZephStep buildCheckBreathabilityScoreStep(
      BuildContext context, BreatheStepperState settings) {
    return ZephStep(
      index: 1,
      validation: () {
        return null;
      },
      showBackButton: false,
      showContinueButton: false,
      name: 'step2_check_score',
      content: Container(
          padding: const EdgeInsets.all(48),
          margin: const EdgeInsets.all(0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color:  ThemeBuilder.mainBgColor(),
          child: SizedBox(
              child: Column(
                children: [
                  // welcome text
                  Align(
                      alignment: Alignment.center,
                      child: Text(
                          "It's time to check your Breathability \r\nscore",
                          style: ThemeBuilder.textStyle(
                              30, Colors.white, FontWeight.bold))),

                  // spacer
                  const SizedBox(height: 10),

                  // secondary text
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          "Keep up to date on the fitness of your lungs with "
                              "your breathability score to better"
                              " understand 7 key pulmonary function"
                              " points that indicate lung strength, "
                              "breath capacity and more.",
                          style: ThemeBuilder.textStyle(
                              14, Colors.white, FontWeight.normal))),

                  const SizedBox(height: 350),
                  // take test link
                  PartsBuilder.buildButton(
                      14,
                      Colors.yellow,
                      Colors.green,
                      "Take breathability test".toUpperCase(),
                          (){
                        stepper.moveForward();
                          },
                      false,
                      MediaQuery.of(context).size.width,
                      50,
                      12),
                ],
              ))),
        color:  ThemeBuilder.mainBgColor() ,
        actionOne: () {  },
        actionTwo: () {  }
    );
  }

  ZephStep buildStartLungTestStep(
      BuildContext context, BreatheStepperState settings) {
    return ZephStep(
      index: 2,
      validation: () {
        return null;
      },
      showBackButton: false,
      showContinueButton: false,
      name: 'step1_lung_test',
      content: Container(
          padding: const EdgeInsets.all(48),
          margin: const EdgeInsets.all(0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color:  Colors.white,
          child: SizedBox(
              child: Column(
                children: [
                  // welcome text
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          'Start your lung test.',
                          style: ThemeBuilder.textStyle(
                              30, Colors.black54, FontWeight.bold))),

                  const SizedBox(height: 55),

                  //check list
                  Column(
                    children: [
                      Row(
                        children:  [
                           Icon(Icons.bluetooth, color: ThemeBuilder.mainBgColor()),
                          const SizedBox(width: 20,),
                           Flexible(
                                child: Text("Make sure your Zeph is connected to your phone.",
                              overflow: TextOverflow.clip,
                                style: ThemeBuilder.textStyle(12, Colors.black54)))
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children:  [
                           Icon(Icons.timer, color: ThemeBuilder.mainBgColor()),
                          const SizedBox(width: 20,),
                          Flexible(
                              child: Text("Breathability test will take 5 minutes to complete",
                                  overflow: TextOverflow.clip,
                                  style: ThemeBuilder.textStyle(12, Colors.black54)))
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children:  [
                          const SizedBox(width: 3,),
                           Image(
                              height: 18,
                              width: 18,
                              image: const AssetImage("assets/images/ic_heartbeats.png"), color: ThemeBuilder.mainBgColor()),
                          const SizedBox(width: 22,),
                          Flexible(
                              child: Text("Make sure your Zeph is connected to your phone.",
                                  overflow: TextOverflow.clip,
                                  style: ThemeBuilder.textStyle(12, Colors.black54)))
                        ],
                      )
                    ],
                  ),
                  // spacer
                  const SizedBox(height: 320),

                  // connect device link
                  PartsBuilder.buildButton(
                      14,
                      Colors.yellow,
                      Colors.green,
                      "Take breathability test".toUpperCase(),
                          (){
                        stepper.moveForward();
                          },
                      false,
                      MediaQuery.of(context).size.width,
                      50,
                      12),
                ],
              ))),
        color:  Colors.white,
        actionOne: () {  },
        actionTwo: () {  }
    );
  }

  ZephStep buildFitnessStep(
      BuildContext context, BreatheStepperState settings) {
    return ZephStep(
        index: 3,
        validation: () {
          return null;
        },
        showBackButton: false,
        showContinueButton: false,
        name: 'step4_fitness',
        content: Container(
            padding: const EdgeInsets.all(48),
            margin: const EdgeInsets.all(0),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color:  Colors.white,
            child: SizedBox(
                child: Column(
                  children: [
                    // welcome text
                    Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                            'Fitness',
                            style: ThemeBuilder.textStyle(
                                40, Colors.black54, FontWeight.bold))),

                    // spacer
                    const SizedBox(height: 500),

                    // connect device link
                    PartsBuilder.buildButton(
                        14,
                        Colors.yellow,
                        Colors.green,
                        "Next".toUpperCase(),
                            (){},
                        false,
                        MediaQuery.of(context).size.width,
                        50,
                        12),
                  ],
                ))),
        color:  Colors.white,
        actionOne: () {  },
        actionTwo: () {  }
    );
  }
}
