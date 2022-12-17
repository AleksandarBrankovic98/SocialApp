// ignore_for_file: unused_local_variable

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shnatter/src/managers/user_manager.dart';
import '../helpers/helper.dart';
import '../managers/relysia_manager.dart';
import '../models/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/route_names.dart';
import 'package:time_elapsed/time_elapsed.dart';

class PostController extends ControllerMVC {
  factory PostController([StateMVC? state]) =>
      _this ??= PostController._(state);
  PostController._(StateMVC? state)
      : eventSubRoute = '',
        pageSubRoute = '',
        groupSubRoute = '',
        super(state);
  static PostController? _this;

  @override
  Future<bool> initAsync() async {
    //
    Helper.eventsData =
        FirebaseFirestore.instance.collection(Helper.eventsField);
    return true;
  }

  Future<bool> uploadPicture(String where, String what, String url) async {
    switch (where) {
      case 'group':
        print(what);
        FirebaseFirestore.instance
            .collection(Helper.groupsField)
            .doc(viewGroupId)
            .update({'groupPicture': url}).then((e) async {
          group[what] = url;
          setState(() {});
        });
        break;

      default:
    }
    return true;
  }

  /////////////////////////////all support ////////////////////////////////////
  //bool of my friends
  Future<bool> boolMyFriend(String userName) async {
    if (UserManager.userInfo['friends'] != null) {
      var friends = UserManager.userInfo['friends'].where(
          (eachUser) => eachUser['userName'] == userName && eachUser['status']);
      if (friends.length > 0) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  //bool of friends of my friends
  Future<bool> boolFriendMyFriend(String userId) async {
    if (UserManager.userInfo['friends'] != null) {
      var myFriends = UserManager.userInfo['friends'];
      var hisFriends = [];
      await Helper.authdata.doc(userId).get().then((value) async {
        hisFriends = value['friends'];
      });
      for (var i = 0; i < myFriends.length; i++) {
        for (var j = 0; j < hisFriends.length; j++) {
          if (myFriends[i]['userName'] == hisFriends[j]['userName'] &&
              myFriends[i]['status'] &&
              hisFriends[j]['status']) {
            return true;
          }
        }
      }
      return false;
    } else {
      return false;
    }
  }

  /////////////////////////////////////////////////////////////////////////////////

  //////////////////////////// start event functions ///////////////////////////////////

  //variable
  List events = [];

  //view each event support data
  var event;
  var viewEventId = '';
  var viewEventInterested = false;
  var viewEventGoing = false;
  var viewEventInvited = false;

  //sub router
  String eventTab = 'Timeline';

  //sub route
  String eventSubRoute;

  //get all event function
  Future<List> getEvent(String condition) async {
    List<Map> realAllEvents = [];
    await Helper.eventsData.get().then((value) async {
      var doc = value.docs;
      for (int i = 0; i < doc.length; i++) {
        var id = doc[i].id;
        var interested = await boolInterested(id);
        var data = doc[i];
        //closed event
        if (data['eventPrivacy'] == 'closed') {
          if (data['eventAdmin']['userName'] ==
                  UserManager.userInfo['userName'] &&
              condition == 'manage') {
            realAllEvents
                .add({'data': data, 'id': id, 'interested': interested});
          }
        }
        //security event
        else /*if (data['eventPrivacy'] == 'security') */ {
          var inInterested = await boolInterested(id);
          var inInvited = await boolInvited(id);
          var inGoing = await boolGoing(id);
          if (inInterested && condition == 'interested') {
            realAllEvents
                .add({'data': data, 'id': id, 'interested': interested});
          } else if (inInvited && condition == 'invited') {
            realAllEvents
                .add({'data': data, 'id': id, 'interested': interested});
          } else if (inGoing && condition == 'going') {
            realAllEvents
                .add({'data': data, 'id': id, 'interested': interested});
          } else if (UserManager.userInfo['userName'] ==
                  data['eventAdmin']['userName'] &&
              condition == 'manage') {
            realAllEvents
                .add({'data': data, 'id': id, 'interested': interested});
          } else if (condition == 'all') {
            if (data['eventPrivacy'] == 'public') {
              realAllEvents
                  .add({'data': data, 'id': id, 'interested': interested});
            }
          }
          setState(() {});
        }
      }
      print('Now you get all events');
    });

    return realAllEvents;
  }

  //get one event function that using uid of firebase database
  Future<bool> getSelectedEvent(String id) async {
    id = id.split('/')[id.split('/').length - 1];
    viewEventId = id;
    await Helper.eventsData.doc(id).get().then((value) async {
      event = value;
      viewEventInterested = await boolInterested(id);
      viewEventGoing = await boolGoing(id);
      viewEventInvited = await boolInvited(id);
      setState(() {});
      print('This event was posted by ${event['eventAdmin']}');
    });
    return true;
  }

  //create event function
  Future<void> createEvent(context, Map<String, dynamic> eventData) async {
    eventData = {
      ...eventData,
      'eventAdmin': UserManager.userInfo['userName'],
      'eventDate': DateTime.now().toString(),
      'eventGoing': [],
      'eventInterested': [],
      'eventInterests': 0,
      'eventInvited': [],
      'eventPost': false,
      'eventPicture': '',
      'eventCanPub': true,
      'eventApproval': true
    };
    await FirebaseFirestore.instance
        .collection(Helper.eventsField)
        .add(eventData);

    Navigator.pushReplacementNamed(context, RouteNames.settings);
  }

  //get all interests from firebase
  Future<List> getAllInterests() async {
    QuerySnapshot querySnapshot =
        await Helper.allInterests.orderBy('title').get();
    var doc = querySnapshot.docs;
    print('Now you get all interests value to const');
    return doc;
  }

  ////////////////////functions that support for making comment to event/////////////////////////////

  //user join in event interested function
  Future<bool> interestedEvent(String eventId) async {
    print('now you are interested or uninterested this event ${eventId}');
    var querySnapshot = await Helper.eventsData.doc(eventId).get();
    var doc = querySnapshot;
    var interested = doc['eventInterested'];
    var respon = await boolInterested(eventId);
    if (respon) {
      interested.removeWhere(
          (item) => item['userName'] == UserManager.userInfo['userName']);
      await FirebaseFirestore.instance
          .collection(Helper.eventsField)
          .doc(eventId)
          .update({'eventInterested': interested});
      return true;
    } else {
      interested.add({
        'userName': UserManager.userInfo['userName'],
        'fullName':
            '${UserManager.userInfo['firstName']} ${UserManager.userInfo['lastName']}',
        'userAvatar': UserManager.userInfo['avatar']
      });
      await FirebaseFirestore.instance
          .collection(Helper.eventsField)
          .doc(eventId)
          .update({'eventInterested': interested});
      return true;
    }
  }

  //bool of user already in event interested or not
  Future<bool> boolInterested(String eventId) async {
    var querySnapshot = await Helper.eventsData.doc(eventId).get();
    var doc = querySnapshot;
    var interested = doc['eventInterested'];
    if (interested == null) {
      return false;
    }
    var returnData = interested.where(
        (eachUser) => eachUser['userName'] == UserManager.userInfo['userName']);
    print('you get bool of interested event');
    if (returnData.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  //user join in event going function
  Future<bool> goingEvent(String eventId) async {
    print('now you are going or ungoing this event ${eventId}');
    var querySnapshot = await Helper.eventsData.doc(eventId).get();
    var doc = querySnapshot;
    var going = doc['eventGoing'];
    var respon = await boolGoing(eventId);
    if (respon) {
      going.removeWhere(
          (item) => item['userName'] == UserManager.userInfo['userName']);
      await FirebaseFirestore.instance
          .collection(Helper.eventsField)
          .doc(eventId)
          .update({'eventGoing': going});
      return true;
    } else {
      going.add({
        'userName': UserManager.userInfo['userName'],
        'fullName':
            '${UserManager.userInfo['firstName']} ${UserManager.userInfo['lastName']}',
        'userAvatar': UserManager.userInfo['avatar']
      });
      await FirebaseFirestore.instance
          .collection(Helper.eventsField)
          .doc(eventId)
          .update({'eventGoing': going});
      return true;
    }
  }

  //bool of user already in event going or not
  Future<bool> boolGoing(String eventId) async {
    var querySnapshot = await Helper.eventsData.doc(eventId).get();
    var doc = querySnapshot;
    var going = doc['eventGoing'];
    if (going == null) {
      return false;
    }
    var returnData = going.where(
        (eachUser) => eachUser['userName'] == UserManager.userInfo['userName']);
    print('you get bool of going event');
    if (returnData.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  //user  join in event invited function
  Future<bool> invitedEvent(String eventId) async {
    print('now you are invited or uninvited this event ${eventId}');
    var querySnapshot = await Helper.eventsData.doc(eventId).get();
    var doc = querySnapshot;
    var invited = doc['eventInvited'];
    var respon = await boolInvited(eventId);
    if (respon) {
      invited.removeWhere(
          (item) => item['userName'] == UserManager.userInfo['userName']);
      await FirebaseFirestore.instance
          .collection(Helper.eventsField)
          .doc(eventId)
          .update({'eventInvited': invited});
      return true;
    } else {
      invited.add({
        'userName': UserManager.userInfo['userName'],
        'fullName':
            '${UserManager.userInfo['firstName']} ${UserManager.userInfo['lastName']}',
        'userAvatar': UserManager.userInfo['avatar']
      });
      await FirebaseFirestore.instance
          .collection(Helper.eventsField)
          .doc(eventId)
          .update({'eventInvited': invited});
      return true;
    }
  }

  //bool of user already in event invited or not
  Future<bool> boolInvited(String eventId) async {
    var querySnapshot = await Helper.eventsData.doc(eventId).get();
    var doc = querySnapshot;
    var invited = doc['eventInvited'];
    if (invited == null) {
      return false;
    }
    var returnData = invited.where(
        (eachUser) => eachUser['userName'] == UserManager.userInfo['userName']);
    print('you get bool of invited event');
    if (returnData.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> updateEventInfo(dynamic pageInfo) async {
    var result = await Helper.pagesData.doc(viewPageId).update(pageInfo);
    return true;
  }

  Future<bool> deleteEvent() async {
    await FirebaseFirestore.instance
        .collection(Helper.eventsField)
        .doc(viewEventId)
        .delete();
    return true;
  }

  ////////////////////functions that make comment to event/////////////////////////////

  ///////////////////////////end events functions //////////////////////////////////////////////////

  //////////////////////////// start page functions ///////////////////////////////////

  //variable
  List pages = [];

  //view each page support data
  var page;
  var viewPageId = '';
  var viewPageName = '';
  var viewPageLiked = false;

  //sub router
  String pageTab = 'Timeline';

  //sub route
  String pageSubRoute;

  //get all page function
  Future<List> getPage(String condition) async {
    List<Map> realAllpage = [];
    await Helper.pagesData.get().then((value) async {
      var doc = value.docs;
      for (int i = 0; i < doc.length; i++) {
        var id = doc[i].id;
        var liked = await boolLiked(id);
        var data = doc[i];
        if (UserManager.userInfo['userName'] ==
                data['pageAdmin'][0]['userName'] &&
            condition == 'manage') {
          realAllpage.add({'data': data, 'id': id, 'liked': liked});
        } else if (condition == 'all') {
          if (data['pagePost']) {
            realAllpage.add({'data': data, 'id': id, 'liked': liked});
          }
        } else if (condition == 'liked' && liked) {
          realAllpage.add({'data': data, 'id': id, 'liked': liked});
        }
        setState(() {});
      }
      print('Now you get all pages');
    });

    return realAllpage;
  }

  //get one page function that using uid of firebase database
  Future<bool> getSelectedPage(String name) async {
    name = name.split('/')[name.split('/').length - 1];
    viewPageName = name;
    var reuturnValue = await Helper.pagesData
        .where('pageUserName', isEqualTo: viewPageName)
        .get();
    var value = reuturnValue.docs;
    page = value[0];
    viewPageId = page.id;
    viewPageLiked = await boolLiked(viewPageId);
    setState(() {});
    print('This page was posted by ${page['pageAdmin'][0]}');
    return true;
  }

  //create page function
  Future<String> createPage(context, Map<String, dynamic> pageData) async {
    if (pageData['pageName'] == null) {
      return 'Please add your page name';
    } else if (pageData['pageUserName'] == null) {
      return 'Please add your page user name';
    } else if (pageData['pageLocation'] == null) {
      return 'Please add your page location';
    }
    pageData = {
      ...pageData,
      'pageAdmin': [
        {'userName': UserManager.userInfo['userName']}
      ],
      'pageDate': DateTime.now().toString(),
      'pageLiked': [],
      'pagePost': false,
      'pagePicture': '',
      'pagePhotos': [],
      'pageAlbums': [],
      'pageVideos': [],
    };

    var reuturnValue = await Helper.pagesData
        .where('pageUserName', isEqualTo: pageData['pageUserName'])
        .get();
    var value = reuturnValue.docs;
    if (value.isEmpty) {
      return 'doubleName';
    }
    await FirebaseFirestore.instance
        .collection(Helper.pagesField)
        .add(pageData);

    Navigator.pushReplacementNamed(
        context, '${RouteNames.pages}/${pageData['pageUserName']}');
    return 'success';
  }

  ////////////////////functions that support for making comment to page/////////////////////////////

  //user join in page liked function
  Future<bool> likedPage(String pageId) async {
    print('now you are liked or unliked this page ${pageId}');
    var querySnapshot = await Helper.pagesData.doc(pageId).get();
    var doc = querySnapshot;
    var liked = doc['pageLiked'];
    var respon = await boolLiked(pageId);
    if (respon) {
      liked.removeWhere(
          (item) => item['userName'] == UserManager.userInfo['userName']);
      await FirebaseFirestore.instance
          .collection(Helper.pagesField)
          .doc(pageId)
          .update({'pageLiked': liked});
      return true;
    } else {
      liked.add({
        'userName': UserManager.userInfo['userName'],
        'fullName':
            '${UserManager.userInfo['firstName']} ${UserManager.userInfo['lastName']}',
        'userAvatar': UserManager.userInfo['avatar']
      });
      await FirebaseFirestore.instance
          .collection(Helper.pagesField)
          .doc(pageId)
          .update({'pageLiked': liked});
      return true;
    }
  }

  //bool of user already in page interested or not
  Future<bool> boolLiked(String pageId) async {
    var querySnapshot = await Helper.pagesData.doc(pageId).get();
    var doc = querySnapshot;
    var liked = doc['pageLiked'];
    if (liked == null) {
      return false;
    }
    var returnData = liked.where(
        (eachUser) => eachUser['userName'] == UserManager.userInfo['userName']);
    print('you get bool of liked page');
    if (returnData.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  Future<String> updatePageInfo(dynamic pageInfo) async {
    if (pageInfo['pageName'] == page['pageName']) {
      var result = await Helper.pagesData.doc(viewPageId).update(pageInfo);
      return 'success';
    } else {
      QuerySnapshot querySnapshot = await Helper.pagesData.get();
      var allPage = querySnapshot.docs;
      allPage.where((eachPage) => eachPage['pageName'] == pageInfo['pageName']);
      if (allPage.isNotEmpty) {
        return 'dobuleName';
      } else {
        var result = await Helper.pagesData.doc(viewPageId).update(pageInfo);
        return 'success';
      }
    }
  }

  Future<bool> deletePage() async {
    await FirebaseFirestore.instance
        .collection(Helper.pagesField)
        .doc(viewPageId)
        .delete();
    return true;
  }

  Future<String> removeMember(String userName) async {
    page['pageLiked'].removeWhere((item) => item['userName'] == userName);
    await FirebaseFirestore.instance
        .collection(Helper.pagesField)
        .doc(viewPageId)
        .update({
      'pageLiked': page['pageLiked'],
    });
    return 'success';
  }

  Future<String> removeAdmin(String userName) async {
    if (page['pageAdmin'][0]['userName'] == userName) {
      return 'superAdmin';
    }
    page['pageAdmin'].removeWhere((item) => item['userName'] == userName);
    await FirebaseFirestore.instance
        .collection(Helper.pagesField)
        .doc(viewPageId)
        .update({
      'pageLiked': page['pageLiked'],
    });
    return 'success';
  }

  ////////////////////functions that make comment to page/////////////////////////////

  ///////////////////////////end pages functions //////////////////////////////////////////////////

  //////////////////////////// start groups functions ///////////////////////////////////

  //variable
  List groups = [];

  //view each group support data
  var group;
  var viewGroupId = '';
  var viewGroupName = '';
  var viewGroupJoined = false;

  //sub router
  String groupTab = 'Timeline';

  //sub route
  String groupSubRoute;

  //get all group function
  Future<List> getGroup(String condition) async {
    List<Map> realAllGroups = [];
    await Helper.groupsData.get().then((value) async {
      var doc = value.docs;
      for (int i = 0; i < doc.length; i++) {
        var id = doc[i].id;
        var joined = await boolJoined(id);
        var data = doc[i];
        if (UserManager.userInfo['userName'] ==
                data['groupAdmin'][0]['userName'] &&
            condition == 'manage') {
          realAllGroups.add({'data': data, 'id': id, 'joined': joined});
        } else if (condition == 'all') {
          if (data['groupPost']) {
            realAllGroups.add({'data': data, 'id': id, 'joined': joined});
          }
        } else if (condition == 'joined' && joined) {
          realAllGroups.add({'data': data, 'id': id, 'joined': joined});
        }
        setState(() {});
      }
      print('Now you get all groups');
    });

    return realAllGroups;
  }

  //get one group function that using uid of firebase database
  Future<bool> getSelectedGroup(String name) async {
    name = name.split('/')[name.split('/').length - 1];
    viewGroupName = name;
    var reuturnValue = await Helper.groupsData
        .where('groupUserName', isEqualTo: viewGroupName)
        .get();
    var value = reuturnValue.docs;
    group = value[0];
    viewGroupId = group.id;
    viewGroupJoined = await boolJoined(viewGroupId);
    setState(() {});
    print('This group was posted by ${group['groupAdmin'][0]['userName']}');
    return true;
  }

  //create group function
  Future<String> createGroup(context, Map<String, dynamic> groupData) async {
    if (groupData['groupName'] == null) {
      return 'Please add your group name';
    } else if (groupData['groupUserName'] == null) {
      return 'Please add your group user name';
    } else if (groupData['groupLocation'] == null) {
      return 'Please add your group location';
    }
    groupData = {
      ...groupData,
      'groupAdmin': [
        {'userName': UserManager.userInfo['userName']},
      ],
      'groupDate': DateTime.now().toString(),
      'groupJoined': [],
      'groupPost': false,
      'groupPicture': '',
      'groupCover': '',
      'groupPhotos': [],
      'groupAlbums': [],
      'groupVideos': [],
      'groupCanPub': false,
      'groupApproval': true,
    };

    var reuturnValue = await Helper.groupsData
        .where('groupUserName', isEqualTo: groupData['groupUserName'])
        .get();
    var value = reuturnValue.docs;
    if (value.isEmpty) {
      return 'doubleName';
    }

    await FirebaseFirestore.instance
        .collection(Helper.groupsField)
        .add(groupData);

    Navigator.pushReplacementNamed(
        context, '${RouteNames.groups}/${groupData['groupUserName']}');
    return 'success';
  }

  ////////////////////functions that support for making comment to group/////////////////////////////

  //user join in group liked function
  Future<bool> joinedGroup(String groupId) async {
    print('now you are joined or unjoined this group ${groupId}');
    var querySnapshot = await Helper.groupsData.doc(groupId).get();
    var doc = querySnapshot;
    var joined = doc['groupJoined'];
    var respon = await boolJoined(groupId);
    if (respon) {
      joined.removeWhere(
          (item) => item['userName'] == UserManager.userInfo['userName']);
      await FirebaseFirestore.instance
          .collection(Helper.groupsField)
          .doc(groupId)
          .update({'groupJoined': joined});
      return true;
    } else {
      joined.add({
        'userName': UserManager.userInfo['userName'],
        'fullName':
            '${UserManager.userInfo['firstName']} ${UserManager.userInfo['lastName']}',
        'userAvatar': UserManager.userInfo['avatar']
      });
      await FirebaseFirestore.instance
          .collection(Helper.groupsField)
          .doc(groupId)
          .update({'groupJoined': joined});
      return true;
    }
  }

  //bool of user already in group interested or not
  Future<bool> boolJoined(String groupId) async {
    var querySnapshot = await Helper.groupsData.doc(groupId).get();
    var doc = querySnapshot;
    print(groupId);
    var joined = doc['groupJoined'];
    if (joined == null) {
      return false;
    }
    var returnData = joined.where(
        (eachUser) => eachUser['userName'] == UserManager.userInfo['userName']);
    print('you get bool of joined group');
    if (returnData.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  Future<String> updateGroupInfo(dynamic groupInfo) async {
    if (groupInfo['groupUserName'] == null) {
      var result = await Helper.groupsData.doc(viewGroupId).update(groupInfo);
      return group['groupUserName'];
    }
    if (groupInfo['groupUserName'] == group['groupUserName']) {
      var result = await Helper.groupsData.doc(viewGroupId).update(groupInfo);
      return group['groupUserName'];
    } else {
      QuerySnapshot querySnapshot = await Helper.groupsData.get();
      var allGroup = querySnapshot.docs;
      var flag = allGroup.where((eachGroup) =>
          eachGroup['groupUserName'] == groupInfo['groupUserName']);
      if (flag.isNotEmpty) {
        return 'dobuleName${groupInfo['groupUserName']}';
      } else {
        var result = await Helper.groupsData.doc(viewGroupId).update(groupInfo);
        return groupInfo['groupUserName'];
      }
    }
  }

  ////////////////////functions that make comment to group/////////////////////////////

  ///////////////////////////end groups functions //////////////////////////////////////////////////

  Future<String> createProduct(
      context, Map<String, dynamic> productData) async {
    if (productData['productName'] == null) {
      return 'Please add your product name';
    } else if (productData['productPrice'] == null) {
      return 'Please add your product price';
    } else if (productData['productCategory'] == null) {
      return 'Please add your product category';
    }
    productData = {
      ...productData,
      'productAdmin': {
        'userName': UserManager.userInfo['userName'],
        'userAvatar': UserManager.userInfo['avatar'],
        'fullName': UserManager.userInfo['fullName']
      },
      'productDate': DateTime.now().toString(),
      'productPost': false,
    };
    await FirebaseFirestore.instance
        .collection(Helper.productsField)
        .add(productData)
        .then((value) async => {
              Navigator.pushReplacementNamed(
                  context, '${RouteNames.products}/${value.id}')
            });
    return 'success';
  }

  //get all product function
  Future<List> getProduct() async {
    List<Map> allProduct = [];
    await Helper.productsData.get().then((value) async {
      var doc = value.docs;
      for (int i = 0; i < doc.length; i++) {
        var id = doc[i].id;
        var data = doc[i];
        allProduct.add({'data': data.data(), 'id': id});
        setState(() {});
      }
      print('Now you get all products');
    });

    return allProduct;
  }

  var viewProductId;
  var product;
  //get one page function that using uid of firebase database
  Future<bool> getSelectedProduct(String name) async {
    name = name.split('/')[name.split('/').length - 1];
    viewProductId = name;
    var reuturnValue = await Helper.productsData.doc(viewProductId).get();
    var value = reuturnValue.data();
    product = value;
    setState(() {});
    print('This page was posted by ${product['productAdmin']}');
    return true;
  }

  saveComment(productId) async {
    await Helper.productLikeComment.doc(productId).set({});
  }
}
