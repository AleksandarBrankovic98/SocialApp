// ignore_for_file: unused_local_variable

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import '../helpers/helper.dart';
import '../managers/relysia_manager.dart';
import '../models/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/route_names.dart';

enum EmailType { emailVerify, googleVerify }

class UserController extends ControllerMVC {
  factory UserController([StateMVC? state]) =>
      _this ??= UserController._(state);
  UserController._(StateMVC? state)
      : isSettingAction = false,
        isProfileChange = false,
        super(state);
  static UserController? _this;
  String token = '';
  String email = '';
  String relysiaEmail = '';
  String relysiaPassword = '';
  String password = '';
  String paymail = '';
  String walletAddress = '';
  int balance = 0;
  bool isSendRegisterInfo = false;
  bool isProfileChange;
  bool isSettingAction;
  bool isSendLoginedInfo = false;
  bool isStarted = false;
  bool isVerify = false;
  bool isSendResetPassword = false;
  bool isLogined = false;
  String failLogin = '';
  String failRegister = '';
  String userAvatar = '';
  var resData = {};
  Map<dynamic, dynamic> userInfo = {};
  // ignore: prefer_typing_uninitialized_variables
  var responseData;
  var context;
  var signUpUserInfo = {};
  @override
  Future<bool> initAsync() async {
    //
    Helper.authdata = FirebaseFirestore.instance
        .collection(Helper.userField)
        .withConverter<TokenLogin>(
          fromFirestore: (snapshots, _) =>
              TokenLogin.fromJSON(snapshots.data()!),
          toFirestore: (tokenlogin, _) => tokenlogin.toMap(),
        );
    return true;
  }

  String createRandNumber() {
    var rng = Random();
    int randomNumber = rng.nextInt(100);
    return randomNumber.toString();
  }

  String createRandEmail() {
    String code = ""; // Timestamp.now.toString();
    for (int i = 0; i < 13; i++) {
      code = code + createRandNumber();
    }
    return "relysia$code@shnatter.com";
  }

  void validate(cont, info) async {
    print("------1--------");
    isSendRegisterInfo = true;
    setState(() {});
    var fill = true;
    var validation = [
      'userName',
      'firstName',
      'lastName',
      'email',
      'password',
    ];
    for (var i = 0; i < validation.length; i++) {
      if (info[validation[i]] == null) {
        fill = false;
        break;
      }
    }
    print("------2--------");
    if (!fill) {
      failRegister = 'You must fill all field';
      isSendRegisterInfo = false;
      setState(() {});
      return;
    }
    print("------3--------");
    context = cont;
    signUpUserInfo = info;
    email = signUpUserInfo['email'];
    password = signUpUserInfo['password'];
    var check = email.contains('@'); //return true if contains
    if (!check) {
      failRegister = 'Invalid Email';
      isSendRegisterInfo = false;
      setState(() {});
      return;
    }
    if (password.length < Helper.passwordMinLength) {
      failRegister = 'Password length should be 8 over';
      isSendRegisterInfo = false;
      setState(() {});
      return;
    }
    print("------4--------");
    QuerySnapshot<TokenLogin> querySnapshot =
        await Helper.authdata.where('email', isEqualTo: email).get();
    QuerySnapshot<TokenLogin> querySnapshot1 = await Helper.authdata
        .where('userName', isEqualTo: signUpUserInfo['userName'])
        .get();
    if (querySnapshot.size > 0) {
      failRegister =
          'Sorry, it looks like $email belongs to an existing account';
      isSendRegisterInfo = false;
      setState(() {});
      return;
    }
    if (querySnapshot1.size > 0) {
      failRegister =
          'Sorry, it looks like ${signUpUserInfo['userName']} belongs to an existing account';
      isSendRegisterInfo = false;
      setState(() {});
      return;
    }
    print("------5--------");
    createRelysiaAccount();
  }

