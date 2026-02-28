import 'package:expense_managment/models/expense_data.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChart extends StatelessWidget {
  final List<ExpenseData> data;
  const ExpenseChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Transform.rotate(
                      angle: -0.8, // Radianes (~45°)
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(top: 8.5),
                        child: Text(
                          data[index].category,
                          style: const TextStyle(fontSize: 12)
                        ),
                      )
                    );
                  }
                  return const SizedBox();
                },

              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          barGroups: _buildBarGroups(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 500),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index].ammount.toDouble(),
            color: Colors.orange,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  double _getMaxY() {
    if (data.isEmpty) return 10;

    final max = data
      .map((e) => e.ammount)
      .reduce((a, b) => a > b ? a : b);

    if (max == 0) {
      return 10; // valor mínimo para que se dibuje el eje
    }

    return max * 1.2; // margen superior visual
  }
}