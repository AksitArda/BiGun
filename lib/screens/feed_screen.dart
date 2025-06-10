import 'package:flutter/material.dart';
import '../models/story.dart';
import '../components/audio_story_card.dart';
import '../components/record_button.dart';
import 'profile_screen.dart';

class FeedScreen extends StatefulWidget {
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<Story> stories = [
    Story(
      id: '1',
      username: 'Ayşe023',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      time: DateTime.now().subtract(Duration(minutes: 10)),
      audioDuration: Duration(seconds: 15),
      comments: [
        Comment(
          id: '1',
          username: 'Mehmet',
          avatarUrl: 'https://i.pravatar.cc/150?img=2',
          text: 'Bu tarz şeyleri çok düşünme asdlkjah',
          time: DateTime.now().subtract(Duration(minutes: 5)),
        ),
      ],
      waveformData: List.generate(50, (i) => 0.1 + (0.8 * i % 10) / 10),
    ),
    Story(
      id: '2',
      username: 'Atilla0',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      time: DateTime.now().subtract(Duration(minutes: 30)),
      audioDuration: Duration(seconds: 20),
      comments: [
        Comment(
          id: '2',
          username: 'Can',
          avatarUrl: 'https://i.pravatar.cc/150?img=4',
          text: 'Antalyalı mısın kankaa?',
          time: DateTime.now().subtract(Duration(minutes: 15)),
        ),
      ],
      waveformData: List.generate(50, (i) => 0.1 + (0.8 * (50 - i) % 10) / 10),
    ),
  ];

  void _handleNewRecording(String path, Duration duration, List<double> waveformData) {
    // Burada kayıt tamamlandığında yapılacak işlemleri ekleyeceğiz
    // Örneğin: Kaydı sunucuya yükleme, story listesine ekleme vb.
    print('Yeni kayıt: $path, Süre: $duration');
    
    setState(() {
      stories.insert(0, Story(
        id: DateTime.now().toString(),
        username: 'Ben', // Gerçek kullanıcı adı buraya gelecek
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        audioUrl: path,
        time: DateTime.now(),
        audioDuration: duration,
        comments: [],
        waveformData: waveformData,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F),      appBar: AppBar(
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
      body: ListView.builder(
        padding: EdgeInsets.only(bottom: 100),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return AudioStoryCard(story: stories[index]);
        },
      ),
      floatingActionButton: RecordButton(
        onRecordingComplete: _handleNewRecording,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
} 