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
import 'package:shoplist/models/product-entry.dart';
import 'package:shoplist/models/product-input-field.dart';
import 'package:shoplist/components/product-entry-list-tile.dart';
import 'package:shoplist/components/product-input-field-list-tile.dart';
import 'package:shoplist/util/fs.dart';
import 'package:shoplist/util/misc.dart';

class NextVisitScreen extends StatefulWidget {
    AppData appData;

    NextVisitScreen(this.appData);

    @override
    NextVisitScreenState createState() => NextVisitScreenState(appData);
}

class NextVisitScreenState extends State<NextVisitScreen> {
    /// The page where the user looks when NextVisiting through the supermarket
    ///
    /// It consists of the product entries of the needsList, ordered according to the order of the routeList
    ///
    /// There are no headers
    ///
    /// TODO: Temporarily disabled reordering this list.
    ///   When it is enabled, we need a smart way to reorder the supermarketOrder
    ///   if reordering in NextVisitList is [a, b, c] -> [a, c, b] and supermarketOrder is [a, d, b, c], does it need to become [a, d, c, b] or [a, c, d, b]?
    ///   There was some logic for this in an older version of the app, see if mimicking that is appropriate
    ///
    /// TODO: allow ProductEntryField here, new entry should be added to homeList in a trivial position (bottom?)

    AppData appData;

    NextVisitScreenState(this.appData);

    @override
    void initState() {
        super.initState();
        appData.load().whenComplete(() {
            setState(() {});
        });
    }

    @override
    Widget build(BuildContext context) {
        var nextVisitList;
        // nextVisitList = List.from(appData.needsList.where((x) => (x is ProductEntry)));
        nextVisitList = List.from(appData.needsList.where((x) => (x is ProductEntry) | (x is ProductInputField) ));
        nextVisitList.sort((a, b) => appData.routeList.indexWhere((ele) => ele.text == reduceProductName(a.text)) - appData.routeList.indexWhere((ele) => ele.text == reduceProductName(b.text)) as int);

        return Scaffold(
            appBar: AppBar(
                title: Text("NextVisit"),
            ),
            // body: ListView( // TODO: ReorderableListView
            body: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                    setState(() {

                        /// TODO: there's some bug
                        /// when using ReorderableListView and printing oldIndex and newIndex
                        /// you will see that dragging a tile one step to a lower position in the list indeed has oldIndex=1, newIndex=0 for instance
                        /// but dragging a tile one step higher makes oldIndex=1, newIndex=3. I think newIndex is too high when shifting up
                        /// this causes issues when dragging an item to the end of the list
                        /// I've circumvented the issue with the if-statements here
                        /// but I'd rather understand whether this is truly a flutter bug or some purposeful design I don't understand
                        int newIndexRouteList;
                        if (oldIndex != newIndex) {
                            int oldIndexRouteList = appData.routeList.indexWhere((ele) => ele.text == reduceProductName(nextVisitList[oldIndex].text));
                            if (newIndex >= nextVisitList.length) {
                                newIndexRouteList = appData.routeList.length;
                            } else {
                                newIndexRouteList = appData.routeList.indexWhere((ele) => ele.text == reduceProductName(nextVisitList[newIndex].text));
                            }
                            appData.routeList = reOrderList(
                                appData.routeList,
                                oldIndexRouteList,
                                newIndexRouteList
                            );
                            appData.store();
                        }
                    });
                },
                children: [
                    for (final entry in nextVisitList) buildRow(entry)
                ]
            )
        );
    }

    Widget buildRow(Entry entry) {
        switch (entry.runtimeType) {
            case ProductEntry:
                return buildProductEntryRow(entry);
            case ProductInputField:
                return buildProductInputFieldRow(entry);
        }
    }

    void addToRouteList(String text) {
        if (!appData.routeList.map((x) => x.text).contains(reduceProductName(text))) {
            appData.routeList.add(RouteEntry(text: reduceProductName(text)));
        }
    }

    void insertInRouteList(int index, String text) {
        if (!appData.routeList.map((x) => x.text).contains(reduceProductName(text))) {
            appData.routeList.insert(index, RouteEntry(text: reduceProductName(text)));
        } else {
            appData.routeList = reOrderList(
                appData.routeList,
                appData.routeList.indexWhere((ele) => ele.text == reduceProductName(text)), // oldIndex
                index // newIndex
            );
        }
    }

    void putProductInputFieldBelowMe(ProductEntry productEntry) {
        appData.routeList = reOrderList(
            appData.routeList,
            appData.routeList.indexWhere((ele) => ele is ProductInputField), // oldIndex
            appData.routeList.indexWhere((ele) => ele.text == reduceProductName(productEntry.text)) + 1 // newIndex
        );
    }

    void putProductInputFieldBottom() {
        appData.routeList = reOrderList(
            appData.routeList,
            appData.routeList.indexWhere((ele) => ele is ProductInputField), // oldIndex
            appData.routeList.length // newIndex
        );
    }

    Widget buildProductEntryRow(ProductEntry entry) {
        void onTextSubmittedCallback(String submittedText) {
             setState( () {
                 entry.text = submittedText;
                 addToRouteList(submittedText);
                 putProductInputFieldBelowMe(entry);
                 appData.store();
             });
         }
         void removeEntryCallback() {
             setState( () {
                 appData.needsList.remove(entry);
                 appData.store();
             });
         }
         void toggleCheckBoxCallback() {
             setState( () {
                 entry.isCheckedOff = !entry.isCheckedOff;
                 appData.store();
             });
         }
         return productEntryListTile(entry, onTextSubmittedCallback, removeEntryCallback, toggleCheckBoxCallback);
    }

    Widget buildProductInputFieldRow(ProductInputField entry) {
        void onTextSubmittedCallback(submittedText) {
            setState( () {
                appData.needsList.add(ProductEntry(text: submittedText));
                insertInRouteList(appData.routeList.indexWhere((ele) => ele is ProductInputField), submittedText);
                appData.store();
            });
        }
        void removeEntryCallback() {
            setState( () {
                putProductInputFieldBottom();
            });
        }
        return productInputFieldListTile(entry, onTextSubmittedCallback, removeEntryCallback);
    }

}
