import 'package:flutter/material.dart';

class Story {
  final String id;
  final String username;
  final String avatarUrl;
  final String audioUrl;
  final DateTime time;
  final List<Comment> comments;
  final Duration audioDuration;
  final List<double>? waveformData; // Ses dalgası için veri

  Story({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.audioUrl,
    required this.time,
    required this.audioDuration,
    this.comments = const [],
    this.waveformData,
  });
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