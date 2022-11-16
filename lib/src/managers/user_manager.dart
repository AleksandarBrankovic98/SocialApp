import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shnatter/src/routes/route_names.dart';

import '../helpers/helper.dart';

class UserManager {
  static var resToken = {};
  static var userInfo = {};
  static bool isLogined = false;

  static Future<void> getUserInfo() async {
    //await removeAllPreference();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString(Helper.userField);
    userInfo = await Helper.getJSONPreference(Helper.userField);
    if (user == null) {
      isLogined = false;
    } else {
      isLogined = true;
      RouteNames.userName = '/${userInfo['userName']}';
    }
  }
}












/*
http
.post(
  Uri.parse(
      'https://api.relysia.com/v1/send?serviceID=9ab1b61e-92ae-4612-9a4f-c5a102a6c068&authToken=$token'),
  headers: {
    'authToken': '$token',
    'content-type': 'application/json',
    'serviceID': '9ab1b69e-92ae-4612-9a4f-c5a102a6c068'
  },
  body:
      '{ "dataArray" : [{"to" : "4064@shnatter.com","amount" : 10,"tokenId" : "$token_id"}]}',
)
*/