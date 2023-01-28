// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/utils/size_config.dart';
import 'package:shnatter/src/views/groups/widget/groupcell.dart';

import '../../../controllers/PostController.dart';
import '../../../models/chatModel.dart';

class MyGroups extends StatefulWidget {
  MyGroups({Key? key, required this.routerChange})
      : con = PostController(),
        super(key: key);
  late PostController con;
  Function routerChange;

  State createState() => MyGroupsState();
}

class MyGroupsState extends mvc.StateMVC<MyGroups> {
  bool check1 = false;
  bool check2 = false;
  late PostController con;
  var userInfo = UserManager.userInfo;
  var myGroups = [];
  int arrayLength = 0;
  @override
  void initState() {
    add(widget.con);
    con = controller as PostController;
    con.setState(() {});
    super.initState();
    getGroupNow();
    print('now initstate');
  }

  void getGroupNow() {
    con.getGroup('manage', UserManager.userInfo['uid']).then((value) => {
          myGroups = [...value],
          myGroups.where((group) =>
              group['data']['groupAdmin'][0]['userName'] ==
              UserManager.userInfo['id']),
          print(myGroups),
          setState(() {})
        });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = SizeConfig(context).screenWidth - SizeConfig.leftBarWidth;
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: GridView.count(
              crossAxisCount: screenWidth > 800
                  ? 4
                  : screenWidth > 600
                      ? 3
                      : screenWidth > 210
                          ? 2
                          : 1,
              childAspectRatio: 2 / 3,
              padding: const EdgeInsets.all(4.0),
              mainAxisSpacing: 4.0,
              shrinkWrap: true,
              crossAxisSpacing: 4.0,
              children: myGroups
                  .map(
                    (group) => GroupCell(
                      groupData: group,
                      refreshFunc: () {
                        getGroupNow();
                      },
                      routerChange: widget.routerChange,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
