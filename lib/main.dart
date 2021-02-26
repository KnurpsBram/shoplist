import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

// TODO: move this to a utilfile?
Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    print(directory.path);
    return directory.path;
}

Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
}


Future<File> writeContent(String stringToWrite) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString(stringToWrite);
}

Future<String> readContent() async {
    try {
        final file = await _localFile;
        // Read the file
        String contents = await file.readAsString();
        return contents;
    } catch (e) {
        // If there is an error reading, return a default String
        return 'Error';
    }
}

String reduceProductName(String productName) {
    return productName.replaceAll("\\d", "").toLowerCase(); // remove numbers and put to lowercase TODO: remove stuff between parentheses
}



class ShopListEntry{
    final String productName;
    bool checkedOff;

    ShopListEntry({ @required this.productName, this.checkedOff=false});

    ShopListEntry.fromJson(Map<String, dynamic> json):
        productName = json['productName'],
        checkedOff  = json['checkedOff']
    ;

    Map<String, dynamic> toJson() => {
        'productName' : productName,
        'checkedOff'  : checkedOff
    };
}

class AppData{
    static final AppData _appData = new AppData._internal();

    List _supermarket_order = ["bananas", "bread", "onion", "paprika", "courgette", "eggs"];

    var _shopping_list = [
        ShopListEntry(productName: "paprika"),
        ShopListEntry(productName: "courgette"),
        ShopListEntry(productName: "onion"),
    ];


    void _storeAppDataToDisk() {
        String string_to_write = jsonEncode(_shopping_list.map((x) => x.toJson()).toList());
        print("###################################################################");
        print(string_to_write);
        /* writeContent(string_to_write); */
    }

    factory AppData() {
        return _appData;
    }

    AppData._internal();

}

final appData = AppData();

class MyApp extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title : 'ShopList',
            home  : MyStatefulWidget()
        );
    }
}

// This is main widget that holds BottomNavigationBar and determines what is shown in the main body
class MyStatefulWidget extends StatefulWidget {
    MyStatefulWidget({Key key}) : super(key: key);

    @override
    _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {

    // START TEMP
    // TODO: use this instead of that appdata object?
    @override
    void initState() {
        super.initState();
        readContent().then((String value) {
            setState(() {
                print("##########################################################");
                print(value);
                appData._shopping_list = jsonDecode(value).map<ShopListEntry>((x) => ShopListEntry.fromJson(x)).toList();
            });
        });
    }
    // END TEMP

    int _selectedIndex = 0;
    static TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    List<Widget> _widgetOptions = <Widget>[
        ShopList(sort_style: "home"),
        ShopList(sort_style: "supermarket"),
    ];

    void _onItemTapped(int index) {
        setState(() {
            _selectedIndex = index;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Center(
                child: _widgetOptions.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart),
                        label: 'Supermarket',
                    ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.amber[800],
                onTap: _onItemTapped,
            ),
        );
    }

}

class ShopList extends StatefulWidget {
    final String sort_style; // this value here is determined by how you call myWidget=ShopList(sort_style='x')

    ShopList({ Key key, this.sort_style}): super(key: key);

    @override
    _ShopListState createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {

    @override
    Widget build(BuildContext context) {

        var _list_to_show;
        switch (widget.sort_style) {
            case "home":
                _list_to_show = List.from(appData._shopping_list);
                break;
            case "supermarket":
                _list_to_show = List.from(appData._shopping_list);
                _list_to_show.sort((a, b) => appData._supermarket_order.indexOf(reduceProductName(a.productName)) - appData._supermarket_order.indexOf(reduceProductName(b.productName)));
                break;
        }

        void _updateMyItems(int oldIndexHome, int newIndexHome) {
            if ( oldIndexHome != newIndexHome ) {
                switch (widget.sort_style) {
                    case "home":
                        ShopListEntry entry = appData._shopping_list.removeAt(oldIndexHome);
                        if (oldIndexHome < newIndexHome) newIndexHome -= 1; // removing the item at oldIndex will shorten the list by 1.
                        appData._shopping_list.insert(newIndexHome, entry);
                        break;
                    case "supermarket":
                        int oldIndexSupermarket = appData._supermarket_order.indexOf(reduceProductName(_list_to_show[oldIndexHome].productName));
                        int newIndexSupermarket = (newIndexHome == _list_to_show.length) ? appData._supermarket_order.length : appData._supermarket_order.indexOf(reduceProductName(_list_to_show[newIndexHome].productName));
                        String reduced_productName = appData._supermarket_order.removeAt(oldIndexSupermarket);
                        if (oldIndexSupermarket < newIndexSupermarket) newIndexSupermarket -= 1;
                        appData._supermarket_order.insert(newIndexSupermarket, reduced_productName);
                        break;
                }
                appData._storeAppDataToDisk();
            }
        }

        return Scaffold(
            appBar: AppBar(
              /* title: Text("My Shopping List"), */
              title: Text(widget.sort_style),
            ),
            body: ListView(
                children: <Widget>[
                    Container(
                        height: MediaQuery.of(context).size.height - 210, // TODO: make depend on the height of the body of the scaffold, not that of the entire screen
                        child: ReorderableListView(
                            onReorder: (oldIndex, newIndex) {
                                setState(() {
                                    _updateMyItems(oldIndex, newIndex);
                                });
                            },
                            children: [
                                for (final entry in _list_to_show) _buildRow(entry)
                            ]
                        )
                    ),
                    ListTile(
                        title: TextField(
                            controller: TextEditingController(),
                            onSubmitted: (entry) {
                                setState( () {
                                    appData._shopping_list.add(ShopListEntry(productName: entry));
                                    if (!appData._supermarket_order.contains(entry)) {
                                        appData._supermarket_order.add(entry);
                                    }
                                });
                            },
                            decoration: new InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                hintText: "bananas, eggs, bread...", //'Hold to make new entry...',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 10.0)
                            ),
                        ),
                    )
                ]
            )
        );
    }

    Widget _buildRow(ShopListEntry entry) {
        return ListTile(
            key: ValueKey(entry.productName),
            title: Text(
                entry.productName,
                style: TextStyle(
                    fontSize: 18.0,
                    color   : entry.checkedOff ? Colors.grey : Colors.black
                )
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            dense: true,
            leading: Icon(Icons.drag_handle),
            trailing: Icon( entry.checkedOff ? Icons.check_box_outlined : Icons.check_box_outline_blank),
            onTap: () {
                setState( () {
                    entry.checkedOff = !entry.checkedOff;
                });
            }
        );
    }
}
