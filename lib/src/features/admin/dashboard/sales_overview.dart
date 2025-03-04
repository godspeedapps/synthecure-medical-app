import 'package:easy_pie_chart/easy_pie_chart.dart'
    as pieChart;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/domain/analytics_totals.dart';
import 'package:synthecure/src/domain/dashboard_analytics.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/services/analytics_service.dart';
import 'package:synthecure/src/utils/format.dart';
import 'package:synthecure/src/widgets/empty_content.dart';
import 'package:synthecure/src/widgets/percent_change.dart';
import 'package:shimmer/shimmer.dart';

final selectedTimePeriodProvider =
    StateProvider<String>((ref) {
  return "daily";
});

class SalesOverview extends ConsumerWidget {
  const SalesOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(selectedTimePeriodProvider);


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
      final nextIndex =
          (periods.indexOf(currentPeriod) + 1) %
              periods.length;
      ref.read(selectedTimePeriodProvider.notifier).state =
          periods[nextIndex];
    }

    String formatDate(String mode) {
      DateTime now = DateTime.now();

      switch (mode.toLowerCase()) {
        case "daily":
          return DateFormat("EEEE, MMM d")
              .format(now); // Example: "Monday, Mar 4"

        case "weekly":
          DateTime weekStart = now.subtract(
              Duration(days: now.weekday - 1)); // Monday
          DateTime weekEnd =
              weekStart.add(Duration(days: 6)); // Sunday
          return "${DateFormat("MMM d").format(weekStart)} - ${DateFormat("MMM d").format(weekEnd)}";
        // Example: "Mar 4 - Mar 10"

        case "monthly":
          return DateFormat("MMMM y")
              .format(now); // Example: "March 2025"

        case "yearly":
          return DateFormat("y")
              .format(now); // Example: "2025"

        default:
          return "Invalid Mode";
      }
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gapH12,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Sales Overview",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      cycleTimePeriod(ref);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(15)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                          ),
                          gapW12,
                          Text(
                            formatDate(mode),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            gapH12,
            LayoutBuilder(
              builder: (context, constraints) {
                // Get the screen width
                double screenWidth = constraints.maxWidth;
    
                // Calculate child width dynamically
                double itemWidth =
                    (screenWidth / 2) - 16; // Minus padding
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
                      title: "Active Reps",
                      icon: Icons.people,
                      iconColor: Colors.green,
                      mode: mode,
                    ),
                    _OverviewCard(
                      title: "Total Hospitals",
                      icon: Icons.local_hospital,
                      iconColor: Colors.red,
                      mode: mode,
                    ),
                    _OverviewCard(
                      title: "Total Doctors",
                      icon: Icons.dock,
                      iconColor: Colors.purple,
                      mode: mode,
                    ),
                    _OverviewCard(
                      title: "Products Sold",
                      icon: Icons.inventory,
                      iconColor: Colors.blue,
                      mode: mode,
                    ),
                  ],
                );
              },
            ),
    
            const SizedBox(height: 16),
            //_OrderChart(model: model, mode: mode),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String mode;

  const _OverviewCard(
      {required this.title,
      required this.icon,
      required this.iconColor,
      required this.mode});

  @override
  Widget build(BuildContext context) {
    String getTimePeriodText(String mode) {
      switch (mode) {
        case "daily":
          return "Today";
        case "weekly":
          return "This Week";
        case "monthly":
          return "This Month";
        case "yearly":
          return "This Year";
        default:
          return "All Time";
      }
    }

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
            Consumer(
              builder: (context, ref, child) {
                final salesOverViewProvider = ref.watch(
                    salesOverviewStreamProvider(
                        id: ref
                            .read(firebaseAuthProvider)
                            .currentUser!
                            .uid,
                        mode: mode));

                return salesOverViewProvider.when(
                    data: (model) {
                      // ✅ Dynamically select the correct data based on title
                      String value;
                      double percentChange;

                      switch (title) {
                        case "Active Reps":
                          value =
                              Format.formatSalesCurrency(
                                  model.totalRevenue);
                          percentChange =
                              model.percentChangeRevenue ??
                                  0.0;
                          break;
                        case "Total Doctors":
                          value = model.totalDoctors
                              .toString(); // ✅ `totalUsers` represents doctors
                          percentChange =
                              model.percentChangeDoctors ??
                                  0.0;
                          break;
                        case "Total Hospitals":
                          value = model.totalCustomers
                              .toString(); // ✅ `totalCustomers` represents hospitals
                          percentChange = model
                                  .percentChangeCustomers ??
                              0.0;
                          break;
                        case "Products Sold":
                          value = model.totalProductsSold
                              .toString();
                          percentChange = model
                                  .percentChangeProductsSold ??
                              0.0;
                          break;
                        default:
                          value = "N/A";
                          percentChange = 0.0;
                          break;
                      }

                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            value,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge,
                          ),
                          gapH12,
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Text(
                                getTimePeriodText(mode),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                              PercentChange(
                                  percentChange:
                                      percentChange)
                            ],
                          ),
                        ],
                      );
                    }, // ✅ Use extracted Shimmer widget
                    loading: () =>
                        const ShimmerOverviewColumn(),
                    error: (_, __) => const EmptyContent(
                          title: 'Something went wrong',
                          message:
                              'Can\'t load items right now',
                        ));
              },
            ),
          ],
        ),
      ),
    );
  }
}


class ShimmerOverviewColumn extends StatelessWidget {
  const ShimmerOverviewColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!, // ✅ Lighter shade
      highlightColor:
          Colors.grey[100]!, // ✅ Softer highlight
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for Value
          Container(
            width: 100,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 12),

          // Shimmer for Percent Change Row
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              // Time Period Placeholder
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              // Percent Change Placeholder
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
