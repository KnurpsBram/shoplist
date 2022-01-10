import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/models/appdata.dart';
import 'package:shoplist/models/shop-list-entry.dart';
import 'package:shoplist/util/fs.dart';
import 'package:shoplist/util/misc.dart';

class WalkScreen extends StatefulWidget {
    AppData appData;

    WalkScreen(this.appData);

    @override
    WalkScreenState createState() => WalkScreenState(appData);
}

class WalkScreenState extends State<WalkScreen> {
    /// The page where the user looks when walking through the supermarket
    ///
    /// It consists of the product entries of the needsList, ordered according to the order of the routeList
    ///
    /// There are no headers
    ///
    /// TODO: Temporarily disabled reordering this list.
    ///   When it is enabled, we need a smart way to reorder the supermarketOrder
    ///   if reordering in walkList is [a, b, c] -> [a, c, b] and supermarketOrder is [a, d, b, c], does it need to become [a, d, c, b] or [a, c, d, b]?
    ///   There was some logic for this in an older version of the app, see if mimicking that is appropriate
    ///
    /// TODO: allow ProductEntryField here, new entry should be added to homeList in a trivial position (bottom?)

    AppData appData;

    WalkScreenState(this.appData);

    @override
    void initState() {
        super.initState();
        appData.load().whenComplete(() {
            setState(() {});
        });
    }

    @override
    Widget build(BuildContext context) {
        var walkList;
        walkList = List.from(appData.needsList.where((x) => (x is ProductEntry)));
        walkList.sort((a, b) => appData.routeList.indexOf(reduceProductName(a.text)) - appData.routeList.indexOf(reduceProductName(b.text)) as int);

        return Scaffold(
            appBar: AppBar(
                title: Text("Walk (dragging tiles disabled...)"),
            ),
            body: ListView( // TODO: ReorderableListView
                children: [
                    for (final entry in walkList) buildRow(entry)
                ]
            )
        );
    }

    Widget buildRow(ProductEntry entry) {
        return ListTile(
            key: ValueKey(entry.id),
            title: TextField(
                controller: TextEditingController(
                    text: entry.text,
                ),
                style: TextStyle(
                    fontSize: 20.0,
                    color: entry.isCheckedOff ? Colors.grey[350] : Colors.black
                ),
                decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
                ),
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
