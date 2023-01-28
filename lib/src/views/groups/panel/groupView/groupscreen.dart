import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/controllers/PostController.dart';
import 'package:shnatter/src/managers/FileManager.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/utils/size_config.dart';
import 'package:shnatter/src/views/box/searchbox.dart';
import 'package:shnatter/src/views/chat/chatScreen.dart';
import 'package:shnatter/src/views/groups/panel/groupView/groupSettingsScreen.dart';
import 'package:shnatter/src/views/navigationbar.dart';
import 'package:shnatter/src/views/panel/leftpanel.dart';

import 'groupAvatarandTabscreen.dart';
import 'groupMembersScreen.dart';
import 'groupPhotosScreen.dart';
import 'groupTimelineScreen.dart';
import 'groupVideosScreen.dart';

class GroupEachScreen extends StatefulWidget {
  GroupEachScreen({Key? key, required this.docId, required this.routerChange})
      : con = PostController(),
        super(key: key);
  final PostController con;
  String docId = '';
  Function routerChange;

  @override
  State createState() => GroupEachScreenState();
}

class GroupEachScreenState extends mvc.StateMVC<GroupEachScreen>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();
  bool showSearch = false;
  late FocusNode searchFocusNode;
  late FileController filecon;
  bool showMenu = false;
  late AnimationController _drawerSlideController;
  double progress = 0;
  //
  var userInfo = UserManager.userInfo;
  @override
  void initState() {
    add(widget.con);
    con = controller as PostController;
    filecon = FileController();
    setState(() {});
    super.initState();
    searchFocusNode = FocusNode();
    _drawerSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    con = controller as PostController;
    getSelectedGroup(widget.docId);
  }

  late PostController con;

  void getSelectedGroup(id) {
    con.getSelectedGroup(id).then((value) => {
          if (value)
            {
              setState(() {}),
              print('Successfully get group you want!!!'),
            }
        });
  }

  void onSearchBarFocus() {
    searchFocusNode.requestFocus();
    setState(() {
      showSearch = true;
    });
  }

  void clickMenu() {
    if (_isDrawerOpen() || _isDrawerOpening()) {
      _drawerSlideController.reverse();
    } else {
      _drawerSlideController.forward();
    }
  }

  void onSearchBarDismiss() {
    if (showSearch)
      setState(() {
        showSearch = false;
      });
  }

  bool _isDrawerOpen() {
    return _drawerSlideController.value == 1.0;
  }

  bool _isDrawerOpening() {
    return _drawerSlideController.status == AnimationStatus.forward;
  }

  bool _isDrawerClosed() {
    return _drawerSlideController.value == 0.0;
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    _drawerSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawerEnableOpenDragGesture: false,
        drawer: Drawer(),
        body: Stack(
          fit: StackFit.expand,
          children: [
            ShnatterNavigation(
              searchController: searchController,
              onSearchBarFocus: onSearchBarFocus,
              onSearchBarDismiss: onSearchBarDismiss,
              drawClicked: clickMenu,
            ),
            Padding(
                padding: const EdgeInsets.only(top: SizeConfig.navbarHeight),
                child: SingleChildScrollView(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizeConfig(context).screenWidth <
                        //         SizeConfig.mediumScreenSize
                        //     ? const SizedBox()
                        //     : LeftPanel(),
                        // //    : SizedBox(width: 0),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: con.group == null
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.end,
                          crossAxisAlignment: con.group == null
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                          children: [
                            con.group == null
                                ? Container(
                                    width: 30,
                                    height: 30,
                                    margin: EdgeInsets.only(
                                        top: SizeConfig(context).screenHeight *
                                            2 /
                                            5),
                                    child: const CircularProgressIndicator(
                                      color: Colors.grey,
                                    ),
                                  )
                                : Expanded(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GroupAvatarandTabScreen(
                                            onClick: (value) {
                                              print(value);
                                              con.groupTab = value;
                                              setState(() {});
                                            },
                                          ),
                                          con.groupTab == 'Timeline'
                                              ? GroupTimelineScreen(
                                                  onClick: (value) {
                                                  con.groupTab = value;
                                                  setState(() {});
                                                })
                                              : con.groupTab == 'Photos'
                                                  ? GroupPhotosScreen(
                                                      onClick: (value) {
                                                      con.groupTab = value;
                                                      setState(() {});
                                                    })
                                                  : con.groupTab == 'Videos'
                                                      ? GroupVideosScreen(
                                                          onClick: (value) {
                                                          con.groupTab = value;
                                                          setState(() {});
                                                        })
                                                      : con.groupTab ==
                                                              'Members'
                                                          ? GroupMembersScreen(
                                                              onClick: (value) {
                                                              con.groupTab =
                                                                  value;
                                                              setState(() {});
                                                            })
                                                          : con.groupTab ==
                                                                  'Settings'
                                                              ? GroupSettingsScreen(
                                                                  onClick:
                                                                      (value) {
                                                                  con.groupTab =
                                                                      value;
                                                                  setState(
                                                                      () {});
                                                                })
                                                              : const SizedBox()
                                          // EventFriendScreen(),
                                        ]),
                                  ),
                          ],
                        )),
                      ]),
                )),
            AnimatedBuilder(
                animation: _drawerSlideController,
                builder: (context, child) {
                  return FractionalTranslation(
                      translation: SizeConfig(context).screenWidth >
                              SizeConfig.smallScreenSize
                          ? Offset(0, 0)
                          : Offset(_drawerSlideController.value * 0.001, 0.0),
                      child: SizeConfig(context).screenWidth >
                                  SizeConfig.smallScreenSize ||
                              _isDrawerClosed()
                          ? const SizedBox()
                          : Padding(
                              padding:
                                  EdgeInsets.only(top: SizeConfig.navbarHeight),
                              child: Container(
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Container(
                                      //   color: Colors.white,
                                      //   width: SizeConfig.leftBarWidth,
                                      //   child: SingleChildScrollView(
                                      //     child: LeftPanel(),
                                      //   ),
                                      // )
                                    ]),
                              )));
                }),
            showSearch
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        showSearch = false;
                      });
                    },
                    child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: const Color.fromARGB(0, 214, 212, 212),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: const SizedBox(
                                      width: 20,
                                      height: 20,
                                    )),
                                Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, right: 9),
                                  width: SizeConfig(context).screenWidth * 0.4,
                                  child: TextField(
                                    focusNode: searchFocusNode,
                                    controller: searchController,
                                    cursorColor: Colors.white,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.search,
                                          color: Color.fromARGB(
                                              150, 170, 212, 255),
                                          size: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15.0)),
                                      ),
                                      filled: true,
                                      fillColor: Color(0xff202020),
                                      hintText: 'Search',
                                      hintStyle: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            ShnatterSearchBox()
                          ],
                        )),
                  )
                : const SizedBox(),
            ChatScreen(),
          ],
        ));
  }
}
