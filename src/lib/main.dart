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

// TODO: Can't move AppData to a different file because it will throw errors like 'appdata._storeAppDataToDisk()'' is not defined and such
// TODO: calling _loadAppDataFromDisk works fine, but the widgets onscreen don't update until some action is performed. boo.

// AppData is a class that holds important information that is shared across restarts and tabs (both the home, trip and supermarket widgets view the same internal lists)
class AppData{
    static final AppData _appData = new AppData._internal();

    List shopList = [
        /* TODO: make header type that only shows in home list with bold type (and grey background?) */
        /* ShopListHeader(headerName: "Monday"). */
        ShopListEntry(productName: "bananas",      homeIndex: 0, supermarketIndex: 1),
        ShopListEntry(productName: "eggs",         homeIndex: 1, supermarketIndex: 3),
        /* ShopListHeader(headerName: "Tuesday"). */
        ShopListEntry(productName: "bread",        homeIndex: 2, supermarketIndex: 2),
        /* ShopListHeader(headerName: "Other stuff"). */
        ShopListEntry(productName: "toilet paper", homeIndex: 3, supermarketIndex: 2),
        ShopListEntry(productName: "",             homeIndex: 4, supermarketIndex: 0),
    ];

    void _storeAppDataToDisk() {
        String shopListString = jsonEncode(shopList.map((x) => x.toJson()).toList());
        print("###################################################################");
        print("Writing to disk:");
        print(shopListString);
        writeShopListString(shopListString);
    }

    void _loadAppDataFromDisk() {
        loadShopListString().then((String shopListString) {
            print("###################################################################");
            print("Loading from disk:");
            print(shopListString);
            shopList = jsonDecode(shopListString).map<ShopListEntry>((x) => ShopListEntry.fromJson(x)).toList();
        });
    }

    List _productNames() => shopList.map((x) => x.productName).toList();
    List _reducedProductNames() => shopList.map((x) => x.getReducedProductName()).toList();

    void _updateHomeIndex(int oldIndex, int newIndex) {

        int index;
        if        ( oldIndex  < newIndex ) {
            index = oldIndex;
        } else if ( oldIndex  > newIndex ) {
            index = oldIndex + 1;
        } else if ( oldIndex == newIndex ) {
            return;
        }

        for (ShopListEntry entry in this.shopList ) {
            if ( entry.homeIndex >= newIndex ) {
                entry.homeIndex += 1;
            }
        }

        for (ShopListEntry entry in this.shopList ) {
            if ( entry.homeIndex == index ) {
                entry.homeIndex = newIndex;
            }
        }

        for (ShopListEntry entry in this.shopList ) {
            if ( entry.homeIndex > oldIndex ) {
                entry.homeIndex -= 1;
            }
        }
    }

    // TODO: the functions _updateHomeIndex and _updateSupermarketIndex are practically the same, find a way to remove the redundancy
    void _updateSupermarketIndex(int oldIndex, int newIndex) {

        int index;
        if ( oldIndex  < newIndex ) {
            index = oldIndex;
        } else if ( oldIndex  > newIndex ) {
            index = oldIndex + 1;
        } else if ( oldIndex == newIndex ) {
            return;
        }

        for (ShopListEntry entry in this.shopList ) {
            if ( entry.supermarketIndex >= newIndex ) {
                entry.supermarketIndex += 1;
            }
        }

        for (ShopListEntry entry in this.shopList ) {
            if ( entry.supermarketIndex == index ) {
                entry.supermarketIndex = newIndex;
            }
        }

        for (ShopListEntry entry in this.shopList ) {
            if ( entry.supermarketIndex > oldIndex ) {
                entry.supermarketIndex -= 1;
            }
        }

    }

    factory AppData() {
        return _appData;
    }

    AppData._internal();

}

// The appData object is a globally available variable
var appData = AppData();

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
        ShopList(sort_style: "Home"),
        ShopList(sort_style: "Trip"),
        ShopList(sort_style: "Supermarket")
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

void addEmptyEntryToShopList() {
  /* The empty entry is also the tile in the list that the user uses to make new entries */
  if (!appData._reducedProductNames().contains("")) {
      appData.shopList.add(ShopListEntry(productName: "", homeIndex: appData.shopList.length, supermarketIndex:appData.shopList.length));
  }
}

// Show the main body; it'll be a list of checkboxtiles that are sorted one way or another
class ShopList extends StatefulWidget {
    final String sort_style;

    ShopList({ Key key, this.sort_style}): super(key: key);

