import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/models/appdata.dart';
import 'package:shoplist/models/shop-list-entry.dart';
import 'package:shoplist/components/route-entry-list-tile.dart';
import 'package:shoplist/components/product-input-field-list-tile.dart';
import 'package:shoplist/util/fs.dart';
import 'package:shoplist/util/misc.dart';

class RouteScreen extends StatefulWidget {
    AppData appData;

    RouteScreen(this.appData);

    @override
    RouteScreenState createState() => RouteScreenState(appData);
}

class RouteScreenState extends State<RouteScreen> {
    /// The page where the user crafts the product order of his/her favourite route through the supermarket
    ///
    /// This list should contain every product the user has ever submitted and sorted
    /// This list contains reduced productnames (lowercased, no numbers, ignore everything between parentheses)
    /// The string "" is interpreted as the ProductInputField
    ///
    /// TODO: the supermarketOrder is a list of strings whereas the homeList is a list of Entry objects, it'd be prettier if supermarketOrder is also a list of Entries (subclasses like SupermarketOrderProductEntry?)
    /// TODO: allow multiple customizable supermarketorderings (MyLocalJumbo, ThatOneBigAlbertHeijn, etc...)

    AppData appData;

    RouteScreenState(this.appData);

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
                title: Text("Route"),
            ),
            body: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                    setState(() {
                        appData.routeList = reOrderList(appData.routeList, oldIndex, newIndex);
                        appData.store();
                    });
                },
                children: [for (final entry in appData.routeList) buildRow(entry)]
            )
        );
    }

    Widget buildRow(Entry entry) {
        switch (entry.runtimeType) {
            case RouteEntry:
                return buildRouteEntryRow(entry);
            case ProductInputField:
                return buildProductInputFieldRow(entry);
        }
    }

    Widget buildRouteEntryRow(RouteEntry entry) {
        void onTextSubmittedCallback(String submittedText) {
             setState( () {
                 entry.text = reduceProductName(submittedText);
                 appData.routeList = reOrderList(
                     appData.routeList,
                     appData.routeList.indexWhere((ele) => ele is ProductInputField), // oldIndex
                     appData.routeList.indexOf(entry) + 1 // newIndex
                 );
                 appData.store();
             });
         }
         void removeEntryCallback() {
             setState( () {
                 appData.routeList.remove(entry);
                 appData.store();
             });
         }
         return routeEntryListTile(entry, onTextSubmittedCallback, removeEntryCallback);
    }

    Widget buildProductInputFieldRow(ProductInputField entry) {
        void onTextSubmittedCallback(submittedText) {
            setState( () {
                appData.routeList.insert(
                    appData.routeList.indexOf(entry),
                    RouteEntry(text: reduceProductName(submittedText))
                );
                appData.store();
            });
        }
        void removeEntryCallback() {
            setState( () {
                appData.routeList.remove(entry);
                appData.routeList.add(entry); // this adds it at the end
                appData.store();
            });
        }
        return productInputFieldListTile(entry, onTextSubmittedCallback, removeEntryCallback);
    }

//     Widget buildRow(String productName) {
//         if (productName != "") { // TODO: is switch-case possible here?
//             return ListTile(
//                 key: ValueKey(productName),
//                 title: TextField(
//                     controller: TextEditingController(
//                         text: productName,
//                     ),
//                     style: TextStyle(
//                         fontSize: 20.0,
//                         color: Colors.black
//                     ),
//                     decoration: new InputDecoration(
//                         border: InputBorder.none,
//                         focusedBorder: InputBorder.none,
//                         contentPadding: EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
//                     ),
//                     onSubmitted: (text) {
//                         setState( () {
//                             if (!appData.routeList.contains(text)) {
//                                 productName = text;
//                             }
//                             appData.routeList = reOrderList( // move the productInputField to below the field that just got something submitted; that's where the user is now looking
//                                 appData.routeList,
//                                 appData.routeList.indexWhere((ele) => ele == ""), // oldIndex
//                                 appData.routeList.indexOf(productName) + 1 // newIndex
//                             );
//                             appData.store();
//                         });
//                     },
//                 ),
//                 contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
//                 dense: true,
//                 leading : Wrap(
//                     children: <Widget>[
//                         IconButton(
//                             padding: EdgeInsets.all(4.0),
//                             constraints: BoxConstraints(),
//                             icon: Icon(Icons.dehaze),
//                         ),
//                         IconButton(
//                             padding: EdgeInsets.all(4.0),
//                             constraints: BoxConstraints(),
//                             icon: Icon(Icons.clear),
//                             onPressed: () {
//                                 setState( () {
//                                     appData.routeList.remove(productName);
//                                     appData.store();
//                                 });
//                             }
//                         ),
//                     ],
//                 ),
//             );
//         } else if (productName == "") {
//             return ListTile(
//                 key: ValueKey("ProductInputField"),
//                 title: TextField(
//                   controller: TextEditingController(
//                       text: "",
//                   ),
//                   decoration: new InputDecoration(
//                       border: InputBorder.none,
//                       focusedBorder  : InputBorder.none,
//                       contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
//                       hintText       : "tap to add new item",
//                       hintStyle      : TextStyle(
//                           fontStyle : FontStyle.italic,
//                           fontSize  : 12.0,
//                           color     : Colors.grey,
//                       )
//                   ),
//                   onSubmitted: (text) {
//                       setState( () {
//                         if (!appData.routeList.contains(text)) {
//                           appData.routeList.insert(appData.routeList.indexOf(""), text);
//                           appData.store();
//                         }
//                       });
//                   },
//                 ),
//                 contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
//                 dense: true,
//                 leading : Wrap(
//                     children: <Widget>[
//                         IconButton(
//                             padding: EdgeInsets.all(4.0),
//                             constraints: BoxConstraints(),
//                             icon: Icon(Icons.dehaze),
//                         ),
//                         IconButton(
//                             padding: EdgeInsets.all(4.0),
//                             constraints: BoxConstraints(),
//                             icon: Icon(Icons.clear),
//                             onPressed: () {
//                                 setState( () {
//                                     appData.routeList.remove("");
//                                     appData.routeList.add(""); // this adds it at the end
//                                     appData.store();
//                                 });
//                             }
//                         ),
//                     ],
//                 ),
//             );
//         } else {
//             print("unsupported type");
//         }
//     }


}
