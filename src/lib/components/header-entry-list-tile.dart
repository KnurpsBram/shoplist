import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import 'package:shoplist/models/header-entry.dart';

ListTile headerEntryListTile(
    HeaderEntry entry,
    Function onTextSubmittedCallback,
    Function removeEntryCallback,
) {
    return ListTile(
        key: ValueKey(entry.id),
        tileColor: Colors.grey, // TODO: this color looks ugly when the user drags the tile, see https://github.com/flutter/flutter/issues/45799
        title: TextField(
            controller: TextEditingController(
                text: entry.text,
            ),
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder  : InputBorder.none,
                contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
            ),
            onSubmitted: (submittedText) {
                onTextSubmittedCallback(submittedText);
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
                        removeEntryCallback();
                    }
                ),
            ],
        ),
    );
}
