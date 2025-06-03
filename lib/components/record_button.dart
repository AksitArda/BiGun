import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class RecordButton extends StatefulWidget {
  final Function(String path, Duration duration, List<double> waveformData) onRecordingComplete;

  const RecordButton({
    Key? key,
    required this.onRecordingComplete,
  }) : super(key: key);

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> with SingleTickerProviderStateMixin {
  late Record _audioRecorder;
  bool _isRecording = false;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  List<double> _waveformData = [];
  late AnimationController _animationController;
  double _buttonScale = 1.0;

  @override
  void initState() {
    super.initState();
    _audioRecorder = Record();
    _initRecorder();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Mikrofon izni gerekli');
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/temp_recording.m4a';
        
        await _audioRecorder.start(
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
          _waveformData = [];
          _buttonScale = 1.2;
        });

        _animationController.repeat(reverse: true);

        // Ses seviyesini dinle
        _recordingTimer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
          if (_isRecording) {
            final amplitude = await _audioRecorder.getAmplitude();
            final normalized = (amplitude.current ?? 0 + 160) / 160;
            setState(() {
              _recordingDuration += Duration(milliseconds: 100);
              _waveformData.add(normalized.clamp(0.0, 1.0));
            });
          }
        });
      }
    } catch (e) {
      print('Kayıt başlatma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt başlatılamadı: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      
      _recordingTimer?.cancel();
      _animationController.stop();
      
      setState(() {
        _isRecording = false;
        _buttonScale = 1.0;
      });

      if (path != null) {
        widget.onRecordingComplete(path, _recordingDuration, _waveformData);
      }
    } catch (e) {
      print('Kayıt durdurma hatası: $e');
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: AnimatedScale(
        scale: _buttonScale,
        duration: Duration(milliseconds: 200),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isRecording ? Colors.red : Colors.green,
            boxShadow: [
              BoxShadow(
                color: (_isRecording ? Colors.red : Colors.green).withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            Icons.mic,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
} 