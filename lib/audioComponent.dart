// lib/audio_player_component.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

enum PlayerState {
  stopped,
  playing,
  paused,
  loading,
  error,
}

class AudioPlayerComponent extends StatefulWidget {
  final String audioUrl;
  final String? title; // Opsiyonel başlık

  const AudioPlayerComponent({
    super.key,
    required this.audioUrl,
    this.title,
  });

  @override
  State<AudioPlayerComponent> createState() => _AudioPlayerComponentState();
}

class _AudioPlayerComponentState extends State<AudioPlayerComponent> {
  FlutterSoundPlayer? _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription?
      _playerSubscription; // Oynatma ilerlemesini takip etmek için

  @override
  void initState() {
    super.initState();
    _audioPlayer = FlutterSoundPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    setState(() {
      _playerState = PlayerState.loading;
    });

    // Ses çalma için sadece internet izni yeterlidir.
    // Ancak bazı player'ların init olması için RECORD_AUDIO iznine ihtiyaç duyduğu
    // durumlar olabilir (genellikle kayıt işlevselliği ile birlikte).
    // Sadece çalma için gerekmeyebilir, ama hata alırsanız eklemeyi düşünebilirsiniz.
    var status = await Permission.microphone
        .request(); // Mikrofon izni genellikle kayıt için, ama player'ın init'i için bazen gerekebilir.

    if (status.isGranted || status.isLimited) {
      // isLimited iOS 14+ için geçerli
      try {
        await _audioPlayer!.openPlayer();
        _playerState = PlayerState.stopped; // Başlangıçta durdurulmuş
        print('AudioPlayerComponent: Player initialized successfully.');
      } catch (e) {
        print('AudioPlayerComponent: Player initialization error: $e');
        setState(() {
          _playerState = PlayerState.error;
        });
      }
    } else {
      print('AudioPlayerComponent: Permissions denied for audio playback.');
      setState(() {
        _playerState = PlayerState.error;
      });
      _showSnackBar('Ses çalma için izinler gerekli.');
    }

    setState(() {
      // İzinler reddedilmezse veya hata oluşmazsa state'i güncelleyin
      if (_playerState != PlayerState.error) {
        _playerState = PlayerState.stopped;
      }
    });
  }

  Future<void> _play() async {
    if (_audioPlayer == null) {
      _showSnackBar('Oynatıcı hazır değil, lütfen bekleyin.');
      return;
    }

    setState(() {
      _playerState = PlayerState.loading;
    });

    try {
      await _audioPlayer!.startPlayer(
        fromURI: widget.audioUrl,
        codec: Codec
            .mp3, // Ses dosyanızın codec'ine göre ayarlayın (mp3, aac, etc.)
        whenFinished: () {
          setState(() {
            _playerState = PlayerState.stopped;
          });
          print('AudioPlayerComponent: Playback finished.');
        },
      );
      setState(() {
        _playerState = PlayerState.playing;
      });
      print('AudioPlayerComponent: Started playing from ${widget.audioUrl}');

      // İlerleme takibi (opsiyonel)
      _playerSubscription = _audioPlayer!.onProgress!.listen((e) {
        // print('AudioPlayerComponent: Current position: ${e.position}');
        // UI'da ilerleme çubuğu göstermek isterseniz burada güncelleyebilirsiniz.
      });
    } catch (e) {
      print('AudioPlayerComponent: Playback error: $e');
      setState(() {
        _playerState = PlayerState.error;
      });
      _showSnackBar('Ses çalınamadı: $e');
    }
  }

  Future<void> _pause() async {
    if (_audioPlayer == null || !_audioPlayer!.isPlaying) return;
    try {
      await _audioPlayer!.pausePlayer();
      setState(() {
        _playerState = PlayerState.paused;
      });
      print('AudioPlayerComponent: Paused playback.');
    } catch (e) {
      print('AudioPlayerComponent: Pause error: $e');
      _showSnackBar('Durdurma hatası: $e');
    }
  }

  Future<void> _resume() async {
    if (_audioPlayer == null || !_audioPlayer!.isPaused) return;
    try {
      await _audioPlayer!.resumePlayer();
      setState(() {
        _playerState = PlayerState.playing;
      });
      print('AudioPlayerComponent: Resumed playback.');
    } catch (e) {
      print('AudioPlayerComponent: Resume error: $e');
      _showSnackBar('Devam ettirme hatası: $e');
    }
  }

  Future<void> _stop() async {
    if (_audioPlayer == null) return;
    try {
      await _audioPlayer!.stopPlayer();
      _playerSubscription?.cancel(); // Aboneliği iptal et
      setState(() {
        _playerState = PlayerState.stopped;
      });
      print('AudioPlayerComponent: Stopped playback.');
    } catch (e) {
      print('AudioPlayerComponent: Stop error: $e');
      _showSnackBar('Durdurma hatası: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Widget _buildPlayButton() {
    switch (_playerState) {
      case PlayerState.loading:
        return const CircularProgressIndicator();
      case PlayerState.playing:
        return IconButton(
          icon: const Icon(Icons.pause, size: 40),
          onPressed: _pause,
          color: Colors.blue,
        );
      case PlayerState.paused:
        return IconButton(
          icon: const Icon(Icons.play_arrow, size: 40),
          onPressed: _resume,
          color: Colors.blue,
        );
      case PlayerState.stopped:
      case PlayerState.error:
      default:
        return IconButton(
          icon: const Icon(Icons.play_arrow, size: 40),
          onPressed: _play,
          color: Colors.green,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.title != null)
              Text(
                widget.title!,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildPlayButton(),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.stop, size: 40),
                  onPressed: _stop,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Durum: ${_playerState.name.toUpperCase()}',
              style: TextStyle(
                color: _playerState == PlayerState.error
                    ? Colors.red
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'URL: ${widget.audioUrl}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playerSubscription?.cancel(); // Aboneliği iptal et
    _audioPlayer!.closePlayer();
    _audioPlayer = null;
    print('AudioPlayerComponent: Player disposed.');
    super.dispose();
  }
}
