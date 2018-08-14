import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as im;
import 'dart:convert';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:io';

import '../utils/bucket.dart';
import '../utils/vision.dart';

import '../models/app_state.dart';
import '../app_state_container.dart';

import '../pages/challenge_results_page.dart';

import 'package:http/http.dart' as http;

class CameraPage extends StatefulWidget {
  CameraPage({this.cameras, this.challengeWords});
  final List<CameraDescription> cameras;
  final Set<String> challengeWords;

  @override
  _CameraPageState createState() => new _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  AppState appState;
  CameraController controller;
  GlobalKey leftFocusBoxKey = GlobalKey();
  GlobalKey rightFocusBoxKey = GlobalKey();
  GlobalKey _cameraBoxKey = GlobalKey();
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

    // final File imageFile = File(filePath);
    // final im.Image src = Image(image: imageFile.readAsBytesSync());
    // im.Image left = im.copyCrop(src, 0, 0, src.width ~/ 2, src.height);
    // im.Image right = im.copyCrop(src, src.width ~/ 2, 0, src.width ~/ 2, src.height);

    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (context) => DisplayImagesTest(
    //     left: left.getBytes(),
    //     right: right.getBytes()
    //   )
    // ));

    // String leftb64 = base64Encode(left.getBytes());
    // String rightb64 = base64Encode(right.getBytes());

    String b64 = Bucket.imageToBase64String(filePath);
    String url =
        'https://us-central1-bikecouch.cloudfunctions.net/resize-crop-and-label';

    http.post(url, headers: {
      'uuid': '${appState.user.uuid}'
    }, body: {
      'image': b64,
      'left': widget.challengeWords.first,
      'right': widget.challengeWords.last,
      'anchors': jsonEncode(getFocusAnchors()),
    }).then(((response) {
      setState(() => _isLoading = false);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChallengeResults(
                  success: json.decode(response.body)['result'],
                ),
          ));
    }));
    // Bucket.uploadFile(filePath, appState.user.uuid);

    // VisionResponse vs = await ComputerVision.annotateImage(
    //     b64, AnnotationRequestMode.Base64String);
    // bool success = vs.annotations.any((annotation) {
    //   return widget.challengeWords.any((word) {
    //     return annotation.description == word;
    //   });
    // });
    // Navigator.of(context).push(MaterialPageRoute(
    //       builder: (context) => ChallengeResults(
    //             success: success,
    //           ),
    //     ));
    // free resources

    File(filePath).delete();
  }

  _makeSnackBar(String message) {
    final snackbar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  _takePhotoWrapper() {
    setState(() => _isLoading = true);
    _takePhoto().then((filePath) {
      if (mounted) {
        // setState(() => imagePath = filePath);
        _uploadPhoto(filePath);
      }
      if (filePath != null) {
        print('image saved to $filePath');
      }
    }).catchError((e) => setState(() {
          setState(() => _isLoading = false);
          _makeSnackBar(e);
        }));
  }

  Future<String> _takePhoto() async {
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
    var container = AppStateContainer.of(context);
    appState = container.state;

    final overlay = Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          createFocusBox(leftFocusBoxKey),
          createFocusBox(rightFocusBoxKey),
        ]);

    if (!controller.value.isInitialized) {
      return new Container();
    }

    return Scaffold(
      key: _scaffoldKey,
      body: new Container(
        color: Colors.black,
        child: new Column(
          children: <Widget>[
            new AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: new Stack(
                children: <Widget>[
                  Center(
                    key: _cameraBoxKey,
                    child: CameraPreview(controller)),
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Text(''),
                  overlay,
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: RotatedBox(quarterTurns: 1, child: Icon(Icons.camera_alt)),
        onPressed: () => _takePhotoWrapper(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget createFocusBox(Key key) {
    final borderWidth = MediaQuery.of(context).size.width * 0.10;
    final borderShade = Colors.black12;
    return Expanded(
      child: Container(
        key: key,
        decoration: BoxDecoration(
          border: BorderDirectional(
            top: BorderSide(
              width: borderWidth / 2,
              color: borderShade,
            ),
            bottom: BorderSide(
              width: borderWidth / 2,
              color: borderShade,
            ),
            start: BorderSide(
              width: borderWidth,
              color: borderShade,
            ),
            end: BorderSide(
              width: borderWidth,
              color: borderShade,
            ),
          )
        )
      )
    );
  }

  /*
    Calculates the UI overlay position anchors for better cropping of the taken image.
    TODO: Allow resizing of the overlay boxes./
  */
  Object getFocusAnchors() {
    RenderBox cameraBox = _cameraBoxKey.currentContext.findRenderObject();
    final cameraHeight = cameraBox.paintBounds.height;
    final cameraWidth = cameraBox.paintBounds.width;

    // NOTE: This is a copy-paste from #createFocusBox, should be pulled out into a constant.
    final shadowWidth = MediaQuery.of(context).size.width * 0.10;

    // Extract the focusbox position and width MINUS the border.
    RenderBox leftBox = leftFocusBoxKey.currentContext.findRenderObject();
    RenderBox rightBox = rightFocusBoxKey.currentContext.findRenderObject();
    Offset leftBoxOffsetRaw = cameraBox.globalToLocal(leftBox.localToGlobal(leftBox.paintBounds.topLeft));
    Offset leftBoxOffset = Offset(leftBoxOffsetRaw.dy + shadowWidth / 2, leftBoxOffsetRaw.dx + shadowWidth);
    final leftBoxWidth = leftBox.paintBounds.width - 2 * shadowWidth;
    final leftBoxHeight = leftBox.paintBounds.height - shadowWidth;
    Offset rightBoxOffsetRaw = cameraBox.globalToLocal(rightBox.localToGlobal(rightBox.paintBounds.topLeft));
    Offset rightBoxOffset = Offset(rightBoxOffsetRaw.dy + shadowWidth / 2, rightBoxOffsetRaw.dx + shadowWidth);
    final rightBoxWidth = rightBox.paintBounds.width - 2 * shadowWidth;
    final rightBoxHeight = rightBox.paintBounds.height - shadowWidth;
 
  
    /*
    All returned sizes are RELATIVE to the full image size.
    That is necessary becasue the UI does not render in the same resolution as the camera.
    Alternativley, all sizes could be scaled UP to the full image resoltion, which one must know beforehand.

                       WIDTH
                  ---------------
                  |             |
                  |             |
                  |             |
         HEIGHT   |             |
                  |             |
                  |             |
                  |             |
                  |             |
                  |             |
                  |  <  @  []   |
    */
    return {
      'camera': 
        {
          // This is UI pixesl !!!
          'height': cameraBox.paintBounds.height,
        },
      'left': 
        {
          'dy_offset': leftBoxOffset.dy / cameraHeight,
          'width': leftBoxWidth / cameraWidth,
          'height': leftBoxHeight / cameraHeight,
        },
      'right':
        {
          'dy_offset': rightBoxOffset.dy / cameraHeight,
          'width': rightBoxWidth / cameraWidth,
          'height': rightBoxHeight / cameraHeight,
        }
    };
  }
}
