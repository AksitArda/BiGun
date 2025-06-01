import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Story {
  final String username;
  final String avatarUrl;
  final String audioUrl;
  final DateTime time;
  final List<String> comments;

  Story({
    required this.username,
    required this.avatarUrl,
    required this.audioUrl,
    required this.time,
    this.comments = const [],
  });
}

class StoryCard extends StatelessWidget {
  final Story story;

  const StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH:mm').format(story.time);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(story.avatarUrl),
                radius: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Image.asset(
                  'assets/wave_placeholder.png',
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 8),
              Text(
                timeString,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
          if (story.comments.isNotEmpty)
            ...story.comments.map((text) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 48.0),
                child: Text(
                  story.username + ': ' + text,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
