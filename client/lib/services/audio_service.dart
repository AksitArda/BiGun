import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/story.dart';
import 'platform/audio_upload_interface.dart';
import 'platform/audio_upload_web.dart';
import 'platform/audio_upload_mobile.dart';

class AudioService {
  static String get _defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    return 'http://10.0.2.2:5000/api';
  }

  final SharedPreferences _prefs;
  late final String baseUrl;
  late final AudioUploadPlatform _platform;

  AudioService(this._prefs) {
    baseUrl = _defaultBaseUrl;
    _platform = kIsWeb ? AudioUploadWeb() : AudioUploadMobile();
  }

  String? get token => _prefs.getString('jwt_token');

  Map<String, String> get _headers {
    final tokenValue = token;
    if (tokenValue != null) {
      return {
        'Authorization': 'Bearer $tokenValue',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  Future<Story> uploadAudio({
    required String title,
    required String audioPath,
    required Duration duration,
    required List<double> waveformData,
  }) async {
    try {
      return await _platform.uploadAudio(
        baseUrl: baseUrl,
        token: token,
        title: title,
        audioPath: audioPath,
        duration: duration,
        waveformData: waveformData,
      );
    } catch (e) {
      print('Error uploading audio: $e');
      rethrow;
    }
  }

  Future<List<Story>> getFeed() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/audio/feed'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Story.fromJson(json)).toList();
      } else {
        final error = json.decode(response.body);
        throw error['message'] ?? 'Failed to load feed';
      }
    } catch (e) {
      print('Error fetching feed: $e');
      rethrow;
    }
  }

  Future<Story> getStory(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/audio/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Story.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw error['message'] ?? 'Failed to load story';
      }
    } catch (e) {
      print('Error fetching story: $e');
      rethrow;
    }
  }
} 