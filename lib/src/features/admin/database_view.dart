import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/domain/sales_totals.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/services/analytics_service.dart';
import 'package:synthecure/src/theme/colors.dart';
import 'package:synthecure/src/widgets/empty_content.dart';
import 'package:synthecure/src/utils/format.dart';
import 'package:easy_pie_chart/easy_pie_chart.dart'
    as pieChart;
import 'package:synthecure/src/widgets/percent_change.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(
            backgroundColor: Colors.white,
            largeTitle: Text('Synthecure'),
            trailing: Icon(
              CupertinoIcons.add_circled,
              color: synthecurePrimaryColor,
            ),
          ),
          DatabaseList(),
          RevenueChart(),
          SalesOverview(),
          SliverToBoxAdapter(
            child: gapH48,
          )
        ],
      ),
    );
  }
}

class SalesOverview extends ConsumerWidget {
  const SalesOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesOverViewProvider = ref.watch(
        salesOverviewStreamProvider(
            id: ref
                .read(firebaseAuthProvider)
                .currentUser!
                .uid));

    return salesOverViewProvider.when(
        data: (SalesTotals model) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  gapH12,
                  const Text(
                    "Sales Overview",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  gapH12,
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Get the screen width
                      double screenWidth =
                          constraints.maxWidth;

                      // Calculate child width dynamically
                      double itemWidth = (screenWidth / 2) -
                          16; // Minus padding
                      double itemHeight =
                          itemWidth; // Adjust this ratio as needed

                      return GridView.count(
                        padding: EdgeInsets.zero,
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        childAspectRatio: itemWidth /
                            itemHeight, // Dynamic aspect ratio
                        children: [
                          _OverviewCard(
                              title: "Total Revenue",
                              value: Format
                                  .formatSalesCurrency(
                                      model.totalRevenue),
                              percentChange: Format
                                  .calculatePercentChange(
                                      model.totalRevenue,
                                      model
                                          .previousTotalRevenue),
                              icon: Icons.attach_money,
                              iconColor: Colors.purple),
                          _OverviewCard(
                              title: "Average Orders",
                              value: Format
                                  .formatSalesCurrency(model
                                      .averageOrderValue),
                              percentChange: Format
                                  .calculatePercentChange(
                                      model
                                          .averageOrderValue,
                                      model
                                          .previousAverageOrderValue),
                              icon:
                                  CupertinoIcons.doc_append,
                              iconColor: Colors.blue),
                          _OverviewCard(
                              title: "Total Hospitals",
                              value: model.totalHospitals
                                  .toString(),
                              percentChange: Format
                                  .calculatePercentChange(
                                      model.totalHospitals
                                          .toDouble(),
                                      model
                                          .previousTotalHospitals
                                          .toDouble()),
                              icon: Icons.people,
                              iconColor: Colors.green),
                          _OverviewCard(
                              title: "Products Sold",
                              value: model.totalProductsSold
                                  .toString(),
                              percentChange: Format
                                  .calculatePercentChange(
                                      model
                                          .totalProductsSold
                                          .toDouble(),
                                      model
                                          .previousTotalProductsSold
                                          .toDouble()),
                              icon: Icons.inventory,
                              iconColor: Colors.red),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _OrderChart(
                    totalOrders: model.totalOrders,
                    previousTotalOrders:
                        model.previousTotalOrders,
                    averageOrders: model.averageOrderValue,
                    percentChange: Format.calculatePercentChange(model.averageOrderValue, model.previousAverageOrderValue),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => SliverToBoxAdapter(
              child: const Center(
                  child: CircularProgressIndicator()),
            ),
        error: (_, __) => SliverToBoxAdapter(
              child: const EmptyContent(
                title: 'Something went wrong',
                message: 'Can\'t load items right now',
              ),
            ));
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final double percentChange;
  final IconData icon;
  final Color iconColor;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.percentChange,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(15)),
                    child: Icon(icon, color: iconColor)),
                const Spacer(),
                Icon(Icons.more_horiz,
                    color: Colors.black45),
              ],
            ),
            gapH16,
            Text(
              title,
              style:
                  Theme.of(context).textTheme.titleMedium,
            ),
            gapH8,
            Text(
              title == "Total Revenue" ||
                      title == "Average Case"
                  ? "\$$value"
                  : value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            gapH12,
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "last week",
                  style:
                      Theme.of(context).textTheme.bodySmall,
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    children: [
                      WidgetSpan(
                        child: Icon(
                          percentChange >= 0
                              ? CupertinoIcons.up_arrow
                              : CupertinoIcons.down_arrow,
                          color: percentChange >= 0
                              ? Colors.green
                              : Colors.red,
                          size: 14,
                        ),
                      ),
                      TextSpan(
                        text:
                            "${percentChange.abs().toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: percentChange >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderChart extends StatelessWidget {
  final int totalOrders;
  final int previousTotalOrders;
  final double percentChange;
  final double averageOrders;
  const _OrderChart(
      {required this.totalOrders,
      required this.previousTotalOrders, required this.percentChange, required this.averageOrders});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Order Information",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                PercentChange(
                  percentChange:
                      Format.calculatePercentChange(
                    totalOrders.toDouble(),
                    previousTotalOrders.toDouble(),

                  ),
                  content: "Total",
                )
              ],
            ),
            const SizedBox(
              height: 36,
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                gapW16,
                SizedBox(
                  height: 120,
                  child: pieChart.EasyPieChart(
                    key: const Key('pie'),
                    children: [
                      pieChart.PieData(
                        value: ((totalOrders -
                                    previousTotalOrders) /
                                totalOrders) *
                            100,
                        color: Theme.of(context)
                            .primaryColorDark,
                      ),
                      pieChart.PieData(
                        value: (previousTotalOrders /
                                totalOrders) *
                            100,
                        color: Theme.of(context)
                            .primaryColorDark
                            .withOpacity(0.2),
                      ),
                    ],
                    pieType: pieChart.PieType.crust,
                    onTap: (index) {},
                    gap: 0.1,
                    start: 0,
                    animateFromEnd: true,
                    size: 130,
                    showValue: false,
                    child: Center(
                        child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(totalOrders.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(fontSize: 22)),
                        Text("Total Orders",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontSize: 13))
                      ],
                    )),
                  ),
                ),
                Spacer(),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    gapH16,
                    Text(
                      "Average Orders",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    gapH8,
                    Text(
                      "\$${Format.formatSalesCurrency(averageOrders)}",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),
                    gapH12,
                    PercentChange(percentChange: percentChange, )
                  ],
                )
              ],
            ),
            gapH20,
          ],
        ),
      ),
    );
  }
}

