import 'package:drafting_dan/src/home/multiply_matrix.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:drafting_dan/src/home/home_route.dart';



class ThreeDimensionanPainter extends CustomPainter {
  List<ThreeDimensionalLine> lines;

  final double xCameraRotationDegreeInRadians;
  final double yCameraRotationDegreeInRadians;
  final double zCameraRotationDegreeInRadians;

  static const distanceFromEyeToPerspectivePage = 100;

  ThreeDimensionalPoint cameraPosition;

  static const axisMargin = 100;

  double maxCoordinate = 0.0;

  ThreeDimensionanPainter({
    required this.lines,
    required this.xCameraRotationDegreeInRadians,
    required this.yCameraRotationDegreeInRadians,
    required this.zCameraRotationDegreeInRadians,
    required this.cameraPosition,
  });

  List<List<double>> get rotationByXMatrix {
    return [
      [1, 0, 0, 0],
      [
        0,
        math.cos(xCameraRotationDegreeInRadians),
        -math.sin(xCameraRotationDegreeInRadians),
        0
      ],
      [
        0,
        math.sin(xCameraRotationDegreeInRadians),
        math.cos(xCameraRotationDegreeInRadians),
        0
      ],
      [0, 0, 0, 1]
    ];
  }

  List<List<double>> get rotationByYMatrix {
    return [
      [
        math.cos(yCameraRotationDegreeInRadians),
        0,
        math.sin(yCameraRotationDegreeInRadians),
        0
      ],
      [0, 1, 0, 0],
      [
        -math.sin(yCameraRotationDegreeInRadians),
        0,
        math.cos(yCameraRotationDegreeInRadians),
        0
      ],
      [0, 0, 0, 1]
    ];
  }

  List<List<double>> get rotationByZMatrix {
    return [
      [
        math.cos(zCameraRotationDegreeInRadians),
        -math.sin(zCameraRotationDegreeInRadians),
        0,
        0
      ],
      [
        math.sin(zCameraRotationDegreeInRadians),
        math.cos(zCameraRotationDegreeInRadians),
        0,
        0
      ],
      [0, 0, 1, 0],
      [0, 0, 0, 1]
    ];
  }

  List<List<double>> getOffsetOriginToCenterMatrix(Size size) {
    return [
      [1, 0, 0, size.width / 2],
      [0, 1, 0, size.height / 2],
      [0, 0, 1, 0],
      [0, 0, 0, 1],
    ];
  }

  List<List<double>> getPerspectiveMatrix(double zCoordinateOfPoint) {
    double xTranslation;
    double yTranslation;
    if (distanceFromEyeToPerspectivePage + zCoordinateOfPoint == 0) {
      xTranslation = 1;
      yTranslation = 1;
    } else {
      xTranslation = distanceFromEyeToPerspectivePage /
          (distanceFromEyeToPerspectivePage + zCoordinateOfPoint);
      yTranslation = distanceFromEyeToPerspectivePage /
          (distanceFromEyeToPerspectivePage + zCoordinateOfPoint);
    }

    return [
      [xTranslation, 0, 0, 0],
      [0, yTranslation, 0, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 1],
    ];
  }

  List<List<double>> get cameraViewMatrix {
    return [
      [1, 0, 0, -cameraPosition.x],
      [0, 1, 0, -cameraPosition.y],
      [0, 0, 1, -cameraPosition.z],
      [0, 0, 0, 1],
    ];
  }

  void drawLine(
    ThreeDimensionalLine line,
    Paint linePaint,
    Canvas canvas,
    Size size,
  ) {
    final beginMatrix = line.begin.toMatrix();
    final endMatrix = line.end.toMatrix();

    var translatedBeginMatrix = beginMatrix;
    translatedBeginMatrix =
        multiplyMatrix(rotationByZMatrix, translatedBeginMatrix);
    translatedBeginMatrix =
        multiplyMatrix(rotationByYMatrix, translatedBeginMatrix);
    translatedBeginMatrix =
        multiplyMatrix(rotationByXMatrix, translatedBeginMatrix);
    translatedBeginMatrix =
        multiplyMatrix(cameraViewMatrix, translatedBeginMatrix);
    translatedBeginMatrix = multiplyMatrix(
      getPerspectiveMatrix(translatedBeginMatrix[2][0]),
      translatedBeginMatrix,
    );
    translatedBeginMatrix = multiplyMatrix(
        getOffsetOriginToCenterMatrix(size), translatedBeginMatrix);

    var translatedEndMatrix = endMatrix;
    translatedEndMatrix =
        multiplyMatrix(rotationByZMatrix, translatedEndMatrix);
    translatedEndMatrix =
        multiplyMatrix(rotationByYMatrix, translatedEndMatrix);
    translatedEndMatrix =
        multiplyMatrix(rotationByXMatrix, translatedEndMatrix);
    translatedEndMatrix = multiplyMatrix(cameraViewMatrix, translatedEndMatrix);
    translatedEndMatrix = multiplyMatrix(
      getPerspectiveMatrix(translatedEndMatrix[2][0]),
      translatedEndMatrix,
    );
    translatedEndMatrix = multiplyMatrix(
        getOffsetOriginToCenterMatrix(size), translatedEndMatrix);

    if (translatedBeginMatrix[2][0] + distanceFromEyeToPerspectivePage > 0 &&
        translatedEndMatrix[2][0] + distanceFromEyeToPerspectivePage > 0) {
      canvas.drawLine(
        Offset(translatedBeginMatrix[0][0], translatedBeginMatrix[1][0]),
        Offset(translatedEndMatrix[0][0], translatedEndMatrix[1][0]),
        linePaint,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      maxCoordinate = math.max(line.begin.x, maxCoordinate);
      maxCoordinate = math.max(line.end.x, maxCoordinate);
      maxCoordinate = math.max(line.begin.y, maxCoordinate);
      maxCoordinate = math.max(line.end.y, maxCoordinate);
      maxCoordinate = math.max(line.begin.z, maxCoordinate);
      maxCoordinate = math.max(line.end.z, maxCoordinate);
    }

    final linePaint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final xAsix = ThreeDimensionalLine(
      begin: ThreeDimensionalPoint(0, 0, 0),
      end: ThreeDimensionalPoint(maxCoordinate + axisMargin, 0, 0),
    );
    final yAsix = ThreeDimensionalLine(
      begin: ThreeDimensionalPoint(0, 0, 0),
      end: ThreeDimensionalPoint(0, maxCoordinate + axisMargin, 0),
    );
    final zAsix = ThreeDimensionalLine(
      begin: ThreeDimensionalPoint(0, 0, 0),
      end: ThreeDimensionalPoint(0, 0, maxCoordinate + axisMargin),
    );

    drawLine(xAsix, linePaint..color = Colors.red, canvas, size);
    drawLine(yAsix, linePaint..color = Colors.green, canvas, size);
    drawLine(zAsix, linePaint..color = Colors.blue, canvas, size);

    for (final line in lines) {
      drawLine(line, linePaint..color = Colors.black, canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