  String createActivationCode() {
    String code = ""; // Timestamp.now.toString();
    for (int i = 0; i < 13; i++) {
      code = code + createRandNumber();
    }
    return code;
  }

  String createPassword() {
    String password = "";
    for (int i = 0; i < 6; i++) {
      password = password + createRandNumber();
    }
    return password;
  }

  Future<void> registerUserInfo() async {
    var uuid = await sendEmailVeryfication();
    signUpUserInfo.removeWhere((key, value) => key == 'password');
    await FirebaseFirestore.instance
        .collection(Helper.userField)
        .doc(uuid)
        .set({
      ...signUpUserInfo,
      'paymail': paymail,
      'avatar': '',
      'walletAddress': walletAddress,
      // 'relysiaEmail': relysiaEmail,
      // 'relysiaPassword': relysiaPassword,
      'paywall': {},
      'isStarted': false,
    });
    await Helper.saveJSONPreference(Helper.userField, {
      ...signUpUserInfo,
      'paywall': {},
      'paymail': paymail,
      'fullName':
          '${signUpUserInfo['firstName']} ${signUpUserInfo['lastName']}',
      'walletAddress': walletAddress,
      // 'relysiaEmail': relysiaEmail,
      // 'relysiaPassword': relysiaPassword,
      'password': password,
      'isStarted': 'false',
      'isVerify': 'false',
      'isRememberme': 'false',
      'avatar': '',
      'uid': uuid,
      'expirationPeriod': DateTime.now().toString()
    });
  }

  Future<int> getBalance() async {
    if (token == '') {
      var relysiaAuth = await RelysiaManager.authUser(
          UserManager.userInfo['email'], UserManager.userInfo['password']);
      token = relysiaAuth['data']['token'];
    }
    await RelysiaManager.getBalance(token).then((res) => {
          print('balance is $res'),
          balance = res,
          Helper.balance = balance,
          setState(() {})
        });
    return balance;
  }

  void getWalletFromPref(context) async {}

