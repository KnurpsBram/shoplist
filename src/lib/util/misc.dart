import 'dart:convert';

String reduceProductName(String productName) {
    productName = productName.toLowerCase();
    productName = productName.replaceAll(RegExp('\\(.*?\\)'), ''); // ignore everything between parentheses
    productName = productName.replaceAll(RegExp("[^a-z]"), ""); // only letters, no numbers no symbols
    productName = productName.trim();
    return productName;
}

void jsonPrettyPrint( dynamic json ) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(json);
    print(prettyprint);
}

List reOrderList ( List myList, int oldIndex, int newIndex ) {
  if (oldIndex < newIndex) {
    newIndex -= 1;
  }
  myList.insert(newIndex, myList.removeAt(oldIndex));
  return myList;
}
