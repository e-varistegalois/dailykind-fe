import 'package:flutter/material.dart';
import '../models/session_summary.dart';

class ChatSidebar extends StatelessWidget {
  final List<SessionSummary> sessions;
  final String? selectedSessionId;
  final Function(String) onSessionSelected;

  const ChatSidebar({
    required this.sessions,
    required this.selectedSessionId,
    required this.onSessionSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text('Chat Sessions')),
          ...sessions.map((session) => ListTile(
                title: Text(session.personality),
                subtitle: Text(session.displayChat, maxLines: 1, overflow: TextOverflow.ellipsis),
                selected: session.sessionId == selectedSessionId,
                onTap: () => onSessionSelected(session.sessionId),
              )),
        ],
      ),
    );
  }
}