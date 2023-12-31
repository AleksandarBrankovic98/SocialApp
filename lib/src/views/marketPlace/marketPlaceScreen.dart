import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/views/marketPlace/panel/marketAllProduct.dart';

import '../../controllers/PostController.dart';
import '../../utils/size_config.dart';

// ignore: must_be_immutable
class MarketPlaceScreen extends StatefulWidget {
  MarketPlaceScreen({Key? key, required this.routerChange})
      : con = PostController(),
        super(key: key);
  final PostController con;
  Function routerChange;

  @override
  State createState() => MarketPlaceScreenState();
}

class MarketPlaceScreenState extends mvc.StateMVC<MarketPlaceScreen>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String category = 'All';
  String arrayOption = 'Latest';
  String searchValue = '';
  late PostController con;

  @override
  void initState() {
    add(widget.con);
    con = controller as PostController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  width: SizeConfig(context).screenWidth >
                          SizeConfig.mediumScreenSize
                      ? 700
                      : SizeConfig(context).screenWidth > 600
                          ? 600
                          : SizeConfig(context).screenWidth,
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 3, left: 10, right: 10),
                        child: customInput(
                          place: 'I am looking for',
                          onChange: (value) {
                            searchValue = value;
                            setState(() {});
                          },
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 20)),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Text(
                              'PRODUCTS',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          const Flexible(fit: FlexFit.tight, child: SizedBox()),
                          Container(
                            width: 160,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(right: 20),
                            child: PopupMenuButton(
                              onSelected: (value) {
                                arrayOption = value;
                                setState(() {});
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 33, 37, 41),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      arrayOption == 'Latest'
                                          ? Icons.menu
                                          : Icons.sort,
                                      color: Colors.white,
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(left: 10)),
                                    Text(
                                      arrayOption,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              itemBuilder: (BuildContext bc) {
                                return [
                                  const PopupMenuItem(
                                    value: 'Latest',
                                    child: Row(children: [
                                      Icon(Icons.menu),
                                      Padding(
                                          padding: EdgeInsets.only(left: 10)),
                                      Text(
                                        "Latest",
                                        style: TextStyle(fontSize: 14),
                                      )
                                    ]),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Price High',
                                    child: Row(
                                      children: [
                                        Icon(Icons.sort),
                                        Padding(
                                            padding: EdgeInsets.only(left: 10)),
                                        Text(
                                          "Price High",
                                          style: TextStyle(fontSize: 14),
                                        )
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Price Low',
                                    child: Row(
                                      children: [
                                        Icon(Icons.sort),
                                        Padding(
                                            padding: EdgeInsets.only(left: 10)),
                                        Text(
                                          "Price Low",
                                          style: TextStyle(fontSize: 14),
                                        )
                                      ],
                                    ),
                                  )
                                ];
                              },
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        width: SizeConfig(context).screenWidth >
                                SizeConfig.mediumScreenSize
                            ? 700
                            : SizeConfig(context).screenWidth > 600
                                ? 600
                                : SizeConfig(context).screenWidth,
                        child: const Divider(
                          thickness: 0.1,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 20)),
                MarketAllProduct(
                  productCategory: category,
                  arrayOption: arrayOption,
                  searchValue: searchValue,
                  routerChange: widget.routerChange,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget customInput({place, onChange}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(top: 2)),
        SizedBox(
          height: 40,
          child: TextField(
            onChanged: onChange,
            decoration: InputDecoration(
              hintText: place,
              hintStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color.fromRGBO(12, 12, 12, 0.1)),
              contentPadding: const EdgeInsets.only(top: 10, left: 10),
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 1.0),
              ),
            ),
          ),
        )
      ],
    );
  }
}
