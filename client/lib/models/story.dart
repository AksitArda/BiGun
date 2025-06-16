import 'package:flutter/material.dart';

class Story {
  final String id;
  final String username;
  final String avatarUrl;
  final String audioUrl;
  final DateTime time;
  final Duration audioDuration;
  final List<String> comments;
  final List<double> waveformData;

  Story({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.audioUrl,
    required this.time,
    required this.audioDuration,
    required this.comments,
    required this.waveformData,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['_id'],
      username: json['uploadedBy']['username'],
      avatarUrl: 'https://i.pravatar.cc/150?img=1', // Default avatar
      audioUrl: json['filepath'],
      time: DateTime.parse(json['createdAt']),
      audioDuration: json['duration'] != null 
          ? Duration(milliseconds: json['duration']) 
          : const Duration(seconds: 30),
      comments: (json['comments'] as List?)?.cast<String>() ?? [],
      waveformData: json['waveformData'] != null 
          ? (json['waveformData'] as List).map((e) => (e as num).toDouble()).toList()
          : List.generate(50, (i) => 0.5),
    );
  }
}

class Comment {
  final String id;
  final String username;
  final String avatarUrl;
  final String text;
  final DateTime time;

  Comment({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.text,
    required this.time,
  });
} 