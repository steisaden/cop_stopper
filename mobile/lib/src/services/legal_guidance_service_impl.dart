import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/src/models/legal_guidance_model.dart';

/// Interface for legal guidance service
abstract class LegalGuidanceService {
  Future<List<LegalGuidanceItem>> getLegalGuidanceByLocation(double latitude, double longitude);
  Future<List<LegalGuidanceItem>> getLegalGuidanceByJurisdiction(String jurisdiction);
  Future<List<LegalGuidanceItem>> getLegalGuidanceByScenario(String scenario);
  Future<LegalGuidanceItem?> getLegalGuidanceById(String id);
}

/// Implementation of legal guidance service
class LegalGuidanceServiceImpl implements LegalGuidanceService {
  final String _baseUrl;
  final http.Client _httpClient;

  LegalGuidanceServiceImpl(this._baseUrl, this._httpClient);

  @override
  Future<List<LegalGuidanceItem>> getLegalGuidanceByLocation(
      double latitude, double longitude) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/legal/guidance?lat=$latitude&lng=$longitude'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LegalGuidanceItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load legal guidance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching legal guidance: $e');
    }
  }

  @override
  Future<List<LegalGuidanceItem>> getLegalGuidanceByJurisdiction(String jurisdiction) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/legal/guidance?jurisdiction=$jurisdiction'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LegalGuidanceItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load legal guidance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching legal guidance: $e');
    }
  }

  @override
  Future<List<LegalGuidanceItem>> getLegalGuidanceByScenario(String scenario) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/legal/guidance?scenario=$scenario'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LegalGuidanceItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load legal guidance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching legal guidance: $e');
    }
  }

  @override
  Future<LegalGuidanceItem?> getLegalGuidanceById(String id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/legal/guidance/$id'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return LegalGuidanceItem.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load legal guidance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching legal guidance: $e');
    }
  }
}