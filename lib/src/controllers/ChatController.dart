// ignore: file_names
// ignore: deprecated_member_use
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../firebase_options.dart';
import '../helpers/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/user_manager.dart';
import '../models/chatModel.dart';
import 'package:path/path.dart' as PPath;
import 'dart:io' show File, Platform;

class ChatController extends ControllerMVC {
  factory ChatController([StateMVC? state]) =>
      _this ??= ChatController._(state);
  ChatController._(StateMVC? state) : 
    progress = 0,
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
  var chatId = '';
  var avatar = '';
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
    print(chattingUser);
    if (chattingUser == '' || data == '') {
      success = false;
    }
    if (newOrNot == 'new') {
      await FirebaseFirestore.instance.collection(Helper.message).add({
        'users': [UserManager.userInfo['userName'], chattingUser],
        UserManager.userInfo['userName']: {
          'name':
              '${UserManager.userInfo['firstName']} ${UserManager.userInfo['lastName']}',
          'avatar': UserManager.userInfo['avatar'] ?? ''
        },
        chattingUser: {
          'name': '$newRFirstName $newRLastName',
          'avatar': avatar
        },
        'lastData': data
      }).then((value) async {
        docId = value.id;
        success = true;
        setState(() {});
        await FirebaseFirestore.instance
            .collection(Helper.message)
            .doc(value.id)
            .collection('content')
            .add({
          'type': messageType,
          'sender': UserManager.userInfo['userName'],
          'receiver': chattingUser,
          'data': data,
          'timeStamp': FieldValue.serverTimestamp()
        });
      });
    } else {
      success = true;
      FirebaseFirestore.instance
          .collection(Helper.message)
          .doc(docId)
          .update({'lastData': data});
      FirebaseFirestore.instance
          .collection(Helper.message)
          .doc(docId)
          .collection('content')
          .add({
        'type': messageType,
        'sender': UserManager.userInfo['userName'],
        'receiver': chattingUser,
        'data': data,
        'timeStamp': FieldValue.serverTimestamp(),
      }).then((value) => {});
    }
    return success;
  }

  final chatCollection = FirebaseFirestore.instance
      .collection(Helper.message)
      .withConverter<ChatModel>(
        fromFirestore: (snapshots, _) => ChatModel.fromJSON(snapshots.data()!),
        toFirestore: (value, _) => value.toMap(),
      );
  Stream<QuerySnapshot<ChatModel>> getChatUsers() {
    var stream = chatCollection
        .where('users', arrayContains: UserManager.userInfo['userName'])
        .snapshots();
    return stream;
  }
  static Future<XFile> chooseImage() async {
    final _imagePicker = ImagePicker();
    XFile? pickedFile;
    if (kIsWeb) {
      pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
    } else {
      //Check Permissions
      await Permission.photos.request();

      var permissionStatus = await Permission.photos.status;

      if (permissionStatus.isGranted) {
      } else {
        print('Permission not granted. Try Again with permission access');
      }
    }
    return pickedFile!;
  }

  uploadFile(XFile? pickedFile,newOrNot,messageType) async {
    final _firebaseStorage = FirebaseStorage.instance;
    if(kIsWeb){
        try{
          
          //print("read bytes");
          Uint8List bytes  = await pickedFile!.readAsBytes();
          //print(bytes);
          Reference _reference = await _firebaseStorage.ref()
            .child('chat-assets/${PPath.basename(pickedFile!.path)}');
          final uploadTask = _reference.putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          uploadTask.whenComplete(() async {
            var downloadUrl = await _reference.getDownloadURL();
            progress = 0;
            sendMessage(newOrNot, messageType, downloadUrl);
            //await _reference.getDownloadURL().then((value) {
            //  uploadedPhotoUrl = value;
            //});
          });
          uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
                      switch (taskSnapshot.state) {
                        case TaskState.running:
                          progress =
                              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
                              setState(() {});
                              print("Upload is $progress% complete.");

                          break;
                        case TaskState.paused:
                          print("Upload is paused.");
                          break;
                        case TaskState.canceled:

                          print("Upload was canceled");
                          break;
                        case TaskState.error:
                        // Handle unsuccessful uploads
                          break;
                        case TaskState.success:
                         print("Upload is completed");
                        // Handle successful uploads on complete
                        // ...
                        //  var downloadUrl = await _reference.getDownloadURL();
                          break;
                      }
                    });
        }catch(e)
        {
          // print("Exception $e");
        }
    }else{
      var file = File(pickedFile!.path);
      //write a code for android or ios
      Reference _reference = await _firebaseStorage.ref()
          .child('chat-assets/${PPath.basename(pickedFile!.path)}');
        _reference.putFile(
          file
        )
        .whenComplete(() async {
            print('value');
          var downloadUrl = await _reference.getDownloadURL();
          await _reference.getDownloadURL().then((value) {
            // userCon.userAvatar = value;
            // userCon.setState(() {});
            // print(value);
          });
        });
    }

  }

   uploadImage(newOrNot,messageType) async {
    XFile? pickedFile = await chooseImage();
    uploadFile(pickedFile,newOrNot,messageType);
  }
}
