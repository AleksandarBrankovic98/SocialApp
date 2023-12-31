import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ListText extends StatelessWidget {
  ListText(
      {super.key,
      required this.onTap,
      required this.label,
      required this.icon});
  final GestureTapCallback onTap;
  String label;
  Icon icon;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.only(top: 8.0)),
          Row(
            children: [
              const Padding(padding: EdgeInsets.only(left: 45.0)),
              icon,
              const Padding(padding: EdgeInsets.only(left: 10.0)),
              Text(
                label,
                style: const TextStyle(
                    color: Color.fromARGB(255, 90, 90, 90), fontSize: 13),
              )
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 10.0)),
        ],
      ),
    );
  }
}
