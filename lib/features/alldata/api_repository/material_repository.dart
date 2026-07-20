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
  Future<dynamic> createRaisePO(
      Map<String, dynamic> body,
      ) async {

    final response = await ApiClient.postForm(
      ApiEndpoints.createRaisePO,
      body,
    );

    return response.data;
  }Future<dynamic> createRaisePOWithEmail(
      Map<String, dynamic> body,
      ) async {

    final response = await ApiClient.postForm(
      ApiEndpoints.createRaisePOWithEmail,
      body,
    );

    return response.data;
  }Future<dynamic> createRaisePOWithOutEmail(
      Map<String, dynamic> body,
      ) async {

    final response = await ApiClient.postForm(
      ApiEndpoints.createRaisePOWithOutEmail,
      body,
    );

    return response.data;
  }
}