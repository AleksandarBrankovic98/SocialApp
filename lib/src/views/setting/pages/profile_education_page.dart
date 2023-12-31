import 'package:flutter/material.dart';
import 'package:shnatter/src/controllers/UserController.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/utils/size_config.dart';
import 'package:shnatter/src/views/setting/widget/setting_header.dart';

import 'package:mvc_pattern/mvc_pattern.dart' as mvc;

class SettingEducationScreen extends StatefulWidget {
  SettingEducationScreen({Key? key, required this.routerChange})
      : con = UserController(),
        super(key: key);
  late UserController con;
  Function routerChange;
  @override
  State createState() => SettingEducationScreenState();
}

// ignore: must_be_immutable
class SettingEducationScreenState extends mvc.StateMVC<SettingEducationScreen> {
  var educationInfo = {};
  late UserController con;

  @override
  void initState() {
    add(widget.con);
    con = controller as UserController;
    super.initState();
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
                  Icons.school,
                  color: Color.fromARGB(255, 43, 83, 164),
                ),
                pagename: 'Education',
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
                            'School',
                            50,
                            1,
                            (value) async {
                              educationInfo['school'] = value;
                            },
                            UserManager.userInfo['school'] ?? '',
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
                            'Major',
                            50,
                            1,
                            (value) async {
                              educationInfo['major'] = value;
                            },
                            UserManager.userInfo['major'] ?? '',
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 25)),
                        Expanded(
                          flex: 1,
                          child: titleAndsubtitleInput(
                            'Class',
                            50,
                            1,
                            (value) async {
                              educationInfo['class'] = value;
                            },
                            UserManager.userInfo['class'] ?? '',
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
      padding: const EdgeInsets.only(top: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
                    print(educationInfo);
                    con.profileChange(educationInfo);
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
