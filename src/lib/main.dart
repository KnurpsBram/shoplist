import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import 'fs.dart';
import 'util.dart';
import 'shop-list-entry.dart';

void main() => runApp(MyApp());

// TODO: Can't move AppData to a different file because it will throw errors like 'appdata.storeAppDataToDisk()'' is not defined and such
// TODO: calling loadAppDataFromDisk works fine, but the widgets onscreen don't update until some action is performed. boo.

// AppData is a class that holds important information that is shared across restarts and tabs (both the home, trip and supermarket widgets view the same internal lists)
class AppData{
    static final AppData _appData = new AppData._internal();

    List homeList = [
        //HeaderEntry(text: "Monday"),
        //ProductEntry(text: "pasta"),
         //ProductEntry(text: "tomatoes"),
        //HeaderEntry(text: "Tuesday"),
        ProductEntry(text: "rice"),
        ProductEntry(text: "broccoli"),
        // HeaderEntryField(),
        // ProductEntryField(),
    ];

    List superMarketOrder = [
      "bananas",
      "tomatoes",
      "broccoli",
      "rice",
      "pasta",
      "ice cream"
    ];

    void storeAppDataToDisk() {

        Map<String, dynamic> outerDict = {'classType': homeList[0].toString()};
        print(outerDict);

        String homeListString = jsonEncode(homeList.map((x) => x.toJson()).toList());
        /* String homeListString = jsonEncode(homeList.map((x) => Map<String, dynamic> 'classType': x.toString(), 'attributes': x.toJson()).toList()); */
        print("###################################################################");
        print("Writing to disk:");
        print(homeListString);
        jsonPrettyPrint(homeList.map((x) => x.toJson()).toList());
        writeShopListString(homeListString);
    }

    void loadAppDataFromDisk() {
        /* loadShopListString().then((String shopListString) {
            print("###################################################################");
            print("Loading from disk:");
            print(shopListString);
            shopList = jsonDecode(shopListString).map<ShopListEntry>((x) => ShopListEntry.fromJson(x)).toList();
        }); */
    }

    List productNames() => homeList.map((x) => x.productName).toList();
    List reducedProductNames() => homeList.map((x) => x.getReducedProductName()).toList();

    factory AppData() {
        return _appData;
    }

    AppData._internal();
}

AppData appData = AppData();

// the MAIN app (stateless)
class MyApp extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title : 'ShopList',
            home  : BottomBarMainBodyWidget()
        );
    }
}

// Show stuff that's always there; the bottom bar and an open window where the main window will go
class BottomBarMainBodyWidget extends StatefulWidget {
    BottomBarMainBodyWidget({Key key}) : super(key: key);

    @override
    _BottomBarMainBodyWidgetState createState() => _BottomBarMainBodyWidgetState();
}

class _BottomBarMainBodyWidgetState extends State<BottomBarMainBodyWidget> {

    int _selectedPageIndex = 0;
    List<Widget> _widgetOptions = <Widget>[
        HomeList(),
        TripList(),
        TripList(),
        /* SuperMarketList() */
    ];

    @override
    Widget build(BuildContext context) {

        return Scaffold(
            body: Center(
                child: _widgetOptions.elementAt(_selectedPageIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart),
                        label: 'Trip',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.apartment),
                        label: 'Supermarket',
                    ),
                ],
                currentIndex: _selectedPageIndex,
                selectedItemColor: Colors.amber[800],
                onTap: (index) {
                    setState(() {
                        _selectedPageIndex = index;
                    });
                }
            ),
        );
    }
}

//
// HOME LIST
//
class HomeList extends StatefulWidget {

    HomeList({ Key key}): super(key: key);

