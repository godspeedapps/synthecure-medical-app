import 'dart:math' show Random;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/features/admin/dashboard/sales_overview.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/services/analytics_service.dart';
import 'package:synthecure/src/utils/format.dart';
import 'package:synthecure/src/widgets/empty_content.dart';
import 'package:synthecure/src/widgets/percent_change.dart';

/// Revenue Growth Chart (Line Chart)
class RevenueChart extends ConsumerWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(selectedTimePeriodProvider);

    final analytics = ref.watch(salesOverviewStreamProvider(
        id: ref
            .watch(firebaseAuthProvider)
            .currentUser!
            .uid,
        mode: mode));

    String getRevenuePeriodText(String mode) {
      switch (mode) {
        case "daily":
          return "Daily Revenue";
        case "weekly":
          return "Weekly Revenue";
        case "monthly":
          return "Monthly Revenue";
        case "yearly":
          return "Yearly Revenue";
        default:
          return "Total Revenue";
      }
    }

          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12)),
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                      12), // ✅ Ensures ripple follows the shape

                  onTap: () {
                    // showCupertinoSheet<void>(
                    //   context: context,
                    //   pageBuilder: (BuildContext context) =>
                    //       Material(
                    //           child: MonthlyRevueFullChart(
                    //     model: model,
                    //   )),
                    // );
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getRevenuePeriodText(
                                      mode),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Consumer(
                                  builder: (context, ref,
                                      child) {
                                    return analytics.when(
                                      data: (model) {

                                           return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          "\$${Format.formatSalesCurrency(model.totalRevenue)}",
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight:
                                                  FontWeight
                                                      .bold),
                                        ),
                                        gapH8,
                                        PercentChange(
                                          percentChange:
                                              model.percentChangeRevenue ??
                                                  0.0,
                                          content: Format
                                              .getTimePeriodText(
                                                  mode),
                                        )
                                      ],
                                    );
                                      },   loading: () => ShimmerRevenueCard(),
                                    error: (_, __) => Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: const EmptyContent(
                                        title: 'Something went wrong',
                                        message: 'Can\'t load items right now',
                                      ),
                                    )
                                    );
                                 
                                  },
                                ),
                              ],
                            ),
                            const Spacer(),

                            // 📌 Chart with Soft Edge Blur Effect
                            SizedBox(
                              height: 50,
                              width: 100,
                              child: Stack(
                                children: [
                                  // HomePageChart(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ),
          );

        }
}

class HomePageChart extends StatelessWidget {
  const HomePageChart({super.key});

  List<FlSpot> generateRandomSpots(int count) {
    final random = Random();
    return List.generate(
        count,
        (index) => FlSpot(
            index.toDouble(), random.nextDouble() * 100));
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0, // ✅ Ensure the chart starts from 0
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled:
              false, // Disable interactions (no tapping)
        ),
        lineBarsData: [
          LineChartBarData(
            spots: generateRandomSpots(
                10), // Generate random data points
            isCurved: true,
            color: Colors.deepPurpleAccent,
            dotData:
                FlDotData(show: false), // Hide data points
            belowBarData: BarAreaData(
              show: true,
              color:
                  Colors.deepPurpleAccent.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}



class ShimmerRevenueCard extends StatelessWidget {
  const ShimmerRevenueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!, // ✅ Lighter base color
      highlightColor: Colors.grey[100]!, // ✅ Softer highlight
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Placeholder
          Container(
            width: 120,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.grey[200], // ✅ Lighter shade
              borderRadius: BorderRadius.circular(8), // ✅ Rounded corners
            ),
          ),
          SizedBox(height: 8),
          // Percent Change Placeholder
          Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[200], // ✅ Lighter shade
              borderRadius: BorderRadius.circular(6), // ✅ Rounded corners
            ),
          ),
        ],
      ),
    );
  }
}
