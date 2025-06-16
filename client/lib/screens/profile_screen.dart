import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bigun/core/theme/app_theme.dart';
import 'package:bigun/models/story.dart';
import 'package:bigun/components/audio_story_card.dart';
import 'package:bigun/components/settings_bottom_sheet.dart';
import 'package:bigun/services/audio_service.dart';
import 'package:bigun/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AudioService _audioService;
  List<Story> _userStories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAudioService();
  }

  Future<void> _initAudioService() async {
    final prefs = await SharedPreferences.getInstance();
    _audioService = AudioService(prefs);
    _loadUserStories();
  }

  Future<void> _loadUserStories() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final stories = await _audioService.getFeed(); // TODO: Kullanıcının kendi hikayelerini getiren endpoint eklenecek
      if (mounted) {
        setState(() {
          _userStories = stories.where((story) => 
            story.username == context.read<AuthProvider>().user?['username']
          ).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hikayeler yüklenirken bir hata oluştu: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SettingsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Text('Profil', style: AppTheme.headlineStyle),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettingsBottomSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserStories,
        color: AppTheme.accentColor,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildProfileHeader(user),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Hikayelerim',
                  style: AppTheme.headlineStyle.copyWith(fontSize: 20),
                ),
              ),
            ),
            _isLoading
                ? SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                      ),
                    ),
                  )
                : _userStories.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'Henüz hiç hikaye paylaşmadınız',
                            style: AppTheme.bodyStyle,
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => AudioStoryCard(
                            story: _userStories[index],
                          ),
                          childCount: _userStories.length,
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic>? user) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: () {
                    // TODO: Implement profile photo edit
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            user?['username'] ?? 'Kullanıcı Adı',
            style: AppTheme.headlineStyle,
          ),
          SizedBox(height: 8),
          Text(
            user?['email'] ?? 'user@email.com',
            style: AppTheme.bodyStyle,
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Hikayeler', '${_userStories.length}'),
              _buildStatColumn('Takipçiler', '0'),
              _buildStatColumn('Takip', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.headlineStyle.copyWith(
            fontSize: 20,
            color: AppTheme.accentColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodyStyle,
        ),
      ],
    );
  }
}
