import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_button.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';

import '../../../app/widget/helper.dart';
import '../../alldata/api_repository/contact_repository.dart';
import '../../alldata/api_repository/material_repository.dart';
import '../../alldata/models/contact_book_model.dart';
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

  //new code
  List<ContactBookData> supplierList = [];
  ContactBookData? selectedSupplier;
  final ContactRepository contactRepository = ContactRepository();

  Future<void> loadSuppliers() async {
    try {
      final response = await contactRepository.getContactList(
        page: 1,
        search: "",
      );

      final data = response["contactLists"]["data"] as List;

      supplierList =
          data.map((e) => ContactBookData.fromJson(e)).toList();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
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
    loadSuppliers(); // <-- Add this

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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: "Order Materials"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Job Summary Card
            _buildHeroCard(),

            const SizedBox(height: 24),

            // 2. Section Header for Materials
            SectionHeaderCard(
              icon: Icons.inventory_2_outlined,
              title: "Order Materials",
              child: Column(
                children: [

                  Row(
                    children: [

                      Expanded(
                        child: CustomText(
                          "Select materials required for this job.",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomText(
                          "${materials.length} Items",
                          style: AppTextStyles.bodyExtraSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: materials.length,
                    itemBuilder: (_, index) {
                      return _buildMaterialEntryCard(index);
                    },
                  ),

                  const SizedBox(height: 10),

                 Container(
                     margin: EdgeInsets.symmetric(horizontal: 30),
                     child:_buildAddMaterialCard()),
                ],
              ),
            ),


            const SizedBox(height: 40),

            // 5. Final Action Buttons (Not sticky, scrolls with content)
            Row(
              children: [

                Expanded(
                  flex: 2,
                  child: CustomButton(
                    title: isSubmitting ? "Processing..." : "Order Material",
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : submitRaisePO,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

// ── MODERN MATERIAL ENTRY CARD ──────────────────────────────────────
  Widget _buildMaterialEntryCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all( 10),
      decoration: BoxDecoration(
        color: Colors.white,
borderRadius: BorderRadius.circular(20),
border: Border.all(color: Colors.black12)
      ),
      child:

          OrderMaterialRow(
            item: materials[index],
            materials: materialStockList,
            showDivider: false,
            selectedMaterialIds: materials
                .where((e) => e.materialId != null && e.materialId!.isNotEmpty)
                .map((e) => e.materialId!)
                .toList(),
            onDelete: materials.length > 1
                ? () {
              setState(() {
                materials[index].dispose();
                materials.removeAt(index);
              });
            }
                : null,
            onMaterialChanged: (value) {
              setState(() {
                materials[index].materialId = value?.id.toString();
                materials[index].materialName = value?.materialName;
                materials[index].availableQty =
                    value?.totalQty ?? 0;
              });
            },
            onQtyChanged: (value) {},
          ),

    );
  }
  Widget _buildAddMaterialCard() {

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            materials.add(OrderMaterialItem());
          });
        },
        icon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          "Add Material",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.only(top: 4, left: 1, right: 1, bottom: 1),
      decoration: BoxDecoration(
        color: Color(
          int.parse(
           widget.job.jobTypeStatus?.colorCode?.replaceAll("#", "0xFF") ??
                "0xFF000000",
          ),
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        CustomText(
                          widget.job.jobName ?? "",
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),

                        const SizedBox(height: 4),

                        CustomText(
                          "Job #${widget.job.jobNumber}",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [

                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 15,
                          color: AppColors.primary,
                        ),

                        const SizedBox(width: 6),

                        CustomText(
                          "${materials.length} Items",
                          style: AppTextStyles.bodyExtraSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [

                  Expanded(
                    child: _miniInfo(
                      Icons.tag,
                      "Customer PO",
                      poController.text.isEmpty
                          ? "-"
                          : poController.text,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child:
                    _miniInfo(
                      Icons.location_on_outlined,
                      "Site",
                      widget.job.jobLocation ?? "-",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
        //new code
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Supplier Email",
                    style: AppTextStyles.bodyExtraSmall.copyWith(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 6),

                  DropdownButtonFormField<ContactBookData>(
                    value: selectedSupplier,
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    items: supplierList.map((supplier) {
                      return DropdownMenuItem<ContactBookData>(
                        value: supplier,
                        child: Text(
                          supplier.email ?? "",
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedSupplier = value;

                        emailController.text = value?.email ?? "";
                      });
                    },
                  ),
                ],
              ),
        /*      _miniInfo(
                Icons.email_outlined,
                "Email",
                emailController.text.isEmpty
                    ? "-"
                    : emailController.text,
              ),*/

            ],
          ),
        ),
      ),
    );
  }
  Widget _miniInfo(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 18,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              CustomText(
                title,
                style: AppTextStyles.bodyExtraSmall.copyWith(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 2),

              CustomText(
                value,
                maxLines: 2,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                label,
                style: AppTextStyles.bodyExtraSmall.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              CustomText(
                value.isEmpty ? "Not Specified" : value,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
