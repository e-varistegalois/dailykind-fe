import 'package:flutter/material.dart';
import '../models/session_summary.dart';
import '../constants/app_colors.dart';

class ChatSidebar extends StatelessWidget {
  final List<SessionSummary> sessions;
  final String? selectedSessionId;
  final Function(String?) onNewChatCreated;
  final Function(String) onSessionSelected;
  final Function(String) onDeleteSession;

  const ChatSidebar({
    super.key,
    required this.sessions,
    required this.selectedSessionId,
    required this.onSessionSelected,
    required this.onNewChatCreated,
    required this.onDeleteSession,
  });

  // Tambahkan warna untuk setiap personality
  Color _getPersonalityColor(String personality) {
    switch (personality.toLowerCase()) {
      case 'calm':
        return AppColors.pinkFont;
      case 'emo':
        return AppColors.blueFont;
      case 'cheerful':
        return Colors.green[700]!;
      case 'humorous':
        return const Color(0xFFFF9800); // oren
      default:
        return AppColors.brownFont;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[50],
      child: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_comment, color: AppColors.secondaryTosca),
              label: const Text(
                'New Chat',
                style: TextStyle(
                  fontFamily: 'Tommy',
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryTosca,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).drawerTheme.backgroundColor ?? Colors.grey[50],
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context); // tutup drawer
                onNewChatCreated(null); // trigger personality chooser di screen utama
              },
            ),
          ),
          const Divider(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isSelected = session.sessionId == selectedSessionId;
                final personalityColor = _getPersonalityColor(session.personality);

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: AppColors.primaryTosca.withOpacity(0.1),
                  title: Text(
                    session.personality.isNotEmpty ? session.personality : 'Session',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w700,
                      color: personalityColor,
                    ),
                  ),
                  subtitle: Text(
                    session.displayChat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w400,
                      color: AppColors.brownFont,
                    ),
                  ),
                  onTap: () => onSessionSelected(session.sessionId),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.secondaryTosca),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDeleteSession(session.sessionId);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: AppColors.brownFont)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}