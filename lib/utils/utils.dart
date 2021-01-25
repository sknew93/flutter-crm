import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_color/random_color.dart';

var screenWidth;
var screenHeight;
Color submitButtonColor = Color.fromRGBO(75, 153, 90, 1);
Color bottomNavBarSelectedBGColor = Color.fromRGBO(219, 232, 249, 1);
Color bottomNavBarSelectedTextColor = Color.fromRGBO(15, 36, 62, 1);
Color bottomNavBarTextColor = Color.fromRGBO(75, 75, 78, 1);
String currentBottomNavigationIndex = "0";

RandomColor randomColor = RandomColor();

OutlineInputBorder boxBorder() {
  return OutlineInputBorder(
    // borderRadius: BorderRadius.all(Radius.circular(15)),
    borderSide: BorderSide(width: 1, color: Colors.grey),
  );
}

DateTime currentBackPressTime;
Future<bool> onWillPop() {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime) > Duration(seconds: 2)) {
    currentBackPressTime = now;
    Fluttertoast.showToast(msg: 'Press again to close Bottle CRM');
    return Future.value(false);
  }
  exit(0);
}

showToast(message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.white,
    textColor: Colors.green,
    fontSize: 16.0,
  );
}

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
  String capitalizeFirstofEach() =>
      this.split(" ").map((str) => str.inCaps).join(" ");
}

Future<void> requestDownload(String _url, String _name) async {
  // final dir = await getDownloadsDirectory(); //From path_provider package
  // var _localPath = dir.path + _name;
  var _localPath = "/storage/emulated/0/Download/";

  final savedDir = Directory(_localPath);
  await savedDir.create(recursive: true).then((value) async {
    String _taskid = await FlutterDownloader.enqueue(
      url: _url,
      fileName: _name,
      savedDir: _localPath,
      showNotification: true,
      openFileFromNotification: false,
    ).catchError((onError) {
      showToast("Downloaded Error >> $onError");
    });

    if (_taskid != null) {
      showToast("$_name, Successfully Downloaded");
    }
  });
}
