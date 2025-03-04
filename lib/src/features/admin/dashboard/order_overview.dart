import 'package:easy_pie_chart/easy_pie_chart.dart'
    as pieChart;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/domain/analytics_totals.dart';
import 'package:synthecure/src/features/admin/dashboard/revenue_chart.dart';
import 'package:synthecure/src/features/admin/dashboard/sales_overview.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/services/analytics_service.dart';
import 'package:synthecure/src/utils/format.dart';
import 'package:synthecure/src/widgets/empty_content.dart';
import 'package:synthecure/src/widgets/percent_change.dart';

class OrderChart extends ConsumerWidget {
  const OrderChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    OrderPercentText(),
                    const SizedBox(
                      height: 36,
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        gapW16,
                        OrderPieChart(),
                        Spacer(),
                        AverageOrderInfo()
                      ],
                    ),
                    gapH20,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AverageOrderInfo extends ConsumerWidget {
  const AverageOrderInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(selectedTimePeriodProvider);

    final analytics = ref.watch(salesOverviewStreamProvider(
      id: ref.watch(firebaseAuthProvider).currentUser!.uid,
      mode: mode,
    ));

    return analytics.when(
      data: (model) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gapH16,
            Text(
              "Average Order",
              style:
                  Theme.of(context).textTheme.titleMedium,
            ),
            gapH8,
            Text(
              "\$${Format.formatSalesCurrency(model.averageOrderValue)}", // ✅ Uses AOV
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 20),
            ),
            gapH12,
            Row(
              children: [
                PercentChange(
                  percentChange: model.percentChangeAOV ??
                      0.0, // ✅ Uses percentChangeAOV
                ),
              ],
            )
          ],
        );
      },
      loading: () => _buildShimmerLoading(context),
      error: (_, __) => const Text("Error loading data"),
    );
  }

  // ✅ Shimmer effect for loading state
  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH16,
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          gapH8,
          Container(
            width: 100,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          gapH12,
          Row(
            children: [
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderPieChart extends ConsumerWidget {
  const OrderPieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(selectedTimePeriodProvider);

    final analytics = ref.watch(salesOverviewStreamProvider(
      id: ref.watch(firebaseAuthProvider).currentUser!.uid,
      mode: mode,
    ));

    return SizedBox(
      height: 120,
      child: analytics.when(
        data: (model) {
          double totalOrders = model.totalOrders.toDouble();
          double percentChange = model.percentChangeOrders ?? 0.0;

          // ✅ Adjust fill based on percent change, ensuring it doesn't exceed 100% or go below 0%
          double fillRatio = (50 + (percentChange / 2)).clamp(0, 100); 

          return pieChart.EasyPieChart(
            key: const Key('pie'),
            children: [
              pieChart.PieData(
                value: fillRatio, // ✅ Pie chart fill adjusted based on percent change
                color: Theme.of(context).primaryColorDark,
              ),
              pieChart.PieData(
                value: 100 - fillRatio,
                color: Theme.of(context).primaryColorDark.withOpacity(0.2),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    model.totalOrders.toString(), // ✅ Keeps totalOrders in the center
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 22),
                  ),
                  Text(
                    Format.getTimePeriodText(mode),
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => _buildShimmerLoading(context),
        error: (_, __) => const Center(child: Text("Error loading data")),
      ),
    );
  }

  // ✅ Shimmer effect while loading
  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderPercentText extends ConsumerWidget {
  const OrderPercentText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(selectedTimePeriodProvider);

    final analytics = ref.watch(salesOverviewStreamProvider(
      id: ref.watch(firebaseAuthProvider).currentUser!.uid,
      mode: mode,
    ));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Order Information",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        analytics.when(
          data: (model) => PercentChange(
            percentChange: model.percentChangeOrders ?? 0.0,
            content: Format.getTimePeriodText(mode),
          ),
          error: (error, stackTrace) =>
              const Text("Error"),
          loading: () => _buildShimmerPercentChange(),
        ),
      ],
    );
  }

  // ✅ Shimmer effect for loading state on PercentChange
  Widget _buildShimmerPercentChange() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 80,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
