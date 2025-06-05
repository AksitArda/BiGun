import 'package:flutter/material.dart';

class AudioWaveVisualizer extends StatelessWidget {
  final List<double> waveformData;
  final bool isPlaying;
  final double progress; // 0.0 to 1.0
  final Function(double position)? onSeek; // Yeni eklenen seek callback

  const AudioWaveVisualizer({
    Key? key,
    required this.waveformData,
    required this.isPlaying,
    required this.progress,
    this.onSeek,
  }) : super(key: key);

  void _handleTapDown(TapDownDetails details, BoxConstraints constraints) {
    if (onSeek != null) {
      final tapPosition = details.localPosition.dx;
      final seekPosition = (tapPosition / constraints.maxWidth).clamp(0.0, 1.0);
      onSeek!(seekPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) => _handleTapDown(details, constraints),
          child: Container(
            height: 40,
            child: CustomPaint(
              painter: WaveformPainter(
                waveformData: waveformData,
                progress: progress,
                color: Colors.grey[600]!.withOpacity(0.5),
                progressColor: Colors.white,
                isInteractive: onSeek != null,
              ),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double progress;
  final Color color;
  final Color progressColor;
  final bool isInteractive;

  WaveformPainter({
    required this.waveformData,
    required this.progress,
    required this.color,
    required this.progressColor,
    this.isInteractive = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / waveformData.length;
    final progressWidth = size.width * progress;

    for (var i = 0; i < waveformData.length; i++) {
      final x = i * barWidth;
      final height = waveformData[i] * size.height * 0.7; // Biraz daha küçük barlar
      final top = (size.height - height) / 2;

      // Çizgi rengi, progress'e göre değişiyor
      paint.color = x <= progressWidth ? progressColor : color;

      canvas.drawLine(
        Offset(x + barWidth / 2, top),
        Offset(x + barWidth / 2, top + height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.progressColor != progressColor;
  }
} 