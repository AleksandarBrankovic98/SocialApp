import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/controllers/PostController.dart';
import 'package:shnatter/src/helpers/helper.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/views/events/widget/eventcell.dart';

import '../../utils/size_config.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/ProfileController.dart';
import 'model/friends.dart';

class ProfileEventsScreen extends StatefulWidget {
  ProfileEventsScreen({Key? key, required this.routerChange})
      : con = ProfileController(),
        super(key: key);
  final ProfileController con;
  Function routerChange;

  @override
  State createState() => ProfileEventsScreenState();
}

class ProfileEventsScreenState extends mvc.StateMVC<ProfileEventsScreen> {
  var userInfo = UserManager.userInfo;
  bool getFlag = true;
  List<Map> myEvents = [];
  Friends friendModel = Friends();
  @override
  void initState() {
    super.initState();
    add(widget.con);
    con = controller as ProfileController;
    getEventNow();
    friendModel.getFriends(con.viewProfileUid).then((value) {
      setState(() {});
    });
  }

  bool isMyFriend() {
    //profile selected is my friend?
    for (var item in friendModel.friends) {
      if (item['uid'] == UserManager.userInfo['uid']) {
        return true;
      }
    }
    return false;
  }

  void getEventNow() {
    PostController().getEvent('manage', con.viewProfileUid).then(
          (value) => {
            myEvents = [...value],
            myEvents.where((event) =>
                event['data']['eventAdmin'] == UserManager.userInfo['id']),
            getFlag = false,
            setState(() {})
          },
        );
  }

  late ProfileController con;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 30, top: 30, bottom: 30, left: 20),
      child: Column(children: [
        mainTabs(),
        isMyFriend() || con.viewProfileUid == UserManager.userInfo['uid']
            ? likesData()
            : const Text(
                "You can see the friends data only if you are friends.")
      ]),
    );
  }

  Widget mainTabs() {
    return Container(
      width: SizeConfig(context).screenWidth,
      height: 70,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(240, 240, 240, 1),
        borderRadius: BorderRadius.circular(3),
      ),
      margin: const EdgeInsets.only(left: 10),
      alignment: Alignment.topLeft,
      child: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(left: 20, top: 20),
              child: const Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 15,
                  ),
                  Padding(padding: EdgeInsets.only(left: 5)),
                  Text(
                    'Events',
                    style: TextStyle(fontSize: 15),
                  )
                ],
              )),
        ],
      ),
    );
  }

  Widget likesData() {
    var screenWidth =
        SizeConfig(context).screenWidth > SizeConfig.mediumScreenSize
            ? SizeConfig(context).screenWidth - SizeConfig.leftBarWidth
            : SizeConfig(context).screenWidth;
    return getFlag
        ? Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(top: 100),
            child: const CircularProgressIndicator(
              color: Colors.grey,
            ),
          )
        : myEvents.isEmpty
            ? Container(
                padding: const EdgeInsets.only(top: 40),
                alignment: Alignment.center,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.network(Helper.emptySVG, width: 90),
                      Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          width: 140,
                          decoration: const BoxDecoration(
                              color: Color.fromRGBO(240, 240, 240, 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: const Text(
                            'No data to show',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(108, 117, 125, 1)),
                          ))
                    ]))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: screenWidth > 1200
                          ? 4
                          : screenWidth > 900
                              ? 3
                              : screenWidth > 650
                                  ? 2
                                  : 1,
                      childAspectRatio: screenWidth > 650 || screenWidth < 450
                          ? 4 / 3
                          : 4 / 2,
                      padding: const EdgeInsets.only(top: 30),
                      mainAxisSpacing: 24.0,
                      shrinkWrap: true,
                      crossAxisSpacing: 20.0,
                      children: myEvents
                          .map(
                            (event) => EventCell(
                              routerChange: widget.routerChange,
                              eventData: event,
                              buttonFun: () {
                                PostController()
                                    .interestedEvent(event['id'])
                                    .then((value) {
                                  getEventNow();
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              );
  }
}
