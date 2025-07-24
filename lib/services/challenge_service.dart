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

  static Future<Challenge?> fetchChallengeById(String challengeId) async {
    try {
      final url = '$_baseUrl$challengeId';
      debugPrint('🌐 Fetching challenge from: $url');
      
      final response = await http.get(Uri.parse(url));
      
      debugPrint('🌐 Challenge API Response: ${response.statusCode}');
      debugPrint('🌐 Challenge API Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['challenge'] != null) {
          final challenge = Challenge.fromJson(data['challenge']);
          debugPrint('✅ Challenge parsed: ${challenge.content}');
          return challenge;
        } else {
          debugPrint('❌ No challenge data in response');
        }
      } else {
        debugPrint('❌ Challenge API failed with status: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching challenge by ID: $e');
      // Return null instead of throwing to handle gracefully
      return null;
    }
  }
}
