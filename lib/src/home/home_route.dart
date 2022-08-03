import 'dart:math' as math;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:drafting_dan/src/home/three_dimensional_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeRoute extends StatefulWidget {
  static const routeName = '/';

  const HomeRoute({Key? key}) : super(key: key);

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  List<ThreeDimensionalLine> lines = [
    ThreeDimensionalLine(
        begin: ThreeDimensionalPoint(0, 0, 0),
        end: ThreeDimensionalPoint(100, 0, 0)),
    ThreeDimensionalLine(
        begin: ThreeDimensionalPoint(100, 0, 0),
        end: ThreeDimensionalPoint(100, 100, 0)),
    ThreeDimensionalLine(
        begin: ThreeDimensionalPoint(100, 100, 0),
        end: ThreeDimensionalPoint(0, 100, 0)),
    ThreeDimensionalLine(
        begin: ThreeDimensionalPoint(0, 100, 0),
        end: ThreeDimensionalPoint(0, 0, 0)),
    //next layer
    ThreeDimensionalLine(
        begin: ThreeDimensionalPoint(0, 0, 100),
        end: ThreeDimensionalPoint(100, 0, 100)),
    ThreeDimensionalLine(
        begin: ThreeDimensionalPoint(100, 0, 100),
        end: ThreeDimensionalPoint(100, 100, 100)),
    ThreeDimensionalLine(
        begin: ThreeDimensionalPoint(100, 100, 100),
        end: ThreeDimensionalPoint(0, 100, 100)),
    ThreeDimensionalLine(
        begin: ThreeDimensionalPoint(0, 100, 100),
        end: ThreeDimensionalPoint(0, 0, 100)),
    // heights
    ThreeDimensionalLine(
        begin: ThreeDimensionalPoint(0, 0, 0),
        end: ThreeDimensionalPoint(0, 0, 150)),
    ThreeDimensionalLine(
        begin: ThreeDimensionalPoint(100, 0, 0),
        end: ThreeDimensionalPoint(100, 0, 100)),
    ThreeDimensionalLine(
        begin: ThreeDimensionalPoint(100, 100, 0),
        end: ThreeDimensionalPoint(100, 100, 100)),
    ThreeDimensionalLine(
        begin: ThreeDimensionalPoint(0, 100, 0),
        end: ThreeDimensionalPoint(0, 100, 100)),
  ];
  List<bool> toolStatuses = [false, false];

  bool isBeginPointSelected = false;
  Offset? begin;

  double xAxisRotationDegreeInRadians = 0.0;
  double yAxisRotationDegreeInRadians = 0.0;
  ThreeDimensionalPoint cameraPosition = ThreeDimensionalPoint(0, 0, 0);

  ThreeDimensionalPoint cameraPositionAfterScale =
      ThreeDimensionalPoint(0, 0, 0);
  FocusNode? focus;

  bool isShiftPressed = false;

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener((event) {
      isShiftPressed = event.isShiftPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WindowTitleBarBox(child: MoveWindow()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ToggleButtons(
                  isSelected: toolStatuses,
                  children: const [
                    Icon(Icons.draw),
                    Icon(Icons.back_hand),
                  ],
                  onPressed: (index) {
                    setState(() {
                      for (int i = 0; i < toolStatuses.length; i++) {
                        toolStatuses[i] = false;
                      }
                      toolStatuses[index] = true;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      lines = [];
                    });
                  },
                  child: const Text('clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTapUp: (details) {
                                    final pointer = details.localPosition;
                                    if (toolStatuses.first) {
                                      if (isBeginPointSelected) {
                                        lines.add(ThreeDimensionalLine(
                                            begin: ThreeDimensionalPoint(
                                                begin!.dx, 0, begin!.dy),
                                            end: ThreeDimensionalPoint(
                                                pointer.dx, 0, pointer.dy)));
                                        begin = null;
                                        isBeginPointSelected = false;
                                      } else {
                                        begin = pointer;
                                        isBeginPointSelected = true;
                                      }
                                    } else {
                                      for (int i = lines.length - 1;
                                          i >= 0;
                                          i--) {
                                        final begin =
                                            lines[i].begin.to(View.front);
                                        final end = lines[i].end.to(View.front);
                                        final distanceWithPointer =
                                            begin.distanceTo(pointer) +
                                                pointer.distanceTo(end);
                                        final lineLength =
                                            begin.distanceTo(end);
                                        const precision = 1.0;
                                        final isPointerOnLine =
                                            (lineLength - distanceWithPointer)
                                                    .abs() <
                                                precision;
                                        if (isPointerOnLine) {
                                          lines[i].isSelected =
                                              !lines[i].isSelected;
                                        }
                                        break;
                                      }
                                    }

                                    setState(() {});
                                  },
                                  child: Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: CustomPaint(
                                      painter: View2dPainter(
                                          lines: lines,
                                          pointer: begin,
                                          view: View.front),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTapUp: (details) {},
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: CustomPaint(
                                      painter: View2dPainter(
                                          lines: lines,
                                          pointer: begin,
                                          view: View.left),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTapUp: (details) {},
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: CustomPaint(
                                      painter: View2dPainter(
                                          lines: lines,
                                          pointer: begin,
                                          view: View.top),
                                    ),
                                  ),
                                ),
                              ),
                              const Expanded(child: Placeholder()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onScaleUpdate: (details) {
                        setState(() {
                          if (!isShiftPressed) {
                            cameraPosition.x -= details.focalPointDelta.dx;
                            cameraPosition.y -= details.focalPointDelta.dy;
                          } else {
                            yAxisRotationDegreeInRadians -=
                                details.focalPointDelta.dx / 50;
                            xAxisRotationDegreeInRadians +=
                                details.focalPointDelta.dy / 50;
                          }

                          cameraPosition.z = (cameraPositionAfterScale.z +
                                      ThreeDimensionanPainter
                                          .distanceFromEyeToPerspectivePage) *
                                  details.scale -
                              ThreeDimensionanPainter
                                  .distanceFromEyeToPerspectivePage;
                        });
                      },
                      onScaleEnd: (details) {
                        cameraPositionAfterScale.x = cameraPosition.x;
                        cameraPositionAfterScale.y = cameraPosition.y;
                        cameraPositionAfterScale.z = cameraPosition.z;
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomPaint(
                          painter: ThreeDimensionanPainter(
                            lines: lines,
                            xCameraRotationDegreeInRadians:
                                xAxisRotationDegreeInRadians,
                            yCameraRotationDegreeInRadians:
                                yAxisRotationDegreeInRadians,
                            cameraPosition: cameraPosition,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThreeDimensionalPoint {
  double x, y, z;

  ThreeDimensionalPoint(this.x, this.y, this.z);

  ThreeDimensionalPoint.fromOffset(Offset offset)
      : x = offset.dx,
        y = offset.dy,
        z = 0;

  double distanceTo(ThreeDimensionalPoint other) {
    return math.sqrt(x * x + y * y + z * z);
  }

  Offset to(View view) {
    if (view == View.front) {
      return Offset(x, z);
    } else if (view == View.top) {
      return Offset(x, y);
    } else if (view == View.left) {
      return Offset(y, z);
    } else {
      throw UnimplementedError();
    }
  }

  List<List<double>> toMatrix() {
    return [
      [x],
      [y],
      [z],
      [1]
    ];
  }
}

class ThreeDimensionalLine {
  ThreeDimensionalPoint begin;
  ThreeDimensionalPoint end;
  bool isSelected;

  ThreeDimensionalLine({
    required this.begin,
    required this.end,
    this.isSelected = false,
  });

  ThreeDimensionalLine.zero()
      : begin = ThreeDimensionalPoint(0, 0, 0),
        end = ThreeDimensionalPoint(0, 0, 0),
        isSelected = false;

  TwoDimensionalLine to(View view) {
    if (view == View.front) {
      return TwoDimensionalLine(
        begin: Offset(begin.x, begin.z),
        end: Offset(end.x, end.z),
      );
    } else if (view == View.top) {
      return TwoDimensionalLine(
        begin: Offset(begin.x, begin.y),
        end: Offset(end.x, end.y),
      );
    } else if (view == View.left) {
      return TwoDimensionalLine(
        begin: Offset(begin.y, begin.z),
        end: Offset(end.y, end.z),
      );
    } else {
      throw UnimplementedError();
    }
  }
}

class TwoDimensionalLine {
  Offset begin;
  Offset end;
  bool isSelected;

  TwoDimensionalLine({
    required this.begin,
    required this.end,
    this.isSelected = false,
  });
}

enum View {
  front,
  top,
  left,
}

extension on Offset {
  double distanceTo(Offset other) {
    return (this - other).distance;
  }
}

class View2dPainter extends CustomPainter {
  List<ThreeDimensionalLine> lines;
  Offset? pointer;
  View view;

  View2dPainter({required this.view, this.lines = const [], this.pointer});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;
    for (final line in lines) {
      final lineIn2d = line.to(view);

      if (line.isSelected) {
        _drawlineSelection(lineIn2d, canvas, size);
      }

      canvas.drawLine(lineIn2d.begin, lineIn2d.end, linePaint);
    }

    if (pointer != null) {
      _drawPointer(canvas, size);
    }
  }

  void _drawlineSelection(TwoDimensionalLine line, Canvas canvas, Size size) {
    final selectionPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;
    const padding = 10.0;

    canvas.drawLine(line.begin.translate(-padding, -padding),
        line.end.translate(padding, -padding), selectionPaint);
    canvas.drawLine(line.end.translate(padding, -padding),
        line.end.translate(padding, padding), selectionPaint);
    canvas.drawLine(line.end.translate(padding, padding),
        line.begin.translate(-padding, padding), selectionPaint);
    canvas.drawLine(line.begin.translate(-padding, padding),
        line.begin.translate(-padding, -padding), selectionPaint);
  }

  void _drawPointer(Canvas canvas, Size size) {
    final pointerPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;
    const pointerSize = 10.0;

    canvas.drawLine(pointer!, pointer!.translate(pointerSize, 0), pointerPaint);
    canvas.drawLine(
        pointer!, pointer!.translate(-pointerSize, 0), pointerPaint);
    canvas.drawLine(pointer!, pointer!.translate(0, pointerSize), pointerPaint);
    canvas.drawLine(
        pointer!, pointer!.translate(0, -pointerSize), pointerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
