import '../../models/story.dart';

abstract class AudioUploadPlatform {
  Future<Story> uploadAudio({
    required String baseUrl,
    required String? token,
    required String title,
    required String audioPath,
    required Duration duration,
    required List<double> waveformData,
  });
} 