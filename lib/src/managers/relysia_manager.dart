import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';

class RelysiaManager {
  static const apiUrlAuth = 'https://api.relysia.com/v1/auth';
  static const serviceId = '8c67e277-4baa-44c9-955a-73f054618196';
  static const shnToken = '90ed65c46635479f2113c6614a002a0dda8455a8-SHNA';
  static var resToken = {};

  static var transHistory = [];
  static Future<Map> authUser(String email, String password) async {
    Map responseData = {};
    try {
      String bodyCode =
          jsonEncode(<String, String>{'email': email, 'password': password});
      await http
          .post(
            Uri.parse(apiUrlAuth),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'serviceID': serviceId
            },
            body: bodyCode,
          )
          .then((res) => {
                responseData = jsonDecode(res.body),
                //print(responseData),
              });
    } catch (exception) {
      if (kDebugMode) {
        print("occurs exception$exception");
      }
    }
    return responseData;
  }

  static Future<Map> createUser(String email, String password) async {
    Map responseData = {};
    try {
      String bodyCode =
          jsonEncode(<String, String>{'email': email, 'password': password});
      await http
          .post(
            Uri.parse('https://api.relysia.com/v1/signUp'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'serviceID': serviceId
            },
            body: bodyCode,
          )
          .then((res) => {
                responseData = jsonDecode(res.body),
              });
    } catch (exception) {}
    return responseData;
  }

  static Future<Map> changePassword(String password, String token) async {
    Map responseData = {};
    try {
      String bodyCode = jsonEncode(<String, String>{'newPassword': password});
      await http
          .post(
            Uri.parse('https://api.relysia.com/v1/password/change'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'serviceID': serviceId,
              'authToken': token,
            },
            body: bodyCode,
          )
          .then((res) => {
                responseData = jsonDecode(res.body),
              });
    } catch (exception) {}
    return responseData;
  }

  static Future<int> createWallet(String token) async {
    var r = 0;
    try {
      await http
          .get(Uri.parse('https://api.relysia.com/v1/createWallet'), headers: {
        'authToken': token,
        'serviceID': serviceId,
        'walletTitle': '00000000-0000-0000-0000-000000000000',
        'paymailActivate': 'true',
      }).then((res) => {
                r = 1,
              });
      // ignore: empty_catches
    } catch (exception) {}
    return r;
  }

  static Future<Map> getPaymail(String token) async {
    Map paymail = {};
    var resData = {};
    try {
      await http.get(Uri.parse('https://api.relysia.com/v1/address'), headers: {
        'authToken': token,
        'serviceID': serviceId,
      }).then((res) => {
            resData = jsonDecode(res.body),
            if (resData['statusCode'] == 200)
              {
                paymail['paymail'] = resData['data']['paymail'],
                paymail['address'] = resData['data']['address'],
              },
          });
    } catch (exception) {}
    return paymail;
  }

  static Future<int> getBalance(String token) async {
    var balance = 0;
    try {
      await http.get(Uri.parse('https://api.relysia.com/v2/balance'), headers: {
        'authToken': token,
        'serviceID': serviceId,
      }).then((res) => {
            resToken = jsonDecode(res.body),
            for (var i = 0; i < resToken['data']['coins'].length; i++)
              {
                if (resToken['data']['coins'][i]['tokenId'] == shnToken)
                  {
                    balance = resToken['data']['coins'][i]['amount'],
                  }
              },
          });
    } catch (exception) {
      if (kDebugMode) {
        print(exception.toString());
      }
    }
    return balance;
  }

  static Future<String> payNow(
      String token, String payMail, String amount, String notes) async {
    String returnData = '';
    var respondData = {};
    try {
      var senderBalance = await getBalance(token);
      if (senderBalance < int.parse(amount)) {
        returnData = 'Not enough token amount';
      } else {
        await http
            .post(
              Uri.parse('https://api.relysia.com/v1/send'),
              headers: {
                'authToken': token,
                'content-type': 'application/json',
                'serviceID': serviceId,
              },
              body:
                  '{ "dataArray" : [{"to" : "$payMail","amount" : $amount ,"tokenId" : "$shnToken","notes":"$notes"}]}',
            )
            .then(
              (res) => {
                respondData = jsonDecode(res.body),
                if (respondData['statusCode'] == 200)
                  {
                    returnData = 'Successfully paid',
                  }
                else
                  {
                    returnData = 'Failed payment',
                  },
              },
            );
      }
    } catch (exception) {
      if (kDebugMode) {
        print(exception.toString());
      }
    }
    return returnData;
  }

  static Future<String> payMultiUserNow(
      String token, List payMail, String amount, String notes) async {
    String returnData = '';
    var respondData = {};
    String body = '';
    try {
      body = '{ "dataArray" : [';
      for (var i = 0; i < payMail.length; i++) {
        body +=
            '{"to" : "${payMail[i]}","amount" : $amount ,"tokenId" : "$shnToken","notes":"$notes"}';
        if (i != payMail.length - 1) {
          body += ',';
        }
      }
      body += ']}';
      var senderBalance = await getBalance(token);
      if (senderBalance < int.parse(amount * payMail.length)) {
        returnData = 'Not enough token amount';
      } else {
        await http
            .post(
              Uri.parse('https://api.relysia.com/v1/send'),
              headers: {
                'authToken': token,
                'content-type': 'application/json',
                'serviceID': serviceId,
              },
              body: body,
            )
            .then(
              (res) => {
                respondData = jsonDecode(res.body),
                if (respondData['statusCode'] == 200)
                  {
                    returnData = 'Successfully paid',
                  }
                else
                  {
                    returnData = 'Failed payment',
                  },
              },
            );
      }
    } catch (exception) {
      if (kDebugMode) {
        print(exception.toString());
      }
    }
    return returnData;
  }

  static Future<Map> getTransactionHistory(String token, nextPageToken) async {
    var response = {};
    bool? result;
    var next = '';
    next = nextPageToken;
    transHistory = [];
    try {
      await http.get(
          Uri.parse('https://api.relysia.com/v2/history?nextPageToken=$next'),
          headers: {
            'authToken': token,
            'serviceID': serviceId,
            'version': '1.1.0'
          }).then(
        (res) async {
          response = jsonDecode(res.body);

          if (response['statusCode'] == 200) {
            if (response['data']['histories'] != []) {
              for (var elem in response['data']['histories']) {
                for (var e in elem['to']) {
                  if (e['tokenId'] == shnToken) {
                    transHistory.add({
                      'txId': elem['txId'] ?? '',
                      'from': elem['from'] ?? '',
                      'notes': elem['notes'] ?? '',
                      'to': e['to'] ?? '',
                      'balance_change': elem['totalAmount'] ?? '',
                      'timestamp': elem['timestamp'] ?? ''
                    });
                  }
                }
              }
              if (response['data']['histories'].length < 10) {
                next = 'null';
              } else {
                next = response['data']['meta']['nextPageToken'].toString();
              }
              result = true;
            } else {
              result = true;
            }
            // print(transHistory);
          } else if (response['statusCode'] == 401) {
            next = 'null';
            result = false;
          }
        },
      );
    } catch (exception) {
      Helper.showToast("An error has occurred. try again later");
    }
    return {'history': transHistory, 'success': result, 'nextPageToken': next};
  }

  static Future<int> deleteUser(String token) async {
    var r = 0;
    var respondData = {};
    try {
      await http.delete(Uri.parse('https://api.relysia.com/v1/user'), headers: {
        'authToken': token,
        'serviceID': serviceId,
        'walletTitle': '00000000-0000-0000-0000-000000000000',
        'paymailActivate': 'true',
      }).then((res) => {
            respondData = jsonDecode(res.body),
            if (respondData['statusCode'] == 200)
              {
                r = 1,
              }
            else if (respondData['statusCode'] == 401 &&
                respondData['data']['msg'] == "Invalid authToken provided")
              {
                r = 2,
              }
            else if (respondData['statusCode'] == 401 &&
                respondData['data']['msg'] == "authToken not found")
              {
                r = 2,
              }
          });
      // ignore: empty_catches
    } catch (exception) {
      Helper.showToast(
          "An error has occurred. Please check your internet connectivity or try again later");
    }
    return r;
  }
}
