import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_button.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/app/widget/custom_textfield.dart';

import '../../alldata/api_repository/material_repository.dart';
import '../../alldata/models/job_list_response.dart';
import '../../alldata/models/material_response.dart';
import 'order_material_item.dart';
import 'order_material_row.dart';

class OrderMaterialScreen extends StatefulWidget {
  final JobModel job;
  const OrderMaterialScreen({
    super.key,
    required this.job,
  });

  @override
  State<OrderMaterialScreen> createState() =>
      _OrderMaterialScreenState();
}

class _OrderMaterialScreenState
    extends State<OrderMaterialScreen> {
  List<MaterialData> materialStockList = [];
  final emailController = TextEditingController();
  final jobController = TextEditingController();
  final poController = TextEditingController();
  final MaterialRepository materialRepository = MaterialRepository();
  List<OrderMaterialItem> materials = [];
  bool isLoading = false;
  bool isSubmitting = false;
  Future<void> loadMaterials() async {

    try {

      final response = await materialRepository.getStockList();

      print("FULL RESPONSE = $response");

      print("Material Lists = ${response["material_lists"]}");

      print("Material Data = ${response["material_lists"]["data"]}");

      materialStockList.clear();

      final data = response["material_lists"]?["data"] as List? ?? [];

      print("DATA = $data");
      print("DATA LENGTH = ${data.length}");
      print("DATA LENGTH = ${data.length}");

      for (final item in data) {

        print(item);

        materialStockList.add(
          MaterialData.fromJson(item),
        );

      }

      print("Material Count = ${materialStockList.length}");

      for (final e in materialStockList) {
        print("Material => ${e.materialName}");
      }

      if (mounted) {
        setState(() {});
      }

    } catch (e) {
      print(e);
    }
  }
/*
  Future<void> submitRaisePO() async {
    if (materials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one material"),
        ),
      );
      return;
    }

    final Map<String, dynamic> body = {};

    body["job_id"] = widget.job.id.toString();
    body["customer_po_number"] = poController.text.trim();
    body["customer_name"] = widget.job.siteContactName ?? "";
    body["email"] = emailController.text.trim();

    for (int i = 0; i < materials.length; i++) {
      final item = materials[i];

      if ((item.materialId ?? "").isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please select material for row ${i + 1}"),
          ),
        );
        return;
      }

      if (item.qtyController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please enter quantity for row ${i + 1}"),
          ),
        );
        return;
      }

      body["purchase_material_id[$i]"] = item.materialId;
      body["material_name[$i]"] = item.materialName;
      body["qty[$i]"] = item.qtyController.text.trim();
      body["markup[$i]"] = item.markup;

      if (item.raisePoId != null) {
        body["relationdata_id[$i]"] = item.raisePoId.toString();
      }
    }

    try {
      final response =
      await materialRepository.createRaisePO(body);

      if (response["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Order Created Successfully"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Something went wrong"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
*/
/*
  Future<void> submitRaisePO() async {
    setState(() {
      isSubmitting = true;
    });
    if (materials.isEmpty) {
      return;
    }

    Map<String,dynamic> body={};

    body["job_id"]=widget.job.id.toString();

    body["customer_po_number"]=poController.text;

    body["customer_name"]=
        widget.job.siteContactName ?? "";

    body["email"]=emailController.text;

    for(int i=0;i<materials.length;i++){

      body["purchase_material_id[$i]"]=
          materials[i].materialId;

      body["material_name[$i]"]=
          materials[i].materialName;

      body["qty[$i]"]=
          materials[i].qtyController.text;

      body["markup[$i]"]=
          materials[i].markup;

      if(materials[i].raisePoId!=null){

        body["relationdata_id[$i]"]=
            materials[i].raisePoId.toString();

      }

    }

    try{

      final response=
      await materialRepository.createRaisePO(body);

      if(response["success"]==true){

        if(!mounted)return;

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text(
                response["message"]),

          ),

        );

        Navigator.pop(context,true);

      }

    }catch(e){

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(e.toString()),

        ),

      );

    }

  }
*/
  Future<void> submitRaisePO() async {

    if (materials.isEmpty) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    Map<String, dynamic> body = {};

    body["job_id"] = widget.job.id.toString();
    body["customer_po_number"] = poController.text;
    body["customer_name"] = widget.job.siteContactName ?? "";
    body["email"] = emailController.text;

    for (int i = 0; i < materials.length; i++) {

      body["purchase_material_id[$i]"] =
          materials[i].materialId;

      body["material_name[$i]"] =
          materials[i].materialName;

      body["qty[$i]"] =
          materials[i].qtyController.text;

      body["markup[$i]"] =
          materials[i].markup;

   /*   if (materials[i].raisePoId != null) {
        body["relationdata_id[$i]"] =
            materials[i].raisePoId.toString();
      }*/
    }

    try {

      final response =
      await materialRepository.createRaisePO(body);

      if (!mounted) return;

      if (response["success"] == true) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Success"),
          ),
        );

        Navigator.pop(context, true);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Something went wrong"),
          ),
        );
      }

    } catch (e) {

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }

    } finally {

      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }

    }
  }
  @override
  void initState() {
    super.initState();

    emailController.text = widget.job.email ?? "";
    jobController.text = widget.job.jobName ?? "";
   // poController.text = widget.job.quote?.quoteNumber ?? "";
    poController.text =
        widget.job.customerPoNumber ?? "";
    materials.add(
      OrderMaterialItem(),
    );
    loadMaterials();

  }

  @override
  void dispose() {
    emailController.dispose();
    jobController.dispose();
    poController.dispose();

    for (var item in materials) {
      item.dispose();
    }

    super.dispose();
  }

  Widget buildLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 8,
      ),
      child: CustomText(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: const CustomAppBar(
        title: "Order Materials",
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            buildMaterialTable(),

            const SizedBox(height: 20),

            Center(
              child: CustomButton(
                background: AppColors.primary,
                title: "Add More",
                onPressed: () {

                  setState(() {

                    materials.add(
                      OrderMaterialItem(),
                    );

                  });

                },
              ),
/*              ElevatedButton(
                onPressed: () {

                  setState(() {

                    materials.add(
                      OrderMaterialItem(),
                    );

                  });

                },
                child: const Text(
                  "Add More",
                ),
              ),*/
            ),

            buildLabel(
              "PO Number from Engineer",
            ),

            CustomTextField(
              controller: poController,
              readOnly: true,
            ),

            buildLabel(
              "Job Name",
            ),

            CustomTextField(
              controller: jobController,
              readOnly: true,
            ),

            buildLabel(
              "Email",
            ),

            CustomTextField(
              controller: emailController,
              readOnly: true,
            ),

            const SizedBox(height: 30),

            Row(

              children: [

                Expanded(

                  child:  CustomButton(
                    background: AppColors.primary,
                    title: "Back",
                    onPressed: () {
                      Navigator.pop(context);
                    },

                  ),


                ),

                const SizedBox(width: 15),

                Expanded(

                  child:CustomButton(
                    title: isSubmitting
                        ? "Ordering..."
                        : "Order",
                    onPressed: isSubmitting
                        ? null
                        : submitRaisePO,
                  )
                ),

              ],

            ),

            const SizedBox(height: 30),

          ],

        ),

      ),

    );

  }
  Widget buildMaterialTable() {

    return Column(

      children: [

        Container(

          padding: const EdgeInsets.all(12),

          decoration: const BoxDecoration(

            color: AppColors.primary,

            borderRadius: BorderRadius.only(

              topLeft: Radius.circular(8),

              topRight: Radius.circular(8),

            ),

          ),

          child: const Row(

            children: [

              Expanded(
                flex: 5,
                child: Text(
                  "Material Name",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),

              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    "Qty",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: 40,
              ),

            ],

          ),

        ),

        Container(

          decoration: BoxDecoration(

            border: Border.all(
              color: Colors.grey.shade300,
            ),

          ),

          child: ListView.builder(

            itemCount: materials.length,

            shrinkWrap: true,

            physics:
            const NeverScrollableScrollPhysics(),

            itemBuilder: (context, index) {

              return OrderMaterialRow(
                item: materials[index],
                materials: materialStockList,
                showDivider: index != materials.length - 1, // <-- ADD THIS
                onDelete: () {
                  setState(() {
                    if (materials.length > 1) {
                      materials[index].dispose();
                      materials.removeAt(index);
                    }
                  });
                },
                onMaterialChanged: (value) {
                  setState(() {
                    materials[index].materialId = value?.id.toString();
                    materials[index].materialName = value?.materialName;
                    materials[index].availableQty = value?.totalQty ?? 0;
                  });
                },
                onQtyChanged: (value) {},
              );
            },

          ),

        ),

      ],

    );

  }

}