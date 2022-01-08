import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'fs.dart';
import 'util.dart';
import 'shop-list-entry.dart';

void main() => runApp(MyApp());

// TODO: calling load works fine, but the widgets onscreen don't update until some action is performed. boo.

class AppData{
    /// All information that must persist between closing and opening the app
    ///
    /// The AppData object can be mapped to json-formatted string and stored on the device.
    /// It can be restored from such a file on the device as well.
    ///
    /// There's two major attributes; homeList and supermarketOrder
    /// The homeList is the shopping list the user crafts at home.
    ///   It consists of all the products he or she might need.
    ///   The user can toggle each product to cross it off the list (without hard-removing it)
    ///   The user can add structure by adding headers ("this is what I need for tuesday", "this is what I need for that pie i want to bake"), purely for bookkeeping
    /// The supermarketOrder is the order in which the products appear if the user follows his or her favourite route
    ///   We're not going to attempt to find the shortest route through the supermarket based on product locations
    ///   That's a travelling salesman problem, which is out of scope for this simple app
    ///   We assume the user always walks the same route through the supermarket regardless of what items he or she needs
    ///
    /// Each entry in the homeList has a uuid (universally unique identifier) because it needs that to be reorderable
    /// The name is not the uuid, because the user might enter 'tomatoes' twice, for example
    /// In the supermarketOrder the name can be the uuid, because we won't allow adding the same entry twice there

    // TODO: Can't move AppData to a different file because it will throw errors like 'appdata.store()' is not defined and such

    static final AppData _appData = new AppData._internal();

    List homeList = [
        HeaderEntry(id: Uuid().v1(), text: "Monday"),
        ProductEntry(id: Uuid().v1(), text: "pasta"),
        ProductEntry(id: Uuid().v1(), text: "tomatoes"),
        HeaderEntry(id: Uuid().v1(), text: "Tuesday"),
        ProductEntry(id: Uuid().v1(), text: "rice"),
        ProductEntry(id: Uuid().v1(), text: "broccoli"),
        HeaderInputField(id: Uuid().v1()),
        ProductInputField(id: Uuid().v1()),
    ];

    List supermarketOrder = [
      "bananas",
      "tomatoes",
      "broccoli",
      "rice",
      "pasta",
      "ice cream",
      ""
    ];

    void fromJson(Map<String, dynamic> json) {
      homeList = json["homeList"].map<Entry>((x) => Entry.fromJson(x)).toList();
      supermarketOrder = json["supermarketOrder"];
    }

    Map<String, dynamic> toJson() {
      return {
        "homeList": homeList.map((x) => x.toJson()).toList(),
        "supermarketOrder": supermarketOrder,
      };
    }

    Future<void> store() async {
        Map<String, dynamic> json = toJson();
        // jsonPrettyPrint(json); // for debugging
        writeAppDataString(jsonEncode(json));
        print("Done writing appData to disk");
    }

    Future<void> load() async {
        return loadAppDataString().then((String jsonString) {
            Map<String, dynamic> json = jsonDecode(jsonString);
            // jsonPrettyPrint(json); // for debugging
            fromJson(json);
            print("Done loading appData from disk");
        });
    }

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
    /// Holds a list of tabs and a bottom bar to let the user switch between tabs

