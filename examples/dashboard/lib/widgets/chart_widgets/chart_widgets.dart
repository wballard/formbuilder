import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

class LineChartWidget extends StatelessWidget {
  final WidgetPlacement placement;
  final bool liveData;

  const LineChartWidget({
    super.key,
    required this.placement,
    required this.liveData,
  });

  @override
  Widget build(BuildContext context) {
    final data = _generateLineData();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue Trend',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (liveData)
                Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.green,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: _LineChartPainter(data: data, color: Theme.of(context).primaryColor),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last 7 days',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  List<double> _generateLineData() {
    final random = math.Random();
    return List.generate(7, (index) => 50 + random.nextDouble() * 50);
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _LineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final maxValue = data.reduce(math.max);
    
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChartWidget extends StatelessWidget {
  final WidgetPlacement placement;
  final bool liveData;

  const BarChartWidget({
    super.key,
    required this.placement,
    required this.liveData,
  });

  @override
  Widget build(BuildContext context) {
    final data = _generateBarData();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sales by Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (liveData)
                Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.green,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: _BarChartPainter(data: data, color: Theme.of(context).primaryColor),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  List<double> _generateBarData() {
    final random = math.Random();
    return List.generate(5, (index) => 30 + random.nextDouble() * 70);
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _BarChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final barWidth = size.width / (data.length * 2);
    final maxValue = data.reduce(math.max);
    
    for (int i = 0; i < data.length; i++) {
      final x = i * (barWidth * 2) + barWidth / 2;
      final barHeight = data[i] / maxValue * size.height * 0.8;
      final y = size.height - barHeight;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartWidget extends StatelessWidget {
  final WidgetPlacement placement;
  final bool liveData;

  const PieChartWidget({
    super.key,
    required this.placement,
    required this.liveData,
  });

  @override
  Widget build(BuildContext context) {
    final data = _generatePieData();
    final colors = [
      Theme.of(context).primaryColor,
      Theme.of(context).primaryColor.withValues(alpha: 0.7),
      Theme.of(context).primaryColor.withValues(alpha: 0.5),
      Theme.of(context).primaryColor.withValues(alpha: 0.3),
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Market Share',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (liveData)
                Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.green,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: _PieChartPainter(data: data, colors: colors),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  List<double> _generatePieData() {
    final random = math.Random();
    final values = List.generate(4, (index) => 20 + random.nextDouble() * 30);
    final total = values.reduce((a, b) => a + b);
    return values.map((v) => v / total).toList();
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;

  _PieChartPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 3;
    
    double startAngle = -math.pi / 2;
    
    for (int i = 0; i < data.length; i++) {
      final sweepAngle = data[i] * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}