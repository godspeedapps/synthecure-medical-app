import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/features/admin/dashboard/sales_overview.dart';
import 'package:synthecure/src/utils/format.dart';

class FullRevenueChart extends ConsumerWidget {
  final List<FlSpot> chartData;
  const FullRevenueChart(
      {super.key, required this.chartData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String getRevenueLabel(String mode) {
      if (mode == "monthly") {
        return "Monthly Revenue";
      } else if (mode == "weekly") {
        return "Weekly Revenue";
      } else if (mode == "daily") {
        return "Daily Revenue";
      } else {
        return "Yearly Revenue";
      }
    }

    final mode = ref.watch(selectedTimePeriodProvider);

    // ✅ Get the largest order amount
    double maxOrder = chartData.map((spot) => spot.y).fold(
        0, (prev, amount) => amount > prev ? amount : prev);

    print(maxOrder);

    // ✅ Add a 20% buffer for better visualization
    double maxYValue = (maxOrder * 1.2).ceilToDouble();

    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 150.0),
          child: Column(
            children: [
              Text(
                getRevenueLabel(mode),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY:
                        maxYValue, // ✅ Dynamic Y-axis scaling
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: false)),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 65,
                        interval: maxYValue /
                            5, // ✅ 5 Large Increments
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return const SizedBox(); // ✅ Hide 0 value
                          }
                          return Text(
                            Format.formatRoundedNumber(
                                value),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium,
                          );
                        },
                      )),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: false)),
                      topTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData:
                            LineTouchTooltipData(
                                tooltipBgColor: Colors
                                    .deepPurpleAccent
                                    .withOpacity(0.8),
                                fitInsideVertically: true,
                                getTooltipItems:
                                    (List<LineBarSpot>
                                        touchedSpots) {
                                  return touchedSpots
                                      .map((spot) {
                                    return LineTooltipItem(
                                      "\$${Format.formatSalesCurrency(spot.y)}",
                                      const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      // children: [
                                      //   TextSpan(
                                      //     text:
                                      //         "\$${Format.formatSalesCurrency(spot.y)}",
                                      //     style: const TextStyle(
                                      //       color: Colors.white,
                                      //       fontSize: 12,
                                      //       fontWeight:
                                      //           FontWeight.bold,
                                      //     ),
                                      //   ),
                                      // ],
                                    );
                                  }).toList();
                                })),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: Colors.deepPurpleAccent,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent,
                              barData, index) {
                            return FlDotCirclePainter(
                              radius:
                                  5, // ✅ Adjust dot size (default is 4.0)
                              color: Colors
                                  .deepPurple, // ✅ Customize dot color if needed
                              strokeColor: Colors.white,
                              strokeWidth: 1.5,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurpleAccent
                                  .withOpacity(0.3),
                              Colors.white,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
