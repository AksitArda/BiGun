import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import '../models/story.dart';
import 'audio_wave_visualizer.dart';

class AudioStoryCard extends StatefulWidget {
  final Story story;

  const AudioStoryCard({
    Key? key,
    required this.story,
  }) : super(key: key);

  @override
  State<AudioStoryCard> createState() => _AudioStoryCardState();
}

class _AudioStoryCardState extends State<AudioStoryCard> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  double _playbackProgress = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _audioPlayer = AudioPlayer();
    
    // Ses dosyasını yükle
    try {
      await _audioPlayer.setUrl(widget.story.audioUrl);
      
      // İlerlemeyi takip et
      _audioPlayer.positionStream.listen((position) {
        if (mounted && !_isDragging) {
          final duration = _audioPlayer.duration ?? Duration.zero;
          setState(() {
            _playbackProgress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;
          });
        }
      });

      // Oynatma durumunu takip et
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
    } catch (e) {
      print('Ses yükleme hatası: $e');
    }
  }

  Future<void> _seekTo(double position) async {
    try {
      final duration = _audioPlayer.duration;
      if (duration != null) {
        _isDragging = true;
        setState(() {
          _playbackProgress = position;
        });
        
        final seekPosition = duration * position;
        await _audioPlayer.seek(seekPosition);
        
        _isDragging = false;

        // Eğer ses çalmıyorsa otomatik başlat
        if (!_isPlaying) {
          await _audioPlayer.play();
        }
      }
    } catch (e) {
      print('Ses konumlandırma hatası: $e');
    }
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      print('Ses çalma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ses çalınamadı: $e')),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH:mm').format(widget.story.time);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _togglePlayback,
                  child: Row(
                    children: [
                      Hero(
                        tag: 'avatar_${widget.story.id}',
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(widget.story.avatarUrl),
                          radius: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isPlaying ? Colors.green : Colors.white.withOpacity(0.1),
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: _isPlaying ? Colors.white : Colors.white70,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.story.username,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (widget.story.waveformData != null)
                        AudioWaveVisualizer(
                          waveformData: widget.story.waveformData!,
                          isPlaying: _isPlaying,
                          progress: _playbackProgress,
                          onSeek: _seekTo,
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  timeString,
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          if (widget.story.comments.isNotEmpty)
            Container(
              padding: EdgeInsets.only(left: 68, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.story.comments.map((comment) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(comment.avatarUrl),
                          radius: 12,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment.username,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                comment.text,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
} 