import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class Bucket {
  static final FirebaseStorage _bucket = FirebaseStorage.instance;

  static Future<String> uploadFile(String filePath) async {
    List<String> s = filePath.split('/');
    final StorageReference ref = _bucket.ref().child(s[s.length - 1]);
    final File image = File(filePath);
    final StorageUploadTask uploadTask = ref.putFile(
      image,
      StorageMetadata(contentType: 'image/jpg')
    );

    final Uri downloadUrl = (await uploadTask.future).downloadUrl;
    return downloadUrl.toString();
  }
}