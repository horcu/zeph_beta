import 'dart:ui';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart' hide DropdownButtonFormField;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeph_beta/helpers/theme_builder.dart';
import 'package:zeph_beta/style/palette.dart';

import '../widgets/dropdown_button.dart';

class PartsBuilder {


  static Widget buildTextFormField({
    String? labelText,
    double? textSize,
    TextInputType? tiType,
    bool isForPassword = false,
    TextEditingController? controller,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      //padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        keyboardType: tiType,
        obscureText: isForPassword,
        style: ThemeBuilder.textStyle(textSize ?? 18, Colors.black38),
        decoration: InputDecoration(
          hintStyle: ThemeBuilder.textStyle(12, Colors.black38),
          labelText: labelText,
        ),
        validator: validator,
        controller: controller,
      ),
    );
  }

  static Widget buildDropDown(double? bh, double? bw,
      {required dynamic data,
      required String name,
      required Function onChange}) {
    return Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: DropdownButtonFormField(
          buttonElevation: 0,
          dropdownElevation: 0,
          buttonDecoration: BoxDecoration(
            boxShadow: null,
            borderRadius: BorderRadius.circular(8),
          ),
          // selectedItemHighlightColor: _handleThemedTextColor(widget
          //     .currentTheme) ,
          dropdownFullScreen: false,
          style: GoogleFonts.raleway(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.normal,
              fontSize: 25,
              color: ThemeBuilder.textColor()),
          decoration: InputDecoration(
            suffixStyle: GoogleFonts.raleway(
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                fontSize: 25,
                color: ThemeBuilder.textColor()),
            prefixStyle: GoogleFonts.raleway(
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                fontSize: 25,
                color: ThemeBuilder.textColor()),
            //Add isDense true and zero Padding.
            //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  style: BorderStyle.solid, color: ThemeBuilder.textColor()),
              borderRadius: BorderRadius.circular(8),
            ),
            //Add more decoration as you want here
            //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
          ),
          isExpanded: false,
          hint: Text(name,
              style: ThemeBuilder.textStyle(12, Palette().white)),
          icon: Icon(
            Icons.arrow_drop_down,
            color: ThemeBuilder.textColor(),
          ),
          iconSize: 30,
          buttonWidth: bw ?? 100.0,
          buttonHeight: bh ?? 50.0,
          buttonPadding: const EdgeInsets.only(left: 20, right: 10),
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: ThemeBuilder.mainBgColor(),
          ),
          items: data
              .map((item) => DropdownMenuItem<String>(
                    value: item.id.toString(),
                    child: Text(item.name.toString().toUpperCase(),
                        style: ThemeBuilder.textStyle(14, Palette().white)),
                  ))
              .toList(),
          validator: (value) {
            if (value == null) {
              return 'Select Choice';
            }
          },
          onChanged: (v) {
            var id = int.parse(v.toString());
            var d = data.firstWhere((element) => element.id == id);
            onChange(d);
          },
          onSaved: (value) {},
        ));
  }

  static Widget buildTextField({
    String? labelText,
    double? textSize,
    TextInputType? tiType,
    bool isForPassword = false,
    TextEditingController? controller,
    FormFieldValidator<String>? validator,
    required Function(String) onChangedCb,
  }) {
    return Container(
      //padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        onChanged: onChangedCb,
        keyboardType: tiType,
        obscureText: isForPassword,
        style: ThemeBuilder.textStyle(textSize ?? 18, Colors.black38),
        decoration: InputDecoration(
          hintStyle: ThemeBuilder.textStyle(12, Colors.black38),
          labelText: labelText,
        ),
        controller: controller,
      ),
    );
  }

  static AppBar buildAppBar(BuildContext context, String mainLabelText) {
    return AppBar(
      foregroundColor: ThemeBuilder.mainForegroundColor(),
      systemOverlayStyle:
          const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      leadingWidth: 250,
      leading: SizedBox(
          width: 250,
          child: GestureDetector(
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(mainLabelText,
                      style:
                          ThemeBuilder.textStyle(16, Palette().white))))),
      toolbarHeight: 60,
      centerTitle: true,
      title: const Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: SizedBox(
            width: 10,
            child: null,
          )),
      backgroundColor: ThemeBuilder.mainBgColor(),
      bottom: PreferredSize(
          preferredSize: const Size(double.infinity, kToolbarHeight),
          child: Container()),
      elevation: 0,
      actions: [
        Align(
            alignment: AlignmentDirectional.topEnd,
            child: SizedBox(
                height: 60,
                width: 50,
                child: Padding(
                    padding:
                        const EdgeInsets.only(top: 0, right: 16, bottom: 5),
                    child: Container())))
      ],
      shadowColor: Colors.white,
    );
  }

  static buildList(
      items, lItem, String emptyTitle, double textSize, String emptySubTitle) {
    return items.isNotEmpty
        ? SizedBox(
            height: 500,
            child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return lItem(data: items[index]);
                }))
        : SizedBox(
            height: 500,
            width: 500,
            child: EmptyWidget(
              hideBackgroundAnimation: true,
              packageImage: PackageImage.Image_3,
              title: emptyTitle,
              subTitle: emptySubTitle,
              titleTextStyle:
                  ThemeBuilder.textStyle(textSize, Palette().white),
              subtitleTextStyle:
                  ThemeBuilder.textStyle(textSize - 2, Palette().white),
            ));
  }

  static buildConfirmationDialog(double textSize, BuildContext context,
      String label, Widget? contentChild, cb) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeBuilder.mainBgColor(),
          title: Text(label,
              style: ThemeBuilder.textStyle(textSize, Palette().white)),
          content: SingleChildScrollView(
            child: contentChild ??
                Column(
                  children: <Widget>[
                    Row(children: [
                      Text(label,
                          style: ThemeBuilder.textStyle(
                              textSize, Palette().white))
                    ]),
                  ],
                ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm',
                  style: ThemeBuilder.textStyle(textSize, Palette().white)),
              onPressed: () {
                cb();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel',
                  style: ThemeBuilder.textStyle(textSize, Palette().white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static buildWeightInput(TextEditingController weightTextEditController) {
    return SizedBox(
        height: 50,
        width: 120,
        child: Stack(children: [
          Positioned(
              child: PartsBuilder.buildTextFormField(
                  labelText: "WEIGHT", textSize: 14, tiType: TextInputType.number, controller: weightTextEditController)),
          Positioned(
              left: 90,
              top: 28,
              child:
                  Text("lbs", style: ThemeBuilder.textStyle(12, Colors.black)))
        ]));
  }

  static buildHeightInput(TextEditingController height1textEditController, TextEditingController height2textEditController) {
    return SizedBox(
        height: 50,
        width: 190,
        child: Stack(children: [
          Positioned(
              width: 100,
              left: 20,
              child: PartsBuilder.buildTextFormField(
                  labelText: "HEIGHT", textSize: 14, tiType: TextInputType.number, controller: height1textEditController)),
          Positioned(
              left: 95,
              top: 28,
              width: 150,
              child:
                  Text("ft", style: ThemeBuilder.textStyle(12, Colors.black))),
          Positioned(
              width: 50,
              left: 120,
              child:
                  PartsBuilder.buildTextFormField(labelText: "", textSize: 14, tiType: TextInputType.number, controller: height2textEditController)),
          Positioned(
              width: 150,
              left: 175,
              top: 28,
              child:
                  Text("in", style: ThemeBuilder.textStyle(12, Colors.black)))
        ]));
  }

  static buildGenderLabel() {
    return SizedBox(
      height: 50,
      width: 200,
      child: Column(
        children: [
          Row(children: [
            Text("Gender", style: ThemeBuilder.textStyle(16, Colors.black54)),
          ]),
          Row(children: [
            Text("(Assigned at birth)",
                style: ThemeBuilder.textStyle(13, Colors.black38)),
          ]),
        ],
      ),
    );
  }

  static buildButton(double textSize, Color bgClr, Color fgClr, String btnText, Function cb, bool showLoadingIcon,
      [double? width, double? height, double? radius]) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 5.0)),
        child: SizedBox(
            height: height,
            width: width,
            child: ElevatedButton(
                style: ButtonStyle(
                  shape:  MaterialStatePropertyAll(RoundedRectangleBorder(
                    side: BorderSide(width: .5, color: fgClr)
                  )),
                  elevation: const MaterialStatePropertyAll(0),
                  textStyle: MaterialStatePropertyAll(
                      ThemeBuilder.textStyle(textSize, bgClr)),
                  backgroundColor: MaterialStatePropertyAll(bgClr),
                ),
                onPressed: () {cb();},
                child:
                showLoadingIcon ?
                 const SpinKitThreeBounce(color: Colors.black54, size: 20,)
                : Text( btnText,
                  style: ThemeBuilder.textStyle(textSize, fgClr),
                ))));
  }

  static buildNoBgButton(double textSize, Color fgClr, String btnText, Function onClickCb,
      [double? width, double? height]) {
    return SizedBox(
            height: height,
            width: width,
            child: ElevatedButton(
                style: ButtonStyle(
                  elevation: const MaterialStatePropertyAll(0),
                  textStyle: MaterialStatePropertyAll(
                      ThemeBuilder.textStyle(textSize, fgClr)),
                  backgroundColor: const MaterialStatePropertyAll(Colors.transparent),
                ),
                onPressed: () => onClickCb(),
                child: Text(
                  btnText,
                  style: ThemeBuilder.textStyle(textSize, fgClr),
                )));
  }

  static  buildDatePicker(TextEditingController dateController,  BuildContext context) {
    return TextField(
        controller: dateController, //editing controller of this TextField
        decoration:  InputDecoration(
          labelStyle: ThemeBuilder.textStyle(14, Colors.black54),
            icon: const Icon(Icons.calendar_today), //icon of text field
            labelText: "Date of birth".toUpperCase() //label text of field
        ),
        readOnly: false, // when true user cannot edit text
        onTap: () async {
         DateTime? picked =  await showDatePicker(
              context: context,
              initialDate: DateTime.now(), //get today's date
              firstDate:DateTime.now().subtract(const Duration(days: 36500)), //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime.now()
          );

         //_dobSelected = picked!;
         dateController.text = DateFormat("MM-dd-yy").format(picked!);
        // dateController.value = ;

        }
    );
  }
}
