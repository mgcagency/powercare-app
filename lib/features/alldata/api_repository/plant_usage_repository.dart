import 'package:powercare_flutter/core/api/api_client.dart';
import 'package:powercare_flutter/core/api/api_endpoints.dart';
import 'package:powercare_flutter/features/alldata/api_repository/plant_usage_request.dart';

import '../models/plant_usage_response.dart';

class PlantUsageRepository {

  Future<PlantUsageResponse> createPlantUsage(
      PlantUsageRequest request,
      ) async {

    final response = await ApiClient.post(
      ApiEndpoints.createPlantUsage,
      request.toJson(),
    );

    return PlantUsageResponse.fromJson(response.data);
  }

}