import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

/// Ses seviyesi hesaplama sınıfı
class AudioLevelCalculator {
  static const double _minDb = -45.0;
  static const double _maxDb = 0.0;
  static const double _dbRange = _maxDb - _minDb;
  
  /// Ham amplitude değerini 0-1 arasında normalize edilmiş bir değere dönüştürür
  static double calculateNormalizedLevel(Amplitude amplitude) {
    final double current = amplitude.current ?? _minDb;
    final double normalized = (current - _minDb) / _dbRange;
    return normalized.clamp(0.0, 1.0);
  }
  
  /// Normalize edilmiş değeri yumuşatır
  static double smoothLevel(double currentLevel, double previousLevel) {
    const double smoothingFactor = 0.6;
    return (previousLevel * smoothingFactor) + (currentLevel * (1 - smoothingFactor));
  }
}

/// A button widget that handles audio recording with visual feedback.
/// Long press to start recording, release to stop.
class RecordButton extends StatefulWidget {
  /// Callback function that provides the recorded audio file path,
  /// duration, and waveform data when recording is complete.
  final Function(String path, Duration duration, List<double> waveformData) onRecordingComplete;

  const RecordButton({
    Key? key,
    required this.onRecordingComplete,
  }) : super(key: key);

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> with SingleTickerProviderStateMixin {
  // Constants
  static const int _maxWaveformPoints = 50;
  static const Duration _sampleRate = Duration(milliseconds: 50);
  
  // Controllers and core state
  final _audioRecorder = AudioRecorder();
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  
  // Recording state
  bool _isRecording = false;
  bool _isLongPressing = false;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  String? _recordingPath;
  List<double> _waveformData = [];
  double _previousLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initRecorder();
  }

  void _initializeControllers() {
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _initRecorder() async {
    try {
      if (!kIsWeb) {
        await _requestMobilePermissions();
      } else if (!await _audioRecorder.hasPermission()) {
        throw Exception('Mikrofon izni gerekli');
      }
    } catch (e) {
      _handleError('Recorder init hatası', e);
    }
  }

  Future<void> _requestMobilePermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Mikrofon izni gerekli');
    }

    final tempDir = await getTemporaryDirectory();
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }
  }

  Future<void> _startRecording() async {
    try {
      if (!await _audioRecorder.hasPermission()) return;

      await _initializeRecording();
      await _startRecordingSession();
      _startWaveformUpdates();
    } catch (e) {
      _handleError('Kayıt başlatılamadı', e);
    }
  }

  Future<void> _initializeRecording() async {
    final tempPath = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    
    if (!kIsWeb) {
      final tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/$tempPath';
    } else {
      _recordingPath = tempPath;
    }
    
    await _audioRecorder.start(
      RecordConfig(encoder: AudioEncoder.aacLc),
      path: _recordingPath!,
    );
  }

  Future<void> _startRecordingSession() async {
    _scaleController.forward();
    setState(() {
      _isRecording = true;
      _isLongPressing = true;
      _recordingDuration = Duration.zero;
      _waveformData = [];
    });
  }

  void _startWaveformUpdates() {
    _recordingTimer = Timer.periodic(_sampleRate, (timer) async {
      if (!_isRecording) return;
      
      final amplitude = await _audioRecorder.getAmplitude();
      final currentLevel = AudioLevelCalculator.calculateNormalizedLevel(amplitude);
      final smoothedLevel = AudioLevelCalculator.smoothLevel(currentLevel, _previousLevel);
      
      if (mounted) {
        setState(() {
          _recordingDuration += _sampleRate;
          _updateWaveformData(smoothedLevel);
          _previousLevel = smoothedLevel;
        });
      }
    });
  }

  void _updateWaveformData(double value) {
    _waveformData.add(value);
    if (_waveformData.length > _maxWaveformPoints) {
      _waveformData.removeAt(0);
    }
  }

  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();
      _scaleController.reverse();
      
      final path = await _audioRecorder.stop();
      
      setState(() {
        _isRecording = false;
        _isLongPressing = false;
      });

      if (kIsWeb) {
        if (path != null) {
          widget.onRecordingComplete(path, _recordingDuration, _waveformData);
        }
      } else if (path != null && File(path).existsSync()) {
        widget.onRecordingComplete(path, _recordingDuration, _waveformData);
      }
    } catch (e) {
      _handleError('Kayıt durdurma hatası', e);
    }
  }

  void _handleError(String message, dynamic error) {
    print('$message: $error');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$message: $error')),
      );
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          bottom: _isRecording ? 100 : 20,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isRecording ? 1.0 : 0.0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kaydediliyor...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_waveformData.isNotEmpty)
                    Container(
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CustomPaint(
                          painter: WaveformPainter(
                            waveformData: _waveformData,
                            color: Colors.green,
                            isRecording: true,
                          ),
                          size: Size.fromHeight(60),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(_recordingDuration),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 56,
          height: 56,
          child: GestureDetector(
            onLongPressStart: (_) => _startRecording(),
            onLongPressEnd: (_) => _stopRecording(),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.red : Colors.green).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: _isLongPressing ? 4 : 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final bool isRecording;

  const WaveformPainter({
    required this.waveformData,
    required this.color,
    this.isRecording = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final barWidth = 3.0;
    final spacing = 3.0;
    final totalBarWidth = barWidth + spacing;
    final middle = size.height / 2;
    
    // Kaç çubuk sığabileceğini hesapla
    final maxBars = (size.width / totalBarWidth).floor();
    final startX = (size.width - (maxBars * totalBarWidth)) / 2;

    // Gradient tanımla
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color,
        color.withOpacity(0.5),
      ],
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height)
      );

    // WhatsApp tarzı minimum yükseklik
    const minHeight = 4.0;
    const maxHeight = 20.0;

    // Her bir çubuğu çiz
    for (var i = 0; i < maxBars && i < waveformData.length; i++) {
      final x = startX + (i * totalBarWidth);
      final amplitude = waveformData[i].clamp(0.0, 1.0);
      
      // Yüksekliği hesapla (minimum 4 piksel)
      final height = minHeight + (amplitude * (maxHeight - minHeight));
      
      // Üst ve alt çubukları çiz
      final topRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          middle - height,
          barWidth,
          height
        ),
        Radius.circular(barWidth / 2)
      );

      final bottomRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          middle,
          barWidth,
          height
        ),
        Radius.circular(barWidth / 2)
      );

      canvas.drawRRect(topRect, paint);
      canvas.drawRRect(bottomRect, paint);
    }

    // Kayıt sırasında parlama efekti
    if (isRecording) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

      for (var i = 0; i < maxBars && i < waveformData.length; i++) {
        final x = startX + (i * totalBarWidth);
        final amplitude = waveformData[i].clamp(0.0, 1.0);
        final height = minHeight + (amplitude * (maxHeight - minHeight));

        final topRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            middle - height,
            barWidth,
            height
          ),
          Radius.circular(barWidth / 2)
        );

        final bottomRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            middle,
            barWidth,
            height
          ),
          Radius.circular(barWidth / 2)
        );

        canvas.drawRRect(topRect, glowPaint);
        canvas.drawRRect(bottomRect, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData ||
           oldDelegate.color != color ||
           oldDelegate.isRecording != isRecording;
  }
} 