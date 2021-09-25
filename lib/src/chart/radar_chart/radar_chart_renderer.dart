import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/chart/base/base_chart/render_base_chart.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'radar_chart_painter.dart';

/// Low level RadarChart Widget.
class RadarChartLeaf extends LeafRenderObjectWidget {
  const RadarChartLeaf(
      {Key? key, required this.data, required this.targetData, required this.longPressDuration})
      : super(key: key);

  final RadarChartData data, targetData;

  final Duration? longPressDuration;

  @override
  RenderRadarChart createRenderObject(BuildContext context) => RenderRadarChart(
      context, data, targetData, MediaQuery.of(context).textScaleFactor, longPressDuration);

  @override
  void updateRenderObject(BuildContext context, RenderRadarChart renderObject) {
    renderObject
      ..data = data
      ..targetData = targetData
      ..textScale = MediaQuery.of(context).textScaleFactor
      ..buildContext = context;
  }
}

/// Renders our RadarChart, also handles hitTest.
class RenderRadarChart extends RenderBaseChart<RadarTouchResponse> {
  RenderRadarChart(BuildContext context, RadarChartData data, RadarChartData targetData,
      double textScale, Duration? longPressDuration)
      : _data = data,
        _targetData = targetData,
        _textScale = textScale,
        super(targetData.radarTouchData, context, longPressDuration);

  RadarChartData get data => _data;
  RadarChartData _data;
  set data(RadarChartData value) {
    if (_data == value) return;
    _data = value;
    markNeedsPaint();
  }

  RadarChartData get targetData => _targetData;
  RadarChartData _targetData;
  set targetData(RadarChartData value) {
    if (_targetData == value) return;
    _targetData = value;
    super.updateBaseTouchData(_targetData.radarTouchData);
    markNeedsPaint();
  }

  double get textScale => _textScale;
  double _textScale;
  set textScale(double value) {
    if (_textScale == value) return;
    _textScale = value;
    markNeedsPaint();
  }

  final _painter = RadarChartPainter();

  PaintHolder<RadarChartData> get paintHolder {
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
  RadarTouchResponse getResponseAtLocation(Offset localPosition) {
    var touchedSpot = _painter.handleTouch(localPosition, size, paintHolder);
    return RadarTouchResponse(touchedSpot);
  }
}
