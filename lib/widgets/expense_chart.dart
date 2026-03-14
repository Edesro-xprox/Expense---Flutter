import 'package:expense_managment/models/category.dart';
import 'package:expense_managment/models/expense_data.dart';
import 'package:expense_managment/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChart extends StatelessWidget {
  final List<ExInData> data;
  final CategoryType type;
  const ExpenseChart({super.key, required this.data, required this.type});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculamos el ancho ideal: 80px por cada barra
        final double itemWidth = 80.0;
        final double calculatedWidth = data.length * itemWidth;
        
        // Si el calculado es menor al ancho de pantalla, usamos el ancho de pantalla (para que estire)
        // Si es mayor, usamos el calculado (para que haga scroll)
        final double finalWidth = calculatedWidth > constraints.maxWidth 
            ? calculatedWidth 
            : constraints.maxWidth;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          height: 300, 
          // El SingleChildScrollView permite que si hay muchos datos, se pueda deslizar
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: finalWidth,
              child: BarChart(
                BarChartData(
                  // 'spaceAround' distribuye las barras uniformemente en el ancho disponible
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: _getYAxisInterval(),
                        getTitlesWidget: (value, meta) => Text(
                          _formatYAxisLabel(value),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Transform.rotate(
                                angle: -0.5, // Ligera rotación para que no choquen
                                child: Text(
                                  data[index].category,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getYAxisInterval(),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index].ammount.toDouble(),
            // Aumentamos el ancho de la barra de 20 a 30 para que se vea mejor
            width: 30, 
            color: type == CategoryType.income ? Colors.green : Colors.redAccent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    });
  }

  double _getMaxY() {
    if (data.isEmpty) return 10;
    final max = data.map((e) => e.ammount).reduce((a, b) => a > b ? a : b);
    return max == 0 ? 10 : max * 1.2;
  }

  double _getYAxisInterval() {
    final maxY = _getMaxY();
    return maxY / 5;
  }

  String _formatYAxisLabel(double value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toInt().toString();
  }
}
