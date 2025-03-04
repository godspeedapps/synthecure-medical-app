import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/domain/analytics_totals.dart';
import 'package:synthecure/src/domain/monthly_analytics.dart';
import 'package:synthecure/src/domain/sales_totals.dart';
import 'package:synthecure/src/features/admin/dashboard/order_overview.dart';
import 'package:synthecure/src/features/admin/dashboard/revenue_chart.dart';
import 'package:synthecure/src/features/admin/dashboard/sales_overview.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/repositories/test_analytics.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/services/analytics_service.dart';
import 'package:synthecure/src/widgets/empty_content.dart';
import 'package:synthecure/src/utils/format.dart';
import 'package:easy_pie_chart/easy_pie_chart.dart'
    as pieChart;

import 'package:synthecure/src/widgets/percent_change.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  /// Function to cycle through time periods
  void cycleTimePeriod(WidgetRef ref) {
    final periods = [
      "daily",
      "weekly",
      "monthly",
      "yearly"
    ];
    final currentPeriod =
        ref.read(selectedTimePeriodProvider);
    final nextIndex = (periods.indexOf(currentPeriod) + 1) %
        periods.length;
    ref.read(selectedTimePeriodProvider.notifier).state =
        periods[nextIndex];
  }


  @override
  Widget build(BuildContext context) {


    

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            collapsedHeight: 65.0,
            //title: Text("Synthecure", style: Theme.of(context).textTheme.titleLarge,),
            title: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Opacity(
                  opacity: 1,
                  child: Image.asset(
                      scale: 1.8,
                      "assets/Synthecure_Logo.jpg"),
                ),
              ),
            ),

            pinned: true,

          
          ),

          SliverToBoxAdapter(child: gapH16),
          const DatabaseList(),
          const RevenueChart(),
          const SalesOverview(),
          const OrderChart(),
          SliverToBoxAdapter(
            child: gapH48,
          )
        ],
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
        "label": "Team",
        "icon": Icons.people,
        "route": AppRoute.displayUsers.name,
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
        "icon": Icons.supervised_user_circle,
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
                backgroundColor: Colors.white,
                iconColor:
                    Theme.of(context).primaryColorDark.withOpacity(0.9),
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

final modeSelectionProvider = StateProvider<String>((ref) {
  return "monthly";
});

class MonthlyRevueFullChart extends ConsumerStatefulWidget {
  final MonthlyAnalytics model;

  const MonthlyRevueFullChart(
      {super.key, required this.model});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MonthlyRevenueFullChartPage();
}

class _MonthlyRevenueFullChartPage
    extends ConsumerState<MonthlyRevueFullChart> {
  @override
  Widget build(BuildContext context) {
    final double screenHeight =
        MediaQuery.of(context).size.height;
    final double chartHeight =
        screenHeight * 0.3; // ✅ Takes up 50% of the screen

    final mode = ref.watch(modeSelectionProvider);

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ✅ Top App Bar with Close Button
          Stack(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    top: 20,
                    left: 16,
                    right: 16,
                    bottom: 16),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        "Close",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(
                              color: Theme.of(context)
                                  .primaryColor,
                            ),
                      ),
                    ),
                    Text(
                      "Analytics this Month",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),
                    // Keeps title centered

                    const SizedBox(
                        width: 48), // Keeps UI balanced
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ✅ Chart with Rounded Borders (~500px height)
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0),
            child: Stack(
              children: [
                // ✅ Background Container (Rounded Borders Without Clipping)
                Container(
                  height: chartHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        24), // ✅ Keeps rounded corners
                  ),
                ),

                // ✅ Line Chart Positioned to Prevent Clipping
                Positioned.fill(
                  child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: mode == "monthly" ||
                              mode == "daily"
                          ? RevenueLineChart(
                              model: widget.model,
                              mode: mode,
                            )
                          : WeeklyBarChart(
                              model: widget.model,
                            )),
                ),

                Positioned(
                    bottom: 16,
                    left: 16,
                    child: GestureDetector(
                        onTap: () {
                          ref
                              .read(modeSelectionProvider
                                  .notifier)
                              .update((state) {
                            List<String> modes = [
                              "monthly",
                              "weekly",
                              "daily"
                            ];
                            int nextIndex =
                                (modes.indexOf(state) + 1) %
                                    modes.length;
                            return modes[nextIndex];
                          });
                        },
                        child: Icon(
                          CupertinoIcons.arrow_2_circlepath,
                          size: 30,
                        )))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RevenueLineChart extends ConsumerStatefulWidget {
  final MonthlyAnalytics model;
  final String mode;
  const RevenueLineChart(
      {super.key, required this.model, required this.mode});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RevenueLineChartState();
}

