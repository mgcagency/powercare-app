import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class MaterialRepository {

  Future<dynamic> getStockList() async {

    final response = await ApiClient.get(
      ApiEndpoints.materialList,

     // "/material/list",
    );

    print(
      "Stock Response => ${response.data}",
    );

    return response.data;
  }

  Future<dynamic> getPurchaseList() async {

    final response = await ApiClient.get(
      ApiEndpoints.materialPurchaseList,

      //"/material/purchase-list",
    );

    print(
      "Purchase Response => ${response.data}",
    );

    return response.data;
  }
}