import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final Map<String, AudioPlayer> _players = {};
  final Map<String, String> _cache = {};

  Future<AudioPlayer> getPlayer(String audioUrl) async {
    if (_players.containsKey(audioUrl)) {
      return _players[audioUrl]!;
    }

    final player = AudioPlayer();
    _players[audioUrl] = player;
    
    // Try to get cached file first
    final cachedPath = await _getCachedFile(audioUrl);
    if (cachedPath != null) {
      await player.setFilePath(cachedPath);
    } else {
      await player.setUrl(audioUrl);
      _cacheFile(audioUrl);
    }

    return player;
  }

  Future<String?> _getCachedFile(String url) async {
    if (_cache.containsKey(url)) {
      return _cache[url];
    }
    
    final cacheDir = await getTemporaryDirectory();
    final file = File('${cacheDir.path}/${url.hashCode}');
    
    if (await file.exists()) {
      _cache[url] = file.path;
      return file.path;
    }
    
    return null;
  }

  Future<void> _cacheFile(String url) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final file = File('${cacheDir.path}/${url.hashCode}');
      
      if (!await file.exists()) {
        final response = await HttpClient().getUrl(Uri.parse(url));
        final httpResponse = await response.close();
        await httpResponse.pipe(file.openWrite());
        _cache[url] = file.path;
      }
    } catch (e) {
      print('Caching error: $e');
    }
  }

  void dispose(String audioUrl) {
    _players[audioUrl]?.dispose();
    _players.remove(audioUrl);
  }

  void disposeAll() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }

  Future<void> clearCache() async {
    final cacheDir = await getTemporaryDirectory();
    await cacheDir.delete(recursive: true);
    _cache.clear();
  }
} 