class _RevenueLineChartState
    extends ConsumerState<RevenueLineChart> {
  @override
  Widget build(BuildContext context) {
    String getOrderDateForSpot(double x) {
      int index = x.toInt();

      // ✅ Monthly Mode: Use `dailyOrders` index
      if (widget.mode == "monthly") {
        List<String> dateKeys =
            widget.model.dailyOrders.keys.toList();

        if (index >= 0 && index < dateKeys.length) {
          return "📅 ${DateFormat("MMM d").format(DateTime.parse(dateKeys[index]))}"; // ✅ "📅 Feb 26"
        }
      }

      // ✅ Daily Mode: Use `currentDayOrders` index
      else {
        List<OrderAnalytics> todayOrders =
            widget.model.currentDayOrders;

        if (index >= 0 && index < todayOrders.length) {
          return "⏰ ${DateFormat('hh:mm a').format(todayOrders[index].orderDate)}"; // ✅ "⏰ 2:30 PM"
        }
      }

      return "";
    }

    String getRevenueLabel(String mode) {
      if (mode == "monthly") {
        return "Monthly Revenue";
      } else if (mode == "weekly") {
        return "Weekly Revenue";
      } else {
        return "Daily Revenue";
      }
    }

    List<FlSpot> revenueSpots = (widget.mode == "monthly")
        ? widget.model.monthlyRevenueSpots
        : widget.model.dailyRevenueSpots;

    // ✅ Get the largest order amount
    double maxOrder = revenueSpots
        .map((spot) => spot.y)
        .fold(
            0,
            (prev, amount) =>
                amount > prev ? amount : prev);

    // ✅ Add a 20% buffer for better visualization
    double maxYValue = (maxOrder * 1.2).ceilToDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxYValue, // ✅ Dynamic Y-axis scaling
        lineBarsData: [
          LineChartBarData(
            spots: revenueSpots,
            isCurved: false,
            color: Colors.deepPurpleAccent,
            barWidth: 4,
            dotData: FlDotData(
              show: true,
              getDotPainter:
                  (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius:
                      4, // ✅ Adjust dot size (default is 4.0)
                  color: Colors
                      .deepPurple, // ✅ Customize dot color if needed
                  strokeColor: Colors.white,
                  strokeWidth: 1,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurpleAccent.withOpacity(0.3),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],

        // ✅ Removed Grid & Border Lines
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),

        // ✅ Adjusted Y-Axis Labels (Larger Increments, Only 5)
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 65,
              interval:
                  maxYValue / 5, // ✅ 5 Large Increments
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const SizedBox(); // ✅ Hide 0 value
                }
                return Text(
                  Format.formatRoundedNumber(value),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameSize: 35, // ✅ Increase size if needed
            axisNameWidget: Padding(
              padding: const EdgeInsets.only(
                  top:
                      16.0), // ✅ Adds spacing below the chart
              child: // Example usage in a Flutter widget:
                  Text(
                getRevenueLabel(widget
                    .mode), // Change mode here ("daily", "weekly", or any other)
                style:
                    Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),

        // ✅ Interactive Touch Features with Fixed Tooltip Clipping
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor:
                Colors.deepPurpleAccent.withOpacity(0.8),
            fitInsideHorizontally:
                true, // ✅ Prevents tooltip cutoff on sides
            fitInsideVertically:
                false, // ✅ Allows overflow above the chart
            getTooltipItems:
                (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  "${getOrderDateForSpot(spot.x)}\n",
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text:
                          "\$${Format.formatSalesCurrency(spot.y)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
          touchCallback: (FlTouchEvent event,
              LineTouchResponse? response) {
            if (event is FlTapUpEvent) {
              setState(() {});
            }
          },
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}

class WeeklyBarChart extends ConsumerStatefulWidget {
  final MonthlyAnalytics model;
  const WeeklyBarChart({super.key, required this.model});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WeeklyBarChartState();
}

class _WeeklyBarChartState
    extends ConsumerState<WeeklyBarChart> {
  /// 🔥 Get Weekday Label for Tooltips
  String getWeekdayLabel(int index) {
    List<String> weekDays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    if (index >= 0 && index < weekDays.length) {
      return "🗓 ${weekDays[index]}"; // ✅ "🗓 Monday"
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final weeklyBarData = widget.model.weeklyBarData;

    print(widget.model.weeklyOrders);

    /// 🔥 Get Max Order for Y-Axis Scaling
    double maxOrder = weeklyBarData
        .map((bar) => bar.barRods[0].toY)
        .fold(
            0,
            (prev, amount) =>
                amount > prev ? amount : prev);

    double maxYValue = (maxOrder * 1.2)
        .ceilToDouble(); // ✅ Add a 20% buffer
    double yInterval = (maxYValue / 5)
        .ceilToDouble(); // ✅ Ensure interval is valid
    if (yInterval == 0)
      yInterval = 1; // ✅ Prevents interval from being 0

    return BarChart(
      BarChartData(
        maxY: maxYValue, // ✅ Dynamic Y-axis scaling
        barGroups:
            weeklyBarData, // ✅ Uses weekly revenue data
        gridData:
            FlGridData(show: true), // ✅ Keep grid lines
        borderData:
            FlBorderData(show: false), // ✅ No outer border
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 65,
              interval:
                  yInterval, // ✅ Ensures interval is valid
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const SizedBox(); // ✅ Hide 0 value
                }
                return Text(
                  Format.formatRoundedNumber(value),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            axisNameSize: 35, // ✅ Increase size if needed
            axisNameWidget: Padding(
              padding: const EdgeInsets.only(
                  top:
                      16.0), // ✅ Adds spacing below the chart
              child: Text(
                "This Week", // ✅ "Weekly Revenue"
                style:
                    Theme.of(context).textTheme.titleMedium,
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                List<String> weekDays = [
                  "Mon",
                  "Tue",
                  "Wed",
                  "Thu",
                  "Fri",
                  "Sat",
                  "Sun"
                ];
                int index = value.toInt();

                /// 🔥 Ensure the index is within bounds
                if (index >= 0 && index < weekDays.length) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 6.0),
                    child: Text(
                      weekDays[
                          index], // ✅ "Mon", "Tue", etc.
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  );
                }
                return const SizedBox(); // ✅ Prevents side titles error
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor:
                Colors.deepPurpleAccent.withOpacity(0.8),
            getTooltipItem:
                (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                "${getWeekdayLabel(group.x.toInt())}\n",
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text:
                        "\$${Format.formatSalesCurrency(rod.toY)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
          touchCallback: (FlTouchEvent event,
              BarTouchResponse? response) {
            if (event is FlTapUpEvent) {
              setState(() {});
            }
          },
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}
