import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import 'fs.dart';
import 'util.dart';
import 'shop-list-entry.dart';

void main() => runApp(MyApp());

// TODO: Can't move AppData to a different file because it will throw errors like 'appdata._storeAppDataToDisk()'' is not defined and such
// TODO: calling _loadAppDataFromDisk works fine, but the widgets onscreen don't update until some action is performed. boo.
//
// AppData is a class that holds important information that is shared across restarts and tabs (both the home, trip and supermarket widgets view the same internal lists)
class AppData{
    static final AppData _appData = new AppData._internal();

    List supermarketOrder = ["bananas", "bread", "eggs"];

    List shopList = [
        ShopListEntry(productName: "bananas"),
        ShopListEntry(productName: "eggs"),
        ShopListEntry(productName: "bread"),
    ];

    void _storeAppDataToDisk() {
        String shopListString = jsonEncode(shopList.map((x) => x.toJson()).toList());
        print("###################################################################");
        print("Writing to disk:");
        print(shopListString);
        writeShopListString(shopListString);

        String supermarketOrderString = jsonEncode(supermarketOrder);
        print("###################################################################");
        print("Writing to disk:");
        print(supermarketOrderString);
        writeSupermarketOrderString(supermarketOrderString);

    }

    void _loadAppDataFromDisk() {
        loadShopListString().then((String shopListString) {
            print("###################################################################");
            print("Loading from disk:");
            print(shopListString);
            shopList = jsonDecode(shopListString).map<ShopListEntry>((x) => ShopListEntry.fromJson(x)).toList();
        });

        loadSupermarketOrderString().then((String supermarketOrderString) {
            print("###################################################################");
            print("Loading from disk:");
            print(supermarketOrderString);
            supermarketOrder = jsonDecode(supermarketOrderString);
        });
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

        // TODO: loading appdata works, but it doesn't update the screen until you perform some action
        setState(() {
            /* appData._storeAppDataToDisk(); */
            appData._loadAppDataFromDisk();
        });

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

// Show the main body; it'll be a list of checkboxtiles that are sorted one way or another
class ShopList extends StatefulWidget {
    final String sort_style;

    ShopList({ Key key, this.sort_style}): super(key: key);

    @override
    _ShopListState createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {

    @override
    Widget build(BuildContext context) {

        var _list_to_show;
        switch (widget.sort_style) {
            case "Home":
                _list_to_show = List.from(appData.shopList);
                break;
            case "Trip":
                _list_to_show = List.from(appData.shopList);
                _list_to_show.sort((a, b) => appData.supermarketOrder.indexOf(reduceProductName(a.productName)) - appData.supermarketOrder.indexOf(reduceProductName(b.productName)));
                break;
            case "Supermarket":
                _list_to_show = List.from(appData.supermarketOrder);
                break;
        }

        void _updateMyItems(int oldIndex, int newIndex) {
            if ( oldIndex != newIndex ) {
                switch (widget.sort_style) {
                    case "Home":
                        ShopListEntry entry = appData.shopList.removeAt(oldIndex);
                        if (oldIndex < newIndex) newIndex -= 1; // removing the item at oldIndex will shorten the list by 1.
                        appData.shopList.insert(newIndex, entry);
                        break;
                    case "Trip":
                        int oldIndexSupermarket = appData.supermarketOrder.indexOf(reduceProductName(_list_to_show[oldIndex].productName));
                        int newIndexSupermarket = (newIndex == _list_to_show.length) ? appData.supermarketOrder.length : appData.supermarketOrder.indexOf(reduceProductName(_list_to_show[newIndex].productName));
                        String reduced_productName = appData.supermarketOrder.removeAt(oldIndexSupermarket);
                        if (oldIndexSupermarket < newIndexSupermarket) newIndexSupermarket -= 1;
                        appData.supermarketOrder.insert(newIndexSupermarket, reduced_productName);
                        break;
                    case "Supermarket":
                        String entry = appData.supermarketOrder.removeAt(oldIndex);
                        if (oldIndex < newIndex) newIndex -= 1;
                        appData.supermarketOrder.insert(newIndex, entry);
                        break;
                }
            }
        }

        return Scaffold(
            appBar: AppBar(
              title: Text(widget.sort_style),
            ),
            body: ListView(
                children: <Widget>[
                    Container(
                        height: MediaQuery.of(context).size.height - 210, // TODO: make depend on the height of the body of the scaffold, not that of the entire screen
                        child: ReorderableListView(
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
                    ),
                    ListTile(
                        title: TextField(
                            controller: TextEditingController(),
                            onSubmitted: (productName) {
                                setState( () {
                                    appData.shopList.add(ShopListEntry(productName: productName));
                                    String reducedProductName = reduceProductName(productName);
                                    if (!appData.supermarketOrder.contains(reducedProductName)) {
                                        appData.supermarketOrder.add(reducedProductName);
                                    }
                                    appData._storeAppDataToDisk();
                                });
                            },
                            decoration: new InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                hintText: "bananas, eggs, bread...",
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 10.0)
                            ),
                        ),
                    )
                ]
            )
        );
    }

    Widget _buildRow(ShopListEntry entry) {
        return ListTile(
            key: ValueKey(entry.productName),
            title: Text(
                entry.productName,
                style: TextStyle(
                    fontSize: entry.checkedOff ? 12.0        : 20.0,
                    color   : entry.checkedOff ? Colors.grey : Colors.black
                )
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            dense: true,
            leading : IconButton( // TODO: the cross has way too much padding on its left and right, remove it somehow
                padding: EdgeInsets.all(0.0),
                icon: Icon(Icons.clear),
                onPressed: () {
                    setState( () {
                        List listOfStrings = appData.shopList.map((x) => x.productName).toList();
                        appData.shopList.removeAt(listOfStrings.indexOf(entry.productName));
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

    Widget _buildRowSupermarket(String productName) {
        return ListTile(
            key: ValueKey(productName),
            title: Text(
                productName,
                style: TextStyle(
                    fontSize: 20.0,
                    color   : Colors.black
                )
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            dense: true,
            leading : IconButton( // TODO: the cross has way too much padding on its left and right, remove it somehow
                padding: EdgeInsets.all(0.0),
                icon: Icon(Icons.clear),
                onPressed: () {
                    setState( () {
                        appData.supermarketOrder.removeAt(appData.supermarketOrder.indexOf(productName));
                        appData._storeAppDataToDisk();
                    });
                }
            ),
        );
    }
}
