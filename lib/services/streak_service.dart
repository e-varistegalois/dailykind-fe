import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/globals.dart';

class StreakService {
  static const String _baseUrl = '$apiBaseUrl/user';

  static Future<Map<String, dynamic>> getUserStreak({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$userId/streak'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch streak data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching streak: $e');
    }
  }
}
