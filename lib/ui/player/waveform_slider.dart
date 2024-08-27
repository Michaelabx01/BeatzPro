import 'package:flutter/material.dart';

class WaveSlider extends StatefulWidget {
  final double progress;
  final Function(double) onChange;

  const WaveSlider({Key? key, required this.progress, required this.onChange}) : super(key: key);

  @override
  _WaveSliderState createState() => _WaveSliderState();
}

class _WaveSliderState extends State<WaveSlider> {
  double _localProgress = 0.0;

  // Lista de alturas predefinidas para las barras que imita el diseño de la imagen
  final List<double> barHeights = [
    6.0, 8.0, 10.0, 14.0, 18.0, 22.0, 26.0, 30.0, 34.0, 38.0,
    40.0, 38.0, 34.0, 30.0, 26.0, 22.0, 18.0, 14.0, 10.0, 8.0, 6.0,
    6.0, 8.0, 10.0, 14.0, 18.0, 22.0, 26.0, 30.0, 34.0, 38.0,
    40.0, 38.0, 34.0, 30.0, 26.0, 22.0, 18.0, 14.0, 10.0, 8.0, 6.0,
  ];

  @override
  void initState() {
    super.initState();
    _localProgress = widget.progress;
  }

  @override
  void didUpdateWidget(covariant WaveSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _localProgress = widget.progress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _localProgress = (details.localPosition.dx / context.size!.width).clamp(0.0, 1.0);
          widget.onChange(_localProgress);
        });
      },
      child: CustomPaint(
        painter: WavePainter(_localProgress, barHeights),
        child: Container(
          height: 80.0, // Altura del contenedor, ajustada para reflejar las barras más grandes
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final List<double> barHeights;

  WavePainter(this.progress, this.barHeights);

  @override
  void paint(Canvas canvas, Size size) {
    Paint activePaint = Paint()
      ..color = Colors.black // Color de las barras (negro como en la imagen)
      ..style = PaintingStyle.fill;

    double barWidth = 4.0; // Ancho de las barras, ajustado para un diseño más sólido
    double space = 2.0; // Espacio entre las barras
    int barCount = barHeights.length;

    for (int i = 0; i < barCount; i++) {
      double normalizedProgress = i / barCount;
      double barHeight = barHeights[i];

      Paint paint = normalizedProgress < progress ? activePaint : activePaint; // Sin cambio de color basado en el progreso
      double x = i * (barWidth + space);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, (size.height - barHeight) / 2, barWidth, barHeight),
          Radius.circular(2.0),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
