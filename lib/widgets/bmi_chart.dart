import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BmiChart extends StatelessWidget {
  final double bmi;

  const BmiChart({required this.bmi});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 45,
          minY: 0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _bottomTitles,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 25),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          barGroups: _barGroups(),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: bmi,
                color: Colors.red,
                dashArray: [5, 5],
                strokeWidth: 3,
                label: HorizontalLineLabel(
                  show: true,
                  labelResolver: (_) => 'Sizning BMI ${bmi.toStringAsFixed(1)}',
                  alignment: Alignment.topLeft,
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _barGroups() {
    return [
      _bar(17, 17.0, 'Kam vazn', Colors.blue),
      _bar(22, 22.0, 'Normal', Colors.green),
      _bar(27, 27.0, 'Ortiqcha', Colors.orange),
      _bar(32, 32.0, 'Semizlik 1', Colors.deepOrange),
      _bar(37, 37.0, 'Semizlik 2', Colors.redAccent),
      _bar(42, 42.0, 'Semizlik 3', Colors.purple),
    ];
  }

  BarChartGroupData _bar(double x, double y, String title, Color color) {
    return BarChartGroupData(
      x: x.toInt(),
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    const titles = {
      17: 'Kam\nvazn',
      22: 'Normal',
      27: 'Ortiqcha',
      32: 'S1',
      37: 'S2',
      42: 'S3',
    };

    return SideTitleWidget(
      meta: meta,
      child: Text(
        titles[value.toInt()] ?? '',
        style: TextStyle(fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }
}
