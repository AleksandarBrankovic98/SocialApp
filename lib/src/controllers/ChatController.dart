// ignore: file_names
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mvc_pattern/mvc_pattern.dart';
import '../../firebase_options.dart';
import '../helpers/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/user_manager.dart';
// ignore: library_prefixes
import 'package:path/path.dart' as PPath;
import 'dart:io' show File;

class ChatController extends ControllerMVC {
  factory ChatController([StateMVC? state]) =>
      _this ??= ChatController._(state);
  ChatController._(StateMVC? state)
      : progress = 0,
        super(state);
  static ChatController? _this;
  double progress;
  var chatBoxs = [];
  var chatUserList = [];
  var chattingUser = '';
  var isMessageTap = 'all-list';
  var docId = '';
  var newRFirstName = '';
  var newRLastName = '';
  var newMessage = [];
  var chatId = '';
  var avatar = '';
  var hidden = true;
  var onlineStatus = [];
  String chatUserFullName = '';
  var notifyCount = 0;
  bool sendData = false;
  List listUsers = [];
  var emojiList = <Widget>[];
  bool takedata = false;
  TextEditingController textController = TextEditingController();
  bool isShowEmoticon = false;
  @override
  Future<bool> initAsync() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  }

  @override
  bool onAsyncError(FlutterErrorDetails details) {
    return false;
  }

  Future<bool> sendMessage(newOrNot, messageType, data) async {
    var newChat = false;
    bool success = false;
    if (sendData) {
      return false;
    }
    sendData = true;
    if (chattingUser == '' || data == '') {
      success = false;
    }
    if (newOrNot == 'new') {
      await Helper.messageCollection.add({
        'users': [UserManager.userInfo['userName'], chattingUser],
        UserManager.userInfo['userName']: {
          'name':
              '${UserManager.userInfo['firstName']} ${UserManager.userInfo['lastName']}',
          'avatar': UserManager.userInfo['avatar'] ?? '',
        },
        chattingUser: {
          'name': '$newRFirstName $newRLastName',
          'avatar': avatar,
        },
        'lastData': data,
        '${UserManager.userInfo['firstName']} ${UserManager.userInfo['lastName']}':
            1,
        '$newRFirstName $newRLastName': 0
      }).then((value) async {
        docId = value.id;
        chatUserFullName = '$newRFirstName $newRLastName';
        success = true;
        setState(() {});
        await Helper.messageCollection.doc(value.id).collection('content').add({
          'type': messageType,
          'sender': UserManager.userInfo['userName'],
          'receiver': chattingUser,
          'data': data,
          'timeStamp': FieldValue.serverTimestamp(),
        });
      });
    } else {
      success = true;
      Helper.messageCollection.doc(docId).update({
        'lastData': data,
        '${UserManager.userInfo['firstName']} ${UserManager.userInfo['lastName']}':
            FieldValue.increment(1)
      });
      Helper.messageCollection.doc(docId).collection('content').add({
        'type': messageType,
        'sender': UserManager.userInfo['userName'],
        'receiver': chattingUser,
        'data': data,
        'timeStamp': FieldValue.serverTimestamp(),
      }).then((value) => {});
    }
    sendData = false;
    return success;
  }

  final chatCollection = Helper.messageCollection;
  getChatUsers() {
    var stream = chatCollection
        .where('users', arrayContains: UserManager.userInfo['userName'])
        .snapshots();
    return stream;
  }

  Future<XFile> chooseImage() async {
    final imagePicker = ImagePicker();
    XFile? pickedFile;
    if (kIsWeb) {
      pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );
    } else {
      //Check Permissions
      // await Permission.photos.request();
      // var permissionStatus = await Permission.photos.status;

      pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );
    }
    return pickedFile!;
  }

  uploadFile(XFile? pickedFile, newOrNot, messageType) async {
    final firebaseStorage = FirebaseStorage.instance;
    UploadTask uploadTask;
    Reference reference;
    try {
      if (kIsWeb) {
        Uint8List bytes = await pickedFile!.readAsBytes();
        reference = firebaseStorage
            .ref()
            .child('images/${PPath.basename(pickedFile.path)}');
        uploadTask = reference.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        var file = File(pickedFile!.path);
        //write a code for android or ios
        reference = firebaseStorage
            .ref()
            .child('images/${PPath.basename(pickedFile.path)}');
        uploadTask = reference.putFile(file);
      }
      uploadTask.whenComplete(() async {
        var downloadUrl = await reference.getDownloadURL();
        progress = 0;
        sendMessage(newOrNot, messageType, downloadUrl);
        //await _reference.getDownloadURL().then((value) {
        //  uploadedPhotoUrl = value;
        //});
      });
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            progress = 100.0 *
                (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            setState(() {});

            break;
          case TaskState.paused:
            break;
          case TaskState.canceled:
            break;
          case TaskState.error:
            break;
          case TaskState.success:
            break;
        }
      });
    } catch (e) {
      // print("Exception $e");
    }
  }

  uploadImage(newOrNot, messageType) async {
    XFile? pickedFile = await chooseImage();
    uploadFile(pickedFile, newOrNot, messageType);
  }

  Future<bool> connectFromMarketPlace(uid) async {
    var snapshot = await FirebaseFirestore.instance
        .collection(Helper.userField)
        .doc(uid)
        .get();
    var targetUserName = 'new';
    for (var chatUsers in listUsers) {
      for (var user in chatUsers.data()['users']) {
        if (user == snapshot['userName']) {
          targetUserName = 'old';
          avatar = chatUsers[user]['avatar'];
          isMessageTap = 'message-list';
          chattingUser = user;
          chatUserFullName = chatUsers[user]['name'];
          docId = chatUsers.id;
        }
      }
    }
    if (targetUserName == 'new') {
      avatar = snapshot['avatar'];
      isMessageTap = 'new';
      chattingUser = snapshot['userName'];
      newRFirstName = snapshot['firstName'];
      newRLastName = snapshot['lastName'];
      chatUserFullName = snapshot['firstName'] + ' ' + snapshot['lastName'];
    }
    setState(() {});
    return false;
  }
}
