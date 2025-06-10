import 'package:flutter/material.dart';
import 'package:bigun/core/theme/app_theme.dart';
import 'package:bigun/models/chat.dart';
import 'package:bigun/components/record_button.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatRoomScreen({Key? key, required this.chatRoom}) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final List<Message> _messages = [];
  final _textController = TextEditingController();
  bool _isRecording = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement API call to fetch messages
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _messages.addAll([
            // Dummy messages
            Message(
              id: '1',
              senderId: 'user2',
              receiverId: 'currentUser',
              content: 'Merhaba!',
              time: DateTime.now().subtract(Duration(minutes: 30)),
            ),
            Message(
              id: '2',
              senderId: 'currentUser',
              receiverId: 'user2',
              content: 'Selam, nasılsın?',
              time: DateTime.now().subtract(Duration(minutes: 25)),
            ),
          ]);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesajlar yüklenirken bir hata oluştu')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendMessage(String content) async {
    if (content.isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().toString(),
      senderId: 'currentUser',
      receiverId: widget.chatRoom.user2Id,
      content: content,
      time: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, newMessage);
      _textController.clear();
    });

    // TODO: Implement API call to send message
  }

  void _handleNewRecording(String path, Duration duration, List<double> waveformData) {
    final newMessage = Message(
      id: DateTime.now().toString(),
      senderId: 'currentUser',
      receiverId: widget.chatRoom.user2Id,
      content: 'Sesli mesaj',
      time: DateTime.now(),
      isAudio: true,
      audioUrl: path,
      audioDuration: duration,
      waveformData: waveformData,
    );

    setState(() {
      _messages.insert(0, newMessage);
    });

    // TODO: Implement API call to send audio message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
            ),
            SizedBox(width: 12),
            Text(
              'Kullanıcı Adı', // TODO: Get real username
              style: AppTheme.headlineStyle.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId == 'currentUser';

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.accentColor : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isAudio) ...[
                    // TODO: Implement audio player widget
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Sesli mesaj',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      message.content,
                      style: TextStyle(color: Colors.white),
                    ),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.time),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8),
      color: AppTheme.cardColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isRecording ? Icons.close : Icons.mic_none,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() => _isRecording = !_isRecording);
            },
          ),
          if (_isRecording)
            Expanded(
              child: RecordButton(
                onRecordingComplete: _handleNewRecording,
              ),
            )
          else ...[
            Expanded(
              child: TextField(
                controller: _textController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Mesaj yaz...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: AppTheme.accentColor),
              onPressed: () => _sendMessage(_textController.text),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
