import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/models/appdata.dart';
import 'package:shoplist/models/shop-list-entry.dart';
import 'package:shoplist/components/product-entry-list-tile.dart';
import 'package:shoplist/components/header-entry-list-tile.dart';
import 'package:shoplist/components/product-input-field-list-tile.dart';
import 'package:shoplist/components/header-input-field-list-tile.dart';
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
        nextVisitList = List.from(appData.needsList.where((x) => (x is ProductEntry)));
        nextVisitList.sort((a, b) => appData.routeList.indexWhere((ele) => ele.text == a.reducedProductName()) - appData.routeList.indexWhere((ele) => ele.text == b.reducedProductName()) as int);

        return Scaffold(
            appBar: AppBar(
                title: Text("NextVisit (dragging tiles disabled...)"),
            ),
            body: ListView( // TODO: ReorderableListView
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

    Widget buildProductEntryRow(ProductEntry entry) {
        void onTextSubmittedCallback(String submittedText) {
             setState( () {
                 entry.text = submittedText;
                 if (!appData.routeList.contains(entry.reducedProductName())) {
                     appData.routeList.add(entry.reducedProductName());
                 }
                 // appData.needsList = reOrderList(
                 //     appData.needsList,
                 //     appData.needsList.indexWhere((ele) => ele is ProductInputField), // oldIndex
                 //     appData.needsList.indexOf(entry) + 1 // newIndex
                 // );
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
                appData.needsList.insert(appData.needsList.indexOf(entry), ProductEntry(text: submittedText));
                String reducedProductName = reduceProductName(submittedText);
                if (!appData.routeList.contains(reducedProductName)) {
                    appData.routeList.add(reducedProductName);
                }
                appData.store();
            });
        }
        void removeEntryCallback() {
            setState( () {
                appData.needsList.remove(entry);
                appData.needsList.add(entry); // this adds it at the end
                appData.store();
            });
        }
        return productInputFieldListTile(entry, onTextSubmittedCallback, removeEntryCallback);
    }

}
