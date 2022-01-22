import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/models/appdata.dart';
import 'package:shoplist/models/entry.dart';
import 'package:shoplist/models/route-entry.dart';
import 'package:shoplist/models/product-input-field.dart';
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
}
