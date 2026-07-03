import 'package:flutter/material.dart';

class OrderMaterialItem {
  String? materialId;
  String? materialName;

  int availableQty;

  String markup;

 // int? raisePoId;

  TextEditingController qtyController;

  OrderMaterialItem({
    this.materialId,
    this.materialName,
    this.availableQty = 0,
    this.markup = "1",
   // this.raisePoId,
    TextEditingController? qtyController,
  }) : qtyController =
      qtyController ?? TextEditingController(text: "1");

  String get qty => qtyController.text;

  set qty(String value) {
    qtyController.text = value;
  }

  void dispose() {
    qtyController.dispose();
  }
}