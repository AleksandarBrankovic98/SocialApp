import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/controllers/PostController.dart';

class AlertYesNoWidget extends StatefulWidget {
  late PostController postCon;
  AlertYesNoWidget({
    Key? key,
    required this.yesFunc,
    required this.noFunc,
    required this.header,
    required this.text,
    required this.progress,
  })  : postCon = PostController(),
        super(key: key);
  Function yesFunc;
  Function noFunc;
  String header;
  String text;
  bool progress;
  @override
  State createState() => AlertYesNoWidgetState();
}

class AlertYesNoWidgetState extends mvc.StateMVC<AlertYesNoWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 400,
        height: 220,
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 350,
                    child: Text(
                      widget.header,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 380,
                    child: Text(
                      widget.text,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              // margin: const EdgeInsets.only(top: 180),
              child: Row(
                children: [
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                        minimumSize: const Size(110, 40),
                        maximumSize: const Size(110, 40),
                      ),
                      onPressed: () {
                        widget.noFunc();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(padding: EdgeInsets.only(top: 17)),
                          Icon(
                            Icons.arrow_back,
                            color: Colors.grey,
                            size: 14.0,
                          ),
                          Padding(padding: EdgeInsets.only(left: 10)),
                          Text('Back',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                        minimumSize: const Size(110, 40),
                        maximumSize: const Size(110, 40),
                      ),
                      onPressed: () async {
                        if (!widget.progress) {
                          widget.progress = true;
                          setState(() {});
                          await widget.yesFunc();
                          widget.progress = false;
                          setState(() {});
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          widget.progress
                              ? const SizedBox(
                                  width: 10,
                                  height: 10.0,
                                  child: CircularProgressIndicator(
                                    color: Colors.grey,
                                  ),
                                )
                              : const SizedBox(),
                          const Padding(padding: EdgeInsets.only(top: 17)),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 14.0,
                          ),
                          const Padding(padding: EdgeInsets.only(left: 10)),
                          const Text('OK',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 10))
                ],
              ),
            ),
          ],
        ));
  }
}
