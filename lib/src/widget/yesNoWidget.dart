import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/controllers/PostController.dart';

import 'package:shnatter/src/utils/size_config.dart';

class YesNoWidget extends StatefulWidget {
  late PostController postCon;
  YesNoWidget({
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
  State createState() => YesNoWidgetState();
}

class YesNoWidgetState extends mvc.StateMVC<YesNoWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: SizeConfig(context).screenWidth,
      height: SizeConfig(context).screenHeight - SizeConfig.navbarHeight,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.5),
      ),
      child: Container(
        width: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: Offset(0, 0), // Shadow position
            ),
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        Text(
                          widget.header,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.text,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.only(bottom: 30),
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
                            onPressed: () {
                              widget.progress ? () {} : widget.yesFunc();
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
                                const Padding(
                                    padding: EdgeInsets.only(top: 17)),
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 14.0,
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(left: 10)),
                                const Text('Pay',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
