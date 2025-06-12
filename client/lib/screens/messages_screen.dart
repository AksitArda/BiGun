import 'package:flutter/material.dart';
import 'package:bigun/core/theme/app_theme.dart';
import 'package:bigun/models/chat.dart';
import 'chat_room_screen.dart';
import 'friend_requests_screen.dart';

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<ChatRoom> _chatRooms = []; // TODO: Implement real chat rooms
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement API call to fetch chat rooms
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _chatRooms.addAll([
            // Dummy data
            ChatRoom(
              id: '1',
              user1Id: 'currentUser',
              user2Id: 'user2',
              lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
              lastMessage: 'Son mesaj örneği',
              hasUnreadMessages: true,
            ),
          ]);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sohbetler yüklenirken bir hata oluştu')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Text('Mesajlar', style: AppTheme.headlineStyle),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendRequestsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
              ),
            )
          : _chatRooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.white24,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Henüz hiç mesajınız yok',
                        style: AppTheme.bodyStyle,
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendRequestsScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Arkadaş Ekle',
                          style: TextStyle(color: AppTheme.accentColor),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadChatRooms,
                  color: AppTheme.accentColor,
                  child: ListView.builder(
                    itemCount: _chatRooms.length,
                    itemBuilder: (context, index) {
                      final chatRoom = _chatRooms[index];
                      return _buildChatRoomTile(chatRoom);
                    },
                  ),
                ),
    );
  }

  Widget _buildChatRoomTile(ChatRoom chatRoom) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(chatRoom: chatRoom),
          ),
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
          ),
          if (chatRoom.hasUnreadMessages)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        'Kullanıcı Adı', // TODO: Get real username
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        chatRoom.lastMessage ?? 'Yeni sohbet',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(chatRoom.lastMessageTime),
        style: TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}g';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}s';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}d';
    } else {
      return 'şimdi';
    }
  }
}
