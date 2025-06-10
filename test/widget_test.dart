import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bigun/components/audio_story_card.dart';
import 'package:bigun/models/story.dart';

void main() {
  testWidgets('AudioStoryCard displays correctly', (WidgetTester tester) async {
    final story = Story(
      id: '1',
      username: 'TestUser',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      audioUrl: 'https://example.com/test.mp3',
      time: DateTime.now(),
      audioDuration: Duration(seconds: 30),
      waveformData: List.generate(50, (i) => 0.5),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AudioStoryCard(story: story),
        ),
      ),
    );

    expect(find.text('TestUser'), findsOneWidget);
    expect(find.byType(AudioWaveVisualizer), findsOneWidget);
  });

  testWidgets('AudioStoryCard handles null waveform data', (WidgetTester tester) async {
    final story = Story(
      id: '1',
      username: 'TestUser',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      audioUrl: 'https://example.com/test.mp3',
      time: DateTime.now(),
      audioDuration: Duration(seconds: 30),
      waveformData: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AudioStoryCard(story: story),
        ),
      ),
    );

    expect(find.text('TestUser'), findsOneWidget);
  });
} 