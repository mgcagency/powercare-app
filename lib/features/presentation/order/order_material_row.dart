import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/widget/custom_textfield.dart';

import '../../alldata/models/material_response.dart';
import 'order_material_item.dart';

class OrderMaterialRow extends StatelessWidget {

  final OrderMaterialItem item;

  final List<MaterialData> materials;

  final bool showDivider;

  final VoidCallback onDelete;

  final Function(MaterialData?) onMaterialChanged;

  final Function(String) onQtyChanged;

  const OrderMaterialRow({
    super.key,
    required this.item,
    required this.materials,
    required this.showDivider,
    required this.onDelete,
    required this.onMaterialChanged,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [

        Padding(

          padding: const EdgeInsets.only(right: 10,top: 10,left: 10,
            bottom: 10,
          ),

          child: Row(

            crossAxisAlignment:
            CrossAxisAlignment.center,

            children: [

              Expanded(

                flex: 5,

                child:
    Builder(
    builder: (_) {
      print("Dropdown Items = ${materials.length}");

      return DropdownButtonFormField<MaterialData>(

        value: materials.any(
                (e) =>
            e.id.toString() ==
                item.materialId)
            ? materials.firstWhere(
                (e) =>
            e.id.toString() ==
                item.materialId)
            : null,

        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),

        hint: const Text(
          "Material",
        ),

        items: materials
            .map(
              (e) =>
              DropdownMenuItem(
                value: e,
                child: Text(
                  e.materialName ?? "",
                ),
              ),
        )
            .toList(),

        // onChanged: onMaterialChanged,
        onChanged: (value) {
          print("Selected = ${value?.materialName}");

          onMaterialChanged(value);

          if (value != null) {
            item.availableQty = value.totalQty ?? 0;

            if (item.qtyController.text.isEmpty ||
                item.qtyController.text == "0") {
              item.qtyController.text = "1";
            }
          }
        },
      );

    })
              ),

              const SizedBox(width: 10),

              Expanded(

                flex: 2,

                child: CustomTextField(

                  controller:
                  item.qtyController,

                  keyboardType:
                  TextInputType.number,

                  hintText: "Qty",

/*
                  onChanged: (value) {

                    int qty =
                        int.tryParse(value) ?? 1;

                    int stock =
                        item.availableQty;

                    if (qty <= 0) {

                      item.qtyController.text =
                      "1";

                      item.qtyController.selection =
                          TextSelection.fromPosition(
                            TextPosition(
                              offset: item
                                  .qtyController
                                  .text
                                  .length,
                            ),
                          );

                    } else if (qty > stock &&
                        stock > 0) {

                      item.qtyController.text =
                          stock.toString();

                      item.qtyController.selection =
                          TextSelection.fromPosition(
                            TextPosition(
                              offset: item
                                  .qtyController
                                  .text
                                  .length,
                            ),
                          );

                    }

                    onQtyChanged(
                      item.qtyController.text,
                    );

                  },
*/
                  onChanged: (value) {

                    int qty = int.tryParse(value) ?? 1;

                    if (qty <= 0) {
                      qty = 1;
                    }

                    if (item.availableQty > 0 &&
                        qty > item.availableQty) {

                      qty = item.availableQty;
                    }

                    item.qtyController.text = qty.toString();

                    item.qtyController.selection =
                        TextSelection.fromPosition(
                          TextPosition(
                            offset: item.qtyController.text.length,
                          ),
                        );

                    onQtyChanged(item.qtyController.text);

                  },
                ),

              ),

              const SizedBox(width: 8),

              IconButton(

                onPressed: onDelete,

                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),

              ),

            ],

          ),

        ),

        if (showDivider)

          Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),

      ],

    );

  }

}