  Future<void> resetPassword({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      isSendResetPassword = true;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void loginWithEmail(context, em, pass, isRememberme) async {
    if (em == '' || pass == '') {
      failLogin = 'You must fill all field';
      setState(() {});
      return;
    }
    email = em;
    password = pass;
    try {
      isSendLoginedInfo = true;
      if (!email.contains('@')) {
        QuerySnapshot<TokenLogin> checkUsername =
            await Helper.authdata.where('userName', isEqualTo: email).get();
        if (checkUsername.size > 0) {
          TokenLogin getInfo = checkUsername.docs[0].data();
          email = getInfo.email;
        } else {
          failLogin = 'The username you entered does not belong to any account';
        }
      }
      setState(() {});
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      var uid = userCredential.user!.uid;
      failLogin = '';
      setState(() {});
      QuerySnapshot<TokenLogin> querySnapshot =
          await Helper.authdata.where('email', isEqualTo: email).get();
      if (querySnapshot.size > 0) {
        TokenLogin user = querySnapshot.docs[0].data();
        relysiaEmail = user.email;
        relysiaPassword = password;
        isStarted = user.isStarted;
        isVerify = userCredential.user!.emailVerified;
        var b = user.userInfo;
        var j = {};
        b.forEach((key, value) {
          j = {...j, key.toString(): value};
        });
        userInfo = {
          ...j,
          'fullName': '${j['firstName']} ${j['lastName']}',
          'password': password,
          'isVerify': isVerify.toString(),
          'isRememberme': isRememberme.toString(),
          'uid': querySnapshot.docs[0].id,
          'expirationPeriod': isRememberme ? '' : DateTime.now().toString()
        };
        print(user.password);
        await Helper.saveJSONPreference(Helper.userField, {...userInfo});
        UserManager.getUserInfo();
        RouteNames.userName = user.userName;
        loginRelysia(context);
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'invalid-email' || e.code == 'user-not-found') {
        failLogin = 'The email you entered does not belong to any account';
        setState(
          () {},
        );
      } else if (e.code == 'wrong-password') {
        failLogin = 'wrong-password';
        setState(() {});
      }
      isSendLoginedInfo = false;
      setState(() {});
    }
  }

  void loginRelysia(context) {
    print("try to login user in relysia....");
    RelysiaManager.authUser(relysiaEmail, relysiaPassword).then((res) async => {
          if (res['data'] != null)
            {
              if (res['statusCode'] == 200)
                {
                  token = res['data']['token'],
                  getBalance(),
                  RelysiaManager.getPaymail(token).then((response) async => {
                        setState(() {}),
                        if (response['paymail'] != null)
                          {
                            paymail = response['paymail'],
                            walletAddress = response['address'],
                            isSendLoginedInfo = false,
                            isLogined = true,
                            Helper.connectOnlineDatabase(),
                            Navigator.pushReplacementNamed(
                                context,
                                isStarted
                                    ? RouteNames.homePage
                                    : RouteNames.started),
                            setState(() {})
                          }
                      }),
                  setState(() {})
                }
              else
                {
                  resData = res['data'],
                  if (resData['msg'] == 'INVALID_EMAIL')
                    {
                      Helper.showToast('You didn\'t sign up in Relysia!'),
                    }
                  else if (resData['msg'] == 'EMAIL_NOT_FOUND')
                    {
                      Helper.showToast('Email Not Found!'),
                    }
                  else
                    {
                      Helper.showToast(resData['msg']),
                    },
                  isSendLoginedInfo = true,
                  setState(() {})
                }
            }
          else
            {isSendLoginedInfo = true, setState(() {})}
        });
  }

  Future<String> sendEmailVeryfication() async {
    setState(() {});
    var uuid = '';
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      uuid = userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        uuid = userCredential.user!.uid;
      } else {}
    } catch (e) {
      rethrow;
    }

    ActionCodeSettings acs = ActionCodeSettings(
        url:
            "https://us-central1-shnatter-a69cd.cloudfunctions.net/emailVerification",
        handleCodeInApp: true);
    await FirebaseAuth.instance.currentUser?.sendEmailVerification(acs);
    return uuid;
  }

  void createRelysiaAccount() async {
    relysiaEmail = signUpUserInfo['email'];
    relysiaPassword = signUpUserInfo['password'];
    print(1);
    responseData =
        await RelysiaManager.createUser(relysiaEmail, relysiaPassword);
    if (responseData['data'] != null) {
      if (responseData['statusCode'] == 200) {
        createEmail();
      } else {
        createRelysiaAccount();
      }
    } else {
      createRelysiaAccount();
    }
  }

  void createEmail() async {
    token = responseData['data']['token'];
    RelysiaManager.createWallet(token).then((rr) => {
          if (rr == 0)
            {
              Helper.showToast("error occurs while create wallet"),
              isSendRegisterInfo = false,
              setState(() {}),
            }
          else
            {
              print('relysiaPassword$relysiaPassword'),
              RelysiaManager.authUser(relysiaEmail, relysiaPassword)
                  .then((responseData) => {
                        if (responseData['data'] != null)
                          {
                            if (responseData['statusCode'] == 200)
                              {
                                token = responseData['data']['token'],
                                RelysiaManager.getPaymail(token)
                                    .then((response) async => {
                                          if (response['paymail'] != null)
                                            {
                                              paymail = response['paymail'],
                                              walletAddress =
                                                  response['address'],
                                              await registerUserInfo(),
                                              await UserManager.getUserInfo(),
                                              RouteNames.userName =
                                                  signUpUserInfo['userName'],
                                              isSendRegisterInfo = false,
                                              isLogined = true,
                                              Navigator.pushReplacementNamed(
                                                  context, RouteNames.started),
                                              setState(() {}),
                                            }
                                        })
                              }
                            else
                              {
                                resData = responseData['data'],
                                if (resData['msg'] == 'INVALID_EMAIL')
                                  {
                                    Helper.showToast(
                                        'You didn\'t sign up in Relysia!'),
                                  }
                                else if (resData['msg'] == 'EMAIL_NOT_FOUND')
                                  {
                                    Helper.showToast('Email Not Found!'),
                                  }
                                else
                                  {
                                    Helper.showToast(resData['msg']),
                                    setState(() {})
                                  },
                                isSendRegisterInfo = false,
                                setState(() {}),
                              }
                          }
                        else
                          {
                            isSendRegisterInfo = false,
                            setState(() {}),
                          },
                      })
            },
        });
  }

