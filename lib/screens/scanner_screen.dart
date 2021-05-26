// A screen that allows users to take a picture using a given camera.
import 'dart:async';
import 'dart:io';
import 'package:face_recognition_app/screens/dashboard_screen.dart';

import '../widgets/face_painter.dart';
import '../widgets/camera_header.dart';
import '../services/camera_service.dart';
import '../services/facenet_service.dart';
import '../services/ml_vision_service.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScannerScreen extends StatefulWidget {
  static const routeName = '/scanner-screen';
  // final CameraDescription cameraDescription;

  // const ScannerScreen({
  //   Key key,
  //   @required this.cameraDescription,
  // }) : super(key: key);

  @override
  ScannerScreenState createState() => ScannerScreenState();
}

class ScannerScreenState extends State<ScannerScreen> {
  /// Service injection
  CameraService _cameraService = CameraService();
  MLVisionService _mlVisionService = MLVisionService();
  FaceNetService _faceNetService = FaceNetService();

  Future _initializeControllerFuture;

  bool cameraInitializated = false;
  bool _detectingFaces = false;
  bool pictureTaken = false;

  // switches when the user press the camera
  bool _saving = false;

  String imagePath;
  Size imageSize;
  Face faceDetected;

  @override
  void initState() {
    super.initState();

    /// starts the camera & start framing faces
    Future.delayed(Duration.zero, this._start);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraService.dispose();
    super.dispose();
  }

  /// starts the camera & start framing faces
  _start() async {
    CameraDescription cameraDescription =
        ModalRoute.of(context).settings.arguments;
    _initializeControllerFuture =
        _cameraService.startService(cameraDescription);
    await _initializeControllerFuture;

    setState(() {
      cameraInitializated = true;
    });

    _frameFaces();
  }

  /// draws rectangles when detects faces
  _frameFaces() {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        // if its currently busy, avoids overprocessing
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          List<Face> faces = await _mlVisionService.getFacesFromImage(image);

          if (faces != null) {
            if (faces.length > 0) {
              // preprocessing the image
              setState(() {
                faceDetected = faces[0];
              });

              if (_saving) {
                _saving = false;
                _faceNetService.setCurrentPrediction(image, faceDetected);
              }
            } else {
              setState(() {
                faceDetected = null;
              });
            }
          }

          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
  }

  /// handles the button pressed event
  Future<void> onShot() async {
    if (faceDetected == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('No face detected!'),
          );
        },
      );

      return false;
    } else {
      _saving = true;

      await Future.delayed(Duration(milliseconds: 500));
      await _cameraService.cameraController.stopImageStream();
      await Future.delayed(Duration(milliseconds: 200));
      XFile file = await _cameraService.takePicture();

      setState(() {
        pictureTaken = true;
        imagePath = file.path;
      });

      return true;
    }
  }

  _onBackPressed() {
    Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
  }

  _reload() {
    setState(() {
      cameraInitializated = false;
      pictureTaken = false;
    });
    this._start();
  }

  @override
  Widget build(BuildContext context) {
    final double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (pictureTaken) {
                    return Container(
                      width: width,
                      height: height,
                      child: Transform(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image.file(File(imagePath)),
                          ),
                          transform: Matrix4.rotationY(mirror)),
                    );
                  } else {
                    return Transform.scale(
                      scale: 1.0,
                      child: AspectRatio(
                        aspectRatio: MediaQuery.of(context).size.aspectRatio,
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Container(
                              width: width,
                              height: width *
                                  _cameraService
                                      .cameraController.value.aspectRatio,
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  CameraPreview(
                                      _cameraService.cameraController),
                                  CustomPaint(
                                    painter: FacePainter(
                                        face: faceDetected,
                                        imageSize: imageSize),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
          CameraHeader(
            "ADD ENTRY",
            onBackPressed: _onBackPressed,
          ),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: height * 0.1,
                width: width * 0.5,
                height: width * 0.12,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(DashboardScreen.routeName);
                  },
                  child: Text(
                    'Check In',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).accentColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// import 'package:face_recognition_app/screens/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
// import 'dart:ui' as ui;
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import '../services/facenet_service.dart';

// class ScannerScreen extends StatefulWidget {
//   static const routeName = '/scanner-screen';
//   @override
//   _ScannerScreenState createState() => _ScannerScreenState();
// }

// class _ScannerScreenState extends State<ScannerScreen> {
//   @override
//   void initState() {
//     _takePicture();
//     super.initState();
//   }

//   FaceNetService _faceNetService = FaceNetService();

//   File _imageFile;
//   List<Face> _faces;
//   bool isLoading = false;
//   ui.Image _image;

//   _takePicture() async {
//     final picker = ImagePicker();
//     final imageFile = await picker.getImage(
//       source: ImageSource.camera,
//     );

//     setState(() {
//       isLoading = true;
//     });

//     final image = FirebaseVisionImage.fromFile(File(imageFile.path));
//     final faceDetector = FirebaseVision.instance.faceDetector();
//     List<Face> faces = await faceDetector.processImage(image);

//     if (mounted) {
//       setState(() {
//         _imageFile = File(imageFile.path);
//         _faces = faces;
//         _loadImage(File(_imageFile.path));
//       });
//     }
//   }

//   _loadImage(File file) async {
//     final data = await file.readAsBytes();
//     await decodeImageFromList(data).then((value) => setState(() {
//           _image = value;
//           isLoading = false;
//         }));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: isLoading
//           ? Center(
//               child: LinearProgressIndicator(),
//             )
//           : (_imageFile == null)
//               ? Center(
//                   child: Text('No Image Taken.'),
//                 )
//               : Stack(
//                   alignment: Alignment.bottomCenter,
//                   children: [
//                     Center(
//                       child: FittedBox(
//                         child: SizedBox(
//                           width: _image.width.toDouble(),
//                           height: _image.height.toDouble(),
//                           child: CustomPaint(
//                             painter: FacePainter(
//                               _image,
//                               _faces,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: height * 0.1,
//                       width: width * 0.7,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.of(context)
//                               .pushReplacementNamed(DashboardScreen.routeName);
//                         },
//                         child: Text('Cancel Scan'),
//                         style: ElevatedButton.styleFrom(
//                             primary: Theme.of(context).errorColor),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: height * 0.04,
//                       width: width * 0.7,
//                       child: ElevatedButton(
//                         onPressed: () {},
//                         child: Text('Check In'),
//                         style: ElevatedButton.styleFrom(
//                             primary: Theme.of(context).primaryColor),
//                       ),
//                     ),
//                   ],
//                 ),
//     );
//   }
// }

// class FacePainter extends CustomPainter {
//   final List<Face> faces;
//   final List<Rect> rects = [];
//   final ui.Image image;

//   FacePainter(this.image, this.faces) {
//     for (var i = 0; i < faces.length; i++) {
//       rects.add(faces[i].boundingBox);
//     }
//   }

//   @override
//   void paint(ui.Canvas canvas, ui.Size size) {
//     final Paint paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 15.0
//       ..color = Colors.yellow;

//     canvas.drawImage(image, Offset.zero, Paint());
//     for (var i = 0; i < faces.length; i++) {
//       canvas.drawRect(rects[i], paint);
//     }
//   }

//   @override
//   bool shouldRepaint(FacePainter old) {
//     return image != old.image || faces != old.faces;
//   }
// }
