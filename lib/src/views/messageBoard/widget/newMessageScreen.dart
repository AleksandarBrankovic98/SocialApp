// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/controllers/ChatController.dart';
import 'package:shnatter/src/helpers/helper.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/utils/size_config.dart';
import 'package:shnatter/src/views/messageBoard/messageScreen.dart';
import 'package:shnatter/src/views/messageBoard/widget/writeMessageScreen.dart';

class NewMessageScreen extends StatefulWidget {
  Function onBack;
  NewMessageScreen({Key? key, required this.onBack})
      : con = ChatController(),
        super(key: key);
  final ChatController con;
  @override
  State createState() => NewMessageScreenState();
}

class NewMessageScreenState extends mvc.StateMVC<NewMessageScreen> {
  bool check1 = false;
  bool check2 = false;
  late ChatController con;
  var userInfo = UserManager.userInfo;
  var allUsersList = [];
  var searchUser = [];
  @override
  void initState() {
    add(widget.con);
    FirebaseFirestore.instance
        .collection(Helper.userField)
        .get()
        .then((value) => {allUsersList = value.docs});
    con = controller as ChatController;
    con.chattingUser = '';
    con.setState(() {});
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
          Stack(
            children: [TextField(
        onChanged: ((value) async {
          var list = [];
          if (value == '') {
            print('$value');
            searchUser = [];
            widget.onBack(false);
            setState(
              () {},
            );
            return;
          }
          widget.onBack(true);
          for (int i = 0; i < allUsersList.length; i++) {
            if (allUsersList[i]['userName'].contains(value)) {
              var flag = 0;

              if (con.chatUserList.isEmpty) {
                if (allUsersList[i]['userName'] != userInfo['userName']) {
                  list.add(allUsersList[i]);
                }
              } else {
                for (int j = 0; j < con.chatUserList.length; j++) {
                  if (allUsersList[i]['userName'] == con.chatUserList[j] ||
                      allUsersList[i]['userName'] == userInfo['userName']) {
                    flag = 1;
                  }
                  if (con.chatUserList.length - 1 == j && flag != 1) {
                    list.add(allUsersList[i]);
                    print(allUsersList[i]['userName']);
                  }
                }
              }
            }
          }
          searchUser = list;
          setState(() {});
        }),
        decoration: InputDecoration(
          hintText: 'To :',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
          // Enabled Border
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 0.1),
          ),
          // Focused Border
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 0.1),
          ),
          // Error Border
          contentPadding: EdgeInsets.only(left: 15, right: 15),
          // Focused Error Border
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 0.1),
          ),
        ),
      ),
      SizedBox(
          // height: SizeConfig(context).screenHeight,
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: searchUser.isNotEmpty ? userList() : Container()),
          ),
    ],
          )
      ]));
  }

  Widget userList() {
    return SingleChildScrollView(
        child: Container(
            child: Column(
      children: searchUser
          .map((e) => ListTile(
                contentPadding: EdgeInsets.all(10),
                enabled: true,
                tileColor: con.chattingUser == e['userName']
                    ? Color.fromRGBO(240, 240, 240, 1)
                    : Colors.white,
                hoverColor: Color.fromRGBO(240, 240, 240, 1),
                onTap: () {
                  con.avatar = e['avatar'];
                  widget.onBack('new');
                  con.chattingUser = e['userName'];
                  con.newRFirstName = e['firstName'];
                  con.newRLastName = e['lastName'];
                  con.setState(() {});
                  setState(
                    () {},
                  );
                },
                leading: e['avatar'] == ''
                    ? CircleAvatar(
                        radius: 25,
                        child: SvgPicture.network(Helper.avatar),
                      )
                    : CircleAvatar(
                        radius: 25, backgroundImage: NetworkImage(e['avatar'])),
                title: Text(e['userName']),
              ))
          .toList(),
    )));
  }
}