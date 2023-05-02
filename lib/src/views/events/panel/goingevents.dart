// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/helpers/helper.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/utils/size_config.dart';
import 'package:shnatter/src/views/events/widget/eventcell.dart';

import '../../../controllers/PostController.dart';

class GoingEvents extends StatefulWidget {
  GoingEvents({Key? key, required this.routerChange})
      : con = PostController(),
        super(key: key);
  late PostController con;
  Function routerChange;

  @override
  State createState() => GoingEventsState();
}

class GoingEventsState extends mvc.StateMVC<GoingEvents> {
  bool loading = false;
  late PostController con;
  var userInfo = UserManager.userInfo;
  var goingEvents = [];
  int arrayLength = 0;
  @override
  void initState() {
    add(widget.con);
    con = controller as PostController;
    super.initState();
    getEventNow();
  }

  void getEventNow() {
    loading = true;
    setState(() {});
    con.getEvent('going', UserManager.userInfo['uid']).then((value) => {
          goingEvents = value,
          loading = false,
          setState(() {}),
        });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = SizeConfig(context).screenWidth - SizeConfig.leftBarWidth;
    if (loading) {
      return Row(
        children: [
          Expanded(
              child: Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(color: Colors.grey),
          )),
        ],
      );
    }
    if (screenWidth <= 600) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: goingEvents.isEmpty
            ? [
                Container(
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
                        ),
                      ),
                    ],
                  ),
                )
              ]
            : goingEvents
                .map(
                  (event) => EventCell(
                    routerChange: widget.routerChange,
                    eventData: event,
                    buttonFun: () {
                      // con.interestedEvent(event['id']).then((value) {
                      getEventNow();
                      // });
                    },
                  ),
                )
                .toList(),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: goingEvents.isEmpty
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
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.count(
                  crossAxisCount: screenWidth > 900
                      ? 3
                      : screenWidth > 600
                          ? 2
                          : 1,
                  // childAspectRatio: 2 / 3,
                  padding: const EdgeInsets.all(4.0),
                  mainAxisSpacing: 4.0,
                  shrinkWrap: true,
                  crossAxisSpacing: 4.0,
                  children: goingEvents
                      .map(
                        (event) => EventCell(
                          routerChange: widget.routerChange,
                          eventData: event,
                          buttonFun: () {
                            // con.interestedEvent(event['id']).then((value) {
                            getEventNow();
                            // });
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
