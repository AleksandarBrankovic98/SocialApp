import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/controllers/UserController.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/utils/size_config.dart';
import 'package:shnatter/src/views/setting/widget/setting_footer.dart';
import 'package:shnatter/src/views/setting/widget/setting_header.dart';

class SettingBasicScreen extends StatefulWidget {
  SettingBasicScreen({Key? key, required this.routerChange})
      : con = UserController(),
        super(key: key);
  late UserController con;
  Function routerChange;
  @override
  State createState() => SettingBasicScreenState();
}

// ignore: must_be_immutable
class SettingBasicScreenState extends mvc.StateMVC<SettingBasicScreen> {
  // ignore: non_constant_identifier_names
  var setting_profile = {};
  var userInfo = UserManager.userInfo;
  List<dynamic> month = [
    {'value': 'none', 'title': 'Month'},
    {'value': '1', 'title': 'Jan'},
    {'value': '2', 'title': 'Feb'},
    {'value': '3', 'title': 'Mar'},
    {'value': '4', 'title': 'Apr'},
    {'value': '5', 'title': 'May'},
    {'value': '6', 'title': 'Jun'},
    {'value': '7', 'title': 'Jul'},
    {'value': '8', 'title': 'Aug'},
    {'value': '9', 'title': 'Sep'},
    {'value': '10', 'title': 'Oct'},
    {'value': '11', 'title': 'Nov'},
    {'value': '12', 'title': 'Dec'}
  ];
  late List gender = [
    {
      'title': 'Male',
      'value': 'Male',
    },
    {
      'title': 'Female',
      'value': 'Female',
    },
    {
      'title': 'Other',
      'value': 'Other',
    },
  ];
  List userRelationship = [
    {
      'value': 'none',
      'title': 'Select Relationship',
    },
    {
      'value': 'single',
      'title': 'Single',
    },
    {
      'value': 'inarelationship',
      'title': 'In a relationship',
    },
    {
      'value': 'Married',
      'title': 'Married',
    },
    {
      'value': 'complicated',
      'title': 'It\'s a complicated',
    },
    {
      'value': 'separated',
      'title': 'Seperated',
    },
    {
      'value': 'divorced',
      'title': 'Divorced',
    },
    {
      'value': 'widowed',
      'title': 'Widowed',
    },
  ];
  List country = [
    {
      'title': 'Select Country',
      'value': 'none',
    },
    {
      'title': 'United State',
      'value': 'us',
    },
    {
      'title': 'Switzerland',
      'value': 'sw',
    },
    {
      'title': 'Canada',
      'value': 'ca',
    },
  ];
  Map day = {};
  List<dynamic> year = [
    {'value': 'none', 'title': 'Year'}
  ];
  late UserController con;
  @override
  void initState() {
    add(widget.con);
    con = controller as UserController;
    // sex = userInfo['sex'] ?? 'male';
    setting_profile['sex'] = userInfo['sex'] ?? 'Male';
    setting_profile['firstName'] = userInfo['firstName'] ?? '';
    setting_profile['workWebsite'] = userInfo['workWebsite'] ?? '';
    setting_profile['lastName'] = userInfo['lastName'] ?? '';
    setting_profile['about'] = userInfo['about'] ?? '';

    setting_profile['current'] = userInfo['current'] ?? '';
    for (int i = 1; i < 13; i++) {
      var d = [
        {'value': 'none', 'title': 'Day'}
      ];
      for (int j = 1; j < 32; j++) {
        if (i == 2 && j == 29) {
          break;
        } else if (i == 4 || i == 6 || i == 9 || i == 11) {
          if (j == 31) {
            break;
          }
        }
        d.add({
          'value': j.toString(),
          'title': j.toString(),
        });
      }
      day = {...day, i.toString(): d};
    }
    for (int i = 1910; i < 2022; i++) {
      year.add({
        'value': i.toString(),
        'title': i.toString(),
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> bDay = day[
        (userInfo['birthM'] == null || userInfo['birthM'] == 'none')
            ? '1'
            : userInfo['birthM']];
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              SettingHeader(
                routerChange: widget.routerChange,
                icon: const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 43, 83, 164),
                ),
                pagename: 'Basic',
                button: const {
                  'buttoncolor': Color.fromARGB(255, 17, 205, 239),
                  'icon': Icon(Icons.person),
                  'text': 'View Profile',
                  'flag': true
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: SizeConfig(context).screenWidth >
                        SizeConfig.smallScreenSize
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 400,
                                  child: titleAndsubtitleInput(
                                    'First Name',
                                    50,
                                    1,
                                    (value) async {
                                      setting_profile['firstName'] = value;
                                    },
                                    setting_profile['firstName'] ??
                                        userInfo['firstName'],
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(left: 25)),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 400,
                                  child: titleAndsubtitleInput(
                                    'Last Name',
                                    50,
                                    1,
                                    (value) async {
                                      setting_profile['lastName'] = value;
                                    },
                                    setting_profile['lastName'] ??
                                        userInfo['lastName'],
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(right: 20))
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 400,
                                  child: customDropDownButton(
                                    title: 'I am',
                                    width: 400,
                                    item: gender,
                                    value:
                                        userInfo['sex'] ?? gender[0]['value'],
                                    onChange: (value) {
                                      //get value when changed
                                      setting_profile['sex'] = value;
                                      userInfo['sex'] = value!;
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(left: 25)),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 400,
                                      child: customDropDownButton(
                                        title: 'Relationship Status',
                                        width: 400,
                                        item: userRelationship,
                                        value: userInfo['relationship'] ??
                                            userRelationship[0]['value'],
                                        onChange: (value) {
                                          //get value when changed
                                          setting_profile['relationship'] =
                                              value;
                                          userInfo['relationship'] = value!;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(right: 20))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 400,
                                  child: customDropDownButton(
                                    title: 'Country',
                                    width: 400,
                                    item: country,
                                    value: userInfo['country'] ??
                                        country[0]['value'],
                                    onChange: (value) {
                                      //get value when changed
                                      setting_profile['country'] = value;
                                      userInfo['country'] = value!;
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(left: 25)),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                    width: 400,
                                    child: Column(
                                      children: [
                                        titleAndsubtitleInput(
                                          'Website',
                                          50,
                                          1,
                                          (value) async {
                                            setting_profile['workWebsite'] =
                                                value;
                                          },
                                          setting_profile['workWebsite'] ?? '',
                                        ),
                                        const Text(
                                            'Website link must start with http:// or https://'),
                                      ],
                                    )),
                              ),
                              const Padding(padding: EdgeInsets.only(right: 20))
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 400,
                                  child: customDropDownButton(
                                    width: 400,
                                    title: 'Birthday',
                                    item: month,
                                    value:
                                        userInfo['birthM'] ?? month[0]['value'],
                                    onChange: (value) {
                                      //get value when changed
                                      userInfo['birthM'] = value.toString();
                                      setting_profile['birthM'] =
                                          value.toString();
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(left: 25)),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 400,
                                  child: customDropDownButton(
                                    title: '',
                                    width: 400,
                                    item: bDay,
                                    value:
                                        userInfo['birthD'] ?? bDay[0]['value'],
                                    onChange: (value) {
                                      //get value when changed
                                      userInfo['birthD'] = value.toString();
                                      setting_profile['birthD'] =
                                          value.toString();
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(left: 25)),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 400,
                                  child: customDropDownButton(
                                    width: 400,
                                    title: '',
                                    item: year,
                                    value:
                                        userInfo['birthY'] ?? year[0]['value'],
                                    onChange: (value) {
                                      //get value when changed
                                      userInfo['birthY'] = value.toString();
                                      setting_profile['birthY'] =
                                          value.toString();
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(right: 20))
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Text('I am jewish',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 82, 95, 127),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold)),
                                          Padding(
                                            padding: EdgeInsets.only(top: 10),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20)),
                                          SizedBox(
                                            height: 20,
                                            child: Transform.scale(
                                              scaleX: 0.55,
                                              scaleY: 0.55,
                                              child: CupertinoSwitch(
                                                activeColor: Colors.grey,
                                                value: userInfo['jew'] ?? false,
                                                onChanged: (value) {
                                                  setState(() {
                                                    setting_profile['jew'] =
                                                        value;
                                                    userInfo['jew'] = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 700,
                                  child: titleAndsubtitleInput(
                                      'About Me', 100, 4, (value) {
                                    setting_profile['about'] = value;
                                  },
                                      setting_profile['about'] ??
                                          userInfo['about']),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 700,
                                  child: titleAndsubtitleInput(
                                    'Religion',
                                    50,
                                    1,
                                    (value) async {
                                      setting_profile['current'] = value;
                                    },
                                    setting_profile['current'] ?? '',
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(right: 20))
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(
                            width: 400,
                            child: titleAndsubtitleInput(
                              'First Name',
                              50,
                              1,
                              (value) async {
                                setting_profile['firstName'] = value;
                              },
                              setting_profile['firstName'] ??
                                  userInfo['firstName'],
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.only(left: 25, right: 25)),
                          SizedBox(
                            width: 400,
                            child: titleAndsubtitleInput(
                              'Last Name',
                              50,
                              1,
                              (value) async {
                                setting_profile['lastName'] = value;
                              },
                              setting_profile['lastName'] ??
                                  userInfo['lastName'],
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(right: 20)),
                          SizedBox(
                            width: 400,
                            child: customDropDownButton(
                              title: 'I am',
                              width: 400,
                              item: gender,
                              value: userInfo['sex'] ?? gender[0]['value'],
                              onChange: (value) {
                                //get value when changed
                                setting_profile['sex'] = value;
                                userInfo['sex'] = value!;
                                setState(() {});
                              },
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(left: 25)),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 400,
                                child: customDropDownButton(
                                  title: 'Relationship Status',
                                  width: 400,
                                  item: userRelationship,
                                  value: userInfo['relationship'] ??
                                      userRelationship[0]['value'],
                                  onChange: (value) {
                                    //get value when changed
                                    setting_profile['relationship'] = value;
                                    userInfo['relationship'] = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.only(right: 20)),
                          SizedBox(
                            width: 400,
                            child: customDropDownButton(
                              title: 'Country',
                              width: 400,
                              item: country,
                              value: userInfo['country'] ?? country[0]['value'],
                              onChange: (value) {
                                //get value when changed
                                setting_profile['country'] = value;
                                userInfo['country'] = value!;
                                setState(() {});
                              },
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(left: 25)),
                          SizedBox(
                              width: 400,
                              child: Column(
                                children: [
                                  titleAndsubtitleInput(
                                    'Website',
                                    50,
                                    1,
                                    (value) async {
                                      setting_profile['workWebsite'] = value;
                                    },
                                    setting_profile['workWebsite'] ?? '',
                                  ),
                                  const Text(
                                      'Website link must start with http:// or https://'),
                                ],
                              )),
                          const Padding(padding: EdgeInsets.only(right: 20)),
                          SizedBox(
                            width: 400,
                            child: customDropDownButton(
                              width: 400,
                              title: 'Birthday',
                              item: month,
                              value: userInfo['birthM'] ?? month[0]['value'],
                              onChange: (value) {
                                //get value when changed
                                userInfo['birthM'] = value.toString();
                                setting_profile['birthM'] = value.toString();
                                setState(() {});
                              },
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(left: 25)),
                          SizedBox(
                            width: 400,
                            child: customDropDownButton(
                              title: '',
                              width: 400,
                              item: bDay,
                              value: userInfo['birthD'] ?? bDay[0]['value'],
                              onChange: (value) {
                                //get value when changed
                                userInfo['birthD'] = value.toString();
                                setting_profile['birthD'] = value.toString();
                                setState(() {});
                              },
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(left: 25)),
                          SizedBox(
                            width: 400,
                            child: customDropDownButton(
                              width: 400,
                              title: '',
                              item: year,
                              value: userInfo['birthY'] ?? year[0]['value'],
                              onChange: (value) {
                                //get value when changed
                                userInfo['birthY'] = value.toString();
                                setting_profile['birthY'] = value.toString();
                                setState(() {});
                              },
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(right: 20)),
                          SizedBox(
                            width: 400,
                            child: titleAndsubtitleInput('About Me', 100, 4,
                                (value) {
                              setting_profile['about'] = value;
                            }, setting_profile['about'] ?? userInfo['about']),
                          ),
                          const Padding(padding: EdgeInsets.only(right: 20)),
                          SizedBox(
                            width: 400,
                            child: titleAndsubtitleInput(
                              'Religion',
                              50,
                              1,
                              (value) async {
                                setting_profile['current'] = value;
                              },
                              setting_profile['current'] ?? '',
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(right: 20))
                        ],
                      ),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              SettingFooter(
                onClick: () {
                  con.profileChange(setting_profile);
                },
                isChange: con.isProfileChange,
              )
            ],
          )),
    );
  }

  Widget titleAndsubtitleInput(title, double height, line, onChange, text) {
    TextEditingController inputController = TextEditingController();
    inputController.text = text;
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
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        maxLines: line,
                        minLines: line,
                        // controller: inputController,
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

  Widget customDropDownButton(
      {title, double width = 0, item = const [], value, onChange}) {
    List items = item;
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Color.fromRGBO(82, 95, 127, 1),
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          const Padding(padding: EdgeInsets.only(top: 2)),
          SizedBox(
            height: 40,
            width: width,
            child: DropdownButtonFormField(
              value: value,
              items: items
                  .map((e) => DropdownMenuItem(
                      value: e['value'],
                      child: Text(
                        e['title'],
                        style: const TextStyle(
                            color: Color.fromARGB(179, 0, 0, 0)),
                      )))
                  .toList(),
              onChanged: onChange,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(top: 10, left: 10),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1),
                ),
              ),
              icon: const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Icon(Icons.arrow_drop_down)),
              iconEnabledColor: Colors.grey, //Icon color

              style: const TextStyle(
                color: Colors.grey, //Font color
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              dropdownColor: Colors.white,
              isExpanded: true,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
