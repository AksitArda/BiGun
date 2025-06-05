import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

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
  final _audioRecorder = Record();
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  
  // Recording state
  bool _isRecording = false;
  bool _isLongPressing = false;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  String? _recordingPath;
  List<double> _waveformData = [];

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
    if (!kIsWeb) {
      final tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(path: _recordingPath!);
    } else {
      await _audioRecorder.start();
    }
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
      final normalized = (amplitude.current ?? -160) + 160;  // -160 to 0 range
      final value = (normalized / 160).clamp(0.0, 1.0);     // 0 to 1 range
      
      if (mounted) {
        setState(() {
          _recordingDuration += _sampleRate;
          _updateWaveformData(value);
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
      alignment: Alignment.center,
      children: [
        if (_isRecording && _waveformData.isNotEmpty)
          _buildWaveformVisualizer(),
        _buildRecordButton(),
      ],
    );
  }

  Widget _buildWaveformVisualizer() {
    return Container(
      width: 200,
      height: 60,
      margin: const EdgeInsets.only(bottom: 80),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          color: Colors.black26,
          padding: const EdgeInsets.all(8),
          child: CustomPaint(
            painter: WaveformPainter(
              waveformData: _waveformData,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 56,
            height: 56,
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
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;

  const WaveformPainter({
    required this.waveformData,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    _drawWaveform(canvas, size, paint);
  }

  void _drawWaveform(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final spacing = size.width / (waveformData.length - 1);
    final middle = size.height / 2;
    final scaleFactor = size.height / 2;

    // Draw upper half
    path.moveTo(0, middle);
    for (var i = 0; i < waveformData.length; i++) {
      final x = i * spacing;
      final amplitude = waveformData[i] * scaleFactor;
      path.lineTo(x, middle - amplitude);
    }

    // Draw lower half (mirror)
    path.lineTo(size.width, middle);
    for (var i = waveformData.length - 1; i >= 0; i--) {
      final x = i * spacing;
      final amplitude = waveformData[i] * scaleFactor;
      path.lineTo(x, middle + amplitude);
    }

    path.close();

    // Fill with semi-transparent color
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.1)
        ..style = PaintingStyle.fill,
    );

    // Draw outline
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData || oldDelegate.color != color;
  }
} 