    int _selectedPageIndex = 0;
    List<Widget> _widgetOptions = <Widget>[
        HomeList(),
        TripList(),
        SupermarketList()
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
    /// The page where the user crafts his or her shopping list
    ///
    /// The user can add new product entries through a special ProductInputField
    ///   If the entry has never been seen before it will also be added to supermarketOrder in a trivial position (bottom)
    ///   When the user reorders the supermarketOrder, it will be remembered forever.
    ///   Before adding the entry to the supermarketOrder the name is 'reduced'; no numbers, lowercase, ignore parentheses
    ///   This means that if the user adds '3 Bananas (unripe)' it will be sorted according to the location of 'bananas' in the supermarketOrder
    /// The user can add headers with the HeaderInputField,
    ///   the HeaderEntries are only there to make the list more readable for the user and so they have no checkbox
    /// The user can drag and reorder existing entries
    /// The user can remove ProductEntries and HeaderEntries
    /// The user cannot remove ProductEntryFields and HeaderEntryFields

    @override
    void initState() {
        super.initState();
        appData.load().whenComplete(() {
          setState(() {});
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Home"),
            ),
            body: ReorderableListView( // TODO: you need to long-press before reordering which is soooooo slow, make the press time shorter somehow: https://github.com/flutter/flutter/issues/25065
                onReorder: (oldIndex, newIndex) {
                    setState(() {
                        appData.homeList = reOrderList(appData.homeList, oldIndex, newIndex);
                        appData.store();
                    });
                },
                children: [
                    for (final entry in appData.homeList) _buildRow(entry)
                ]
            )
        );
    }

    Widget _buildRow(Entry entry) {

      if (entry is ProductEntry) { // TODO: is switch-case possible here?
        return ListTile(
          key: ValueKey(entry.id),
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
            onSubmitted: (productName) {
                setState( () {
                    entry.text = productName;
                    String reducedProductName = reduceProductName(productName);
                    if (!appData.supermarketOrder.contains(reducedProductName)) {
                      appData.supermarketOrder.add(reducedProductName);
                    }
                    appData.homeList = reOrderList( // move the productInputField to below the field that just got something submitted; that's where the user is now looking
                        appData.homeList,
                        appData.homeList.indexWhere((ele) => ele is ProductInputField), // oldIndex
                        appData.homeList.indexOf(entry) + 1 // newIndex
                    );
                    appData.homeList = reOrderList(appData.homeList, appData.homeList.indexWhere((ele) => ele is ProductInputField), appData.homeList.indexOf(entry) + 1);
                    appData.store();
                });
            },
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          dense: true,
          leading : Wrap(
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.all(4.0),
                constraints: BoxConstraints(),
                icon: Icon(Icons.dehaze),
              ),
              IconButton(
                  padding: EdgeInsets.all(4.0),
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.clear),
                  onPressed: () {
                      setState( () {
                          appData.homeList.remove(entry);
                          appData.store();
                      });
                  }
              ),
            ],
          ),
          trailing: IconButton(
            padding: EdgeInsets.all(4.0),
            constraints: BoxConstraints(),
            icon: Icon(entry.isCheckedOff ? Icons.check_box_outlined : Icons.check_box_outline_blank),
            onPressed: () {
                setState( () {
                    entry.isCheckedOff = !entry.isCheckedOff;
                    appData.store();
                });
            }
          )
        );
      } else if (entry is ProductInputField) {
        return ListTile(
          key: ValueKey(entry.id),
          title: TextField(
            controller: TextEditingController(
                text: "",
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder  : InputBorder.none,
                contentPadding : EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText       : "tap to add new item",
                hintStyle      : TextStyle(
                    fontStyle : FontStyle.italic,
                    fontSize  : 12.0,
                    color     : Colors.grey,
                )
            ),
            onSubmitted: (productName) {
                setState( () {
                    appData.homeList.insert(appData.homeList.indexOf(entry), ProductEntry(id: Uuid().v1(), text: productName));
                    String reducedProductName = reduceProductName(productName);
                    if (!appData.supermarketOrder.contains(reducedProductName)) {
                      appData.supermarketOrder.add(reducedProductName);
                    }
                    appData.store();
                });
            },
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          dense: true,
          leading : IconButton(
            padding: EdgeInsets.all(4.0),
            constraints: BoxConstraints(),
            icon: Icon(Icons.dehaze),
          ),
        );
      } else if (entry is HeaderEntry) {
        return ListTile(
          key: ValueKey(entry.id),
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
            onSubmitted: (headerName) {
                setState( () {
                    entry.text = headerName;
                    appData.store();
                });
            },
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          dense: true,
          leading : Wrap(
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.all(4.0),
                constraints: BoxConstraints(),
                icon: Icon(Icons.dehaze),
              ),
              IconButton(
                  padding: EdgeInsets.all(4.0),
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.clear),
                  onPressed: () {
                      setState( () {
                          appData.homeList.remove(entry);
                          appData.store();
                      });
                  }
              ),
            ],
          ),
        );
      } else if (entry is HeaderInputField) {
        return ListTile(
          key: ValueKey(entry.id),
          tileColor: Colors.grey, // TODO: this color looks ugly when the user drags the tile, see https://github.com/flutter/flutter/issues/45799
          title: TextField(
            controller: TextEditingController(
                text: "",
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder  : InputBorder.none,
                contentPadding : EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText       : "tap to add new header",
                hintStyle      : TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle : FontStyle.italic,
                    fontSize  : 12.0,
                )
            ),
            onSubmitted: (text) {
                setState( () {
                    appData.homeList.insert(appData.homeList.indexOf(entry), HeaderEntry(id: Uuid().v1(), text: text));
                    appData.store();
                });
            },
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          dense: true,
          leading : IconButton(
            padding: EdgeInsets.all(4.0),
            constraints: BoxConstraints(),
            icon: Icon(Icons.dehaze),
          ),
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
    /// The page where the user sees on his or her trip to the supermarket
    ///
    /// It consists of the product entries of the homeList, ordered according to the supermarketOrder
    ///
    /// There are no headers
    ///
    /// TODO: Temporarily disabled reordering this list.
    ///   When it is enabled, we need a smart way to reorder the supermarketOrder
    ///   if reordering in triplist is [a, b, c] -> [a, c, b] and supermarketOrder is [a, d, b, c], does it need to become [a, d, c, b] or [a, c, d, b]?
    ///   There was some logic for this in an older version of the app, see if mimicking that is appropriate
    ///
    /// TODO: allow ProductEntryField here, new entry should be added to homeList in a trivial position (bottom?)

    @override
    void initState() {
        super.initState();
        appData.load().whenComplete(() {
          setState(() {});
        });
    }

    @override
    Widget build(BuildContext context) {
        var _tripList;
        _tripList = List.from(appData.homeList.where((x) => (x is ProductEntry)));
        _tripList.sort((a, b) => appData.supermarketOrder.indexOf(reduceProductName(a.text)) - appData.supermarketOrder.indexOf(reduceProductName(b.text)) as int);

        return Scaffold(
            appBar: AppBar(
              title: Text("Trip (dragging tiles disabled...)"),
            ),
            body: ListView( // TODO: ReorderableListView
                children: [
                    for (final entry in _tripList) _buildRow(entry)
                ]
            )
        );
    }

    Widget _buildRow(ProductEntry entry) {
      return ListTile(
          key: ValueKey(entry.id),
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
          leading : Wrap(
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.all(4.0),
                constraints: BoxConstraints(),
                icon: Icon(Icons.dehaze),
              ),
              IconButton(
                  padding: EdgeInsets.all(4.0),
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.clear),
                  onPressed: () {
                      setState( () {
                          appData.homeList.remove(entry);
                          appData.store();
                      });
                  }
              ),
            ],
          ),
          trailing: IconButton(
            padding: EdgeInsets.all(4.0),
            constraints: BoxConstraints(),
            icon: Icon(entry.isCheckedOff ? Icons.check_box_outlined : Icons.check_box_outline_blank),
            onPressed: () {
                setState( () {
                    entry.isCheckedOff = !entry.isCheckedOff;
                    appData.store();
                });
            }
          )
        );
    }
}