    @override
    _ShopListState createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {

    @override
    void initState() {
        super.initState();
        /* appData._storeAppDataToDisk(); */
        appData._loadAppDataFromDisk();
    }

    @override
    Widget build(BuildContext context) {

        var _list_to_show;
        switch (widget.sort_style) {
            case "Home":
                _list_to_show = List.from(appData.shopList.where((x) => x.inShopList));
                _list_to_show.sort((a, b) => a.homeIndex - b.homeIndex as int);
                break;
            case "Trip":
                _list_to_show = List.from(appData.shopList.where((x) => x.inShopList));
                _list_to_show.sort((a, b) => a.supermarketIndex - b.supermarketIndex as int);
                break;
            case "Supermarket":
                _list_to_show = List.from(appData.shopList);
                _list_to_show.sort((a, b) => a.supermarketIndex - b.supermarketIndex as int);
                break;
        }

        void _updateMyItems(int oldIndex, int newIndex) {

            if ( oldIndex != newIndex ) {
                switch (widget.sort_style) {
                    case "Home":
                        oldIndex = _list_to_show[oldIndex].homeIndex;
                        if ( newIndex > oldIndex ) newIndex -= 1; // odd that this is necessary
                        newIndex = _list_to_show[newIndex].homeIndex;
                        if ( newIndex > oldIndex ) newIndex += 1;
                        appData._updateHomeIndex(oldIndex, newIndex);
                        break;
                    case "Trip":
                        oldIndex = _list_to_show[oldIndex].supermarketIndex;
                        if ( newIndex > oldIndex ) newIndex -= 1; // odd that this is necessary
                        newIndex = _list_to_show[newIndex].supermarketIndex;
                        if ( newIndex > oldIndex ) newIndex += 1;
                        appData._updateSupermarketIndex(oldIndex, newIndex);
                        break;
                    case "Supermarket":
                        appData._updateSupermarketIndex(oldIndex, newIndex);
                        break;
                }
            }
        }

        return Scaffold(
            appBar: AppBar(
              title: Text(widget.sort_style),
            ),
            body: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                    setState(() {
                        _updateMyItems(oldIndex, newIndex);
                        appData._storeAppDataToDisk();
                    });
                },
                children: [
                    for (final entry in _list_to_show) (widget.sort_style == "Supermarket") ? _buildRowSupermarket(entry) : _buildRow(entry)
                ]
            )
        );
    }


    Widget _buildRow(ShopListEntry entry) {
        return ListTile(
            key: ValueKey(entry.productName),
            title: TextField(
                controller: TextEditingController(
                    text: entry.productName,
                ),
                style: TextStyle(
                    fontSize: entry.checkedOff ? 12.0        : 20.0,
                    color   : entry.checkedOff ? Colors.grey : Colors.black
                ),
                decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder  : InputBorder.none,
                    contentPadding : EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                    hintText       : "tap to create new entry...",
                    hintStyle      : TextStyle(
                        fontStyle : FontStyle.italic,
                        fontSize  : 12.0,
                        color     : Colors.grey,
                    )
                ),
                onSubmitted: (productName) {
                    setState( () {
                      // TODO; allow adding duplicate productName; it should appear twice in homelist and triplist, but only once in supermarket order. Perhaps we need a randomly generated uuid as ValueKey
                      if (!appData._productNames().contains(productName)) {
                        entry.productName = productName;
                        addEmptyEntryToShopList();
                        appData._storeAppDataToDisk();
                      }
                    });
                },
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            dense: true,
            leading : IconButton( // TODO: the cross has way too much padding on its left and right, remove it somehow
                padding: EdgeInsets.all(0.0),
                icon: Icon(Icons.clear),
                onPressed: () {
                    setState( () {
                        entry.inShopList = false;
                        appData._storeAppDataToDisk();
                    });
                }
            ),
            trailing: Icon(entry.checkedOff ? Icons.check_box_outlined : Icons.check_box_outline_blank),
            onTap: () {
                setState( () {
                    entry.checkedOff = !entry.checkedOff;
                    appData._storeAppDataToDisk();
                });
            }
        );
    }

    Widget _buildRowSupermarket(ShopListEntry entry) {
        return ListTile(
            key: ValueKey(entry.productName),
            title: TextField(
                controller: TextEditingController(
                    text: entry.getReducedProductName()
                ),
                style: TextStyle(
                    fontSize: 20.0,
                    color   : Colors.black
                ),
                decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder  : InputBorder.none,
                    contentPadding : EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                    hintText       : "tap to create new entry...",
                    hintStyle      : TextStyle(
                        fontStyle : FontStyle.italic,
                        fontSize  : 12.0,
                        color     : Colors.grey,
                    )
                ),
                onSubmitted: (productName) {
                    setState( () {
                        /* TODO: if you change the productName to something that's already there, no action is taken, make a pop-up informing the user that this entry is already in the list */
                        if (!appData._reducedProductNames().contains(productName)) {
                          entry.productName = productName;
                          entry.inShopList = false;
                          addEmptyEntryToShopList();
                          appData._storeAppDataToDisk();
                        }
                    });
                },
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            dense: true,
            leading : IconButton( // TODO: the cross has way too much padding on its left and right, remove it somehow
                padding: EdgeInsets.all(0.0),
                icon: Icon(Icons.clear),
                onPressed: () {
                    setState( () {
                        for (ShopListEntry entry_ in appData.shopList ) {
                            if ( entry_.homeIndex > entry.homeIndex ) {
                                entry_.homeIndex -= 1;
                            }
                            if ( entry_.supermarketIndex > entry.supermarketIndex ) {
                                entry_.supermarketIndex -= 1;
                            }
                        }
                        appData.shopList.removeAt(appData.shopList.indexOf(entry));
                        appData._storeAppDataToDisk();
                    });
                }
            ),
        );
    }
}
