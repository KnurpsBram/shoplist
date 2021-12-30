import 'dart:convert';

String reduceProductName(String productName) {
    productName = productName.replaceAll(RegExp("[0-9]"), "");
    productName = productName.toLowerCase();
    int i_start = productName.indexOf("(");
    int i_end   = productName.indexOf(")");
    if (i_start > 0 && i_end > 0) {
        productName = productName.replaceAll(productName.substring(i_start, i_end+1), "");
    }
    productName = productName.trim();
    return productName;
}

void jsonPrettyPrint( dynamic json ) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(json);
    print(prettyprint);
}
