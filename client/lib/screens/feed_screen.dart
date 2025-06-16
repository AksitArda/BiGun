import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../components/audio_story_card.dart';
import '../components/record_button.dart';
import '../core/theme/app_theme.dart';
import '../services/audio_service.dart';
import 'profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedScreen extends StatefulWidget {
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late AudioService _audioService;
  List<Story> stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAudioService();
  }

  Future<void> _initAudioService() async {
    final prefs = await SharedPreferences.getInstance();
    _audioService = AudioService(prefs);
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final feedStories = await _audioService.getFeed();
      if (mounted) {
        setState(() {
          stories = feedStories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feed yüklenirken bir hata oluştu: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleNewRecording(String path, Duration duration, List<double> waveformData) async {
    try {
      final story = await _audioService.uploadAudio(
        title: 'Yeni Ses Kaydı',
        audioPath: path,
        duration: duration,
        waveformData: waveformData,
      );
      
      if (mounted) {
        setState(() {
          stories.insert(0, story);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ses yüklenirken bir hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'BiGün',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeed,
        child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
              ),
            )
          : stories.isEmpty
            ? Center(
                child: Text(
                  'Henüz hiç ses kaydı yok',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.only(bottom: 100),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  return AudioStoryCard(story: stories[index]);
                },
              ),
      ),
      floatingActionButton: RecordButton(
        onRecordingComplete: _handleNewRecording,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
} 