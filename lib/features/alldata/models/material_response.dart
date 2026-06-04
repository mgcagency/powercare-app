class MaterialData {

  int? id;
  String? materialName;
  String? supplierName;
  String? invoiceNumber;
  String? description;
  int? totalQty;
  String? unitPrice;
  String? totalPrice;
  String? datePurchase;

  MaterialData.fromJson(
      Map<String,dynamic> json){

    id = json["id"];
    materialName =
    json["material_name"];
    supplierName =
    json["supplier_name"];
    invoiceNumber =
    json["invoice_number"];
    description =
    json["description"];
    totalQty =
    json["total_qty"];
    unitPrice =
    json["unit_price"];
    totalPrice =
    json["total_price"];
    datePurchase =
    json["date_purchase"];
  }
}