import 'package:flutter/material.dart';
import 'package:bigun/core/theme/app_theme.dart';
import 'package:bigun/models/chat.dart';

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FriendRequest> _friendRequests = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendRequests() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement API call to fetch friend requests
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _friendRequests = [
            FriendRequest(
              id: '1',
              senderId: 'user3',
              receiverId: 'currentUser',
              time: DateTime.now().subtract(Duration(hours: 2)),
            ),
          ];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arkadaşlık istekleri yüklenirken bir hata oluştu')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      // TODO: Implement API call to search users
      await Future.delayed(Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _searchResults = [
            {
              'id': 'user4',
              'username': 'Test Kullanıcı',
              'avatarUrl': 'https://i.pravatar.cc/150?img=4',
            },
          ];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı araması sırasında bir hata oluştu')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _sendFriendRequest(String userId) async {
    try {
      // TODO: Implement API call to send friend request
      await Future.delayed(Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arkadaşlık isteği gönderildi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arkadaşlık isteği gönderilirken bir hata oluştu')),
      );
    }
  }

  Future<void> _handleFriendRequest(String requestId, bool accept) async {
    try {
      // TODO: Implement API call to handle friend request
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _friendRequests.removeWhere((request) => request.id == requestId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Arkadaşlık isteği kabul edildi' : 'Arkadaşlık isteği reddedildi'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem sırasında bir hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.primaryColor,
        appBar: AppBar(
          title: Text('Arkadaşlar', style: AppTheme.headlineStyle),
          bottom: TabBar(
            indicatorColor: AppTheme.accentColor,
            tabs: [
              Tab(text: 'Arkadaş Bul'),
              Tab(text: 'İstekler (${_friendRequests.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSearchTab(),
            _buildRequestsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Kullanıcı ara...',
              hintStyle: TextStyle(color: Colors.white54),
              prefixIcon: Icon(Icons.search, color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentColor),
              ),
            ),
            onChanged: _searchUsers,
          ),
        ),
        if (_isSearching)
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['avatarUrl']),
                  ),
                  title: Text(
                    user['username'],
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: TextButton(
                    onPressed: () => _sendFriendRequest(user['id']),
                    child: Text(
                      'İstek Gönder',
                      style: TextStyle(color: AppTheme.accentColor),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRequestsTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
        ),
      );
    }

    if (_friendRequests.isEmpty) {
      return Center(
        child: Text(
          'Henüz arkadaşlık isteği yok',
          style: AppTheme.bodyStyle,
        ),
      );
    }

    return ListView.builder(
      itemCount: _friendRequests.length,
      itemBuilder: (context, index) {
        final request = _friendRequests[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
          ),
          title: Text(
            'Kullanıcı Adı', // TODO: Get real username
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            _formatTime(request.time),
            style: TextStyle(color: Colors.white54),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.check, color: Colors.green),
                onPressed: () => _handleFriendRequest(request.id, true),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () => _handleFriendRequest(request.id, false),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'şimdi';
    }
  }
}
