import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/challenge.dart';
import '../constants/globals.dart';

class ChallengeService {
  static const String _baseUrl = '$apiBaseUrl/challenge/';
  static Future<Challenge?> fetchActiveChallenge() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['challenge'] != null) {
          return Challenge.fromJson(data['challenge']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching challenge: $e');
      throw Exception('Failed to load weekly challenge');
    }
  }
}
