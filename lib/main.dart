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
      audioUrl:
          'https://cdn.discordapp.com/attachments/825383394258845727/1346998575221047448/S4nity_Track8.mp3?ex=683d94ee&is=683c436e&hm=370dc36497630aab14ad7556836867b8c83f0c6610bb7e290676e340971337a1&',
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
