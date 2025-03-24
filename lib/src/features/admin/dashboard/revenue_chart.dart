import 'dart:math' show pi, sin;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/domain/dashboard_analytics.dart';
import 'package:synthecure/src/domain/order_detail.dart';
import 'package:synthecure/src/features/admin/dashboard/full_revenue_chart.dart';
import 'package:synthecure/src/features/admin/dashboard/sales_overview.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/services/analytics_service.dart';
import 'package:synthecure/src/utils/format.dart';
import 'package:synthecure/src/widgets/empty_content.dart';
import 'package:synthecure/src/widgets/percent_change.dart';

/// Revenue Growth Chart (Line Chart)
class RevenueChart extends ConsumerWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.read(isAdminProvider);

    final GlobalKey<_HomePageChartState> chartKey =
        GlobalKey();

    final mode = ref.watch(selectedTimePeriodProvider);

    final analytics = ref.watch(salesOverviewStreamProvider(
        id: ref
            .watch(firebaseAuthProvider)
            .currentUser!
            .uid,
        mode: mode));

    String getRevenuePeriodText(String mode) {
      String titleText = isAdmin! ?  "Revenue" : "Sales";

      switch (mode) {
        case "daily":
          return "Daily $titleText";
        case "weekly":
          return "Weekly $titleText";
        case "monthly":
          return "Monthly $titleText";
        case "yearly":
          return "Yearly $titleText";
        default:
          return "Total $titleText";
      }
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 8.0, vertical: 8.0),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(
                12), // ✅ Ensures ripple follows the shape

            onTap: () async {
              final chartState = chartKey.currentState;
              if (chartState == null) return;

              List<FlSpot> chartData =
                  chartState.getChartData();

              await showCupertinoSheet(
                  context: context,
                  pageBuilder: (context) =>
                      FullRevenueChart(
                          chartData: chartData));
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
                            getRevenuePeriodText(mode),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Consumer(
                            builder: (context, ref, child) {
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
                                  },
                                  loading: () =>
                                      ShimmerRevenueCard(),
                                  error: (_, __) => Padding(
                                        padding:
                                            const EdgeInsets
                                                .all(32.0),
                                        child:
                                            const EmptyContent(
                                          title:
                                              'Something went wrong',
                                          message:
                                              'Can\'t load items right now',
                                        ),
                                      ));
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
                            HomePageChart(
                              key: chartKey,
                            ),
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

class HomePageChart extends ConsumerStatefulWidget {
  const HomePageChart({super.key});

  @override
  ConsumerState<HomePageChart> createState() =>
      _HomePageChartState();
}

class _HomePageChartState
    extends ConsumerState<HomePageChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  List<FlSpot> _chartData = []; // ✅ Store FlSpot data

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: false);

    // ✅ Ensure UI updates when animation value changes
    _animationController.addListener(() {
      setState(() {}); // Forces re-build
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ✅ Called by parent to get the latest chart data
  List<FlSpot> getChartData() {
    return _chartData;
  }

  // ✅ Generate real revenue spots from orderDetails
  List<FlSpot> generateRealSpots(
      List<OrderDetail> orderDetails) {
    List<FlSpot> flSpots = [];

    if (orderDetails.isEmpty) {
      flSpots = [const FlSpot(0, 0), const FlSpot(1, 0)];
    } else if (orderDetails.length == 1) {
      flSpots = [
        const FlSpot(0, 0),
        FlSpot(1, orderDetails[0].orderTotal),
      ];
    } else {
      flSpots = List.generate(
        orderDetails.length,
        (index) => FlSpot(index.toDouble(),
            orderDetails[index].orderTotal),
      );
    }

    return flSpots;
  }

  // ✅ Generate animated placeholder spots (Oscillating Line)
  List<FlSpot> generateLoadingSpots() {
    return List.generate(
      10,
      (index) {
        double x = index.toDouble();
        double y = 50 +
            20 *
                sin(_animationController.value * pi * 2 +
                    x);
        return FlSpot(x, y);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(selectedTimePeriodProvider);
    final salesOverview =
        ref.watch(salesOverviewStreamProvider(
      id: ref.watch(firebaseAuthProvider).currentUser!.uid,
      mode: mode,
    ));

    return SizedBox(
      height: 200,
      child: salesOverview.when(
        data: (DashboardAnalytics model) {
          _chartData = generateRealSpots(
              model.orderDetails); // ✅ Store latest data

          return LineChart(
            LineChartData(
              minY: 0,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots:
                      generateRealSpots(model.orderDetails),
                  isCurved: true,
                  color: Colors.deepPurpleAccent,
                  dotData: FlDotData(show: false),
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
          );
        },
        loading: () => SizedBox(
          height: 200,
          child: LineChart(
            // ✅ Animated oscillating sine wave
            LineChartData(
              minY: 0,
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: generateLoadingSpots(),
                  isCurved: true,
                  color: Colors.deepPurpleAccent
                      .withOpacity(0.7),
                  dotData: FlDotData(show: false),
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
        error: (_, __) =>
            const Center(child: Text("Error loading data")),
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
      highlightColor:
          Colors.grey[100]!, // ✅ Softer highlight
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Placeholder
          Container(
            width: 120,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.grey[200], // ✅ Lighter shade
              borderRadius: BorderRadius.circular(
                  8), // ✅ Rounded corners
            ),
          ),
          SizedBox(height: 8),
          // Percent Change Placeholder
          Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[200], // ✅ Lighter shade
              borderRadius: BorderRadius.circular(
                  6), // ✅ Rounded corners
            ),
          ),
        ],
      ),
    );
  }
}
