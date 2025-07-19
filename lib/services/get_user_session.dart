import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session_summary.dart';
import '../constants/globals.dart';

Future<List<SessionSummary>> fetchUserSessions(String userId) async {
  final url = '$apiBaseUrl/chatbot/sessions/user/$userId';
  print('DEBUG: Fetching sessions from: $url');
  
  try {
    final response = await http.get(Uri.parse(url));
    print('DEBUG: Response status: ${response.statusCode}');
    print('DEBUG: Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('DEBUG: Parsed response type: ${responseData.runtimeType}');
      print('DEBUG: Parsed response: $responseData');
      
      List<dynamic> sessionsData;
      
      // Check if response is directly an array or has a 'sessions' key
      if (responseData is List) {
        sessionsData = responseData;
      } else if (responseData is Map && responseData.containsKey('sessions')) {
        sessionsData = responseData['sessions'];
      } else {
        print('DEBUG: Unexpected response structure');
        return [];
      }
      
      print('DEBUG: Sessions data: $sessionsData');
      print('DEBUG: Sessions data type: ${sessionsData.runtimeType}');
      
      return sessionsData.map((json) {
        print('DEBUG: Processing session JSON: $json');
        return SessionSummary.fromJson(json as Map<String, dynamic>);
      }).toList();
      
    } else {
      throw Exception('Failed to load sessions: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('DEBUG: Exception in fetchUserSessions: $e');
    rethrow;
  }
}