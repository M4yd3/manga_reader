import 'package:flutter/material.dart';

class NeatSlider extends StatefulWidget {
  final int segments;
  final int position;
  final EdgeInsets padding;
  final double radius;
  final bool active;
  final Color color;

  const NeatSlider({
    required this.segments,
    required this.position,
    this.padding = const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
    this.radius = 2.5,
    this.active = false,
    this.color = const Color(0xff909090),
  });

  @override
  _NeatSliderState createState() => _NeatSliderState();
}

class _NeatSliderState extends State<NeatSlider> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.padding.vertical * 2 - 0.5,
      width: double.infinity,
      child: CustomPaint(
        painter: SliderPainter(
          segments: widget.segments,
          position: widget.position,
          padding: widget.padding,
          radius: widget.radius,
          active: widget.active,
          color: widget.color,
        ),
      ),
    );
  }
}

class SliderPainter extends CustomPainter {
  final int segments;
  final int position;
  final EdgeInsets padding;
  final double radius;
  final bool active;
  final Color color;

  SliderPainter({
    required this.segments,
    required this.position,
    required this.padding,
    required this.radius,
    required this.active,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Get.log('$size');

    final height = size.height;
    final width = size.width;

    final paint = Paint()
      ..color = color
      ..style = (PaintingStyle.fill)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    canvas.drawLine(Offset(padding.left, height),
        Offset(width - padding.right, height), paint);
    canvas.drawCircle(Offset(padding.left, height), radius, paint);
    canvas.drawCircle(Offset(width - padding.left, height), radius, paint);

    final startPos = padding.left + radius * 2;
    final endPos = width - (padding.right + radius * 2);
    var canvasPosition =
        (endPos - startPos) / (segments - 1) * (position - 1) + startPos;

    if (position == 0) paint.color = Colors.transparent;
    if (position == 1) canvasPosition = startPos;
    if (position == segments) canvasPosition = endPos;
    // Get.log('canvasPosition: $canvasPosition, position: $position');

    canvas.drawCircle(Offset(canvasPosition, height), radius, paint);
  }

  @override
  bool shouldRepaint(SliderPainter oldDelegate) {
    return oldDelegate.position != position;
  }
}
