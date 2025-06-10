import 'package:flutter/material.dart';
import 'package:bigun/core/theme/app_theme.dart';
import 'package:bigun/models/story.dart';
import 'package:bigun/components/audio_story_card.dart';
import 'package:bigun/components/settings_bottom_sheet.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Story> _userStories = []; // TODO: Fetch user stories
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserStories();
  }

  Future<void> _loadUserStories() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement API call to fetch user stories
      // Simulating API call with dummy data
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _userStories.addAll([
            Story(
              id: '1',
              username: 'CurrentUser',
              avatarUrl: 'https://i.pravatar.cc/150?img=1',
              audioUrl: 'https://example.com/audio1.mp3',
              time: DateTime.now().subtract(Duration(hours: 2)),
              audioDuration: Duration(seconds: 30),
              waveformData: List.generate(50, (i) => 0.5),
            ),
            // Add more stories as needed
          ]);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hikayeler yüklenirken bir hata oluştu')),
      );
    } finally {
      if (mounted) {
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
              child: _buildProfileHeader(),
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

  Widget _buildProfileHeader() {
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
            'Kullanıcı Adı',
            style: AppTheme.headlineStyle,
          ),
          SizedBox(height: 8),
          Text(
            'user@email.com',
            style: AppTheme.bodyStyle,
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Hikayeler', '${_userStories.length}'),
              _buildStatColumn('Takipçiler', '150'),
              _buildStatColumn('Takip', '120'),
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
