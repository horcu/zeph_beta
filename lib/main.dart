
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:zeph_beta/helpers/parts_builder.dart';
import 'package:zeph_beta/helpers/theme_builder.dart';
import 'package:zeph_beta/pages/breathability.dart';
import 'package:zeph_beta/pages/onboarding.dart';

import 'package:zeph_beta/state/onboarding_stepper_state.dart';
import 'package:zeph_beta/stepper/models/zeph_step.dart';
import 'package:zeph_beta/user/local_storage_user_state_persistence.dart';
import 'package:zeph_beta/user/user_state.dart';

import 'app_lifecycle/app_lifecycle.dart';
import 'misc/firebase_options.dart';
import 'stepper/models/zeph_stepper_config.dart';
import 'stepper/zeph_stepper.dart';

bool shouldUseFirestoreEmulator = false;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
 // if (Firebase.apps.isEmpty) {
  try{
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch(e){}finally{}


  if (shouldUseFirestoreEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Zeph',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OnBoardingPage(title: 'Flutter Demo Home Page'),
    );
  }
}

