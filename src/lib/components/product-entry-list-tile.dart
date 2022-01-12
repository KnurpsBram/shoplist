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

ListTile productEntryListTile(
    ProductEntry productEntry,
    Function onTextSubmittedCallback,
    Function toggleCheckBoxCallback
) {
// ListTile productEntryListTile(ProductEntry productEntry) {
    return ListTile(
        key: ValueKey(productEntry.id),
        title: TextField(
            controller: TextEditingController(
                text: productEntry.text,
            ),
            style: TextStyle(
                fontSize: 20.0,
                color: productEntry.isCheckedOff ? Colors.grey[350] : Colors.black
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
            ),
            onSubmitted: (submittedText) {
                onTextSubmittedCallback(productEntry, submittedText);
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
                    // onPressed: () {
                    //     setState( () {
                    //         appData.needsList.remove(productEntry);
                    //         appData.store();
                    //     });
                    // }
                ),
            ],
        ),
        trailing: IconButton(
            padding: EdgeInsets.all(4.0),
            constraints: BoxConstraints(),
            icon: Icon(productEntry.isCheckedOff ? Icons.check_box_outlined : Icons.check_box_outline_blank),
            onPressed: () {
                toggleCheckBoxCallback(productEntry);
                // setState( () {
                //     productEntry.isCheckedOff = !productEntry.isCheckedOff;
                //     appData.store();
                // });
            }
        )
    );
}
