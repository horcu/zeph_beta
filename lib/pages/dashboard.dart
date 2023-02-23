
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:zeph_beta/helpers/parts_builder.dart';
import 'package:zeph_beta/models/UserInformation.dart';
import 'package:zeph_beta/services/db_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../app_lifecycle/app_lifecycle.dart';
import '../helpers/theme_builder.dart';
import '../state/dashboard_state.dart';
import '../state/zeph_device_state.dart';
import '../user/local_storage_user_state_persistence.dart';
import '../user/user_state.dart';
import '../widgets/guage.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var _selectedIndex = 0;

  final PageController _pageController = PageController();
  late VideoPlayerController _controller;
  String _userInitials = "";
  final bool _cadenceVideoIsPlaying = false;
  late DashboardState dashState;
  late UserState userState;
  late ZephDeviceState deviceState;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var userId = FirebaseAuth.instance.currentUser?.uid ?? "0";
      if (userId != "0") {
        await _getUserData();
      }
      _getLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              return DashboardState();
            },
          ),
              ChangeNotifierProvider(
                create: (context) {
                  return ZephDeviceState();
                },
              ),
        ],
            child: FutureBuilder(
                future: checkIsLoggedIn(),
                builder: (context, snapshot) {
                  if (!snapshot.hasError &&
                      snapshot.data != null &&
                      snapshot.data == true) {
                    dashState = context.watch<DashboardState>();
                    deviceState = context.watch<ZephDeviceState>();

                    _userInitials = dashState.userInformation.firstName != ""
                        ? dashState.userInformation.firstName.substring(0, 1) +
                            dashState.userInformation.lastName.substring(0, 1)
                        : "";

                    return Scaffold(
                      appBar: AppBar(
                        backgroundColor: ThemeBuilder.forest,
                        elevation: 0,
                        systemOverlayStyle: SystemUiOverlayStyle(
                          // Status bar color
                          statusBarColor: ThemeBuilder.forest,

                          // Status bar brightness (optional)
                          statusBarIconBrightness: Brightness.light, // For Android (dark icons)
                          statusBarBrightness: Brightness.light, // For iOS (dark icons)
                        ),
                      ),
                      body: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: SizedBox(
                            child: Stack(
                              children: [
                                // curvy appbar
                                Align(
                                    alignment: Alignment.topCenter,
                                    child: SizedBox(
                                        height: 400,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: CustomPaint(
                                          painter: CurvePainter(),
                                          child: SizedBox.expand(
                                              child: Column(children: [
                                            const SizedBox(
                                              height: 0,
                                            ),

                                            // zeph logo and user icon
                                            Row(
                                              children: [
                                                const SizedBox(width: 20),
                                                CircleAvatar(
                                                    backgroundColor:
                                                        ThemeBuilder.lime,
                                                    child: Text(
                                                      _userInitials,
                                                      style: ThemeBuilder
                                                          .textStyle(
                                                              20,
                                                              ThemeBuilder
                                                                  .forest),
                                                    )),
                                                const Spacer(),
                                                const Image(
                                                    height: 30,
                                                    image: AssetImage(
                                                        "assets/images/zeph.png")),
                                                const SizedBox(width: 20)
                                              ],
                                            ),

                                            // spacer
                                            const SizedBox(
                                              height: 5,
                                            ),

                                            // location information
                                            Row(
                                              children: [
                                                const SizedBox(height: 50),
                                                const Spacer(),
                                                SizedBox(
                                                  height: 40,
                                                  child: Column(
                                                    children: [
                                                      Row(children:  [
                                                        const SizedBox(
                                                          width: 22,
                                                        ),
                                                        Text(
                                                            dashState.stateCity.toString(),
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white))
                                                      ]),
                                                      Row(children: const [
                                                        Text(
                                                            "Air Quality: 74 AQI",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                        SizedBox(width: 5),
                                                        Icon(
                                                          Icons.circle,
                                                          size: 13,
                                                          color: Colors.green,
                                                        )
                                                      ]),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                              ],
                                            ),
                                                                                           // welcome message
                                            SizedBox(
                                                child:
                                                Row(children: [
                                                  SizedBox(width: 20,),
                                                Text(
                                              "Hello, ${dashState.userInformation.firstName}!",
                                              style: ThemeBuilder.textStyle(
                                                  30, ThemeBuilder.trueWhite),
                                            )
                                            ])),

                                            // breathability data
                                             SizedBox(height: 110,
                                            child:  Row(
                                              children:  [
                                                const SizedBox(width: 50,),
                                               const SizedBox(height: 30, width: 30, child: Gauge()),
                                                const SizedBox(width: 50,),
                                                Flexible(child: Text("Your lungs are in good shape. You have the potential"
                                                    " to increase strength and endurance.", style: ThemeBuilder.textStyle(14, ThemeBuilder.trueWhite),)),
                                                const SizedBox(width: 20,),
                                              ],
                                            ),),

                                            // bottom buttons
                                            Container(
                                              padding: const EdgeInsets.only(left: 20),
                                                height: 50,
                                                child: Row(
                                                  children: [

                                                  // take test button
                                                  SizedBox(
                                                  height: 50,
                                                  child: PartsBuilder.buildButton(
                                                        13,
                                                        Colors.transparent,
                                                        Colors.white,
                                                        "Take test"
                                                            .toUpperCase(),
                                                        () {},
                                                        false,
                                                        Image(
                                                            color: deviceState.isConnected ? ThemeBuilder.mint : Colors.grey,
                                                            height: 35,
                                                            width: 25,
                                                            image: const AssetImage("assets/images/device.png")),
                                                        null,
                                                        null,
                                                        16),),

                                                  const SizedBox(width: 10,),
                                                  // favorites
                                                  SizedBox(
                                                      height: 50,
                                                      child:  PartsBuilder.buildButton(
                                                        13,
                                                        Colors.transparent,
                                                        Colors.white,
                                                        "favorites"
                                                            .toUpperCase(),
                                                        () {},
                                                        false,
                                                        const SizedBox.shrink(),
                                                        null,
                                                        null,
                                                        16)),

                                                    const Spacer(),

                                                  // device button
                                                  SizedBox(
                                                      height: 50,
                                                      child:
                                                          PartsBuilder.buildButton(
                                                              14,
                                                              Colors.transparent,
                                                              Colors.white,
                                                              deviceState.deviceName != "" ? deviceState.deviceName : "CONNECT" ,
                                                                  (){

                                                              }, true,
                                                              Image(
                                                                  color: deviceState.isConnected ? ThemeBuilder.mint : Colors.grey,
                                                                  height: 25,
                                                                  width: 25,
                                                                  image: const AssetImage("assets/images/device.png")), null, null, 20),
                                                    ),

                                                    const Spacer(),
                                                  ],
                                                ))
                                          ])),
                                        ))),

                                // Pages
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                        padding: const EdgeInsets.all(0),
                                        margin: const EdgeInsets.only(
                                            left: 0, right: 18),
                                        height:
                                            MediaQuery.of(context).size.height -
                                                470,
                                        child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(45.0)),
                                            child: SizedBox.expand(
                                                //width: MediaQuery.of(context).size.width,
                                                //height: MediaQuery.of(context).size.height - 220,
                                                child: PageView(
                                                    controller: _pageController,
                                                    onPageChanged: (index) {
                                                      setState(() {
                                                        _selectedIndex = index;
                                                        _pageController.animateToPage(
                                                            index,
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                            curve: Curves.ease);
                                                      });
                                                    },
                                                    children: <Widget>[
                                                  // Today
                                                  buildTodayWidget(),

                                                  //Train
                                                  buildTrainWidget(),

                                                  //Data
                                                  buildDataWidget(),

                                                  //Alerts
                                                  buildAlertsWidget(),
                                                ]))))),
                              ],
                            ),
                          )),
                      bottomNavigationBar: BottomNavyBar(
                        containerHeight: 65,
                        selectedIndex: _selectedIndex,
                        showElevation: true,
                        // use this to remove appBar's elevation
                        onItemSelected: (index) => setState(() {
                          _selectedIndex = index;
                          _pageController.animateToPage(index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease);
                        }),
                        items: [
                          BottomNavyBarItem(
                            icon: const ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                                child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: Image(
                                        height: 30,
                                        width: 30,
                                        image: AssetImage(
                                            "assets/images/today_ic-playstore.png")))),
                            title: Text(
                              'Today',
                              style: ThemeBuilder.textStyle(
                                  14, ThemeBuilder.forest),
                            ),
                            activeColor: ThemeBuilder.mint,
                          ),
                          BottomNavyBarItem(
                              icon: const ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Image(
                                          height: 30,
                                          width: 30,
                                          image: AssetImage(
                                              "assets/images/trainn-playstore.png")))),
                              title: Text(
                                'Train',
                                style: ThemeBuilder.textStyle(
                                    14, ThemeBuilder.forest),
                              ),
                              activeColor: ThemeBuilder.mint),
                          BottomNavyBarItem(
                              icon: const ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Image(
                                          height: 30,
                                          width: 30,
                                          image: AssetImage(
                                              "assets/images/data_ic-playstore.png")))),
                              title: Text(
                                'Data',
                                style: ThemeBuilder.textStyle(
                                    14, ThemeBuilder.forest),
                              ),
                              activeColor: ThemeBuilder.mint),
                          BottomNavyBarItem(
                              icon: const ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Image(
                                          image: AssetImage(
                                              "assets/images/ic_alerts2-playstore.png")))),
                              title: Text(
                                'Alerts',
                                style: ThemeBuilder.textStyle(
                                    14, ThemeBuilder.forest),
                              ),
                              activeColor: ThemeBuilder.mint),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                        color: ThemeBuilder.forest,
                        child: SpinKitThreeBounce(
                          color: ThemeBuilder.mint,
                        ));
                  }
                })));
  }

  Widget buildAlertsWidget() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: ThemeBuilder.trueWhite,
      child: const Center(child: Text("Alerts!")),
    );
  }

  Widget buildDataWidget() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: ThemeBuilder.trueWhite,
      child: const Center(child: Text("Data!")),
    );
  }

  Widget buildTrainWidget() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: ThemeBuilder.trueWhite,
      child: const Center(child: Text("Train!")),
    );
  }

  Widget buildTodayWidget() {
    return Container(
        padding: const EdgeInsets.all(8),
        color: ThemeBuilder.trueWhite,
        child: SingleChildScrollView(
            child: Column(children: [
          // top text
          Container(
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Quick Dose",
                    style: ThemeBuilder.textStyle(16, ThemeBuilder.black),
                  ))),

          // secondary text
          Container(
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Take some time before bed to do some cadence "
                    "breathing to help prepare your body for a restful night's sleep.",
                    style: ThemeBuilder.textStyle(14, ThemeBuilder.black),
                  ))),

          //spacer
          const SizedBox(
            height: 20,
          ),

          // cadence breathing video
          Padding(
              padding: const EdgeInsets.only(left: 20),
              child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(35.0),
                      bottomRight: Radius.circular(35.0)),
                  child: Container(
                      height: 200,
                      color: Colors.red,
                      width: MediaQuery.of(context).size.width - 10,
                      padding: const EdgeInsets.only(
                          top: 0, left: 0, right: 0, bottom: 0),
                      child: Center(
                          child: GestureDetector(
                              onTap: () => _toggleVideoPlayback(),
                              child: VideoPlayer(_controller)))))),

          // cadence breathing text and video time
          Padding(
              padding: const EdgeInsets.only(left: 20, top: 5),
              child: Row(
                children: [
                  Text("Cadence Breathing",
                      style: ThemeBuilder.textStyle(13, ThemeBuilder.black)),
                  const Spacer(),
                  Text("4:00",
                      style: ThemeBuilder.textStyle(13, ThemeBuilder.black))
                ],
              )),

          //spacer
          const SizedBox(
            height: 15,
          ),

          // Start training test and view plan link
          Padding(
              padding: const EdgeInsets.only(left: 20, top: 0),
              child: Row(children: [
                Text("Start Training",
                    style: ThemeBuilder.textStyle(16, ThemeBuilder.black)),
                const Spacer(),
                PartsBuilder.buildNoBgButton(11, ThemeBuilder.forest,
                    "View plan".toUpperCase(), () {}, 100)
              ])),

          // training video horizontal list 1
          Container(
              margin: const EdgeInsets.only(top: 10.0),
              height: 205.0,
              child: ListView(
                  // This next line does the trick.
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Column(children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(35.0),
                                  bottomRight: Radius.circular(35.0)),
                              child: Column(children: [
                                Container(
                                    height: 180,
                                    color: Colors.purple,
                                    width: 220,
                                    padding: const EdgeInsets.only(
                                        top: 0, left: 0, right: 0, bottom: 0),
                                    child: Center(child: Container()))
                              ]))),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                          width: 180,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Inhale Strength",
                            style:
                                ThemeBuilder.textStyle(13, ThemeBuilder.black),
                          ))
                    ]),
                    Column(children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(35.0),
                                  bottomRight: Radius.circular(35.0)),
                              child: Container(
                                  height: 180,
                                  color: Colors.blue,
                                  width: 220,
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 0, right: 0, bottom: 0),
                                  child: Center(child: Container())))),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                          width: 180,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Inhale Strength 2",
                            style:
                                ThemeBuilder.textStyle(13, ThemeBuilder.black),
                          ))
                    ]),
                    Column(children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(35.0),
                                  bottomRight: Radius.circular(35.0)),
                              child: Container(
                                  height: 180,
                                  color: Colors.red,
                                  width: 220,
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 0, right: 0, bottom: 0),
                                  child: Center(
                                      child: VideoPlayer(_controller))))),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                          width: 180,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Inhale Strength 3",
                            style:
                                ThemeBuilder.textStyle(13, ThemeBuilder.black),
                          ))
                    ]),
                  ])),

          // training video horizontal list 2
          // Container(
          //     margin: const EdgeInsets.symmetric(vertical: 20.0),
          //     height: 180.0,
          //     child: ListView(
          //         // This next line does the trick.
          //         scrollDirection: Axis.horizontal,
          //         children: <Widget>[
          //           Padding(
          //               padding: const EdgeInsets.only(left: 20),
          //               child: ClipRRect(
          //                   borderRadius: const BorderRadius.only(
          //                       topLeft: Radius.circular(35.0),
          //                       bottomRight: Radius.circular(35.0)),
          //                   child: Container(
          //                       height: 220,
          //                       color: Colors.red,
          //                       width: 220,
          //                       padding: const EdgeInsets.only(
          //                           top: 0, left: 0, right: 0, bottom: 0),
          //                       child:
          //                           Center(child: VideoPlayer(_controller))))),
          //           Padding(
          //               padding: const EdgeInsets.only(left: 20),
          //               child: ClipRRect(
          //                   borderRadius: const BorderRadius.only(
          //                       topLeft: Radius.circular(35.0),
          //                       bottomRight: Radius.circular(35.0)),
          //                   child: Container(
          //                       height: 220,
          //                       color: Colors.red,
          //                       width: 220,
          //                       padding: const EdgeInsets.only(
          //                           top: 0, left: 0, right: 0, bottom: 0),
          //                       child:
          //                           Center(child: VideoPlayer(_controller))))),
          //           Padding(
          //               padding: const EdgeInsets.only(left: 20),
          //               child: ClipRRect(
          //                   borderRadius: const BorderRadius.only(
          //                       topLeft: Radius.circular(35.0),
          //                       bottomRight: Radius.circular(35.0)),
          //                   child: Container(
          //                       height: 220,
          //                       color: Colors.red,
          //                       width: 220,
          //                       padding: const EdgeInsets.only(
          //                           top: 0, left: 0, right: 0, bottom: 0),
          //                       child:
          //                           Center(child: VideoPlayer(_controller))))),
          //         ]))
        ])));

    // training videos
  }

  _toggleVideoPlayback() {
    if (!_cadenceVideoIsPlaying) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  Future<bool> checkIsLoggedIn() async {
    return true;
  }

  Future<void> _getUserData() async {
    return await DbService().getUserData((DocumentSnapshot snapshot) {
      if (kDebugMode) {
        print(snapshot);
        var jsonData = snapshot.data();
        var userInformation = UserInformation.fromJson(jsonData);
        dashState.setUserInformation(userInformation);
      }
    }, (error) {
      // print then log that the user's info cannot be retrieved
      if (kDebugMode) {
        print(error);
      }
    });
  }

  _getLocation() async
  {
    Position position = await
    Geolocator.getCurrentPosition(desiredAccuracy:
    LocationAccuracy.high);
    debugPrint('location: ${position.latitude}');
    List<Placemark> addresses = await
    placemarkFromCoordinates(position.latitude,position.longitude);

    var first = addresses.first;

    dashState.setCurrentLocationStateAndCity(first.locality.toString(), first.administrativeArea.toString());

  }

}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = ThemeBuilder.forest;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, 520);

    path.quadraticBezierTo(-15, 320, size.width - 50, 311);
    path.quadraticBezierTo(size.width + 40, 320, size.width, -40);

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
