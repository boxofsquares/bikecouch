import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as im;
import 'dart:convert';

import 'dart:async';
import 'dart:io';

import '../utils/bucket.dart';
import '../utils/vision.dart';

import '../pages/challenge_results_page.dart';

class CameraPage extends StatefulWidget {
  CameraPage({this.cameras, this.challengeWords});
  final List<CameraDescription> cameras;
  final Set<String> challengeWords;

  @override
  _CameraPageState createState() => new _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController controller;
  String imagePath;
  bool _isLoading;
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    _isLoading = false;
    super.initState();
    controller = new CameraController(widget.cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  _uploadPhoto(String filePath) async {
    // String url = await Bucket.uploadFile(filePath);

    final File imageFile = File(filePath);
    final im.Image src = im.decodeJpg(imageFile.readAsBytesSync());
    im.Image left = im.copyCrop(src, 0, 0, src.width ~/ 2, src.height);
    im.Image right = im.copyCrop(src, src.width ~/ 2, 0, src.width ~/ 2, src.height);

    String leftb64 = base64Encode(left.getBytes());
    String rightb64 = base64Encode(right.getBytes());


    // String b64 = Bucket.imageToBase64String(filePath);
    VisionResponse vs = await ComputerVision.annotateImage(
        leftb64, AnnotationRequestMode.Base64String);
    bool success = vs.annotations.any((annotation) {
      return widget.challengeWords.any((word) {
        return annotation.description == word;
      });
    });
    Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChallengeResults(
                success: success,
              ),
        ));
    // free resources
    setState(() => _isLoading = false);
    File(filePath).delete();
  }

  _makeSnackBar(String message) {
    final snackbar = SnackBar(
      content: Text(message)
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  _takePhoto() {
    setState(() => _isLoading = true);
    _takePhotoWrapper()
      .then((filePath) {
        if (mounted) {
          // setState(() => imagePath = filePath);
          _uploadPhoto(filePath);
        }
        if (filePath != null) {
          print('image saved to $filePath');
        }
      })
      .catchError((e) => setState(() {
        _isLoading = false;
        _makeSnackBar(e);
      })
      );
  }

  Future<String> _takePhotoWrapper() async {
    print('taking picture');
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      print('already taking picture!!!');
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
  }

  String timestamp() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {

    final rounded = Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: MediaQuery.of(context).size.width * 0.10,
            color: Colors.black12,
          )
        )
      ),
    );

    final overlay = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        rounded,
        rounded,
      ]
    );
  

    if (!controller.value.isInitialized) {
      return new Container();
    }
    return Scaffold(
      key: _scaffoldKey, 
      body: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio:
            controller.value.aspectRatio,
            child: CameraPreview(controller)
          ),
          _isLoading ? Center(
            child: CircularProgressIndicator(),
          ) : Text(''),
          overlay,
        ],
        
      ),
      floatingActionButton: FloatingActionButton(
        child: RotatedBox(
          quarterTurns: 1,
          child:Icon(Icons.camera_alt)
        ),
        onPressed: () => _takePhoto(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
