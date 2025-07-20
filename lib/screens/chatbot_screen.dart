import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/session_summary.dart';
import '../services/get_user_session.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/chat_area.dart';
import '../constants/app_colors.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  List<SessionSummary> sessions = [];
  String? selectedSessionId;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('DEBUG: User not logged in');
      setState(() {
        isLoading = false;
        errorMessage = 'User not logged in';
      });
      return;
    }
    final userId = user.uid;
    print('DEBUG: Loading sessions for userId: $userId');
    
    try {
      final fetchedSessions = await fetchUserSessions(userId);
      print('DEBUG: Fetched ${fetchedSessions.length} sessions');
      setState(() {
        sessions = fetchedSessions;
        isLoading = false;
        if (sessions.isNotEmpty) {
          selectedSessionId = sessions.first.sessionId;
          print('DEBUG: Selected session: $selectedSessionId');
        } else {
          print('DEBUG: No sessions found');
        }
      });
    } catch (e) {
      print('DEBUG: Error loading sessions: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ChatSidebar(
        sessions: sessions,
        selectedSessionId: selectedSessionId,
        onSessionSelected: (id) {
          setState(() {
            selectedSessionId = id;
            Navigator.pop(context); // Close drawer
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primaryTosca,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Text(
          'Chatbot',
          style: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryTosca,
            fontSize: 22,
          ),
        ),
        actions: [
          if (errorMessage != null)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: loadSessions,
            ),
        ],
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $errorMessage'),
                      ElevatedButton(
                        onPressed: loadSessions,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : selectedSessionId == null
                  ? Center(child: Text('Pilih sesi chat di sidebar'))
                  : ChatArea(sessionId: selectedSessionId!),
    );
  }
}