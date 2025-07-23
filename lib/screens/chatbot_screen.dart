import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/session_summary.dart';
import '../services/get_user_session.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/chat_area.dart';
import '../constants/globals.dart';
import '../constants/app_colors.dart';
import 'package:http/http.dart' as http;

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  List<SessionSummary> sessions = [];
  String? selectedSessionId;
  bool isLoading = true;
  String? errorMessage;

  final List<Map<String, dynamic>> personalities = [
    {
      'label': 'Calm',
      'desc': 'Comforting presence',
      'image': null,
    },
    {
      'label': 'Emo',
      'desc': 'Logical & honest',
      'image': null,
    },
    {
      'label': 'Humorous',
      'desc': 'Makes you laugh',
      'image': null,
    },
    {
      'label': 'Cheerful',
      'desc': 'Always encouraging',
      'image': null,
    },
  ];

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
      setState(() {
        isLoading = false;
        errorMessage = 'User not logged in';
      });
      return;
    }
    final userId = user.uid;

    try {
      final fetchedSessions = await fetchUserSessions(userId);
      setState(() {
        sessions = fetchedSessions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleNewChat(String personality) async {
    setState(() {
      isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'User not logged in';
      });
      return;
    }

    const apiUrl = '$apiBaseUrl/chatbot/';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: '{"userId": "${user.uid}", "personality": "$personality"}',
    );

    if (response.statusCode == 201) {
      final data = response.body;
      final sessionId = RegExp(r'"sessionId"\s*:\s*"([^"]+)"').firstMatch(data)?.group(1);
      await loadSessions();
      setState(() {
        selectedSessionId = sessionId;
      });
    } else {
      setState(() {
        errorMessage = 'Failed to create chat';
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void _handleDeleteSession(String sessionId) async {
    setState(() {
      isLoading = true;
    });
    final apiUrl = '$apiBaseUrl/chatbot/sessions/session/$sessionId';
    try {
      final response = await http.delete(Uri.parse(apiUrl));
      if (response.statusCode != 200) {
        setState(() {
          errorMessage = 'Gagal hapus session: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
    await loadSessions();
    setState(() {
      if (sessions.isNotEmpty) {
        selectedSessionId = sessions.first.sessionId;
      } else {
        selectedSessionId = null;
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'there';

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: ChatSidebar(
        sessions: sessions,
        selectedSessionId: selectedSessionId,
        onSessionSelected: (id) {
          setState(() {
            selectedSessionId = id;
            Navigator.pop(context);
          });
        },
        onNewChatCreated: (sessionId) {
          setState(() {
            selectedSessionId = null;
          });
        },
        onDeleteSession: _handleDeleteSession,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primaryTosca,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.history, color: AppColors.secondaryTosca),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'History',
          ),
        ),
        title: const Text(
          'Chatbot',
          style: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryTosca,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment, color: AppColors.secondaryTosca),
            tooltip: 'New Chat',
            onPressed: () {
              setState(() {
                selectedSessionId = null;
              });
            },
          ),
          if (errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.secondaryTosca),
              onPressed: loadSessions,
            ),
        ],
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondaryTosca))
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $errorMessage', style: const TextStyle(color: AppColors.brownFont)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTosca,
                          foregroundColor: AppColors.brownFont,
                        ),
                        onPressed: loadSessions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : selectedSessionId == null
                  ? _buildPersonalityChooser(context, userName)
                  : ChatArea(
                      sessionId: selectedSessionId!,
                      personality: sessions.firstWhere((s) => s.sessionId == selectedSessionId).personality,
                      onNewMessage: loadSessions,
                    ),
    );
  }

  Widget _buildPersonalityChooser(BuildContext context, String userName) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello, $userName.',
                style: const TextStyle(
                  fontFamily: 'Tommy',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: AppColors.brownFont,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "How are you doing today? I'm ready to hear what's on your mind.",
                style: TextStyle(
                  fontFamily: 'Tommy',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: AppColors.brownFont,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: personalities.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final p = personalities[index];
                  return GestureDetector(
                    onTap: isLoading ? null : () => _handleNewChat(p['label']),
                    child: Card(
                      elevation: 3,
                      color: AppColors.primaryTosca.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.secondaryTosca, width: 1.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Placeholder image, ganti dengan Image.asset(p['image']) jika sudah ada PNG
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                border: Border.fromBorderSide(BorderSide(color: AppColors.secondaryTosca, width: 1)),
                              ),
                              child: const Icon(Icons.image, size: 32, color: AppColors.secondaryTosca),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              p['label'],
                              style: const TextStyle(
                                fontFamily: 'Tommy',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.brownFont,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p['desc'],
                              style: const TextStyle(
                                fontFamily: 'Tommy',
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: Color(0xB3A67C52), // AppColors.brownFont.withOpacity(0.7)
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}