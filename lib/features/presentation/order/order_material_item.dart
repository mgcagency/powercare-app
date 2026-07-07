import 'package:flutter/cupertino.dart';

class OrderMaterialItem {
  String? materialId;
  String? materialName;

  int availableQty;

  String markup;

  // NEW
  double unitPrice;
  double totalPrice;

  TextEditingController qtyController;
  TextEditingController usedController;

  OrderMaterialItem({
    this.materialId,
    this.materialName,
    this.availableQty = 0,
    this.markup = "1",
    this.unitPrice = 0.0,
    this.totalPrice = 0.0,
    TextEditingController? qtyController,
    TextEditingController? usedController,
  })  : qtyController =
      qtyController ?? TextEditingController(text: "1"),
        usedController =
            usedController ?? TextEditingController(text: "0");

  String get qty => qtyController.text;

  set qty(String value) {
    qtyController.text = value;
  }

  void calculateTotal() {
    final qty = int.tryParse(qtyController.text) ?? 0;
    totalPrice = qty * unitPrice;
  }

  void dispose() {
    qtyController.dispose();
    usedController.dispose();
  }
}