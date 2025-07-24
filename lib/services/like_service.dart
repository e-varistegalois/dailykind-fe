import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/globals.dart';

class LikeService {
  static Future<bool> toggleLike(String postId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/post/likes/$postId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}