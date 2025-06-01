import 'package:flutter/material.dart';
import 'storyCard.dart';

void main() {
  runApp(StoryFeedPage());
}

class StoryFeedPage extends StatelessWidget {
  final List<Story> stories = [
    // Örnek veriler
    Story(
      username: 'Ayşe023',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      audioUrl: 'https://example.com/audio1.aac',
      time: DateTime.now().subtract(Duration(minutes: 10)),
      comments: ['Bu tarz şeyleri çok düşünme asdlkjah'],
    ),
    Story(
      username: 'Atilla0',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      audioUrl: 'https://example.com/audio2.aac',
      time: DateTime.now().subtract(Duration(minutes: 30)),
      comments: ['Antalyalı mısın kankaa?'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Color(0xFF1F1F1F),
      body: ListView.builder(
        padding: EdgeInsets.only(bottom: 80),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return StoryCard(story: stories[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.mic),
        onPressed: () {
          // Ses kaydı işlemi burada olacak
        },
      ),
    ));
  }
}
