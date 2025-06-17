import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
    // Base URL'i platform'a göre ayarla
    final baseUrl = kIsWeb 
        ? 'http://localhost:5000' 
        : 'http://10.0.2.2:5000';

    // Gelen filepath'i düzelt
    final filepath = json['filepath'];
    if (filepath == null) {
      throw Exception('Audio file path is missing');
    }

    final audioUrl = filepath.toString().startsWith('http') 
        ? filepath.toString()
        : '$baseUrl/$filepath';

    return Story(
      id: json['_id'] ?? '',
      username: json['uploadedBy']?['username'] ?? 'Unknown User',
      avatarUrl: 'https://i.pravatar.cc/150?img=1', // Default avatar
      audioUrl: audioUrl,
      time: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
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