import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import '../../models/story.dart';
import 'audio_upload_interface.dart';

class AudioUploadWeb implements AudioUploadPlatform {
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
      // Web'de dosyayı doğru şekilde oku
      final response = await html.HttpRequest.request(
        audioPath,
        responseType: 'arraybuffer',
      );

      final buffer = response.response as ByteBuffer;
      final Uint8List audioData = buffer.asUint8List();
      final blob = html.Blob([audioData], 'audio/mpeg');
      final formData = html.FormData();

      // FormData'ya dosyayı ekle
      formData.appendBlob('audio', blob, 'audio.mp3');
      formData.append('title', title);
      formData.append('duration', duration.inMilliseconds.toString());
      formData.append('waveformData', jsonEncode(waveformData));

      final request = html.HttpRequest();
      final completer = Completer<Story>();

      request.open('POST', '$baseUrl/audio/upload');
      if (token != null) {
        request.setRequestHeader('Authorization', 'Bearer $token');
      }

      request.onLoad.listen((e) {
        if (request.status == 201) {
          final data = json.decode(request.responseText!);
          completer.complete(Story.fromJson(data));
        } else {
          completer.completeError('Upload failed: ${request.statusText}');
        }
      });

      request.onError.listen((e) {
        completer.completeError('Upload error: $e');
      });

      request.send(formData);
      return await completer.future;
    } catch (e) {
      print('Web upload error: $e');
      throw e.toString();
    }
  }
}
