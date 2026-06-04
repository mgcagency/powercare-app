import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class ContactRepository {

  Future<dynamic> getContactList({
    required int page,
    String search = "",
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.contactList,
      parameters: {
        "page": page,
        "search": search,
      },
    );
    return response.data;
  }
}