import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shnatter/src/controllers/UserController.dart';
import 'package:shnatter/src/helpers/helper.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/utils/size_config.dart';
import 'package:shnatter/src/views/setting/widget/setting_header.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class SettingLocationScreen extends StatefulWidget {
  SettingLocationScreen({Key? key, required this.routerChange})
      : con = UserController(),
        super(key: key);
  late UserController con;
  Function routerChange;
  @override
  State createState() => SettingLocationScreenState();
}

// ignore: must_be_immutable
class SettingLocationScreenState extends mvc.StateMVC<SettingLocationScreen> {
  late UserController con;
  var userInfo = UserManager.userInfo;
  List<Suggestion> autoLocationList = [];

  var locationInfo = {};
  @override
  void initState() {
    locationInfo['current'] = userInfo['current'];
    locationInfo['hometown'] = userInfo['hometown'];
    add(widget.con);
    con = controller as UserController;
    super.initState();
  }

  Future<void> fetchSuggestions(
    String input,
  ) async {
    final sessionToken = const Uuid().v4();
    // HttpsCallable callable =
    //     FirebaseFunctions.instance.httpsCallable('getLocationAutoList');
    // await callable.call(<String, dynamic>{
    //   'locationKey': input,
    //   'apiKey': Helper.apiKey,
    //   'sessionToken': sessionToken
    // });

    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input &types=address&language=en&key=${Helper.apiKey}&sessiontoken=$sessionToken';
    try {
      final response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          // compose suggestions in a list
          autoLocationList = result['predictions']
              .map<Suggestion>(
                  (p) => Suggestion(p['place_id'], p['description']))
              .toList();
          setState(() {});
        }
        if (result['status'] == 'ZERO_RESULTS') {
          autoLocationList = [];
          setState(() {});
        }
      } else {
        throw Exception('Failed to fetch suggestion');
      }
    } catch (e) {
      autoLocationList = [];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Container(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              SettingHeader(
                routerChange: widget.routerChange,
                icon: const Icon(
                  Icons.location_on,
                  color: Color.fromARGB(255, 43, 83, 164),
                ),
                pagename: 'Location',
                button: const {
                  'buttoncolor': Color.fromARGB(255, 17, 205, 239),
                  'icon': Icon(Icons.person),
                  'text': 'View Profile',
                  'flag': true
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                width:
                    SizeConfig(context).screenWidth > SizeConfig.smallScreenSize
                        ? SizeConfig(context).screenWidth * 0.5 + 40
                        : SizeConfig(context).screenWidth * 0.9 - 30,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: titleAndsubtitleInput(
                            'Current Location',
                            50,
                            1,
                            (value) {
                              locationInfo['current'] = value;
                            },
                            locationInfo['current'] ?? '',
                          ),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(top: 20)),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: titleAndsubtitleInput(
                            'Hometown',
                            50,
                            1,
                            (value) {
                              locationInfo['hometown'] = value;
                            },
                            locationInfo['hometown'] ?? '',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              footer()
            ],
          )),
    );
  }

  Widget titleAndsubtitleInput(title, double height, line, onChange, text) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 85, 95, 127)),
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  width: 400,
                  height: height,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: text,
                        maxLines: line,
                        minLines: line,
                        onChanged: (value) {
                          onChange(value);
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(top: 10, left: 10),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget footer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.only(top: 20),
      child: Container(
          height: 65,
          decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(
              color: Color.fromARGB(255, 220, 226, 237),
              width: 1,
            )),
            color: Color.fromARGB(255, 240, 243, 246),
            // borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          padding: const EdgeInsets.only(top: 5, left: 15),
          child: Row(
            children: [
              const Flexible(fit: FlexFit.tight, child: SizedBox()),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(3),
                    backgroundColor: Colors.white,
                    // elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0)),
                    minimumSize: con.isProfileChange
                        ? const Size(90, 50)
                        : const Size(120, 50),
                    maximumSize: con.isProfileChange
                        ? const Size(90, 50)
                        : const Size(120, 50),
                  ),
                  onPressed: () {
                    con.profileChange(locationInfo);
                  },
                  child: con.isProfileChange
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                  color: Colors.black),
                            ),
                            Padding(padding: EdgeInsets.only(left: 7)),
                            Text('Loading',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold))
                          ],
                        )
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.black,
                              fontWeight: FontWeight.bold))),
              const Padding(padding: EdgeInsets.only(right: 30))
            ],
          )),
    );
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}
