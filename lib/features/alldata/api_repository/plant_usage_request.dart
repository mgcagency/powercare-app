class PlantUsageRequest {
  final String jobId;
  final String cherrypickerUsed;
  final String hiredPlantSupplierName;
  final String hirePlantQtyPurchased;
  final String hirePlantQtyUsed;
  final String offHired;

  PlantUsageRequest({
    required this.jobId,
    required this.cherrypickerUsed,
    required this.hiredPlantSupplierName,
    required this.hirePlantQtyPurchased,
    required this.hirePlantQtyUsed,
    required this.offHired,
  });

  Map<String, dynamic> toJson() {
    return {
      "job_id": jobId,
      "cherrypicker_used": cherrypickerUsed,
      "hired_plant_supplier_name": hiredPlantSupplierName,
      "hire_plant_qty_purchased": hirePlantQtyPurchased,
      "hire_plant_qty_used": hirePlantQtyUsed,
      "off_hired": offHired,
    };
  }
}