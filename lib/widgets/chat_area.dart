import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/globals.dart';
import '../constants/app_colors.dart';

class ChatArea extends StatefulWidget {
  final String sessionId;
  final String personality;
  final VoidCallback? onNewMessage;
  const ChatArea({
    required this.sessionId,
    required this.personality,
    this.onNewMessage,
    super.key,
  });

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Widget _buildPersonalityImage(String personality) {
    IconData icon;
    Color color;
    switch (personality.toLowerCase()) {
      case 'calm':
        icon = Icons.spa;
        color = AppColors.pinkFont;
        break;
      case 'emo':
        icon = Icons.psychology;
        color = AppColors.blueFont;
        break;
      case 'cheerful':
        icon = Icons.wb_sunny;
        color = Colors.green[700]!;
        break;
      case 'humorous':
        icon = Icons.emoji_emotions;
        color = const Color(0xFFFF9800);
        break;
      default:
        icon = Icons.person;
        color = AppColors.secondaryTosca;
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.28,
      width: double.infinity,
      alignment: Alignment.center,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon, color: color, size: 64),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  @override
  void didUpdateWidget(covariant ChatArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      fetchHistory();
    }
  }

  Future<void> fetchHistory() async {
    setState(() {
      _isLoading = true;
    });
    final apiUrl = '$apiBaseUrl/chatbot/sessions/session/${widget.sessionId}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final history = data['history'] as List<dynamic>? ?? [];
        setState(() {
          _messages = history
              .map<Map<String, String>>((msg) => {
                    'role': msg['role'] ?? '',
                    'content': msg['content'] ?? '',
                  })
              .toList();
        });
        // Scroll ke bawah setelah load history
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      //
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _messages.add({'role': 'user', 'content': message});
    });

    const apiUrl = '$apiBaseUrl/chatbot/send-message';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sessionId': widget.sessionId,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _messages.add({'role': 'model', 'content': data['response'] ?? ''});
      });
    } else {
      setState(() {
        _messages.add({'role': 'model', 'content': 'Error: ${response.reasonPhrase}'});
      });
    }
    setState(() {
      _isLoading = false;
    });
    _controller.clear();

    // Scroll ke bawah setelah kirim pesan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    if (widget.onNewMessage != null) {
      widget.onNewMessage!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPersonalityImage(widget.personality),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.secondaryTosca))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primaryTosca.withOpacity(0.8)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['content'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Tommy',
                            fontWeight: FontWeight.w400,
                            color: AppColors.brownFont,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !_isLoading,
                  style: const TextStyle(
                    fontFamily: 'Tommy',
                    fontWeight: FontWeight.w400,
                    color: AppColors.brownFont,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(
                      color: AppColors.brownFont.withOpacity(0.5),
                      fontFamily: 'Tommy',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (value) => sendMessage(value),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.brownFont),
                onPressed: _isLoading
                    ? null
                    : () => sendMessage(_controller.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}