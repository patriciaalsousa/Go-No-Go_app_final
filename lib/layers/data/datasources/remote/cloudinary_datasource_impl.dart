import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/cloudinary_config.dart';
import '../cloudinary_datasource.dart';
import 'package:flutter/foundation.dart';

class CloudinaryDataSourceImpl implements CloudinaryDataSource {
  @override
  Future<String?> uploadToCloud(XFile imageFile) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload');

    final request = http.MultipartRequest('POST', url);

    request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;

    request.fields['folder'] = 'gonogo';

    final bytes = await imageFile.readAsBytes();

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: imageFile.name,
    ));

    try {
      final response = await request.send();

      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(responseString);
        // Retorna a URL segura (https)
        return jsonMap['secure_url'];
      } else {
        if (kDebugMode) {
          print('Erro Cloudinary: ${response.statusCode}');
          print('Detalhes do erro: $responseString');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception Cloudinary: $e');
      }
      return null;
    }
  }
}
