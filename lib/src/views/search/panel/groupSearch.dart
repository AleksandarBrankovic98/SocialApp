// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/controllers/SearcherController.dart';
import 'package:shnatter/src/helpers/helper.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/utils/size_config.dart';
import 'package:shnatter/src/views/search/widget/groupCell.dart';

class GroupSearch extends StatefulWidget {
  GroupSearch(
      {Key? key, required this.routerChange, required this.searchResult})
      : con = SearcherController(),
        super(key: key);
  late SearcherController con;
  Function routerChange;
  List searchResult;

  @override
  State createState() => GroupSearchState();
}

class GroupSearchState extends mvc.StateMVC<GroupSearch> {
  late SearcherController searchCon;
  var userInfo = UserManager.userInfo;

  @override
  void initState() {
    add(widget.con);
    searchCon = controller as SearcherController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.searchResult.isEmpty
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
                      borderRadius: BorderRadius.all(Radius.circular(20))),
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
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  width: SizeConfig(context).screenWidth,
                  height: SizeConfig(context).screenHeight -
                      SizeConfig.navbarHeight -
                      150 -
                      (UserManager.userInfo['isVerify'] ? 0 : 50),
                  child: ListView.separated(
                    itemCount: widget.searchResult.length,
                    itemBuilder: (context, index) => SearchGroupCell(
                      groupInfo: widget.searchResult[index],
                      routerChange: widget.routerChange,
                    ),
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                      height: 1,
                      endIndent: 10,
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
