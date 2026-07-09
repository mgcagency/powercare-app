import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';

import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../../app/widget/custom_text.dart';
import '../../alldata/api_repository/material_repository.dart';
import '../../alldata/models/material_response.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final MaterialRepository repository = MaterialRepository();

  List<MaterialData> materials = [];

  bool isLoading = false;
  int selected = 0; // 0 = Stock, 1 = Purchase

  @override
  void initState() {
    super.initState();

    fetchMaterials();
  }

  Future<void> fetchMaterials() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (selected == 0) {
        final response = await repository.getStockList();

        print("STOCK RESPONSE => $response");

        final list = response["material_lists"]["data"];

        print("STOCK LIST => $list");

        materials = list
            .map<MaterialData>((e) => MaterialData.fromJson(e))
            .toList();
      } else {
        final response = await repository.getPurchaseList();

        print("PURCHASE RESPONSE => $response");

        final list = response["purchase_material_lists"]["data"];

        print("PURCHASE LIST => $list");

        materials = list
            .map<MaterialData>((e) => MaterialData.fromJson(e))
            .toList();
      }

      setState(() {});
    } catch (e) {
      print("Material Error => $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBar(title: "Materials"),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / 2;

                    return Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          left: selected * tabWidth,
                          top: 4,
                          bottom: 4,
                          child: Container(
                            width: tabWidth - 4,
                            decoration: BoxDecoration(
                              color: AppColors.navyBlue,
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            _tabButton("Stock", 0),

                            _tabButton("Purchase", 1),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: selected == 0 ? _buildStockView() : _buildPurchaseView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final active = selected == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          if (selected != index) {
            setState(() {
              selected = index;
            });
            fetchMaterials();

            // API Call
            // fetchMaterials();
          }
        },
        child: Center(
          child: CustomText(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: active ? Colors.white : Colors.black87,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
/*        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
            ),
            child: CustomText(text),
          ),
        ),*/
      ),
    );
  }

  Widget _buildStockView() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (materials.isEmpty) {
      return const Center(child: CustomText("No Materials Found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final item = materials[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: const Icon(Icons.inventory),
            ),

            title: CustomText(item.materialName ?? ""),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(item.supplierName ?? ""),

                CustomText("Qty : ${item.totalQty ?? 0}"),
              ],
            ),

            trailing: CustomText(
              "£${item.totalPrice ?? "0"}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPurchaseView() {
    return ListView.builder(
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final item = materials[index];

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: const Icon(Icons.inventory),
            ),

            title: CustomText(
              item.materialName ?? "",
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),

            subtitle: CustomText(
              item.supplierName ?? "",
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey,
              ),
            ),

            trailing: CustomText(
              "Qty : ${item.totalQty ?? 0}",
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      /*    child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: const Icon(Icons.inventory),
            ),
            title: CustomText(item.materialName ?? ""),

            subtitle: CustomText(item.supplierName ?? ""),

            trailing: CustomText("Qty : ${item.totalQty ?? 0}"),
            *//*CustomText(
                "£${item.totalPrice ?? "0"}",
              ),*//*
          ),*/
        );
      },
    );
  }
}