class DatabaseList extends StatelessWidget {
  const DatabaseList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dashboardItems = [
      {
        "label": "Orders",
        "icon": CupertinoIcons.doc_append,
        "route": AppRoute.allOrders.name,
      },
      {
        "label": "Hospitals",
        "icon": Icons.local_hospital,
        "route": AppRoute.allHospitals.name,
      },
      {
        "label": "Products",
        "icon": Icons.inventory,
        "route": AppRoute.allProducts.name,
      },
      {
        "label": "Doctors",
        "icon": Icons.person,
        "route": AppRoute.allDoctors.name,
      },
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: dashboardItems.length,
          padding:
              const EdgeInsets.symmetric(horizontal: 8.0),
          itemBuilder: (context, index) {
            final item = dashboardItems[index];

            return Padding(
              padding: EdgeInsets.only(
                  left: index == 0 ? 8.0 : 0,
                  right: index == dashboardItems.length - 1
                      ? 8.0
                      : 0),
              child: _DashboardItem(
                label: item["label"],
                icon: item["icon"],
                backgroundColor: Theme.of(context)
                    .primaryColor
                    .withOpacity(0.05),
                iconColor:
                    Theme.of(context).primaryColorDark,
                onTap: () =>
                    context.pushNamed(item["route"]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _DashboardItem({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
            20), // Smaller curved corners
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: iconColor.withOpacity(0.3),
          child: SizedBox(
            width:
                80, // Adjust width to create a smaller box

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: iconColor,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Revenue Growth Chart (Line Chart)
class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 8.0, vertical: 8.0),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("analytics")
                  .doc("yearly_2025")
                  .collection("monthly")
                  .doc("2025-02")
                  .collection("orders")
                  .orderBy(FieldPath.fromString(
                      'orderDate')) // Sort by YYYY-MM
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 160,
                    child: Center(
                        child: CircularProgressIndicator()),
                  );
                }

                final monthlyData = snapshot.data!.docs;
                List<FlSpot> revenueSpots = [];
                double latestRevenue = 0;
                double? lastSheetRevenue = 0;
                double totalRevenue = 0;

                // ✅ Loop through Firestore data
                for (int i = 0;
                    i < monthlyData.length;
                    i++) {
                  final data = monthlyData[i].data()
                      as Map<String, dynamic>;
                  final revenue =
                      (data["total"] ?? 0).toDouble();

                  totalRevenue += revenue;

                  // 🔥 Ensure at least two data points for FlChart
                  if (monthlyData.length == 1) {
                    revenueSpots.insert(
                        0,
                        FlSpot(0,
                            0)); // Add a ghost zero-value point
                  }

                  // 🔥 Add actual revenue data point
                  double xValue = revenueSpots.isEmpty
                      ? 1
                      : revenueSpots.last.x + 1;
                  revenueSpots.add(FlSpot(xValue, revenue));
                }

                // ✅ Get latest & last month revenue AFTER processing data
                latestRevenue = revenueSpots.last.y;

                lastSheetRevenue = revenueSpots.length > 1
                    ? revenueSpots[revenueSpots.length - 2]
                        .y
                    : 0;

                // ✅ Fix percent change calculation
                double percentChange = (revenueSpots
                            .length <
                        2)
                    ? (latestRevenue != 0
                        ? 100
                        : 0) // If one month, default to 100%
                    : (lastSheetRevenue == 0)
                        ? (latestRevenue != 0
                            ? 100
                            : 0) // If last month was 0, show 100% change
                        : ((latestRevenue -
                                    lastSheetRevenue) /
                                lastSheetRevenue) *
                            100;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Monthly Revenue",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "\$${Format.formatSalesCurrency(totalRevenue)}",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w600),
                              children: [
                                TextSpan(
                                  text: "last case sheet  ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                                WidgetSpan(
                                  child: Icon(
                                    percentChange >= 0
                                        ? CupertinoIcons
                                            .up_arrow
                                        : CupertinoIcons
                                            .down_arrow,
                                    color:
                                        percentChange >= 0
                                            ? Colors.green
                                            : Colors.red,
                                    size: 14,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "${percentChange.abs().toStringAsFixed(1)}%",
                                  style: TextStyle(
                                    color:
                                        percentChange >= 0
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
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
                            LineChart(
                              LineChartData(
                                minY: 0,
                                gridData:
                                    FlGridData(show: true),
                                titlesData: FlTitlesData(
                                    show: false),
                                borderData: FlBorderData(
                                    show: false),
                                lineTouchData:
                                    LineTouchData(
                                  enabled:
                                      false, // Disable interactions (no tapping)
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: revenueSpots,
                                    isCurved: true,
                                    color: Colors
                                        .deepPurpleAccent,
                                    dotData: FlDotData(
                                        show:
                                            false), // Hide data points
                                    belowBarData:
                                        BarAreaData(
                                      show: true,
                                      color: Colors
                                          .deepPurpleAccent
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
