import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:image_picker/image_picker.dart';
import '../constants/globals.dart';
import './challenge_service.dart';

// Custom exception for content moderation errors
class ContentModerationException implements Exception {
  final String message;
  ContentModerationException(this.message);
  
  @override
  String toString() => message; 
}

class PostService {
  static const String _baseUrl = '$apiBaseUrl/post';

  // Helper function to get MIME type from file extension
  static String _getMimeType(String filename) {
    final extension = filename.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        // Default to PNG if we can't determine
        return 'image/png';
    }
  }

  // Upload post with image (published status)
  static Future<Map<String, dynamic>> uploadPost({
    required String userId,
    required String challengeId,
    required String content,
    required dynamic image, // Can be File or XFile
  }) async {
    try {
      debugPrint('uploadPost called with:');
      debugPrint('- userId: $userId');
      debugPrint('- challengeId: $challengeId');
      debugPrint('- content: "$content"');
      debugPrint('- image type: ${image.runtimeType}');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload-post'),
      );

      // Add form data with PUBLISHED status
      request.fields['user_id'] = userId;
      request.fields['challenge_id'] = challengeId;
      request.fields['content'] = content;
      request.fields['status'] = 'PUBLISHED';
      
      debugPrint('Form fields: ${request.fields}');
      
      // Add image file - handle both File and XFile
      http.MultipartFile multipartFile;
      if (kIsWeb || image is XFile) {
        // Web or XFile
        final XFile xFile = image is XFile ? image : XFile(image.path);
        final bytes = await xFile.readAsBytes();
        final mimeType = _getMimeType(xFile.name);
        multipartFile = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: xFile.name,
          contentType: http_parser.MediaType.parse(mimeType),
        );
      } else {
        // Mobile/Desktop - File
        final mimeType = _getMimeType(image.path);
        multipartFile = await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: http_parser.MediaType.parse(mimeType),
        );
      }
      
      request.files.add(multipartFile);
      
      debugPrint('Multipart file added:');
      debugPrint('- field name: ${multipartFile.field}');
      debugPrint('- filename: ${multipartFile.filename}');
      debugPrint('- content type: ${multipartFile.contentType}');
      debugPrint('- length: ${multipartFile.length}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Upload Post Response: ${response.statusCode}');
      debugPrint('Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        final errorData = json.decode(responseBody);
        final message = errorData['message'] ?? 'Unknown error';
        throw ContentModerationException(message);
      }
    } catch (e) {
      if (e is ContentModerationException) {
        rethrow;
      }
      debugPrint('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  // Upload post with text only (published status)
  static Future<Map<String, dynamic>> uploadTextPost({
    required String userId,
    required String challengeId,
    required String content,
  }) async {
    try {
      debugPrint('uploadTextPost called with:');
      debugPrint('- userId: $userId');
      debugPrint('- challengeId: $challengeId');
      debugPrint('- content: "$content"');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload-post'),
      );

      // Add form data with PUBLISHED status
      request.fields['user_id'] = userId;
      request.fields['challenge_id'] = challengeId;
      request.fields['content'] = content; // Changed from 'text' to 'content'
      request.fields['status'] = 'PUBLISHED';
      
      debugPrint('Form fields: ${request.fields}');
      
      // No image file added for text-only posts

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Upload Text Post Response: ${response.statusCode}');
      debugPrint('Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        // Parse the error response and throw just the message
        final errorData = json.decode(responseBody);
        final message = errorData['message'] ?? 'Unknown error';
        // Throw a custom exception with just the message
        throw ContentModerationException(message);
      }
    } catch (e) {
      // If it's already our custom exception, just rethrow it
      if (e is ContentModerationException) {
        rethrow;
      }
      // For other errors (like network issues), wrap them
      debugPrint('Error creating text post: $e');
      throw Exception('Failed to create text post: $e');
    }
  }

  // Update existing draft post (PUT method)
  static Future<Map<String, dynamic>> updateDraftPost({
    required String postId,
    required String userId,
    required String challengeId,
    required String text,
    dynamic image, // Can be File or XFile
  }) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$_baseUrl/$postId'), // Correct endpoint: PUT /post/{postId}
      );

      // Add form data with PUBLISHED status (when updating draft, it becomes published)
      request.fields['user_id'] = userId;
      request.fields['challenge_id'] = challengeId;
      request.fields['content'] = text;
      request.fields['status'] = 'PUBLISHED'; // Important: mark as published when updating draft
      
      // Add image file if provided - handle both File and XFile
      if (image != null) {
        http.MultipartFile multipartFile;
        if (kIsWeb || image is XFile) {
          // Web or XFile
          final XFile xFile = image is XFile ? image : XFile(image.path);
          final bytes = await xFile.readAsBytes();
          final mimeType = _getMimeType(xFile.name);
          multipartFile = http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: xFile.name,
            contentType: http_parser.MediaType.parse(mimeType),
          );
        } else {
          // Mobile/Desktop - File
          final mimeType = _getMimeType(image.path);
          multipartFile = await http.MultipartFile.fromPath(
            'image',
            image.path,
            contentType: http_parser.MediaType.parse(mimeType),
          );
        }
        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Update Draft Response: ${response.statusCode}');
      debugPrint('Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        // Parse the error response and throw just the message
        final errorData = json.decode(responseBody);
        final message = errorData['message'] ?? 'Unknown error';
        throw ContentModerationException(message);
      }
    } catch (e) {
      if (e is ContentModerationException) {
        rethrow;
      }
      debugPrint('Error updating post: $e');
      throw Exception('Failed to update post: $e');
    }
  }

  // Get user's draft posts
  static Future<List<Map<String, dynamic>>> getUserDrafts({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId/drafts'),
      );

      debugPrint('Get User Drafts Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> drafts = List<Map<String, dynamic>>.from(data['drafts'] ?? []);
        
        // Enrich each draft with challenge content
        for (int i = 0; i < drafts.length; i++) {
          final draft = drafts[i];
          final challengeId = draft['challengeId'] ?? draft['challenge_id'];
          
          debugPrint('🔍 Processing draft ${i + 1}: challengeId = $challengeId');
          debugPrint('🔍 Draft data: ${draft.keys.toList()}');
          
          if (challengeId != null) {
            try {
              debugPrint('🌐 Fetching challenge content for ID: $challengeId');
              final challenge = await ChallengeService.fetchChallengeById(challengeId);
              if (challenge != null) {
                debugPrint('✅ Challenge found: ${challenge.content}');
                // Add the actual challenge content to the draft
                drafts[i] = {
                  ...draft,
                  'challengeContent': challenge.content,
                };
                debugPrint('✅ Draft enriched with challengeContent: ${challenge.content}');
              } else {
                debugPrint('❌ Challenge not found for ID: $challengeId');
                // Fallback if challenge not found
                drafts[i] = {
                  ...draft,
                  'challengeContent': 'Complete this challenge',
                };
              }
            } catch (e) {
              debugPrint('❌ Error fetching challenge for draft: $e');
              // Add fallback content
              drafts[i] = {
                ...draft,
                'challengeContent': 'Complete this challenge',
              };
            }
          } else {
            debugPrint('❌ No challenge ID found in draft');
            // No challenge ID found, add fallback
            drafts[i] = {
              ...draft,
              'challengeContent': 'Complete this challenge',
            };
          }
        }
        
        return drafts;
      } else {
        throw Exception('Failed to get drafts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting drafts: $e');
      throw Exception('Failed to get drafts: $e');
    }
  }

  // Get all user posts
  static Future<List<Map<String, dynamic>>> getAllUserPosts({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
      );

      debugPrint('Get All User Posts Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['posts'] ?? []);
      } else {
        throw Exception('Failed to get posts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting posts: $e');
      throw Exception('Failed to get posts: $e');
    }
  }

  // Get separated user posts (drafts and published)
  static Future<Map<String, List<Map<String, dynamic>>>> getUserPosts({
    required String userId,
  }) async {
    try {
      // Get both drafts and all posts
      final draftsResponse = await getUserDrafts(userId: userId);
      final allPostsResponse = await getAllUserPosts(userId: userId);

      // Create a set of draft IDs for easy lookup
      final draftIds = draftsResponse.map((post) => post['id']).toSet();
      
      debugPrint('Draft IDs from /drafts endpoint: $draftIds');
      debugPrint('Total posts from /user endpoint: ${allPostsResponse.length}');

      // Separate posts into drafts and published
      final List<Map<String, dynamic>> drafts = [];
      final List<Map<String, dynamic>> published = [];

      for (var post in allPostsResponse) {
        final postId = post['id'];
        debugPrint('Processing post ID: $postId');
        
        if (draftIds.contains(postId)) {
          debugPrint('Post $postId is a DRAFT');
          // This post ID exists in drafts, so it's a draft
          // But we want to use the draft data from /drafts endpoint which has more info (like challenge data)
          final draftData = draftsResponse.firstWhere(
            (draft) => draft['id'] == postId,
            orElse: () => post, // fallback to post data if not found
          );
          drafts.add(draftData);
        } else {
          debugPrint('Post $postId is PUBLISHED');
          // This post ID doesn't exist in drafts, so it's published
          published.add(post);
        }
      }

      debugPrint('Final separation - Drafts: ${drafts.length}, Published: ${published.length}');

      return {
        'blooming': drafts,
        'bloomed': published,
      };
    } catch (e) {
      debugPrint('Error getting user posts: $e');
      throw Exception('Failed to get user posts: $e');
    }
  }

  // Create draft post without image (for challenge acceptance)
  static Future<Map<String, dynamic>> createDraftPost({
    required String userId,
    required String challengeId,
    String? text,
    String? challengeContent,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload-post'),
      );

      // Add form data for draft - match the API field names
      request.fields['user_id'] = userId;
      request.fields['challenge_id'] = challengeId;
      request.fields['content'] = text ?? '';
      request.fields['status'] = 'DRAFT';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Draft Post Response: ${response.statusCode}');
      debugPrint('Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = json.decode(responseBody);
        // Add challengeContent to the result for local use
        if (challengeContent != null) {
          result['challengeContent'] = challengeContent;
        }
        return result;
      } else {
        throw Exception('Failed to create draft: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      debugPrint('Error creating draft: $e');
      throw Exception('Failed to create draft: $e');
    }
  }

  // Complete post with image (published status) - uses 'text' field
  static Future<Map<String, dynamic>> completePost({
    required String userId,
    required String challengeId,
    required String text,
    required dynamic image, // Can be File or XFile
  }) async {
    try {
      debugPrint('completePost called with:');
      debugPrint('- userId: $userId');
      debugPrint('- challengeId: $challengeId');
      debugPrint('- text: "$text"');
      debugPrint('- image type: ${image.runtimeType}');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload-post'), // POST for new post creation
      );

      // Add form data with PUBLISHED status
      request.fields['user_id'] = userId;
      request.fields['challenge_id'] = challengeId;
      request.fields['text'] = text; // Using 'text' for complete post
      request.fields['status'] = 'PUBLISHED';
      
      debugPrint('Form fields: ${request.fields}');
      
      // Add image file - handle both File and XFile
      http.MultipartFile multipartFile;
      if (kIsWeb || image is XFile) {
        // Web or XFile
        final XFile xFile = image is XFile ? image : XFile(image.path);
        final bytes = await xFile.readAsBytes();
        final mimeType = _getMimeType(xFile.name);
        multipartFile = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: xFile.name,
          contentType: http_parser.MediaType.parse(mimeType),
        );
      } else {
        // Mobile/Desktop - File
        final mimeType = _getMimeType(image.path);
        multipartFile = await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: http_parser.MediaType.parse(mimeType),
        );
      }
      
      request.files.add(multipartFile);
      
      debugPrint('Multipart file added:');
      debugPrint('- field name: ${multipartFile.field}');
      debugPrint('- filename: ${multipartFile.filename}');
      debugPrint('- content type: ${multipartFile.contentType}');
      debugPrint('- length: ${multipartFile.length}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Complete Post Response: ${response.statusCode}');
      debugPrint('Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        final errorData = json.decode(responseBody);
        final message = errorData['message'] ?? 'Unknown error';
        throw ContentModerationException(message);
      }
    } catch (e) {
      if (e is ContentModerationException) {
        rethrow;
      }
      debugPrint('Error completing post: $e');
      throw Exception('Failed to complete post: $e');
    }
  }

  // Complete post with text only (published status) - uses 'text' field
  static Future<Map<String, dynamic>> completeTextPost({
    required String userId,
    required String challengeId,
    required String text,
  }) async {
    try {
      debugPrint('completeTextPost called with:');
      debugPrint('- userId: $userId');
      debugPrint('- challengeId: $challengeId');
      debugPrint('- content: "$text"');
      
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$_baseUrl/upload-post'),
      );

      // Add form data with PUBLISHED status
      request.fields['user_id'] = userId;
      request.fields['challenge_id'] = challengeId;
      request.fields['content'] = text; // Using 'text' for complete post
      request.fields['status'] = 'PUBLISHED';
      
      debugPrint('Form fields: ${request.fields}');
      
      // No image file added for text-only posts

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Complete Text Post Response: ${response.statusCode}');
      debugPrint('Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        final errorData = json.decode(responseBody);
        final message = errorData['message'] ?? 'Unknown error';
        throw ContentModerationException(message);
      }
    } catch (e) {
      if (e is ContentModerationException) {
        rethrow;
      }
      debugPrint('Error completing text post: $e');
      throw Exception('Failed to complete text post: $e');
    }
  }
}