import 'package:flutter/material.dart';
import 'package:shnatter/src/controllers/UserController.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/utils/size_config.dart';
import 'package:shnatter/src/views/setting/widget/setting_header.dart';
import 'package:shnatter/src/widget/startedInput.dart';
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
  var userInfo = UserManager.userInfo;
  @override
  void initState() {
    add(widget.con);
    con = controller as UserController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 30),
        child: Column(
          children: [
            SettingHeader(
              routerChange: widget.routerChange,
              icon: Icon(
                Icons.school,
                color: Color.fromARGB(255, 43, 83, 164),
              ),
              pagename: 'Education',
              button: {
                'buttoncolor': Color.fromARGB(255, 17, 205, 239),
                'icon': Icon(Icons.person),
                'text': 'View Profile',
                'flag': true
              },
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            Container(
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('School',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 82, 95, 127),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                width: 700,
                                child: input(
                                    validator: (value) async {
                                      print(value);
                                    },
                                    onchange: (value) async {
                                      educationInfo['school'] = value;
                                      setState(() {});
                                    },
                                    text: userInfo['school'] ?? ''),
                              )
                            ],
                          )),
                      const Padding(padding: EdgeInsets.only(right: 20))
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 20)),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Major',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 82, 95, 127),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                width: 300,
                                child: input(
                                    validator: (value) async {
                                      print(value);
                                    },
                                    onchange: (value) async {
                                      educationInfo['major'] = value;
                                      setState(() {});
                                    },
                                    text: userInfo['major'] ?? ''),
                              )
                            ],
                          )),
                      const Padding(padding: EdgeInsets.only(left: 25)),
                      Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Class',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 82, 95, 127),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                width: 300,
                                child: input(
                                    validator: (value) async {
                                      print(value);
                                    },
                                    onchange: (value) async {
                                      educationInfo['class'] = value;
                                      setState(() {});
                                    },
                                    text: userInfo['class'] ?? ''),
                              )
                            ],
                          )),
                      const Padding(padding: EdgeInsets.only(right: 20))
                    ],
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            footer()
          ],
        ));
  }

  Widget input({label, onchange, obscureText = false, validator, text}) {
    return Container(
      height: 28,
      child: StartedInput(
        validator: (val) async {
          validator(val);
        },
        obscureText: obscureText,
        onChange: (val) async {
          onchange(val);
        },
        text: text,
      ),
    );
  }

  Widget footer() {
    return Padding(
      padding: EdgeInsets.only(right: 20, top: 20),
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
                    padding: EdgeInsets.all(3),
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
                    con.profileChange(educationInfo);
                  },
                  child: con.isProfileChange
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
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
