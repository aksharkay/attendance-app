import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import './camera_service.dart';

class MLVisionService {
  static final MLVisionService _cameraServiceService =
      MLVisionService._internal();

  factory MLVisionService() {
    return _cameraServiceService;
  }
  MLVisionService._internal();

  CameraService _cameraService = CameraService();

  FaceDetector _faceDetector;
  FaceDetector get faceDetector => this._faceDetector;

  void initialize() {
    this._faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<List<Face>> getFacesFromImage(CameraImage image) async {
    FirebaseVisionImageMetadata _firebaseImageMetadata =
        FirebaseVisionImageMetadata(
      rotation: _cameraService.cameraRotation,
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      planeData: image.planes.map(
        (Plane plane) {
          return FirebaseVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );

    FirebaseVisionImage _firebaseVisionImage = FirebaseVisionImage.fromBytes(
        image.planes[0].bytes, _firebaseImageMetadata);

    List<Face> faces =
        await this._faceDetector.processImage(_firebaseVisionImage);
    return faces;
  }
}
