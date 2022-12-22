import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import '../models/setting.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../models/userModel.dart';

class Helper {
  static ValueNotifier<Setting> setting = ValueNotifier(Setting());
  //BuildContext context;
  // for mapping data retrieved form json array
  static var authdata = FirebaseFirestore.instance
      .collection(Helper.userField)
      .withConverter<TokenLogin>(
        fromFirestore: (snapshots, _) => TokenLogin.fromJSON(snapshots.data()!),
        toFirestore: (tokenlogin, _) => tokenlogin.toMap(),
      );
  static var eventsData =
      FirebaseFirestore.instance.collection(Helper.eventsField);
  static var pagesData =
      FirebaseFirestore.instance.collection(Helper.pagesField);
  static var groupsData =
      FirebaseFirestore.instance.collection(Helper.groupsField);
  static var productsData =
      FirebaseFirestore.instance.collection(Helper.productsField);
  static var productLikeComment =
      FirebaseFirestore.instance.collection(Helper.productLikeCommentField);
  static var allInterests =
      FirebaseFirestore.instance.collection(Helper.interestsField);
  static var avatar =
      'https://firebasestorage.googleapis.com/v0/b/shnatter-a69cd.appspot.com/o/shnatter-assests%2Fsvg%2Fprofile%2Fblank_profile_male.svg?alt=media&token=eaf0c1c7-5a30-4771-a7b8-9dc312eafe82';
  static var pageAvatar =
      'https://firebasestorage.googleapis.com/v0/b/shnatter-a69cd.appspot.com/o/shnatter-assests%2Fblank_page.jpg?alt=media&token=404c2404-1b87-4760-b6e6-286462a9cd1a';
  static var groupImage =
      'https://firebasestorage.googleapis.com/v0/b/shnatter-a69cd.appspot.com/o/shnatter-assests%2Fblank_group.jpg?alt=media&token=92339ace-99df-41de-84c5-581260ffb6ec';
  static var userField = 'user';
  static var eventsField = 'events';
  static var pagesField = 'pages';
  static var groupsField = 'groups';
  static var productsField = 'products';
  static var interestsField = 'interests';
  static var friendField = 'friends';
  static var balance = 0;
  static var message = 'messages';
  static var newMessageSearch = 'userName';
  static var apiKey = 'AIzaSyAtquiA4SXxBhs-lpAdk_xt3_dZtY4PId0';
  static var emoticons = 'emoticons';
  static var onlineStatusField = 'onlineStatus';
  static var productLikeCommentField = 'productLikeComment';
  static var passwordMinLength = 9;
  static var emptySVG =
      'https://firebasestorage.googleapis.com/v0/b/shnatter-a69cd.appspot.com/o/shnatter-assests%2Fnodaa.svg?alt=media&token=ebfb99db-2cf6-4dd4-ba96-2ca150ba1352';
  static bool isUuid(String input) {
    return RegExp(
            "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")
        .hasMatch(input);
  }

  static showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.black,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        gravity: ToastGravity.CENTER);
  }

  static failAlert(String str) {
    return Container(
        padding:
            const EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 10),
        decoration: const BoxDecoration(
            color: Color.fromRGBO(247, 86, 118, 1),
            borderRadius: BorderRadius.all(Radius.circular(3))),
        child: str == 'wrong-password'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                    Text(
                      'please re-enter password',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Text(
                      'The password you entered is incorrect. If you forgot your password? Request a new one',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ])
            : Text(
                str,
                style: TextStyle(color: Colors.white, fontSize: 11),
              ));
  }

  static saveJSONPreference(String field, Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    String saveData = jsonEncode(data);
    prefs.setString(field, saveData);
  }

  static Future<Map> getJSONPreference(String field) async {
    final prefs = await SharedPreferences.getInstance();
    String k = '{}';
    k = prefs.getString(field)!;
    return jsonDecode(k);
  }

  static String hashPassword(password) {
    var bytes = utf8.encode(password); // data being hashed
    var digest = sha256.convert(bytes).toString();
    return digest.toString();
  }

  static Future<void> removeAllPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(userField);
  }

  static connectOnlineDatabase() async {
    var snapshot = await FirebaseFirestore.instance
        .collection(onlineStatusField)
        .where('userName', isEqualTo: UserManager.userInfo['userName'])
        .get();
    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection(onlineStatusField)
          .add({'userName': UserManager.userInfo['userName'], 'status': 1});
    } else {
      await FirebaseFirestore.instance
          .collection(onlineStatusField)
          .doc(snapshot.docs[0].id)
          .update({'status': 1});
    }
    final Stream<QuerySnapshot> stream =
        FirebaseFirestore.instance.collection(onlineStatusField).snapshots();
    stream.listen((event) {
      event.docs.forEach((e) {
        print(e.data());
      });
    });
  }

  static makeOffline() async {
    var userInfo = UserManager.userInfo;
    if (userInfo['userName'] != null) {
      print('offline');
      http.post(
          Uri.parse(
              'https://us-central1-poiintz-dev.cloudfunctions.net/tokenAward'),
          headers: {'Access-Control-Allow-Origin': '*'},
          body: {'userName': userInfo['userName']});
    }
  }

  static getUserAvatar(userName) async {
    var snapshot = await FirebaseFirestore.instance
        .collection(userField)
        .where('userName', isEqualTo: userName)
        .get();
    var avatar = snapshot.docs[0]['avatar'];
    return avatar;
  }
}
