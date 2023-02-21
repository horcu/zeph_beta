import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:zeph_beta/enums/PrimaryGoal.dart';
import 'package:zeph_beta/models/zeph_user.dart';
import 'package:zeph_beta/services/db_service.dart';
import 'package:zeph_beta/state/zeph_user_state.dart';
import '../app_lifecycle/app_lifecycle.dart';
import '../enums/gender.dart';
import '../helpers/parts_builder.dart';
import '../helpers/theme_builder.dart';
import '../models/credentials.dart';
import '../screens/app_tiles.dart';
import '../screens/device_screen.dart';
import '../state/onboarding_stepper_state.dart';
import '../stepper/models/zeph_step.dart';
import '../stepper/models/zeph_stepper_config.dart';
import '../stepper/zeph_stepper.dart';
import '../user/local_storage_user_state_persistence.dart';
import '../user/user_state.dart';
import '../widgets/scan_results_widget.dart';
import 'breathability.dart';
import 'package:flutter_blue/flutter_blue.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key, required this.title});

  final String title;

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  late final BluetoothState? state;
  late final Key _formKey = const Key("form");
  late final TextEditingController _nameTextEditCtrl = TextEditingController();
  late final TextEditingController _emailCtrl = TextEditingController();
  late String? selectedRole = 'Writer';

  late final TextEditingController _nameTextEditController =
      TextEditingController();
  late final TextEditingController _emailTextEditController =
      TextEditingController();
  late final TextEditingController _passwordTextEditController =
      TextEditingController();
  late final TextEditingController _reenterPasswordTextEditController =
      TextEditingController();

  List<bool> _primaryGoalsSelectionList = [false, false, false, false];
  final List<PrimaryGoal> _primaryGoals = [
    PrimaryGoal.lungHealth,
    PrimaryGoal.deepBreathing,
    PrimaryGoal.fitness,
    PrimaryGoal.relaxMeditate
  ];

  int _selectedGoalIndex = -1;

  late final TextEditingController _dobTextEditController =
      TextEditingController();
  late final TextEditingController _weightTextEditController =
      TextEditingController();
  late final TextEditingController _height1TextEditController =
      TextEditingController();
  late final TextEditingController _height2TextEditController =
      TextEditingController();

  static String _gender = "female";
  late ZephStepper stepper = ZephStepper(
      notifier: OnboardingStepperState(), steps: const [], onCompleted: () {});

  bool permGranted = false;

  late OnboardingStepperState settings;
  late ZephUserState userState;

  // Availability
  @override
  void initState() {
    super.initState();
    // animate to the first page after a few seconds
    Future.delayed(const Duration(milliseconds: 2800), () {
      if(stepper.steps.isNotEmpty) {
        stepper.moveForward();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void onFinish() {}

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
              return OnboardingStepperState();
            },
          ),
          ChangeNotifierProvider(
            create: (context) {
              return ZephUserState();
            },
          ),
        ],
            child: FutureBuilder(
                future: checkPermissions(),
                builder: (context, snapshot) {
                  if (!snapshot.hasError && snapshot.data == true) {
                    settings = context.watch<OnboardingStepperState>();
                    userState = context.watch<ZephUserState>();

                    buildStepper(context, settings, onFinish);

                    if(settings.stepIndex == -1) {
                      settings.setCurrentStep(stepper.steps[0]);
                      settings.setCurrentStepIndex(0);
                    }

                    return Scaffold(
                        resizeToAvoidBottomInset: false,
                        backgroundColor: settings.currentStep.color,
                        appBar: null,
                        body: Container(
                            height: MediaQuery.of(context).size.height,
                            color: settings.currentStep.color,
                            child: Stack(children: [
                              Padding(
                                  padding: const EdgeInsets.only(top: 70),
                                  child: stepper),
                              AnimatedPositioned(
                                  right: settings.currentStep.index == 1 ||
                                          settings.currentStep.index == 2
                                      ? 0
                                      : 2000,
                                  duration: const Duration(microseconds: 1000),
                                  child: const Image(
                                    height: 180,
                                      image: AssetImage(
                                          "assets/images/topright.png"))),
                              AnimatedPositioned(
                                bottom: 0,
                                left: settings.currentStep.index == 1 ||
                                        settings.currentStep.index == 2
                                    ? 0
                                    : -500,
                                duration: const Duration(microseconds: 1200),
                                child: const Image(
                                  image: AssetImage(
                                      "assets/images/bottomleft.png"),
                                ),
                              ),
                            ])));
                  } else {
                    return Container(
                        color: ThemeBuilder.forest,
                        child:  SpinKitThreeBounce(
                          color: ThemeBuilder.mint,
                        ));
                  }
                })));
  }

  void buildStepper(BuildContext context, OnboardingStepperState settings,
      void Function() onFinish) {
    final steps = [
      //required
      buildSplashScreen(),
      ZephStep(
          color: Colors.white,
          name: "step1",
          content: Container(
              padding: const EdgeInsets.all(38),
              margin: const EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Container(
                  padding: const EdgeInsets.all(0),
                  child: SizedBox(
                      child: Column(
                    children: [
                      // spacer
                      const SizedBox(height: 60),

                      // welcome text
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text('Login',
                              style: ThemeBuilder.textStyle(
                                  45, Colors.black, FontWeight.bold))),

                      // spacer

                      // secondary text
                      // Align(
                      //     alignment: Alignment.topLeft,
                      //     child: Text(
                      //         'Lets set up your Zeph account to access \r\ntailored-to-you breathe exercises, \r\nlung tests training and more!',
                      //         style: ThemeBuilder.textStyle(
                      //             14, Colors.black, FontWeight.normal))),

                      // spacer
                      const SizedBox(height: 10),

                      PartsBuilder.buildTextField(onChangedCb: (val ) {  }, labelText: "Username".toUpperCase()),

                      PartsBuilder.buildTextField(onChangedCb: (val ) {  }, labelText: "Password".toUpperCase()),

                      const SizedBox(height: 5),

                      PartsBuilder.buildButton(
                          16,
                          ThemeBuilder.forest,
                          Colors.white,
                          "Login".toUpperCase(),
                              () {},
                          false,
                          MediaQuery.of(context).size.width,
                          50),

                      const SizedBox(height: 5),

                      PartsBuilder.buildButton(
                          16,
                          Colors.white,
                          Colors.black54,
                          "Continue with Apple".toUpperCase(),
                          () {},
                          false,
                          MediaQuery.of(context).size.width,
                          50),
                      // spacer
                      const SizedBox(height: 10),

                      PartsBuilder.buildButton(
                          16,
                          Colors.white,
                          Colors.black54,
                          "Continue with Google".toUpperCase(),
                          () {},
                          false,
                          MediaQuery.of(context).size.width,
                          50),
                      // spacer
                      const SizedBox(height: 15),

                      Row(children: [
                        Container(
                            color: Colors.black54,
                            height: 1,
                            width:
                                (MediaQuery.of(context).size.width / 2) - 60),
                        const SizedBox(width: 5),
                        Text("or".toUpperCase()),
                        const SizedBox(width: 5),
                        Container(
                            color: Colors.black54,
                            height: 1,
                            width: (MediaQuery.of(context).size.width / 2) - 60)
                      ]),

                      // spacer
                      const SizedBox(height: 15),

                      PartsBuilder.buildButton(16, ThemeBuilder.mint,
                          Colors.white, "Create Account".toUpperCase(), () {
                        stepper.moveForward();
                      }, false, MediaQuery.of(context).size.width, 50)
                    ],
                  )))),
          validation: () {
            return null;
          },
          showBackButton: false,
          showContinueButton: false,
          index: 0,
          actionOne: () {},
          actionTwo: () {}),
      ZephStep(
          color: Colors.white,
          name: "step2",
          content: Container(
              padding: const EdgeInsets.all(38),
              margin: const EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Container(
                  padding: const EdgeInsets.all(0),
                  child: SizedBox(
                      child: Column(
                    children: [
                      // spacer
                      const SizedBox(height: 30),

                      // welcome text
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Welcome \r\nto Zeph',
                              style: ThemeBuilder.textStyle(
                                  45, Colors.black, FontWeight.bold))),

                      // spacer
                      const SizedBox(height: 10),

                      // secondary text
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              'Lets set up your Zeph account to access \r\ntailored-to-you breathe exercises, \r\nlung tests training and more!',
                              style: ThemeBuilder.textStyle(
                                  14, Colors.black, FontWeight.normal))),

                      // spacer
                      const SizedBox(height: 20),

                      // name
                      SizedBox(
                          height: 47,
                          child: PartsBuilder.buildTextFormField(
                              labelText: "NAME",
                              textSize: 14,
                              controller: _nameTextEditController,
                              validator: (d) {
                                return "";
                              })),

                      //email
                      SizedBox(
                          height: 47,
                          child: PartsBuilder.buildTextFormField(
                              labelText: "EMAIL",
                              textSize: 14,
                              controller: _emailTextEditController,
                              validator: (s) {
                                return "";
                              })),

                      //password
                      SizedBox(
                          height: 47,
                          child: PartsBuilder.buildTextFormField(
                              labelText: "PASSWORD",
                              textSize: 14,
                              isForPassword: true,
                              controller: _passwordTextEditController,
                              validator: (d) {
                                return "";
                              })),

                      //re-enter password
                      SizedBox(
                          height: 47,
                          child: PartsBuilder.buildTextFormField(
                              labelText: "RE-ENTER PASSWORD",
                              textSize: 14,
                              isForPassword: true,
                              controller: _reenterPasswordTextEditController,
                              validator: (d) {
                                return "";
                              })),
                    ],
                  )))),
          validation: () {
            ZephUser zephUser = _getCredentials();
            userState.setZephUser(zephUser);

            return null;
          },
          showBackButton: true,
          showContinueButton: allCredentialDataCaptured(),
          index: 1,
          actionOne: () {},
          actionTwo: () {}),
      ZephStep(
          index: 2,
          color: Colors.white,
          name: "step3",
          content: Container(
              padding: const EdgeInsets.only(left: 48, right: 48),
              margin: const EdgeInsets.all(0),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Container(
                  padding: const EdgeInsets.all(0),
                  child: SizedBox(
                      height: 370,
                      child: Column(
                        children: [
                          // welcome text
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text("What's your primary goal for Zeph ?",
                                  style: ThemeBuilder.textStyle(
                                      45, Colors.black, FontWeight.bold))),

                          // spacer
                          const SizedBox(height: 10),

                          // secondary text
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                  'Understanding your goals helps us create a customized plan that is tailored to your needs.',
                                  style: ThemeBuilder.textStyle(
                                      14, Colors.black, FontWeight.normal))),

                          // spacer
                          const SizedBox(height: 20),

                          ToggleButtons(
                            direction: Axis.vertical,
                            renderBorder: false,
                            isSelected: _primaryGoalsSelectionList,
                            children: [
                              Container(
                                  margin:
                                      const EdgeInsets.only(top: 6, right: 6),
                                  width: MediaQuery.of(context).size.width,
                                  child: OutlinedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              _primaryGoalsSelectionList[0]
                                                  ? MaterialStatePropertyAll(
                                                      ThemeBuilder.mint)
                                                  : const MaterialStatePropertyAll(
                                                      Colors.transparent),
                                          shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ))),
                                      onPressed: () {
                                        _resetPrimaryGoalsSelectionList();
                                        setState(() {
                                          _primaryGoalsSelectionList[0] =
                                              !_primaryGoalsSelectionList[0];
                                          _selectedGoalIndex = 0;
                                        });
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            "IMPROVE LUNG HEALTH",
                                            style: ThemeBuilder.textStyle(
                                                13, Colors.black),
                                          )))),
                              Container(
                                  margin:
                                      const EdgeInsets.only(top: 6, right: 6),
                                  width: MediaQuery.of(context).size.width,
                                  child: OutlinedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              _primaryGoalsSelectionList[1]
                                                  ? MaterialStatePropertyAll(
                                                      ThemeBuilder.mint)
                                                  : const MaterialStatePropertyAll(
                                                      Colors.transparent),
                                          shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ))),
                                      onPressed: () {
                                        _resetPrimaryGoalsSelectionList();
                                        setState(() {
                                          _primaryGoalsSelectionList[1] =
                                              !_primaryGoalsSelectionList[1];
                                          _selectedGoalIndex = 1;
                                        });
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            "PRACTICE DEEP BREATHING",
                                            style: ThemeBuilder.textStyle(
                                                13, Colors.black),
                                          )))),
                              Container(
                                  margin:
                                      const EdgeInsets.only(top: 6, right: 6),
                                  width: MediaQuery.of(context).size.width,
                                  child: OutlinedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              _primaryGoalsSelectionList[2]
                                                  ? MaterialStatePropertyAll(
                                                      ThemeBuilder.mint)
                                                  : const MaterialStatePropertyAll(
                                                      Colors.transparent),
                                          shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ))),
                                      onPressed: () {
                                        _resetPrimaryGoalsSelectionList();
                                        setState(() {
                                          _primaryGoalsSelectionList[2] =
                                              !_primaryGoalsSelectionList[2];
                                          _selectedGoalIndex = 2;
                                        });
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            "MAXIMIZE FITNESS",
                                            style: ThemeBuilder.textStyle(
                                                13, Colors.black),
                                          )))),
                              Container(
                                  margin:
                                      const EdgeInsets.only(top: 6, right: 6),
                                  width: MediaQuery.of(context).size.width,
                                  child: OutlinedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              _primaryGoalsSelectionList[3]
                                                  ? MaterialStatePropertyAll(
                                                      ThemeBuilder.mint)
                                                  : const MaterialStatePropertyAll(
                                                      Colors.transparent),
                                          shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ))),
                                      onPressed: () {
                                        _resetPrimaryGoalsSelectionList();
                                        setState(() {
                                          _primaryGoalsSelectionList[3] =
                                              !_primaryGoalsSelectionList[3];
                                          _selectedGoalIndex = 3;
                                        });
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            "RELAX & MEDITATE",
                                            style: ThemeBuilder.textStyle(
                                                13, Colors.black),
                                          )))),
                            ],
                          )
                        ],
                      )))),
          validation: () {
            ZephUser u = _getPrimaryGoal();
            userState.setZephUser(u);
            return null;
          },
          showBackButton: true,
          showContinueButton:
              _primaryGoalsSelectionList.any((element) => element == true),
          actionOne: () {},
          actionTwo: () {}),
    ];

    //conditional
    if (_selectedGoalIndex > -1) {
      switch (_selectedGoalIndex) {
        case 0:
          {
            steps.add(ZephStep(
                index: 3,
                color: Colors.white,
                name: "step4_lung_health",
                content: Container(
                    padding: const EdgeInsets.all(48),
                    margin: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Container(
                        padding: const EdgeInsets.all(0),
                        child: SizedBox(
                            height: 370,
                            child: Column(
                              children: [
                                // welcome text
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                        "Great! You're one step \r\ncloser to a \r\nsigh of relief",
                                        style: ThemeBuilder.textStyle(45,
                                            Colors.black, FontWeight.bold))),

                                // spacer
                                const SizedBox(height: 10),

                                // secondary text
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                        'Practicing resistance allows gradual strengthening of your accessory lung muscles',
                                        style: ThemeBuilder.textStyle(14,
                                            Colors.black, FontWeight.normal))),

                                // spacer
                                const SizedBox(height: 20),
                              ],
                            )))),
                validation: () {
                  return null;
                },
                showBackButton: true,
                showContinueButton: true,
                actionOne: () {},
                actionTwo: () {}));
            break;
          }
        case 1:
          {
            steps.add(ZephStep(
                index: 3,
                color: Colors.white,
                name: "step4_breathing",
                content: Container(
                    padding: const EdgeInsets.all(48),
                    margin: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Container(
                        padding: const EdgeInsets.all(0),
                        child: SizedBox(
                            height: 370,
                            child: Column(
                              children: [
                                // welcome text
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                        "You'll master that inhale in no time.",
                                        style: ThemeBuilder.textStyle(45,
                                            Colors.black, FontWeight.bold))),

                                // spacer
                                const SizedBox(height: 50),

                                // secondary text
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                        "Diaphragmatic breathing is an ancient art that we'rre pairing with precision science to improve how you learn and master the metronome of your body.",
                                        style: ThemeBuilder.textStyle(14,
                                            Colors.black, FontWeight.normal))),

                                // spacer
                                const SizedBox(height: 20),
                              ],
                            )))),
                validation: () {
                  return null;
                },
                showBackButton: true,
                showContinueButton: true,
                actionOne: () {},
                actionTwo: () {}));
            break;
          }
        case 2:
          {
            steps.add(ZephStep(
                index: 3,
                color: Colors.white,
                name: "step4_fitness",
                content: Container(
                    padding: const EdgeInsets.all(48),
                    margin: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Container(
                        padding: const EdgeInsets.all(0),
                        child: SizedBox(
                            height: 370,
                            child: Column(
                              children: [
                                // welcome text
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                        "So you're \r\nready to \r\nlevel up your \r\ntraining?",
                                        style: ThemeBuilder.textStyle(45,
                                            Colors.black, FontWeight.bold))),

                                // spacer
                                const SizedBox(height: 50),

                                // secondary text
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                        "Training the muscular skeletal body is essential, but fine tuning the engine of breath is key to building sustained power.",
                                        style: ThemeBuilder.textStyle(14,
                                            Colors.black, FontWeight.normal))),
                              ],
                            )))),
                validation: () {
                  return null;
                },
                showBackButton: true,
                showContinueButton: true,
                actionOne: () {},
                actionTwo: () {}));
            break;
          }
        case 3:
          {
            steps.add(ZephStep(
                index: 3,
                color: Colors.white,
                name: "step4_relax_meditate",
                content: Container(
                    padding: const EdgeInsets.all(48),
                    margin: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Container(
                        padding: const EdgeInsets.all(0),
                        child: SizedBox(
                            height: 370,
                            child: Column(
                              children: [
                                // welcome text
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                        "Here's the playbook for full-body zen",
                                        style: ThemeBuilder.textStyle(45,
                                            Colors.black, FontWeight.bold))),

                                // spacer
                                const SizedBox(height: 50),

                                // secondary text
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                        "Relaxing the diaphragm and practicing deep breathing imporoves rest, recovery and mental and physical performance.",
                                        style: ThemeBuilder.textStyle(14,
                                            Colors.black, FontWeight.normal))),
                              ],
                            )))),
                validation: () {
                  return null;
                },
                showBackButton: true,
                showContinueButton: true,
                actionOne: () {},
                actionTwo: () {}));
            break;
          }
      }
    }

    //required at end
    steps.add(buildGetSpecificsStep(context, settings));
    steps.add(buildPairingDeviceStep(context, settings));

    // set the index
    for (int i = 1; i < steps.length; i++) {
      var step = steps[i];
      step.index = i;
    }

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
                  const Icon(Icons.chevron_left, color: Colors.black45),
                  Text("BACK", style: ThemeBuilder.textStyle(14, Colors.black)),
                ],
              )),
          continueWidget: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Row(
                children: [
                  Text("CONTINUE",
                      style: ThemeBuilder.textStyle(14, Colors.black)),
                  const Icon(Icons.chevron_right, color: Colors.black45)
                ],
              )),
          stepText: null,
          ofText: null),
      steps: steps,
    );


  }

  ZephUser _getCredentials() {
    var userCredentials = Credentials();
    userCredentials.name = _nameTextEditController.value.text;
    userCredentials.email = _emailTextEditController.value.text;
    userCredentials.password = _passwordTextEditController.value.text;
    userCredentials.signUpDate = DateTime.now().toUtc();
    var zephUser = userState.zephUser;
    zephUser.credentials = userCredentials;
    return zephUser;
  }

  ZephUser _getPrimaryGoal() {
    var u = userState.zephUser;
    var selectionIndex =
        _primaryGoalsSelectionList.indexWhere((element) => element == true);
    var selectedGoal = _primaryGoals[selectionIndex];
    u.primaryGoal = selectedGoal;
    return u;
  }

  ZephStep buildGetSpecificsStep(
      BuildContext context, OnboardingStepperState? settings) {
    return ZephStep(
        index: 4,
        validation: () async {
          // gather the last bit of onboarding data
          ZephUser? u = _getPersonalData();

          if (u != null) {
            userState.setZephUser(u);

            // push data to firebase
            await DbService().saveOnboardingData(u, () {
              var t = 2;
            }, (e) {
              if (kDebugMode) {
                print(e);
              }
            });
          }
          return null;
        },
        showBackButton: true,
        showContinueButton: _allSpecificsCollected(),
        color: Colors.white,
        content: Container(
            padding: const EdgeInsets.only(left: 48, right: 48),
            margin: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Container(
                padding: const EdgeInsets.all(0),
                child: SizedBox(
                    child: Column(
                  children: [
                    // welcome text
                    Visibility(
                        visible: true,
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text('Now for \r\nsome \r\nspecifics',
                                style: ThemeBuilder.textStyle(
                                    45, Colors.black, FontWeight.bold)))),

                    // spacer
                    const SizedBox(height: 20),

                    // secondary text
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                            'Lungs come in all shapes and sizes. Help us better understand yours.',
                            style: ThemeBuilder.textStyle(
                                14, Colors.black, FontWeight.normal))),

                    // spacer
                    const SizedBox(height: 10),

                    // weight / height
                    SizedBox(
                        height: 110,
                        child: Row(
                          children: [
                            const Spacer(),
                            PartsBuilder.buildWeightInput(
                                _weightTextEditController),
                            const Spacer(),
                            PartsBuilder.buildHeightInput(
                                _height1TextEditController,
                                _height2TextEditController),
                            const Spacer()
                          ],
                        )),

                    // Date of birth
                    SizedBox(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        child:
                            // PartsBuilder.buildTextFormField(
                            //       labelText: "DATE OF BIRTH",
                            //       textSize: 14,
                            //       controller: _dobTextEditController,
                            //       validator: (d) {
                            //         return "";
                            //       })
                            PartsBuilder.buildDatePicker(
                                _dobTextEditController, context)),

                    //Gender (assigned at birth)
                    SizedBox(
                        height: 110,
                        width: MediaQuery.of(context).size.width,
                        child: Row(children: [
                          PartsBuilder.buildGenderLabel(),
                          const Spacer(),
                          _buildSwitcher(
                              (x) {}, "M", "F", () => _gender == "male"),
                        ]))
                  ],
                )))),
        name: 'step4_specifics',
        actionOne: () {},
        actionTwo: () {});
  }

  ZephUser? _getPersonalData() {
    try {
      var u = userState.zephUser;
      var pd = u.personalData;
      var height = (int.parse(_height1TextEditController.value.text) * 12 +
              int.parse(_height2TextEditController.value.text))
          .toString();
      pd.height = height;
      pd.weight = _weightTextEditController.value.text;
      pd.dob = _dobTextEditController.value.text;
      pd.gender = _gender == "male" ? Gender.male : Gender.female;
      return u;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Widget _buildSelector({
    BuildContext? context,
    required String name,
  }) {
    final isActive = name == selectedRole;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context!).primaryColor : null,
          border: Border.all(
            width: 0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(),
      ),
    );
  }

  _buildSwitcher(
      Function onC, String activeText, inactiveText, bool Function() valFunc) {
    return SizedBox(
      height: 100,
      child: FlutterSwitch(
        width: 105.0,
        height: 35.0,
        activeText: activeText,
        inactiveText: inactiveText,
        value: valFunc(),
        borderRadius: 30.0,
        padding: 8.0,
        showOnOff: true,
        activeToggleColor: ThemeBuilder.mainBgColor(),
        activeTextColor: const Color(0xFFb8b8b8),
        inactiveTextColor: ThemeBuilder.mainBgColor(),
        inactiveColor: const Color(0xFFb8b8b8),
        activeColor: ThemeBuilder.mainBgColor(),
        onToggle: (bool value) {
          onC(value);
          if (_gender == "male") {
            setState(() {
              _gender = "female";
            });
          } else {
            setState(() {
              _gender = "male";
            });
          }
        },
      ),
    );
  }

  void _resetPrimaryGoalsSelectionList() {
    _primaryGoalsSelectionList = [false, false, false, false];
  }

  ZephStep buildPairingDeviceStep(
      BuildContext context, OnboardingStepperState settings) {
    return ZephStep(
        index: 5,
        validation: () {
          return null;
        },
        showBackButton: false,
        showContinueButton: false,
        name: 'step5_bt_connect',
        content: Container(
            padding: const EdgeInsets.only(left: 48, right: 48),
            margin: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            color: ThemeBuilder.mint,
            child: SizedBox(
                child: Column(children: [
              // device and bluetooth sign
              Visibility(
                  visible: true,
                  child: SizedBox(
                      child: Stack(children: [
                    //bluetooth icon
                    Positioned(
                        left: !settings.deviceConnected ? 150 : 160,
                        top: !settings.deviceConnected ? 0 : 30,
                        width: 30,
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12.0)),
                            child: Container(
                                color: Colors.yellowAccent,
                                width: 30,
                                height: 30,
                                child: Icon(
                                  Icons.bluetooth_connected_sharp,
                                  color: ThemeBuilder.mint,
                                )))),

                    //zeph device
                    AnimatedContainer(
                        duration: const Duration(milliseconds: 1300),
                        child: Image(
                            height: !settings.deviceConnected ? 280 : 420,
                            width: 280,
                            color: ThemeBuilder.offwhite,
                            image:
                                const AssetImage("assets/images/device.png"))),
                  ]))),

              // buffer
              const SizedBox(
                height: 10,
              ),

              // top label text
              Align(
                  child: settings.deviceConnected
                      ? Text('Connected!',
                          style: ThemeBuilder.textStyle(
                              30, Colors.white, FontWeight.bold))
                      : Text('Pair with your pair of lungs',
                          style: ThemeBuilder.textStyle(
                              30, Colors.white, FontWeight.bold))),

              // spacer
              const SizedBox(height: 10),

              // secondary text
              Visibility(
                  visible: !settings.deviceConnected,
                  child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 50),
                      child: Text(
                          'Connect your bluetooth enabled Zeph device and start a routine that tracks, trains and strengthens your lungs and accessory muscles.',
                          style: ThemeBuilder.textStyle(
                              14, Colors.white, FontWeight.normal)))),

              // connect device button
              Visibility(
                  visible: !settings.deviceConnected ||
                      (!settings.scanResultsFound && !settings.isScanning),
                  child: PartsBuilder.buildButton(
                      16,
                      ThemeBuilder.forest,
                      ThemeBuilder.mint,
                      settings.isScanning
                          ? "Searching for devices ..."
                          : "Connect your Zeph".toUpperCase(), () async {
                    if (settings.deviceConnected || settings.isScanning) {
                      return;
                    }
                    var future = FlutterBlue.instance
                        .startScan(timeout: const Duration(seconds: 10));
                    future.whenComplete(() => {settings.setIsScanning(false)});
                    settings.setIsScanning(true);
                  }, settings.isScanning && !settings.scanResultsFound,
                      MediaQuery.of(context).size.width, 50, 12)),

              // Visibility(
              //     visible: settings.isScanning && !settings.scanResultsFound,
              //     child: Container(
              //           height: 30,
              //           color: ThemeBuilder.mint, child: const SpinKitThreeBounce(color: Colors.black54,))),

              // scan result list

              Visibility(
                  visible: true,
                  child: Positioned(
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        margin: const EdgeInsets.only(top: 0, bottom: 0),
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              // StreamBuilder<List<BluetoothDevice>>(
                              //   stream: Stream.periodic(const Duration(seconds: 3))
                              //       .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                              //   initialData: [],
                              //   builder: (c, snapshot) {
                              //     if(snapshot.data == null) {
                              //       return  const Text("No devices detected");
                              //     } else {
                              //         return Column(
                              //           children: snapshot.data!
                              //               .map((d) =>
                              //               ListTile(
                              //                 title: Text(d.name),
                              //                 subtitle: Text(
                              //                     d.id.toString()),
                              //                 trailing: StreamBuilder<
                              //                     BluetoothDeviceState>(
                              //                   stream: d.state,
                              //                   initialData: BluetoothDeviceState
                              //                       .disconnected,
                              //                   builder: (c, snapshot) {
                              //                     if (snapshot.data ==
                              //                         BluetoothDeviceState
                              //                             .connected) {
                              //                       return ElevatedButton(
                              //                         child: Text('OPEN'),
                              //                         onPressed: () =>
                              //                             Navigator.of(
                              //                                 context)
                              //                                 .push(
                              //                                 MaterialPageRoute(
                              //                                     builder: (
                              //                                         context) =>
                              //                                         DeviceScreen(
                              //                                             device: d))),
                              //                       );
                              //                     }
                              //                     return Text(
                              //                         snapshot.data
                              //                             .toString());
                              //                   },
                              //                 ),
                              //               ))
                              //               .toList(),
                              //         );
                              //     }},
                              // ),

                              Visibility(
                                  visible: !settings.deviceConnected &&
                                      settings.isScanning,
                                  child: ScanResultsWidget(
                                      scans: FlutterBlue.instance.scanResults))
                              // StreamBuilder<List<ScanResult>>(
                              //   stream: FlutterBlue.instance.scanResults,
                              //   initialData: [],
                              //   builder: (c, snapshot) =>
                              //       Column(
                              //     children: snapshot.data!
                              //         .map(
                              //           (r) => r.device.name
                              //               .toLowerCase()
                              //               .contains("zeph")
                              //
                              //               ? ScanResultTile(
                              //         result: r,
                              //         onTap: () =>{
                              //         r.device.connect(),
                              //             settings.setDeviceConnected(true)
                              //         },
                              //       ) : const SizedBox.shrink(),
                              //     ).toList(),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ))),

              // connect later button
              Visibility(
                  replacement: Container(
                    height: 15,
                  ),
                  visible: !settings.deviceConnected,
                  child: PartsBuilder.buildNoBgButton(
                      12, Colors.white, "Connect later".toUpperCase(), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Breathability()),
                    );
                  }, 300, 50))
            ]))),
        color: ThemeBuilder.mint,
        actionOne: () {},
        actionTwo: () {});
  }

  bool _allSpecificsCollected() {
    return _dobTextEditController.value.text != "" &&
        _gender != "unknown" &&
        _weightTextEditController.value.text != "" &&
        _height1TextEditController.value.text != "" &&
        _height2TextEditController.value.text != "";
  }

  Future<bool> checkPermissions() async {
    var reqList = <Permission>[];
    var devicesPermission = await Permission.nearbyWifiDevices.status;
    reqList.add(Permission.nearbyWifiDevices);
    var bluetoothPermission = await Permission.bluetooth.status;
    reqList.add(Permission.bluetooth);
    var bluetoothScanPermission = await Permission.bluetoothScan.status;
    reqList.add(Permission.bluetoothScan);
    var bluetoothConnectPermission = await Permission.bluetoothConnect.status;
    reqList.add(Permission.bluetoothConnect);
    var locationPermission = await Permission.location.status;
    reqList.add(Permission.location);

    if (permGranted == false) {
      Map<Permission, PermissionStatus> statuses = await reqList.request();

      if (statuses.values.any((element) => !element.isGranted)) {
        permGranted = false;
        return false;
      }
      permGranted = true;
      return true;
    }

    return true;
  }

  bool allCredentialDataCaptured() {
    return _emailTextEditController.value.text != "" &&
        _passwordTextEditController.value.text != "" &&
        _reenterPasswordTextEditController.value.text != "" &&
        _nameTextEditController.value.text != "" &&
        passwordsAreValid() &&
        emailAddressIsValid();
  }

  bool passwordsAreValid() {
    //TODO add check for bad name characters line numbers and symbols
    return _passwordTextEditController.value.text ==
        _reenterPasswordTextEditController.value.text;
  }

  bool emailAddressIsValid() {
    //TODO get email validation library to use here
    return true;
  }

  Stream<List<T>> aggregate<T>(Stream<T> s) async* {
    List<T> res = [];
    await for (T item in s) {
      res.add(item);
      yield res;
    }
  }

  Stream<T> fromIterableDelayed<T>(Iterable<T> i, Duration delay) async* {
    for (T item in i) {
      await Future.delayed(delay);
      yield item;
    }
  }

  ZephStep buildSplashScreen() {
    return ZephStep(
        color: ThemeBuilder.forest,
        name: "step0",
        content: Container(
            padding: const EdgeInsets.all(38),
            margin: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            color: ThemeBuilder.forest,
            child: Container(
              height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(0),
              child: Stack(
                children:  [
                  AnimatedPositioned(
                    left: MediaQuery.of(context).size.width/ 2 - 120,
                    top: MediaQuery.of(context).size.height/ 2 - 160,
                      duration: const Duration(milliseconds: 700),
                      child:  const SizedBox(
                      height: 70,
                      width: 140,
                      child: Image(image: AssetImage("assets/images/zeph.png"), height: 70, width: 140,))),
                  AnimatedPositioned(
                      left: MediaQuery.of(context).size.width/ 2 - 110,
                      top: MediaQuery.of(context).size.height - 250,
                      duration: const Duration(milliseconds: 700),
                      child:  const SizedBox(
                          height: 70,
                          width: 140,
                          child: Image(image: AssetImage("assets/images/zeph_icon.png"), height: 70, width: 140,))),
                ],
              ),
                )),
        validation: () {
          return null;
        },
        showBackButton: false,
        showContinueButton: false,
        index: 0,
        actionOne: () {},
        actionTwo: () {});
  }
}
