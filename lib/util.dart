String reduceProductName(String productName) {
    return productName.replaceAll("\\d", "").toLowerCase(); // remove numbers and put to lowercase TODO: remove stuff between parentheses
}
