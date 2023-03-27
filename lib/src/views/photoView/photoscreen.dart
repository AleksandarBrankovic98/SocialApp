import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/controllers/PostController.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import 'package:shnatter/src/utils/size_config.dart';
import 'package:shnatter/src/widget/postCell.dart';

class PhotoEachScreen extends StatefulWidget {
  PhotoEachScreen({Key? key, required this.docId, required this.routerChange})
      : con = PostController(),
        super(key: key);
  final PostController con;
  String docId;
  Function routerChange;

  @override
  State createState() => PhotoEachScreenState();
}

class PhotoEachScreenState extends mvc.StateMVC<PhotoEachScreen>
    with SingleTickerProviderStateMixin {
  bool loading = true;
  late PostController con;
  var userInfo = UserManager.userInfo;
  @override
  void initState() {
    add(widget.con);
    con = controller as PostController;
    super.initState();
    print(widget.docId);
    //  getSelectedPhoto(widget.docId);
  }

  void getSelectedPhoto(String docId) {
    con.getSelectedPost(docId).then((value) => {
          loading = false,
          setState(() {}),
          print('You get selected post info!'),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig(context).screenWidth < SizeConfig.mediumScreenSize
          ? SizeConfig(context).screenWidth
          : SizeConfig(context).screenWidth - 220,
      height: SizeConfig(context).screenHeight - 100,
      child: Image.network(
        widget.docId,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