  Future<void> resetGetUserInfo() async {
    var info;
    FirebaseFirestore.instance
        .collection(Helper.userField)
        .doc(UserManager.userInfo['uid'])
        .get()
        .then((value) async => {
              userInfo = await Helper.getJSONPreference(Helper.userField),
              info = UserManager.userInfo.toString(),
              await Helper.saveJSONPreference(Helper.userField,
                  {...userInfo, 'avatar': value.data()!['avatar']}),
              await Helper.getJSONPreference(Helper.userField)
            });
  }

  //change user avatar
  Future<void> changeAvatar() async {
    await FirebaseFirestore.instance
        .collection(Helper.userField)
        .doc(UserManager.userInfo['uid'])
        .update({'avatar': userAvatar});
    FirebaseFirestore.instance
        .collection(Helper.message)
        .where('users', arrayContains: UserManager.userInfo['userName'])
        .get()
        .then((value) async {
      for (int i = 0; i < value.docs.length; i++) {
        await FirebaseFirestore.instance
            .collection(Helper.message)
            .doc(value.docs[i].id)
            .update({
          UserManager.userInfo['userName']: {
            'avatar': userAvatar,
            'name':
                "${UserManager.userInfo['firstName']} ${UserManager.userInfo['lastName']}"
          }
        });
      }
    });
    resetGetUserInfo();
  }

  //in started page, save profile function, (all save profile)
  Future<void> saveProfile(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection(Helper.userField)
        .doc(UserManager.userInfo['uid'])
        .update({
      ...data,
      'isStarted': true,
    });
    resetGetUserInfo();
  }

  //get all interests from firebase
  Future<List> getAllInterests() async {
    QuerySnapshot querySnapshot =
        await Helper.allInterests.orderBy('title').get();
    var doc = querySnapshot.docs;
    return doc;
  }

