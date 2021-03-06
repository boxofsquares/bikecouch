// Flutter
import 'package:flutter/services.dart';

// Dart
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

enum AnnotationRequestMode {
  URI,
  Base64String
}

class ComputerVision {
  static String _accessToken;
  static String _visionEndpoint = 'https://vision.googleapis.com//v1p3beta1/images:annotate';

  static Future<String> loadAsset() async {
    return await rootBundle.loadString('creds.json');
  }

  static Future<VisionResponse> annotateImage(String imageUri, AnnotationRequestMode mode) async {
    _accessToken = jsonDecode(await loadAsset())['google-api-key'];

    http.Response res = await http
        .post(_visionEndpoint + '?key=$_accessToken',
          body: _buildRequestString(imageUri, mode),
        )
        .timeout(new Duration(seconds: 4));

    if (res.statusCode == 200) {
      return VisionResponse.fromJSONResponse(json.decode(res.body));
    } else {
      throw Exception('Failed connecting to Vision API.');
    }
  }

  static String _buildRequestString(String imageSource, AnnotationRequestMode mode) {
    Map<String,dynamic> imageOpts;
    switch(mode) {
      case AnnotationRequestMode.URI:
        imageOpts = {'source': {'imageUri': imageSource}};
        break;
      case AnnotationRequestMode.Base64String:
        imageOpts = {'content': imageSource};
        break;
    }
    String encodedString = jsonEncode({
      'requests' : 
      [
        {
          'features': [
            {'type': 'LABEL_DETECTION'}
          ],
          'image': imageOpts
        }
      ]
    });
    return encodedString;
  }
}

class VisionResponse {
  final List<LabelAnnotation> annotations;

  VisionResponse({this.annotations});

  factory VisionResponse.fromJSONResponse(Map<String, dynamic> jsonResponse) {
    List<Map<String, dynamic>> objs =
        jsonResponse['responses'][0]['labelAnnotations'].cast<Map<String,dynamic>>();
    if (objs == null) {
      throw Exception('DataVision: ${jsonResponse["responses"][0]["error"]["message"]}');
    }
    List<LabelAnnotation> annotations = objs.map((map) {
      return new LabelAnnotation(
        mid: map['mid'],
        description: map['description'],
        score: map['score'],
        topicality: map['topicality'],
      );
    }).toList();
    return new VisionResponse(
      annotations: annotations,
    );
  }
}

class LabelAnnotation {
  final String mid;
  final String description;
  final double score;
  final double topicality;

  LabelAnnotation({this.mid, this.description, this.score, this.topicality});
}
