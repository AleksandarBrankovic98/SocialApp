// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/utils/size_config.dart';
import 'package:shnatter/src/views/events/widget/eventcell.dart';

import '../../../controllers/PostController.dart';
import '../../../models/chatModel.dart';

class InterestedEvents extends StatefulWidget {
  InterestedEvents({Key? key})
      : con = PostController(),
        super(key: key);
  late PostController con;
  State createState() => InterestedEventsState();
}

class InterestedEventsState extends mvc.StateMVC<InterestedEvents> {
  bool check1 = false;
  bool check2 = false;
  late PostController con;
  var userInfo = UserManager.userInfo;
  var interestedEvents = [];
  int arrayLength = 0;
  @override
  void initState() {
    add(widget.con);
    con = controller as PostController;
    con.getEvent();
    con.setState(() { });
    super.initState();
    con.getEvent().then((value) => {
      for (int i = 0; i<value.length; i++) {
        for (int j = 0; j<value[i]['eventInterested'].length; j++) {
          if (value[i]['eventInterested'][j] == UserManager.userInfo['userName']) {
            interestedEvents.add(value[i]),
            setState(() { })
          }
        }
      },
    });
  }
  @override
  Widget build(BuildContext context) {
    var  screenWidth = SizeConfig(context).screenWidth - SizeConfig.leftBarWidth;
    return Container(
      child: 
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: GridView.count(
                crossAxisCount: screenWidth > 800 ? 4 : screenWidth > 600 ? 3 : screenWidth > 210 ? 2 : 1  ,
                childAspectRatio: 2/ 3,
                padding: const EdgeInsets.all(4.0),
                mainAxisSpacing: 4.0,
                shrinkWrap: true,
                crossAxisSpacing: 4.0,
                children: 
                  interestedEvents.map((event) => 
                    EventCell(
                      eventTap: (){},
                      picture: 'null',
                      interests: 1,
                      header: event['eventName'],
                      interested: false)).toList(),),
          ),
        ],
      ),
    );
  }
}