import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/globals.dart';

class PostService {
  static const String _baseUrl = '$apiBaseUrl/post';

  // Upload post with image (auto published, no status field)
  static Future<Map<String, dynamic>> uploadPost({
    required String userId,
    required String challengeId,
    required String text,
    required File image,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload-post'),
      );

      // Add form data (no status field - auto published)
      request.fields['user_id'] = userId;
      request.fields['challenge_id'] = challengeId;
      request.fields['text'] = text;
      
      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Upload Post Response: ${response.statusCode}');
      debugPrint('Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to create post: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  // Upload post with text only (auto published, no status field)
  static Future<Map<String, dynamic>> uploadTextPost({
    required String userId,
    required String challengeId,
    required String text,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload-post'),
      );

      // Add form data (no status field - auto published)
      request.fields['user_id'] = userId;
      request.fields['challenge_id'] = challengeId;
      request.fields['text'] = text;
      
      // No image file added for text-only posts

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Upload Text Post Response: ${response.statusCode}');
      debugPrint('Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to create text post: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
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
    File? image,
  }) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$_baseUrl/$postId'),
      );

      // Add form data
      request.fields['user_id'] = userId;
      request.fields['challenge_id'] = challengeId;
      request.fields['text'] = text;
      
      // Add image file if provided
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Update Draft Response: ${response.statusCode}');
      debugPrint('Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to update post: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
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
        // API returns {"drafts": [...], "count": 1, "message": "..."}
        return List<Map<String, dynamic>>.from(data['drafts'] ?? []);
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
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload-post'),
      );

      // Add form data for draft - match the API field names
      request.fields['user_id'] = userId;
      request.fields['challenge_id'] = challengeId;
      request.fields['text'] = text ?? 'Draft: Ready to complete this challenge!';
      request.fields['status'] = 'DRAFT';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Draft Post Response: ${response.statusCode}');
      debugPrint('Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to create draft: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      debugPrint('Error creating draft: $e');
      throw Exception('Failed to create draft: $e');
    }
  }
}
