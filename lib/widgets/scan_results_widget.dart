import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../helpers/theme_builder.dart';
import '../screens/app_tiles.dart';
import '../state/onboarding_stepper_state.dart';

class ScanResultsWidget extends StatefulWidget {
  const ScanResultsWidget({super.key, required this.scans});

  final Stream<List<ScanResult>> scans;

  @override
  State<ScanResultsWidget> createState() => _ScanResultsWidgetState();
}

class _ScanResultsWidgetState extends State<ScanResultsWidget> {
  late OnboardingStepperState settings;

  @override
  Widget build(BuildContext context) {
    settings = context.watch<OnboardingStepperState>();

    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBlue.instance.scanResults,
      initialData: const [],
      builder: (c, snapshot) {
        if(snapshot.hasData && snapshot.data!.isNotEmpty){
          settings.setScanResultsFound(true);
          return Container(
              color: ThemeBuilder.mint,
              child: Column(
                children: snapshot.data!
                    .map(
                      (r) =>
                  r.device.name
                      .toLowerCase()
                      .contains("zeph")

                      ? ScanResultTile(
                    result: r,
                    onTap: () =>
                    {
                      r.device.connect(),
                      settings.setDeviceConnected(true),
                      settings.setDeviceName(r.device.name)
                    },
                  ) : const SizedBox.shrink(),
                ).toList(),
              )
          );
        } else {
          settings.setScanResultsFound(false);
         return Container(
              height: 30,
              color: ThemeBuilder.mint,
              child: const SpinKitThreeBounce(color: Colors.black54,));
        }
      }
    );
  }
}