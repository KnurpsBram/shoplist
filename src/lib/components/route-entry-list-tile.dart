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

ListTile routeEntryListTile(
    RouteEntry routeEntry,
    Function onTextSubmittedCallback,
    Function removeEntryCallback,
) {
    return ListTile(
        key: ValueKey(routeEntry.id),
        title: TextField(
            controller: TextEditingController(
                text: routeEntry.text,
            ),
            style: TextStyle(
                fontSize: 20.0,
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
            ),
            onSubmitted: (submittedText) {
                onTextSubmittedCallback(submittedText);
            }
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
                        removeEntryCallback();
                    }
                ),
            ],
        )
    );
}
