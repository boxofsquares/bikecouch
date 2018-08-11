import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as im;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
class Bucket {
  static final FirebaseStorage _bucket = FirebaseStorage.instance;

  static uploadFile(String filePath, String uuid) async {
    // List<String> s = filePath.split('/');
    final StorageReference ref = _bucket.ref().child('$uuid.jpg');
    final File imageFile = File(filePath);
    // NOTE: Hoping that decodeJpg is slightly more efficient than
    // the generic decodeImage
    // final im.Image image = im.decodeJpg(imageFile.readAsBytesSync());
    // final im.Image imageSmall = im.copyResize(image, 640);

    // imageFile.writeAsBytesSync(im.encodeJpg(imageFile, quality: 85), mode: FileMode.write);
    final StorageUploadTask uploadTask = ref.putFile(
      imageFile,
      StorageMetadata(contentType: 'image/jpg')
    );
    
    final Uri downloadUrl = (await uploadTask.future).downloadUrl;
    print(downloadUrl);
    // return downloadUrl.toString();
  }

  static String imageToBase64String(String filePath) {
    final File imageFile = File(filePath);
    // NOTE: This is A LOT faster than decodeing the image, resizing it,
    // and then storing it to the bucket.
    String s = base64Encode(imageFile.readAsBytesSync());
    print(s.length);
    return s;
  }
}