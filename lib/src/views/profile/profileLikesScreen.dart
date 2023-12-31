import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/controllers/PostController.dart';
import 'package:shnatter/src/helpers/helper.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/views/pages/widget/pagecell.dart';
import '../../utils/size_config.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/ProfileController.dart';

class ProfileLikesScreen extends StatefulWidget {
  Function onClick;
  ProfileLikesScreen(
      {Key? key, required this.onClick, required this.routerChange})
      : con = ProfileController(),
        super(key: key);
  final ProfileController con;
  Function routerChange;
  @override
  State createState() => ProfileLikesScreenState();
}

class ProfileLikesScreenState extends mvc.StateMVC<ProfileLikesScreen> {
  var userInfo = UserManager.userInfo;
  var myPages = [];
  bool getFlag = true;
  @override
  void initState() {
    super.initState();
    add(widget.con);
    con = controller as ProfileController;
    getPageNow();
  }

  getPageNow() {
    PostController()
        .getPage('manage', UserManager.userInfo['uid'])
        .then((value) => {
              myPages = value,
              getFlag = false,
              setState(() {}),
            });
  }

  late ProfileController con;
  @override
  Widget build(BuildContext context) {
    return Column(children: [mainTabs(), likesData()]);
  }

  Widget mainTabs() {
    return Container(
      width: SizeConfig(context).screenWidth,
      height: 70,
      margin: const EdgeInsets.only(left: 30, right: 30),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(240, 240, 240, 1),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.topLeft,
      child: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(left: 20, top: 20),
              child: const Row(
                children: [
                  Icon(
                    Icons.thumb_up,
                    size: 15,
                  ),
                  Padding(padding: EdgeInsets.only(left: 5)),
                  Text(
                    'Likes',
                    style: TextStyle(fontSize: 15),
                  )
                ],
              )),
        ],
      ),
    );
  }

  Widget likesData() {
    var screenWidth = SizeConfig(context).screenWidth - SizeConfig.leftBarWidth;
    return getFlag
        ? Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(top: 100),
            child: const CircularProgressIndicator(
              color: Colors.grey,
            ),
          )
        : myPages.isEmpty
            ? Container(
                margin: const EdgeInsets.only(left: 30, right: 30),
                height: 200,
                color: Colors.white,
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
                      children: myPages
                          .map(
                            (page) => PageCell(
                              pageInfo: page,
                              refreshFunc: () {
                                getPageNow();
                              },
                              routerChange: widget.routerChange,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              );
  }
}
