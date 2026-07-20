import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/app/widget/custom_textfield.dart';

import '../../alldata/models/material_response.dart';
import 'order_material_item.dart';

class OrderMaterialRow extends StatelessWidget {

  final OrderMaterialItem item;
  final List<MaterialData> materials;
  final List<String> selectedMaterialIds;
  final bool showDivider;
  final VoidCallback? onDelete;
  final Function(MaterialData?) onMaterialChanged;
  final Function(String) onQtyChanged;

  const OrderMaterialRow({
    super.key,
    required this.item,
    required this.materials,
    required this.showDivider,
    required this.selectedMaterialIds,
    required this.onDelete,
    required this.onMaterialChanged,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final availableMaterials = materials.where((material) {
      // Keep the currently selected material visible
      if (material.id.toString() == item.materialId) {
        return true;
      }

      // Hide materials already selected elsewhere
      return !selectedMaterialIds.contains(material.id.toString());
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
Row(children: [
  Expanded(child:Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
        /// Material
        CustomText(
          "Material",
        //txtColor: AppColors.navyBlue,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<MaterialData>(
          value: availableMaterials.any(
                (e) => e.id.toString() == item.materialId,
          )
              ? availableMaterials.firstWhere(
                (e) => e.id.toString() == item.materialId,
          )
              : null,

          isExpanded: true,

          decoration: InputDecoration(
            hintText: "Select Material",
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
          ),

          items: availableMaterials.map(
                (e) => DropdownMenuItem<MaterialData>(
              value: e,
              child: CustomText(e.materialName ?? ""),
            ),
          ).toList(),

          onChanged: !item.isEditable?null:(value) {
            onMaterialChanged(value);

            if (value != null) {
              item.availableQty = value.totalQty ?? 0;

              int qty = int.tryParse(item.qtyController.text) ?? 1;

              if (item.availableQty <= 0) {
                qty = 0;
              } else {
                if (qty <= 0) {
                  qty = 1;
                }

                if (qty > item.availableQty) {
                  qty = item.availableQty;
                }
              }

              item.qtyController.text = qty.toString();

              item.qtyController.selection = TextSelection.fromPosition(
                TextPosition(
                  offset: item.qtyController.text.length,
                ),
              );

              onQtyChanged(item.qtyController.text);
            }
          },
        ),
  ],)),
  const SizedBox(width: 16),
  /// Delete Button
  if (onDelete != null && item.isEditable)
    Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(
          "Remove",
          //txtColor: AppColors.navyBlue,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onDelete,
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.red.withOpacity(.2),
              ),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
              size: 22,
            ),
          ),
        ),
      ],
    ),
    ]),

        const SizedBox(height: 18),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Quantity
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "Quantity",
                    //txtColor: AppColors.navyBlue,
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  CustomTextField(
                    readOnly: !item.isEditable,
                    controller: item.qtyController,
                    keyboardType: TextInputType.number,
                    hintText: "Qty",
                    onChanged: (value) {
                      if (value.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: CustomText("Quantity must be greater than 0"),
                          ),
                        );
                        return;
                      }

                      final qty = int.tryParse(value);

                      if (qty == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: CustomText("Quantity must be greater than 0"),
                          ),
                        );
                        return;
                      }

                      if (qty == 0) {
                        item.qtyController.clear();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: CustomText("Quantity must be greater than 0"),
                          ),
                        );
                        return;
                      }

                      if (qty > item.availableQty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: CustomText(
                              "Maximum available quantity is ${item.availableQty}",
                            ),
                          ),
                        );
                        return;
                      }

                      onQtyChanged(value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            /// Used Qty
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "Used",
                    //txtColor: AppColors.navyBlue,
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  CustomTextField(
                    readOnly: !item.isUsedEditable,
                    controller: item.usedController,
                    keyboardType: TextInputType.number,
                    hintText: "Used Qty",
                    onChanged: (value) {
                      if (value.isEmpty) {
                        return;
                      }

                      final usedQty = int.tryParse(value);
                      final orderQty = int.tryParse(item.qtyController.text) ?? 0;

                      if (usedQty == null) {
                        return;
                      }

                      if (usedQty < 0) {
                        item.usedController.text = "0";
                        item.usedController.selection = TextSelection.fromPosition(
                          TextPosition(offset: item.usedController.text.length),
                        );
                        return;
                      }

                      if (usedQty > orderQty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: CustomText(
                              "Used quantity cannot be greater than ordered quantity ($orderQty).",
                            ),
                          ),
                        );

                        item.usedController.text = orderQty.toString();
                        item.usedController.selection = TextSelection.fromPosition(
                          TextPosition(offset: item.usedController.text.length),
                        );
                      }
                    },
                  ),
                ],
              ),
            ), /// Available Stock
              const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "Available",
                    //txtColor: AppColors.navyBlue,
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    height: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: item.availableQty > 0
                          ? Colors.green.withOpacity(.08)
                          : Colors.red.withOpacity(.08),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: item.availableQty > 0
                            ? Colors.green.withOpacity(.25)
                            : Colors.red.withOpacity(.25),
                      ),
                    ),
                    child: CustomText(
                      "${item.availableQty}",
                      style: TextStyle(
                        color: item.availableQty > 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}