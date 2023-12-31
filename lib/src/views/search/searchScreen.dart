// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart' as mvc;
import 'package:shnatter/src/controllers/SearcherController.dart';
import 'package:shnatter/src/views/search/panel/eventSearch.dart';
import 'package:shnatter/src/views/search/panel/groupSearch.dart';
import 'package:shnatter/src/views/search/panel/peopleSearch.dart';
import 'package:shnatter/src/views/search/panel/postSearch.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key, required this.routerChange})
      : con = SearcherController(),
        super(key: key);
  final SearcherController con;
  Function routerChange;

  @override
  State createState() => SearchScreenState();
}

class SearchScreenState extends mvc.StateMVC<SearchScreen>
    with SingleTickerProviderStateMixin {
  //route variable
  String searchPageRoute = 'People';
  String searchValue = '';
  List searchResultUsers = [];
  List searchResultEvents = [];
  List searchResultGroups = [];

  late SearcherController searchCon;
  List tabInfo = [
    {
      'icon': Icons.calendar_month,
      'text': 'People',
    },
    {
      'icon': FontAwesomeIcons.newspaper,
      'text': 'Post',
    },
    {
      'icon': Icons.groups,
      'text': 'Group',
    },
    {
      'icon': Icons.event,
      'text': 'Event',
    },
  ];

  @override
  void initState() {
    add(widget.con);
    searchCon = controller as SearcherController;
    // searchCon.getUsersByFirstName('');
    // searchCon.getUsersByLastName('');
    //searchCon.getPosts();
    // searchCon.getEvents();
    // searchCon.getGroups();
    searchCon.addNotifyCallBack(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 20, right: 20),
                    width: 500,
                    child: TextField(
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) async {
                        // searchValue = value;

                        // await SearcherController().updateSearchText(value);
                        // await SearcherController().getEvents(searchValue);
                        // await SearcherController().getGroups(searchValue);
                        // if (value != '') {
                        //   SearcherController().users = [
                        //     ...SearcherController().usersByFirstName,
                        //     ...SearcherController().usersByFirstNameCaps,
                        //     ...SearcherController().usersByLastName,
                        //     ...SearcherController().usersByLastNameCaps,
                        //     ...SearcherController().usersByWholeName,
                        //     ...SearcherController().usersByWholeNameCaps,
                        //   ];
                        //   print("searchText is ${SearcherController().users}");
                        //   SearcherController().users = [
                        //     ...{...SearcherController().users}
                        //   ];

                        //   searchResultUsers = [...SearcherController().users];
                        //   searchResultEvents = [...SearcherController().events];
                        //   searchResultGroups = [...SearcherController().groups];
                        // } else {
                        //   searchResultUsers = [];

                        //   searchResultEvents = [];
                        //   searchResultGroups = [];
                        // }

                        // super.setState(() {});
                      },
                      onSubmitted: (value) async {
                        searchValue = value;
                        searchCon.isLoading = true;
                        setState(
                          () {},
                        );
                        await searchCon.updateSearchText(value);

                        await searchCon.getEvents(searchValue);
                        await searchCon.getGroups(searchValue);
                        if (value != '') {
                          // SearcherController().users = [
                          //   ...SearcherController().usersByFirstName,
                          //   ...SearcherController().usersByFirstNameCaps,
                          //   ...SearcherController().usersByLastName,
                          //   ...SearcherController().usersByLastNameCaps,
                          //   ...SearcherController().usersByWholeName,
                          //   ...SearcherController().usersByWholeNameCaps,
                          // ];

                          searchResultUsers = [...searchCon.users];
                          searchResultEvents = [...searchCon.events];
                          searchResultGroups = [...searchCon.groups];
                        } else {
                          searchResultUsers = [];

                          searchResultEvents = [];
                          searchResultGroups = [];
                        }
                        searchCon.isLoading = false;
                        super.setState(() {});
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search,
                            color: Color.fromARGB(150, 170, 212, 255),
                            size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        filled: true,
                        fillColor: Colors.grey,
                        hintText: 'I am looking for',
                        hintStyle: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  tabWidget(() {}),
                  const SizedBox(height: 20),
                  searchRouteWidget()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabWidget(changeRoute) {
    return Row(
      children: [
        for (int i = 0; i < tabInfo.length; i++)
          Expanded(
            child: InkWell(
              onTap: () {
                searchPageRoute = tabInfo[i]['text'];
                setState(() {});
              },
              child: Container(
                width: 200,
                height: 50,
                margin: const EdgeInsets.all(5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: searchPageRoute == tabInfo[i]['text']
                        ? const Color.fromARGB(255, 34, 37, 41)
                        : null,
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      tabInfo[i]['icon'],
                      color: searchPageRoute == tabInfo[i]['text']
                          ? Colors.white
                          : const Color.fromARGB(255, 34, 37, 41),
                    ),
                    const SizedBox(width: 7),
                    Text(tabInfo[i]['text'],
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: searchPageRoute == tabInfo[i]['text']
                              ? Colors.white
                              : const Color.fromARGB(255, 34, 37, 41),
                        ))
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget searchRouteWidget() {
    switch (searchPageRoute) {
      case 'People':
        return PeopleSearch(
          routerChange: widget.routerChange,
          searchResult: searchResultUsers,
        );
      case 'Post':
        return PostSearch(
          routerChange: widget.routerChange,
          searchValue: searchValue,
        );
      case 'Group':
        return GroupSearch(
          routerChange: widget.routerChange,
          searchResult: searchResultGroups,
        );
      case 'Event':
        return EventSearch(
          routerChange: widget.routerChange,
          searchResult: searchResultEvents,
        );
      default:
        return Container();
    }
  }
}
