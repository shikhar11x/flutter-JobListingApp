import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';

enum JobType { active, archived }

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'https://api.wraeglobal.com/roleRouter';

  Future<List<Job>> fetchJobs(JobType type) async {
    final endpoint = type == JobType.active
        ? '$_baseUrl/getActiveRoles'
        : '$_baseUrl/getArchivedRoles';

    try {
      final response = await http
          .get(Uri.parse(endpoint))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw ApiException('Server error: ${response.statusCode}');
      }

      final decoded = json.decode(response.body);
      final List<dynamic> rolesJson = decoded['roles'] ?? [];

      return rolesJson
          .map((e) => Job.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw ApiException('Received malformed data from server.');
    } catch (e, stacktrace) {
      print("DEBUG ERROR: $e");
      print("DEBUG STACKTRACE: $stacktrace");
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}
