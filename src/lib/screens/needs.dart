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

class NeedsScreen extends StatefulWidget {
    AppData appData;

    NeedsScreen(this.appData);

    @override
    NeedsScreenState createState() => NeedsScreenState(appData);
}

class NeedsScreenState extends State<NeedsScreen> {
    /// The page where the user crafts his/her shopping list based on what he/she needs
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

    AppData appData;

    NeedsScreenState(this.appData);

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
                title: Text("Needs"),
            ),
            body: ReorderableListView( // TODO: you need to long-press before reordering which is soooooo slow, make the press time shorter somehow: https://github.com/flutter/flutter/issues/25065
                onReorder: (oldIndex, newIndex) {
                    setState(() {
                        appData.needsList = reOrderList(appData.needsList, oldIndex, newIndex);
                        appData.store();
                    });
                },
                children: [for (final entry in appData.needsList) buildRow(entry)]
            )
        );
    }

    Widget buildRow(Entry entry) {
        switch (entry.runtimeType) {
            case ProductEntry:
                return buildProductEntryRow(entry);
            case HeaderEntry:
                return buildHeaderEntryRow(entry);
            case ProductInputField:
                return buildProductInputFieldRow(entry);
            case HeaderInputField:
                return buildHeaderInputFieldRow(entry);
        }
    }

    Widget buildProductEntryRow(ProductEntry entry) {
        void onTextSubmittedCallback(String submittedText) {
             setState( () {
                 entry.text = submittedText;

                 // if (!appData.routeList.contains(entry.reducedProductName())) {
                 //     appData.routeList.add(entry.reducedProductName());
                 // }

                 // TODO: don't double-add in the routeList
                 appData.routeList.add(RouteEntry(text: reduceProductName(submittedText)));

                 appData.needsList = reOrderList(
                     appData.needsList,
                     appData.needsList.indexWhere((ele) => ele is ProductInputField), // oldIndex
                     appData.needsList.indexOf(entry) + 1 // newIndex
                 );
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

    Widget buildHeaderEntryRow(HeaderEntry entry) {
        void onTextSubmittedCallback(submittedText) {
            setState( () {
                entry.text = submittedText;
                appData.needsList = reOrderList(
                    appData.needsList,
                    appData.needsList.indexWhere((ele) => ele is ProductInputField), // oldIndex
                    appData.needsList.indexOf(entry) + 1 // newIndex
                );
                appData.store();
            });
        }
        void removeEntryCallback() {
            setState( () {
                appData.needsList.remove(entry);
                appData.store();
            });
        }
        return headerEntryListTile(entry, onTextSubmittedCallback, removeEntryCallback);
    }

    Widget buildProductInputFieldRow(ProductInputField entry) {
        void onTextSubmittedCallback(submittedText) {
            setState( () {
                appData.needsList.insert(appData.needsList.indexOf(entry), ProductEntry(text: submittedText));
                String reducedProductName = reduceProductName(submittedText);

                // if (!appData.routeList.contains(reducedProductName)) {
                //     appData.routeList.add(reducedProductName);
                // }

                // TODO: don't double-add in the routeList
                appData.routeList.add(RouteEntry(text: reduceProductName(submittedText)));

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

    Widget buildHeaderInputFieldRow(HeaderInputField entry) {
        void onTextSubmittedCallback(submittedText) {
            setState( () {
                appData.needsList.insert(appData.needsList.indexOf(entry), HeaderEntry(text: submittedText));
                appData.needsList = reOrderList( // move the productInputField to below the field that just got something submitted; that's where the user is now looking
                    appData.needsList,
                    appData.needsList.indexWhere((ele) => ele is ProductInputField), // oldIndex
                    appData.needsList.indexOf(entry) + 1 // newIndex
                );
                appData.needsList = reOrderList( // move the productInputField to below the field that just got something submitted; that's where the user is now looking
                    appData.needsList,
                    appData.needsList.indexOf(entry), // oldIndex
                    appData.needsList.indexOf(entry) + 2// newIndex
                );
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
        return headerInputFieldListTile(entry, onTextSubmittedCallback, removeEntryCallback);
    }
}
