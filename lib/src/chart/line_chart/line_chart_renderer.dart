import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/chart/base/base_chart/render_base_chart.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_painter.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Low level LineChart Widget.
class LineChartLeaf extends LeafRenderObjectWidget {
  const LineChartLeaf({
    Key? key,
    required this.data,
    required this.targetData,
    required this.longPressDuration,
  }) : super(key: key);

  final LineChartData data, targetData;
  final Duration? longPressDuration;

  @override
  RenderLineChart createRenderObject(BuildContext context) => RenderLineChart(
      context, data, targetData, MediaQuery.of(context).textScaleFactor, longPressDuration);

  @override
  void updateRenderObject(BuildContext context, RenderLineChart renderObject) {
    renderObject
      ..data = data
      ..targetData = targetData
      ..textScale = MediaQuery.of(context).textScaleFactor
      ..buildContext = context;
  }
}

/// Renders our LineChart, also handles hitTest.
class RenderLineChart extends RenderBaseChart<LineTouchResponse> {
  RenderLineChart(BuildContext context, LineChartData data, LineChartData targetData,
      double textScale, Duration? longPressDuration)
      : _data = data,
        _targetData = targetData,
        _textScale = textScale,
        super(targetData.lineTouchData, context, longPressDuration);

  LineChartData get data => _data;
  LineChartData _data;
  set data(LineChartData value) {
    if (_data == value) return;
    _data = value;
    markNeedsPaint();
  }

  LineChartData get targetData => _targetData;
  LineChartData _targetData;
  set targetData(LineChartData value) {
    if (_targetData == value) return;
    _targetData = value;
    super.updateBaseTouchData(_targetData.lineTouchData);
    markNeedsPaint();
  }

  double get textScale => _textScale;
  double _textScale;
  set textScale(double value) {
    if (_textScale == value) return;
    _textScale = value;
    markNeedsPaint();
  }

  final _painter = LineChartPainter();

  PaintHolder<LineChartData> get paintHolder {
    return PaintHolder(data, targetData, textScale);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    _painter.paint(buildContext, CanvasWrapper(canvas, size), paintHolder);
    canvas.restore();
  }

  @override
  LineTouchResponse getResponseAtLocation(Offset localPosition) {
    var touchedSpots = _painter.handleTouch(localPosition, size, paintHolder);
    return LineTouchResponse(touchedSpots);
  }
}
