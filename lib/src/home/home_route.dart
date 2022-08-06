import 'dart:math' as math;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:drafting_dan/src/home/multiply_matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:drafting_dan/src/home/three_dimensional_view.dart';

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

  double xAxisRotationDegreeInRadians = -(math.pi + math.pi / 4);
  double yAxisRotationDegreeInRadians = 0.0;
  double zAxisRotationDegreeInRadians = math.pi + math.pi / 4;
  ThreeDimensionalPoint cameraPosition = ThreeDimensionalPoint(0, 0, -120);

  ThreeDimensionalPoint cameraPositionAfterScale =
      ThreeDimensionalPoint(0, 0, -120);

  bool isShiftPressed = false;

  static const noInformation = 'Drafting Dan 1.0v alpha';
  String information = noInformation;
  String status = 'status';

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener((event) {
      isShiftPressed = event.isShiftPressed;
    });
  }

  void showMessage(String message) {
    setState(() {
      information = message;
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          information = noInformation;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WindowTitleBarBox(child: MoveWindow()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
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
                  Expanded(
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
                                      child: TwoDimensionalView(
                                        lines: lines,
                                        isInEditMode: toolStatuses.first,
                                        view: View.front,
                                        onMessage: showMessage,
                                      ),
                                    ),
                                    Expanded(
                                      child: TwoDimensionalView(
                                        lines: lines,
                                        isInEditMode: toolStatuses.first,
                                        view: View.left,
                                        onMessage: showMessage,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TwoDimensionalView(
                                        lines: lines,
                                        isInEditMode: toolStatuses.first,
                                        view: View.top,
                                        onMessage: showMessage,
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
                                  cameraPosition.x -=
                                      details.focalPointDelta.dx;
                                  cameraPosition.y -=
                                      details.focalPointDelta.dy;
                                } else {
                                  zAxisRotationDegreeInRadians -=
                                      details.focalPointDelta.dx / 50;
                                  xAxisRotationDegreeInRadians +=
                                      details.focalPointDelta.dy / 50;
                                }

                                cameraPosition.z = cameraPositionAfterScale.z +
                                    (ThreeDimensionanPainter
                                            .distanceFromEyeToPerspectivePage) *
                                        (details.scale - 1);
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
                                  zCameraRotationDegreeInRadians:
                                      zAxisRotationDegreeInRadians,
                                  cameraPosition: cameraPosition,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(information),
                      Text(status),
                    ],
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

class TwoDimensionalView extends StatefulWidget {
  const TwoDimensionalView({
    super.key,
    required this.lines,
    required this.isInEditMode,
    required this.view,
    this.onMessage,
  });

  final View view;
  final List<ThreeDimensionalLine> lines;
  final bool isInEditMode;
  final void Function(String message)? onMessage;

  @override
  State<TwoDimensionalView> createState() => _TwoDimensionalViewState();
}

class _TwoDimensionalViewState extends State<TwoDimensionalView> {
  bool isBeginPointSelected = false;
  Offset? begin;

  bool hasPanMoved = false;

  ThreeDimensionalLine? movingLine;
  ThreeDimensionalLine? selectedLine;
  Offset? panPointer;

  final FocusNode _focusNode = FocusNode();

  KeyEventResult processDeleteKey(FocusNode node, RawKeyEvent rawKeyEvent) {
    if (rawKeyEvent.isKeyPressed(LogicalKeyboardKey.backspace)) {
      if (selectedLine != null) {
        setState(() {
          widget.lines.removeWhere((line) => line == selectedLine);
        });
        return KeyEventResult.handled;
      } else {
        widget.onMessage?.call('No line selected');
      }
    }
    return KeyEventResult.skipRemainingHandlers;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKey: processDeleteKey,
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
        },
        onPanDown: setupPanPointer,
        onPanCancel: () {
          if (widget.isInEditMode && panPointer != null) {
            drawLine();
          }
        },
        onPanUpdate: (details) {
          final renderBox = context.findRenderObject() as RenderBox;
          if (!renderBox.size.contains(details.localPosition)) {
            print('OUTSIDE!!!');
          }
          if (!hasPanMoved && movingLine == null) {
            setupMovingLine(details);
          } else if (movingLine != null) {
            moveLine(details);
          }

          hasPanMoved = true;
        },
        onPanEnd: resetParams,
        onTapUp: selectLine,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: View2dPainter(
              lines: widget.lines,
              pointer: begin,
              view: widget.view,
            ),
          ),
        ),
      ),
    );
  }

  void selectLine(TapUpDetails details) {
    if (!widget.isInEditMode) {
      final pointer = details.localPosition;
      for (final line in widget.lines) {
        line.isSelected = false;
      }
      for (int i = widget.lines.length - 1; i >= 0; i--) {
        final begin = widget.lines[i].begin.to(widget.view);
        final end = widget.lines[i].end.to(widget.view);
        final distanceWithPointer =
            begin.distanceTo(pointer) + pointer.distanceTo(end);
        final lineLength = begin.distanceTo(end);
        const precision = 1.0;
        final isPointerOnLine =
            (lineLength - distanceWithPointer).abs() < precision;
        if (isPointerOnLine) {
          if (widget.lines[i] == selectedLine) {
            selectedLine = null;
            widget.lines[i].isSelected = false;
          } else {
            selectedLine = widget.lines[i];
            widget.lines[i].isSelected = true;
          }
          break;
        }
      }
      selectedLine = null;
    }

    setState(() {});
  }

  void resetParams(DragEndDetails details) {
    hasPanMoved = false;
    panPointer = null;
    movingLine = null;
  }

  void moveLine(DragUpdateDetails details) {
    setState(() {
      movingLine!.begin.translateOn(widget.view, details.delta);
      movingLine!.end.translateOn(widget.view, details.delta);
    });
  }

  void setupMovingLine(DragUpdateDetails details) {
    Offset pointer;
    if (!hasPanMoved) {
      pointer = panPointer ?? details.localPosition;
    } else {
      pointer = details.localPosition;
    }
    for (int i = widget.lines.length - 1; i >= 0; i--) {
      final begin = widget.lines[i].begin.to(widget.view);
      final end = widget.lines[i].end.to(widget.view);
      final distanceWithPointer =
          begin.distanceTo(pointer) + pointer.distanceTo(end);
      final lineLength = begin.distanceTo(end);
      const precision = 1.0;
      final isPointerOnLine =
          (lineLength - distanceWithPointer).abs() < precision;
      if (isPointerOnLine) {
        movingLine = widget.lines[i];
        break;
      }
    }
  }

  void drawLine() {
    final pointer = panPointer!;
    if (isBeginPointSelected) {
      var newLine = ThreeDimensionalLine.zero()
        ..begin.translateOn(widget.view, begin!)
        ..end.translateOn(widget.view, pointer);

      widget.lines.add(newLine);
      begin = null;
      isBeginPointSelected = false;
    } else {
      begin = pointer;
      isBeginPointSelected = true;
    }
    setState(() {});
  }

  void setupPanPointer(DragDownDetails details) {
    panPointer = details.localPosition;
  }
}

