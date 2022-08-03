import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:drafting_dan/src/home/home_route.dart';

List<List<double>> multiplyMatrix(
    List<List<double>> m1, List<List<double>> m2) {
  List<List<double>> result = [];
  for (int j = 0; j < m1.length; j++) {
    result.insert(j, []);
    for (int k = 0; k < m2[0].length; k++) {
      double sum = 0.0;
      for (int i = 0; i < m2.length; i++) {
        sum += m2[i][k] * m1[j][i];
      }
      result[j].add(sum);
    }
  }
  return result;
}

class ThreeDimensionanPainter extends CustomPainter {
  List<ThreeDimensionalLine> lines;

  final double xCameraRotationDegreeInRadians;
  final double yCameraRotationDegreeInRadians;
  final double zCameraRotationDegreeInRadians = 0;

  static const distanceFromEyeToPerspectivePage = 100;

  ThreeDimensionalPoint cameraPosition;

  ThreeDimensionanPainter({
    required this.lines,
    required this.xCameraRotationDegreeInRadians,
    required this.yCameraRotationDegreeInRadians,
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

  void drawLine(ThreeDimensionalLine line, Canvas canvas, Size size) {
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

    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

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
      drawLine(line, canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