  saveAccountSettings(email, userName, password) async {
    var userManager = UserManager.userInfo;
    var uuid = '';
    isSettingAction = true;
    setState(() {});
    if (!email.contains('@')) {
      return;
    }
    if (password.length < Helper.passwordMinLength) {
      return;
    }
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userManager['email'], password: userManager['password']);
    await FirebaseAuth.instance.currentUser?.delete();
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      uuid = userCredential.user!.uid;
      var snapshot = await FirebaseFirestore.instance
          .collection(Helper.userField)
          .doc(UserManager.userInfo['uid'])
          .get();
      await FirebaseFirestore.instance
          .collection(Helper.userField)
          .doc(UserManager.userInfo['uid'])
          .delete();
      var user = {};
      snapshot.data()!.forEach((key, value) {
        user = {
          ...user,
          key: key == 'email'
              ? email
              : key == 'password'
                  ? password
                  : key == 'userName'
                      ? userName
                      : value
        };
      });
      await FirebaseFirestore.instance
          .collection(Helper.userField)
          .doc(uuid)
          .set({
        ...user,
      });
      var j = {};
      user.forEach((key, value) {
        j = {...j, key.toString(): value.toString()};
      });
      await Helper.saveJSONPreference(Helper.userField, {...j, 'uid': uuid});
      UserManager.getUserInfo();
      isSettingAction = false;
      setState(() {});
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        uuid = userCredential.user!.uid;
      } else {}
      isSettingAction = false;
      setState(() {});
    } catch (e) {
      rethrow;
    }
  }

  changePassword(email, password) async {
    var userManager = UserManager.userInfo;
    var uuid = '';
    isSettingAction = true;
    setState(() {});
    if (password.length < Helper.passwordMinLength) {
      print(0);
      isSettingAction = false;
      setState(() {});
      return;
    }
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userManager['email'], password: userManager['password']);
    await FirebaseAuth.instance.currentUser?.delete();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      uuid = userCredential.user!.uid;
      var snapshot = await FirebaseFirestore.instance
          .collection(Helper.userField)
          .where('email', isEqualTo: email)
          .get();
      await FirebaseFirestore.instance
          .collection(Helper.userField)
          .doc(snapshot.docs[0].id)
          .delete();
      var user = {};
      snapshot.docs[0].data().forEach((key, value) {
        user = {...user, key: key == 'password' ? password : value};
      });
      await FirebaseFirestore.instance
          .collection(Helper.userField)
          .doc(uuid)
          .set({
        ...user,
      });
      var j = {};
      user.forEach((key, value) {
        j = {...j, key.toString(): value.toString()};
      });
      await Helper.saveJSONPreference(Helper.userField, {...j, 'uid': uuid});
      UserManager.getUserInfo();
      isSettingAction = false;
      setState(() {});
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('email already in use');
      } else {}
      isSettingAction = false;
      setState(() {});
    } catch (e) {
      rethrow;
    }
  }

  profileChange(profile) async {
    if (profile.isNotEmpty) {
      isProfileChange = true;
      setState(() {});
      var userManager = UserManager.userInfo;
      var snapshot = await FirebaseFirestore.instance
          .collection(Helper.userField)
          .where('userName', isEqualTo: userManager['userName'])
          .get();
      await FirebaseFirestore.instance
          .collection(Helper.userField)
          .doc(snapshot.docs[0].id)
          .update({...profile});
      profile.forEach((key, value) {
        userManager[key] = value;
      });
      var j = {};
      userManager.forEach((key, value) {
        j = {...j, key.toString(): value};
      });
      await Helper.saveJSONPreference(Helper.userField, {...j});
      await UserManager.getUserInfo();
      isProfileChange = false;
      setState(() {});
    }
  }

  deleteUserAccount() async {
    isProfileChange = true;
    setState(() {});
    var userManager = UserManager.userInfo;
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userManager['email'], password: userManager['password']);
    await FirebaseAuth.instance.currentUser?.delete();
    var snapshot = await FirebaseFirestore.instance
        .collection(Helper.userField)
        .where('userName', isEqualTo: userManager['userName'])
        .get();
    await FirebaseFirestore.instance
        .collection(Helper.userField)
        .doc(snapshot.docs[0].id)
        .delete();
    isProfileChange = false;
    setState(() {});
  }

  pinPost() async {
    var pinData = UserManager.userInfo['pinnedPost'];
    pinData = pinData
        .where((eachPage) => eachPage['pageName'] == eachPage['pageName']);
    await FirebaseFirestore.instance
        .collection(Helper.userField)
        .doc(UserManager.userInfo['uid'])
        .update({
      'pinnedPost': [
        ...UserManager.userInfo['uid'],
      ]
    });
  }

  //for Paywall
  Future<bool> payShnToken(String payMail, String amount, String notes) async {
    bool payResult = false;
    if (token == '') {
      var relysiaAuth = await RelysiaManager.authUser(
          UserManager.userInfo['email'], UserManager.userInfo['password']);
      token = relysiaAuth['data']['token'];
    }
    await RelysiaManager.payNow(token, payMail, amount, notes).then(
      (value) => {
        print(value),
        Helper.showToast(value),
        if (value == 'Successfully paid')
          {
            payResult = true,
          }
      },
    );
    return payResult;
  }
}