    @override
    _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {

    @override
    void initState() {
        super.initState();
        /* appData.storeAppDataToDisk(); */
        appData.loadAppDataFromDisk();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Home"),
            ),
            body: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                    setState(() {
                        appData.homeList = reOrderList(appData.homeList, oldIndex, newIndex);
                        appData.storeAppDataToDisk();
                    });
                },
                children: [
                    for (final entry in appData.homeList) _buildRow(entry)
                ]
            )
        );
    }

    Widget _buildRow(Entry entry) {

      if (entry is ProductEntry) {
        return ListTile(
          key: ValueKey(entry.text), // TODO: use uuid
          title: TextField(
            controller: TextEditingController(
                text: entry.text,
            ),
            style: TextStyle(
                fontSize   : entry.isCheckedOff ? 12.0        : 20.0,
                color      : entry.isCheckedOff ? Colors.grey : Colors.black
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder  : InputBorder.none,
                contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          dense: true,
          leading : IconButton( // TODO: the cross has way too much padding on its left and right, remove it somehow
              padding: EdgeInsets.all(0.0),
              icon: Icon(Icons.clear),
              onPressed: () {
                  setState( () {
                      appData.homeList.remove(entry);
                      appData.storeAppDataToDisk();
                  });
              }
          ),
          trailing: Icon(entry.isCheckedOff ? Icons.check_box_outlined : Icons.check_box_outline_blank),
          onTap: () {
              setState( () {
                  entry.isCheckedOff = !entry.isCheckedOff;
                  appData.storeAppDataToDisk();
              });
          }
        );
      } else if (entry is ProductEntryField) {
        return ListTile(
          key: ValueKey("productentryfield"), // TODO: use uuid
          title: TextField(
            controller: TextEditingController(
                text: "",
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder  : InputBorder.none,
                contentPadding : EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText       : entry.hintText,
                hintStyle      : TextStyle(
                    fontStyle : FontStyle.italic,
                    fontSize  : 12.0,
                    color     : Colors.grey,
                )
            ),
            onSubmitted: (text) {
                setState( () {
                  // TODO; allow adding duplicate productName; it should appear twice in homelist and triplist, but only once in supermarket order. Perhaps we need a randomly generated uuid as ValueKey
                  // if (!appData.productNames().contains(productName)) {
                    appData.homeList.insert(appData.homeList.indexOf(entry), ProductEntry(text: text));
                    appData.storeAppDataToDisk();
                  //}
                });
            },
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          dense: true,
        );
      } else if (entry is HeaderEntry) {
        return ListTile(
          key: ValueKey(entry.text), // TODO: use uuid
          tileColor: Colors.grey, // TODO: this color looks ugly when the user drags the tile, see https://github.com/flutter/flutter/issues/45799
          title: TextField(
            controller: TextEditingController(
                text: entry.text,
            ),
            style: TextStyle(
                fontWeight: FontWeight.bold,
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder  : InputBorder.none,
                contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          dense: true,
          leading : IconButton( // TODO: the cross has way too much padding on its left and right, remove it somehow
              icon: Icon(Icons.clear),
              onPressed: () {
                  setState( () {
                      appData.homeList.remove(entry);
                      appData.storeAppDataToDisk();
                  });
              }
          )
        );
      } else if (entry is HeaderEntryField) {
        return ListTile(
          key: ValueKey("headerentryfield"), // TODO: use uuid
          tileColor: Colors.grey, // TODO: this color looks ugly when the user drags the tile, see https://github.com/flutter/flutter/issues/45799
          title: TextField(
            controller: TextEditingController(
                text: "",
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder  : InputBorder.none,
                contentPadding : EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText       : entry.hintText,
                hintStyle      : TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle : FontStyle.italic,
                    fontSize  : 12.0,
                )
            ),
            onSubmitted: (text) {
                setState( () {
                  // TODO; allow adding duplicate productName; it should appear twice in homelist and triplist, but only once in supermarket order. Perhaps we need a randomly generated uuid as ValueKey
                  // if (!appData.productNames().contains(productName)) {
                    appData.homeList.insert(appData.homeList.indexOf(entry), HeaderEntry(text: text));
                    appData.storeAppDataToDisk();
                  //}
                });
            },
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          dense: true,
        );
      } else {
        print("unsupported entry type");
      }
    }
}




//
// TRIP LIST
//
class TripList extends StatefulWidget {

    TripList({ Key key}): super(key: key);

    @override
    _TripListState createState() => _TripListState();
}

class _TripListState extends State<TripList> {

    @override
    void initState() {
        super.initState();
        /* appData.storeAppDataToDisk(); */
        appData.loadAppDataFromDisk();
    }

    @override
    Widget build(BuildContext context) {
        var _tripList;
        _tripList = List.from(appData.homeList.where((x) => (x is ProductEntry)));
        _tripList.sort((a, b) => appData.superMarketOrder.indexOf(reduceProductName(a.text)) - appData.superMarketOrder.indexOf(reduceProductName(b.text)) as int);

        return Scaffold(
            appBar: AppBar(
              title: Text("Trip"),
            ),
            body: ListView(
                children: [
                    for (final entry in _tripList) _buildRow(entry)
                ]
            )
        );
    }

    Widget _buildRow(ProductEntry entry) {
      return ListTile(
          key: ValueKey(entry.text), // TODO: use uuid
          title: TextField(
            controller: TextEditingController(
                text: entry.text,
            ),
            style: TextStyle(
                fontSize   : entry.isCheckedOff ? 12.0        : 20.0,
                color      : entry.isCheckedOff ? Colors.grey : Colors.black
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder  : InputBorder.none,
                contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          dense: true,
          leading : IconButton( // TODO: the cross has way too much padding on its left and right, remove it somehow
              padding: EdgeInsets.all(0.0),
              icon: Icon(Icons.clear),
              onPressed: () {
                  setState( () {
                      appData.homeList.remove(entry);
                      appData.storeAppDataToDisk();
                  });
              }
          ),
          trailing: Icon(entry.isCheckedOff ? Icons.check_box_outlined : Icons.check_box_outline_blank),
          onTap: () {
              setState( () {
                  entry.isCheckedOff = !entry.isCheckedOff;
                  appData.storeAppDataToDisk();
              });
          }
        );

    }
}
