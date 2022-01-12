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
                children: [
                    for (final entry in appData.needsList) buildRow(entry)
                ]
            )
        );
    }

    void toggleCheckBoxCallback(ProductEntry productEntry) {
        setState( () {
            productEntry.toggleCheckBox();
            appData.store();
        });
    }

    void onTextSubmittedCallback(ProductEntry productEntry, String submittedText) {
          setState( () {
              productEntry.text = submittedText;
              String reducedProductName = reduceProductName(submittedText);
              if (!appData.routeList.contains(reducedProductName)) {
                  appData.routeList.add(reducedProductName);
              }
              appData.needsList = reOrderList( // move the productInputField to below the field that just got something submitted; that's where the user is now looking
                  appData.needsList,
                  appData.needsList.indexWhere((ele) => ele is ProductInputField), // oldIndex
                  appData.needsList.indexOf(productEntry) + 1 // newIndex
              );
              appData.store();
          });
    }

    Widget buildRow(Entry entry) {
        if (entry is ProductEntry) { // TODO: is switch-case possible here?
            return productEntryListTile(entry, onTextSubmittedCallback, toggleCheckBoxCallback);

        } else if (entry is ProductInputField) {
            return ListTile(
                key: ValueKey(entry.id),
                title: TextField(
                  controller: TextEditingController(
                      text: "",
                  ),
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
                      hintText: "tap to add new item",
                      hintStyle: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12.0,
                          color: Colors.grey,
                      )
                  ),
                  onSubmitted: (productName) {
                      setState( () {
                          appData.needsList.insert(appData.needsList.indexOf(entry), ProductEntry(id: Uuid().v1(), text: productName));
                          String reducedProductName = reduceProductName(productName);
                          if (!appData.routeList.contains(reducedProductName)) {
                              appData.routeList.add(reducedProductName);
                          }
                          appData.store();
                      });
                  },
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                dense: true,
                leading: Wrap(
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
                                    appData.needsList.remove(entry);
                                    appData.needsList.add(entry); // this adds it at the end
                                    appData.store();
                                });
                            }
                        ),
                    ],
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
                            appData.needsList = reOrderList( // move the productInputField to below the field that just got something submitted; that's where the user is now looking
                                appData.needsList,
                                appData.needsList.indexWhere((ele) => ele is ProductInputField), // oldIndex
                                appData.needsList.indexOf(entry) + 1 // newIndex
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
                                    appData.needsList.remove(entry);
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
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
                        hintText: "tap to add new header",
                        hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 12.0,
                        )
                    ),
                    onSubmitted: (text) {
                        setState( () {
                            appData.needsList.insert(appData.needsList.indexOf(entry), HeaderEntry(id: Uuid().v1(), text: text));
                            appData.needsList = reOrderList( // move the productInputField to below the field that just got something submitted; that's where the user is now looking
                                appData.needsList,
                                appData.needsList.indexWhere((ele) => ele is ProductInputField), // oldIndex
                                appData.needsList.indexOf(entry) // newIndex
                            );
                            appData.store();
                        });
                    },
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                dense: true,
                leading: Wrap(
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
                                    appData.needsList.remove(entry);
                                    appData.needsList.add(entry); // this adds it at the end
                                    appData.store();
                                });
                            }
                        ),
                    ],
                ),
            );
        } else {
            print("unsupported entry type");
        }
    }
}