class ThreeDimensionalPoint {
  double x, y, z;

  ThreeDimensionalPoint(this.x, this.y, this.z);

  ThreeDimensionalPoint.zero()
      : x = 0,
        y = 0,
        z = 0;

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

  void translateOn(View view, Offset offset) {
    if (view == View.front) {
      x = x + offset.dx;
      z = z + offset.dy;
    } else if (view == View.top) {
      x = x + offset.dx;
      y = y + offset.dy;
    } else if (view == View.left) {
      y = y + offset.dx;
      z = z + offset.dy;
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

  ThreeDimensionalPoint copyWith({double? x, double? y, double? z}) {
    return ThreeDimensionalPoint(
      x ?? this.x,
      y ?? this.y,
      z ?? this.z,
    );
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

  double get length {
    return (begin - end).distance;
  }
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

  Offset rotateBy(double angle) {
    final rotationMatrix = [
      [math.cos(angle), -math.sin(angle)],
      [math.sin(angle), math.cos(angle)],
    ];

    final offsetMatrix = [
      [dx],
      [dy],
    ];

    final result = multiplyMatrix(rotationMatrix, offsetMatrix);

    return Offset(result[0][0], result[1][0]);
  }

  Offset translateWith(Offset other) {
    return this + other;
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
    const padding = 5.0;
    if (line.length == 0) {
      return;
    }

    final lineVector = line.end - line.begin;
    final rotatedLineVector = Offset(lineVector.dy, -lineVector.dx);
    final normal = rotatedLineVector / rotatedLineVector.distance;
    final parallel = lineVector / lineVector.distance;

    final ratio = (line.end.dy - line.begin.dy) / line.length;
    final cos = math.cos(ratio);
    final angle = -(math.pi / 4 - math.acos(cos));

    canvas.drawLine(
      line.begin - parallel * padding + normal * padding,
      line.end + parallel * padding + normal * padding,
      selectionPaint,
    );
    canvas.drawLine(
      line.begin - parallel * padding + normal * padding, // + Offset(30, 30),
      line.begin - parallel * padding - normal * padding,
      selectionPaint,
    );
    canvas.drawLine(
      line.begin - parallel * padding - normal * padding,
      line.end + parallel * padding - normal * padding,
      selectionPaint,
    );
    canvas.drawLine(
      line.end + parallel * padding + normal * padding, // + Offset(30, 30),
      line.end + parallel * padding - normal * padding,
      selectionPaint,
    );
    return;
    canvas.drawLine(
      line.begin
          .translate(-padding, -padding)
          .translateWith(-line.begin)
          .rotateBy(angle)
          .translateWith(line.begin),
      line.end
          .translate(padding, -padding)
          .translateWith(-line.end)
          .rotateBy(angle)
          .translateWith(line.end),
      selectionPaint,
    );
    canvas.drawLine(
      line.begin
          .translate(padding, -padding)
          .translateWith(-line.begin)
          .rotateBy(angle)
          .translateWith(line.begin),
      line.end
          .translate(padding, padding)
          .translateWith(-line.end)
          .rotateBy(angle)
          .translateWith(line.end),
      selectionPaint,
    );
    canvas.drawLine(
      line.begin
          .translate(padding, padding)
          .translateWith(-line.begin)
          .rotateBy(angle)
          .translateWith(line.begin),
      line.end
          .translate(-padding, padding)
          .translateWith(-line.end)
          .rotateBy(angle)
          .translateWith(line.end),
      selectionPaint,
    );
    canvas.drawLine(
      line.begin
          .translate(-padding, padding)
          .translateWith(-line.begin)
          .rotateBy(angle)
          .translateWith(line.begin),
      line.end
          .translate(-padding, -padding)
          .translateWith(-line.end)
          .rotateBy(angle)
          .translateWith(line.end),
      selectionPaint,
    );
    // canvas.drawLine(line.end.translate(padding, -padding),
    //     line.end.translate(padding, padding), selectionPaint);
    // canvas.drawLine(line.end.translate(padding, padding),
    //     line.begin.translate(-padding, padding), selectionPaint);
    // canvas.drawLine(line.begin.translate(-padding, padding),
    //     line.begin.translate(-padding, -padding), selectionPaint);
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