//
// SUPERMARKET LIST
//
class SupermarketList extends StatefulWidget {

    SupermarketList({ Key key}): super(key: key);

    @override
    _SupermarketListState createState() => _SupermarketListState();
}

class _SupermarketListState extends State<SupermarketList> {
    /// The page where the user crafts the product order of his or her favourite route through the supermarket
    ///
    /// This list should contain every product the user has ever submitted and sorted
    /// This list contains reduced productnames (lowercased, no numbers, ignore everything between parentheses)
    /// The string "" is interpreted as the ProductInputField
    ///
    /// TODO: the supermarketOrder is a list of strings whereas the homeList is a list of Entry objects, it'd be prettier if supermarketOrder is also a list of Entries (subclasses like SupermarketOrderProductEntry?)
    /// TODO: allow multiple customizable supermarketorderings (MyLocalJumbo, ThatOneBigAlbertHeijn, etc...)

    @override
    void initState() {
        super.initState();
        appData.load().whenComplete(() {
          setState(() {});
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Full Supermarket Order"),
            ),
            body: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                    setState(() {
                        appData.supermarketOrder = reOrderList(appData.supermarketOrder, oldIndex, newIndex);
                        appData.store();
                    });
                },
                children: [
                    for (final productName in appData.supermarketOrder) _buildRow(productName)
                ]
            )
        );
    }

    Widget _buildRow(String productName) {

      if (productName != "") { // TODO: is switch-case possible here?
        return ListTile(
          key: ValueKey(productName),
          title: TextField(
            controller: TextEditingController(
                text: productName,
            ),
            style: TextStyle(
                fontSize   : 20.0,
                color      : Colors.black
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder  : InputBorder.none,
                contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
            ),
            onSubmitted: (text) {
                setState( () {
                    if (!appData.supermarketOrder.contains(text)) {
                        productName = text;
                    }
                    appData.supermarketOrder = reOrderList( // move the productInputField to below the field that just got something submitted; that's where the user is now looking
                        appData.supermarketOrder,
                        appData.supermarketOrder.indexWhere((ele) => ele == ""), // oldIndex
                        appData.supermarketOrder.indexOf(productName) + 1 // newIndex
                    );
                    appData.store();
                });
            },

          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          dense: true,
          leading : Wrap(
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.all(4.0),
                constraints: BoxConstraints(),
                icon: Icon(Icons.dehaze),
              ),
              IconButton(
                  padding: EdgeInsets.all(4.0),
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.clear),
                  onPressed: () {
                      setState( () {
                          appData.supermarketOrder.remove(productName);
                          appData.store();
                      });
                  }
              ),
            ],
          ),
        );
      } else if (productName == "") {
        return ListTile(
          key: ValueKey("ProductInputField"),
          title: TextField(
            controller: TextEditingController(
                text: "",
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder  : InputBorder.none,
                contentPadding : EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText       : "tap to add new item",
                hintStyle      : TextStyle(
                    fontStyle : FontStyle.italic,
                    fontSize  : 12.0,
                    color     : Colors.grey,
                )
            ),
            onSubmitted: (text) {
                setState( () {
                  if (!appData.supermarketOrder.contains(text)) {
                    appData.supermarketOrder.insert(appData.supermarketOrder.indexOf(""), text);
                    appData.store();
                  }
                });
            },
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          dense: true,
          leading : IconButton(
            padding: EdgeInsets.all(4.0),
            constraints: BoxConstraints(),
            icon: Icon(Icons.dehaze),
          ),
        );
      } else {
        print("unsupported type");
      }
    }
}
