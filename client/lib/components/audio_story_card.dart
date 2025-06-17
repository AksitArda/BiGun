import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import '../models/story.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AudioWaveVisualizer extends StatelessWidget {
  final List<double> waveformData;
  final bool isPlaying;
  final double progress;
  final Function(double position)? onSeek;

  const AudioWaveVisualizer({
    Key? key,
    required this.waveformData,
    required this.isPlaying,
    required this.progress,
    this.onSeek,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) {
            if (onSeek != null) {
              final tapPosition = details.localPosition.dx;
              final seekPosition = (tapPosition / constraints.maxWidth).clamp(0.0, 1.0);
              onSeek!(seekPosition);
            }
          },
          child: Container(
            height: 48,
            child: CustomPaint(
              painter: WaveformPainter(
                waveformData: _processWaveformData(waveformData, constraints.maxWidth),
                progress: progress,
                color: Colors.grey[600]!,
                progressColor: Colors.green,
                isPlaying: isPlaying,
              ),
              size: Size(constraints.maxWidth, 48),
            ),
          ),
        );
      },
    );
  }

  List<double> _processWaveformData(List<double> originalData, double width) {
    if (originalData.isEmpty) return List.filled(50, 0.5);
    
    // Ekran genişliğine göre nokta sayısını ayarla
    int targetPoints = (width / 3).floor(); // Her 3 piksel için 1 nokta
    targetPoints = targetPoints.clamp(50, 200); // Min 50, max 200 nokta
    
    if (originalData.length == targetPoints) return originalData;
    
    List<double> processedData = [];
    double step = originalData.length / targetPoints;
    
    for (int i = 0; i < targetPoints; i++) {
      int startIdx = (i * step).floor();
      int endIdx = ((i + 1) * step).floor();
      endIdx = endIdx.clamp(0, originalData.length);
      
      if (startIdx >= endIdx) {
        processedData.add(originalData[startIdx]);
        continue;
      }
      
      // Bu aralıktaki değerlerin ortalamasını al
      double sum = 0;
      for (int j = startIdx; j < endIdx; j++) {
        sum += originalData[j];
      }
      processedData.add(sum / (endIdx - startIdx));
    }
    
    return processedData;
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double progress;
  final Color color;
  final Color progressColor;
  final bool isPlaying;

  const WaveformPainter({
    required this.waveformData,
    required this.progress,
    required this.color,
    required this.progressColor,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final barWidth = size.width / waveformData.length;
    final spacing = barWidth * 0.2; // Çubuklar arası boşluk
    final drawWidth = barWidth - spacing;
    
    final centerY = size.height / 2;
    final maxBarHeight = size.height * 0.8; // Maksimum çubuk yüksekliği
    
    final progressWidth = size.width * progress;
    
    for (int i = 0; i < waveformData.length; i++) {
      final x = i * barWidth;
      final amplitude = waveformData[i].clamp(0.0, 1.0);
      
      // Çubuk yüksekliğini hesapla
      final barHeight = maxBarHeight * amplitude;
      final halfBarHeight = barHeight / 2;
      
      // Çubuğun başlangıç ve bitiş noktaları
      final top = centerY - halfBarHeight;
      final bottom = centerY + halfBarHeight;
      
      final paint = Paint()
        ..color = x <= progressWidth ? progressColor : color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = drawWidth;
      
      // Yuvarlak köşeli çubuk çiz
      canvas.drawLine(
        Offset(x + drawWidth / 2, top),
        Offset(x + drawWidth / 2, bottom),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.isPlaying != isPlaying ||
           oldDelegate.waveformData != waveformData;
  }
}

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _audioPlayer = AudioPlayer();
    
    try {
      await _audioPlayer.setUrl(widget.story.audioUrl);
      setState(() => _isLoading = false);
      
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

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
    } catch (e) {
      print('Ses yükleme hatası: $e');
      setState(() => _isLoading = false);
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH:mm').format(widget.story.time);
    final duration = _audioPlayer.duration ?? Duration.zero;
    final position = duration * _playbackProgress;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'avatar_${widget.story.id}',
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: CachedNetworkImageProvider(widget.story.avatarUrl),
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
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        timeString,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _isLoading
                    ? SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: Colors.green,
                          size: 40,
                        ),
                        onPressed: _togglePlayback,
                      ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      if (widget.story.waveformData != null)
                        AudioWaveVisualizer(
                          waveformData: widget.story.waveformData!,
                          isPlaying: _isPlaying,
                          progress: _playbackProgress,
                          onSeek: _seekTo,
                        ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 