// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/controllers/PostController.dart';
import 'package:shnatter/src/helpers/helper.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/routes/route_names.dart';
import 'package:shnatter/src/utils/colors.dart';

import 'package:shnatter/src/utils/size_config.dart';

class ShnatterEventSuggest extends StatefulWidget {
  ShnatterEventSuggest({Key? key, required this.routerChange})
      : super(key: key);
  Function routerChange;

  @override
  State createState() => ShnatterEventSuggestState();
}

class ShnatterEventSuggestState extends mvc.StateMVC<ShnatterEventSuggest> {
  //
  bool isSound = true;
  var con = PostController();
  var userInfo = UserManager.userInfo;
  var isJoining = {};
  @override
  void initState() {
    isSound = UserManager.userInfo['eventsSuggestion'] ?? true;
    Future.delayed(const Duration(microseconds: 0), () async {
      con.unInterestedEvents =
          await con.getEvent('unInterested', userInfo['userName']);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
          width: SizeConfig(context).screenWidth < 600
              ? SizeConfig(context).screenWidth
              : 600,
          // width: SizeConfig.rightPaneWidth,
          // color: Colors.white,
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Suggested Events",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 45.0),
                  ),
                  Row(children: [
                    GestureDetector(
                      onTap: () {
                        widget.routerChange({
                          'router': RouteNames.events,
                        });
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: Transform.scale(
                        scaleX: 0.7,
                        scaleY: 0.7,
                        child: CupertinoSwitch(
                          //thumbColor: kprimaryColor,
                          activeColor: kprimaryColor,
                          value: isSound,
                          onChanged: (value) async {
                            await Helper.userCollection
                                .doc(UserManager.userInfo['uid'])
                                .update({'eventsSuggestion': value});

                            setState(() {
                              isSound = value;
                            });
                            var userManager = UserManager.userInfo;
                            userManager['eventsSuggestion'] = value;
                            var box = {};
                            userManager.forEach((key, value) {
                              box = {...box, key.toString(): value};
                            });
                            await Helper.saveJSONPreference(
                                Helper.userField, {...box});
                            await UserManager.getUserInfo();
                          },
                        ),
                      ),
                    ),
                  ])
                ],
              ),
              const Divider(
                height: 1,
                //thickness: 5,
                //indent: 20,
                //endIndent: 0,
                //color: Colors.black,
              ),
              AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: isSound ? con.unInterestedEvents.length * 70 : 0,
                  curve: Curves.fastOutSlowIn,
                  child: SizedBox(
                    //size: Size(100,100),
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: con.unInterestedEvents.length,
                      itemBuilder: (context, index) => Material(
                          child: ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 5, right: 5),
                        leading: GestureDetector(
                          onTap: () {
                            widget.routerChange({
                              'router': RouteNames.events,
                              'subRouter': con.unInterestedEvents[index]['id'],
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: CircleAvatar(
                              radius: 17,
                              backgroundImage: NetworkImage(
                                con.unInterestedEvents[index]['data']
                                            ['eventPicture'] ==
                                        ''
                                    ? Helper.blankEvent
                                    : con.unInterestedEvents[index]['data']
                                        ['eventPicture'],
                              ),
                            ),
                          ),
                        ),
                        title: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 11),
                            children: <TextSpan>[
                              TextSpan(
                                  text: con.unInterestedEvents[index]['data']
                                      ['eventName'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Colors.black),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      widget.routerChange({
                                        'router': RouteNames.events,
                                        'subRouter':
                                            con.unInterestedEvents[index]['id']
                                      });
                                    })
                            ],
                          ),
                        ),
                        subtitle: Text(
                          '${con.unInterestedEvents[index]['data']['eventInterested'].length} Interested',
                          style: const TextStyle(fontSize: 10),
                        ),
                        trailing: ElevatedButton(
                            onPressed: () async {
                              isJoining[index] = true;
                              setState(() {});
                              con
                                  .interestedEvent(
                                      con.unInterestedEvents[index]['id'])
                                  .then((value) async {
                                con.unInterestedEvents = await con.getEvent(
                                    'unInterested', userInfo['userName']);
                                isJoining[index] = false;
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0)),
                                minimumSize:
                                    isJoining[index] != null && isJoining[index]
                                        ? const Size(60, 35)
                                        : const Size(111, 35),
                                maximumSize:
                                    isJoining[index] != null && isJoining[index]
                                        ? const Size(60, 35)
                                        : const Size(111, 35)),
                            child: isJoining[index] != null && isJoining[index]
                                ? const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.black,
                                        size: 18.0,
                                      ),
                                      Text(' Interested',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900)),
                                    ],
                                  )),
                      )),
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                        height: 1,
                        endIndent: 10,
                      ),
                    ),
                  ))
            ],
          )),
    );
  }
}
