
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zeph_beta/models/credentials.dart';
import 'package:zeph_beta/models/personal_data.dart';
import 'package:zeph_beta/models/zeph_user.dart';

class DbService {
  late FirebaseFirestore db;

    DbService(){
      db = FirebaseFirestore.instance;
      Settings set = const Settings(
        persistenceEnabled: true,
          sslEnabled: false);
      db.settings = set;
    }

  Future<void> saveOnboardingData(ZephUser user, successCb, errorCb) async{
    String? id= FirebaseAuth.instance.currentUser?.uid;
      db.collection("UserInformation")
        .doc(id)
        .set(user.toUserInfoJson()).then((value) => successCb(value))
        .onError((e, _) => errorCb(e));
  }

  Future<void> saveLatestBreathabilityScore(double score, successCb, errorCb) async{
   // String? id= FirebaseAuth.instance.currentUser?.uid;
   // db.collection("UserInformation")
   //       .doc(id)
        //.path("latestBreathabilityScore")
       // .set(user.toUserInfoJson()).then((value) => successCb(value))
       // .onError((e, _) => errorCb(e));
  }
}