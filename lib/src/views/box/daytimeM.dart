import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:shnatter/src/utils/size_config.dart';

// ignore: must_be_immutable
class DayTimeM extends StatelessWidget {
  DayTimeM({super.key, required this.time, required this.username});
  int time;
  String username;
  List<Map> sampleData = [
    {
      'id': 'morning',
      'welcome': 'Good Morning, ',
      'message':
          'Write it on your heart that every day is the best day in the year',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/shnatter-a69cd.appspot.com/o/shnatter-assests%2Fsvg%2FdayTimeMessage%2Fsunrise.svg?alt=media&token=5ae999ef-086c-4c96-a161-c7ec9d8a2f2b',
    },
    {
      'id': 'afternoon',
      'welcome': 'Good Afternoon, ',
      'message':
          'May Your Good Afternoon Be Light, Blessed, Productive And Happy',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/shnatter-a69cd.appspot.com/o/shnatter-assests%2Fsvg%2FdayTimeMessage%2Fsun.svg?alt=media&token=89731a8a-6027-4b9c-b71b-af34dff68aca',
    },
    {
      'id': 'evening',
      'welcome': 'Good Evening, ',
      'message': 'We hope you are enjoying your evening',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/shnatter-a69cd.appspot.com/o/shnatter-assests%2Fsvg%2FdayTimeMessage%2Fnight.svg?alt=media&token=759baa82-e5be-4b88-9c03-6bc66510cd2d',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig(context).screenWidth > SizeConfig.smallScreenSize
          ? 530
          : 370,
      padding: const EdgeInsets.only(left: 20, right: 20),
      height: SizeConfig(context).screenWidth > SizeConfig.smallScreenSize
          ? 120
          : 90,
      alignment: Alignment.center,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
              left: BorderSide(
            color: Color.fromARGB(255, 251, 165, 64),
            width: 3,
          )),
          // borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              child: SvgPicture.network(sampleData[time]['image']),
            ),
            const Padding(padding: EdgeInsets.only(left: 10)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: SizeConfig(context).screenWidth >
                          SizeConfig.smallScreenSize
                      ? 410
                      : 240,
                  child: Text(
                    '${sampleData[time]['welcome']} $username',
                    style: const TextStyle(
                        overflow: TextOverflow.clip,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: SizeConfig(context).screenWidth >
                          SizeConfig.smallScreenSize
                      ? 410
                      : 240,
                  child: Text(
                    sampleData[time]['message'],
                    style: const TextStyle(
                      overflow: TextOverflow.clip,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
