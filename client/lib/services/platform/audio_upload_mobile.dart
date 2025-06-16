import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../../models/story.dart';
import 'audio_upload_interface.dart';

class AudioUploadMobile implements AudioUploadPlatform {
  @override
  Future<Story> uploadAudio({
    required String baseUrl,
    required String? token,
    required String title,
    required String audioPath,
    required Duration duration,
    required List<double> waveformData,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/audio/upload');
      final request = http.MultipartRequest('POST', url);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.fields['title'] = title;
      request.fields['duration'] = duration.inMilliseconds.toString();
      request.fields['waveformData'] = jsonEncode(waveformData);

      final audioFile = File(audioPath);
      final audioBytes = await audioFile.readAsBytes();
      final file = http.MultipartFile.fromBytes(
        'audio',
        audioBytes,
        filename: 'audio.mp3',
        contentType: MediaType('audio', 'mpeg'),
      );
      request.files.add(file);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Story.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw error['message'] ?? 'Ses dosyası yüklenemedi';
      }
    } catch (e) {
      print('Mobile upload error: $e');
      throw e.toString();
    }
  }
} 