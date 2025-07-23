import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session_summary.dart';
import '../constants/globals.dart';
import 'package:flutter/foundation.dart';

Future<List<SessionSummary>> fetchUserSessions(String userId) async {
  final url = '$apiBaseUrl/chatbot/sessions/user/$userId';
  debugPrint('DEBUG: Fetching sessions from: $url');
  
  try {
    final response = await http.get(Uri.parse(url));
    debugPrint('DEBUG: Response status: ${response.statusCode}');
    debugPrint('DEBUG: Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      debugPrint('DEBUG: Parsed response type: ${responseData.runtimeType}');
      debugPrint('DEBUG: Parsed response: $responseData');
      
      List<dynamic> sessionsData;
      
      // Check if response is directly an array or has a 'sessions' key
      if (responseData is List) {
        sessionsData = responseData;
      } else if (responseData is Map && responseData.containsKey('sessions')) {
        sessionsData = responseData['sessions'];
      } else {
        debugPrint('DEBUG: Unexpected response structure');
        return [];
      }
      
      debugPrint('DEBUG: Sessions data: $sessionsData');
      debugPrint('DEBUG: Sessions data type: ${sessionsData.runtimeType}');
      
      return sessionsData.map((json) {
        debugPrint('DEBUG: Processing session JSON: $json');
        return SessionSummary.fromJson(json as Map<String, dynamic>);
      }).toList();
      
    } else {
      throw Exception('Failed to load sessions: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    debugPrint('DEBUG: Exception in fetchUserSessions: $e');
    rethrow;
  }
}