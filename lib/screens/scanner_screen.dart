import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ScannerScreen extends StatefulWidget {
  static const routeName = '/scanner-screen';
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  @override
  void initState() {
    _takePicture();
    super.initState();
  }

  File _imageFile;
  List<Face> _faces;
  bool isLoading = false;
  ui.Image _image;

  _takePicture() async {
    final picker = ImagePicker();
    final imageFile = await picker.getImage(
      source: ImageSource.camera,
    );

    setState(() {
      isLoading = true;
    });

    final image = FirebaseVisionImage.fromFile(File(imageFile.path));
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(image);

    if (mounted) {
      setState(() {
        _imageFile = File(imageFile.path);
        _faces = faces;
        _loadImage(File(_imageFile.path));
      });
    }
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) => setState(() {
          _image = value;
          isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(
              child: LinearProgressIndicator(),
            )
          : (_imageFile == null)
              ? Center(
                  child: Text('No Image Taken.'),
                )
              : Center(
                  child: FittedBox(
                    child: SizedBox(
                      width: _image.width.toDouble(),
                      height: _image.height.toDouble(),
                      child: CustomPaint(
                        painter: FacePainter(
                          _image,
                          _faces,
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final List<Rect> rects = [];
  final ui.Image image;

  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..color = Colors.yellow;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter old) {
    return image != old.image || faces != old.faces;
  }
}
