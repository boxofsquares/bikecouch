import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';
import 'dart:io';

import '../utils/bucket.dart';
import '../utils/vision.dart';

import '../pages/test_annotations.dart';



class CameraPage extends StatefulWidget {
  CameraPage({this.cameras});
  final List<CameraDescription> cameras;

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
    String url = await Bucket.uploadFile(filePath);
    VisionResponse vs = await ComputerVision.annotateImage(url);
    setState(() => _isLoading = false);
    Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TestAnnotations(
                vs: vs,
              ),
        )
    );
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
          ) : Text('')
        ],
        
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () => _takePhoto(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}