import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/controllers/doctor_controller.dart';
import 'package:synthecure/src/controllers/hospital_controller.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/features/admin/hospitals/add_hospital.dart';
import 'package:synthecure/src/widgets/empty_content.dart';

typedef ItemWidgetBuilder<T> = Widget Function(
    BuildContext context, T item);

class ListItemsBuilder<T> extends StatelessWidget {
  const ListItemsBuilder(
      {super.key,
      required this.data,
      required this.itemBuilder,
      required this.message,
      required this.title});
  final AsyncValue<List<T>> data;
  final ItemWidgetBuilder<T> itemBuilder;
  final String message;
  final String title;

  @override
  Widget build(BuildContext context) {
    return data.when(
      data: (items) {
        return items.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.only(top: 12),
                itemCount: items.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0 ||
                      index == items.length + 1) {
                    return const SizedBox.shrink();
                  }
                  return itemBuilder(
                      context, items[index - 1]);
                },
              )
            : EmptyContent(
                message: message,
                title: title,
              );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, __) => const EmptyContent(
        title: 'Something went wrong',
        message: 'Can\'t load items right now',
      ),
    );
  }
}

typedef SliverItemWidgetBuilder<T> = Widget Function(
    BuildContext context, T item);

class SliverListItemsBuilder<T> extends StatelessWidget {
  const SliverListItemsBuilder(
      {super.key,
      required this.data,
      required this.itemBuilder,
      required this.message,
      required this.title});

  final AsyncValue<List<T>> data;
  final SliverItemWidgetBuilder<T> itemBuilder;
  final String message;
  final String title;

  @override
  Widget build(BuildContext context) {
    return data.when(
      data: (items) {
        if (items.isEmpty) {
          return SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: EmptyContent(
              message: message,
              title: title,
            ),
          ));
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // Add padding elements at the start and end of the list
              if (index == 0 || index == items.length + 1) {
                return const SizedBox.shrink();
              }
              return itemBuilder(context, items[index - 1]);
            },
            childCount: items.length +
                2, // Include padding elements
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SliverToBoxAdapter(
        child: EmptyContent(
          title: 'Something went wrong',
          message: 'Can\'t load items right now',
        ),
      ),
    );
  }
}

class GridItemsBuilder<T> extends StatelessWidget {
  const GridItemsBuilder({
    super.key,
    required this.data,
    required this.itemBuilder,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
  });

  final AsyncValue<List<T>> data;
  final ItemWidgetBuilder<T> itemBuilder;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return data.when(
      data: (items) {
        return items.isNotEmpty
            ? Padding(
                padding: EdgeInsets.zero,
                child: GridView.builder(
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing:
                              crossAxisSpacing,
                          mainAxisSpacing: mainAxisSpacing,
                          childAspectRatio:
                              childAspectRatio,
                          mainAxisExtent: 180),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return itemBuilder(
                        context, items[index]);
                  },
                ),
              )
            : const Center(
                child: Text(
                  'No items available',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text(
          'Something went wrong. Please try again later.',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

typedef SliverItemWidgetBuilderSortDoctors<Doctor> = Widget
    Function(BuildContext context, Doctor item);

class SliverListItemsBuilderSortDoctors<T>
    extends ConsumerWidget {
  const SliverListItemsBuilderSortDoctors(
      {super.key,
      required this.data,
      required this.itemBuilder,
      required this.message,
      required this.title});

  final AsyncValue<List<Doctor>> data;
  final SliverItemWidgetBuilder<Doctor> itemBuilder;
  final String message;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return data.when(
      data: (items) {
        // Sort doctors: selected ones first, then unselected
        final sortedDoctors = items
          .where((doc) => ref
              .read(selectedDoctorsProvider)
              .any((selectedDoc) => selectedDoc.id == doc.id)) // Match by id
          .toList()
        ..addAll(items
            .where((doc) => !ref
                .read(selectedDoctorsProvider)
                .any((selectedDoc) => selectedDoc.id == doc.id)) // Match by id
            .toList());



        if (items.isEmpty) {
          return SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: EmptyContent(
              message: message,
              title: title,
            ),
          ));
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // Add padding elements at the start and end of the list
              if (index == 0 ||
                  index == sortedDoctors.length + 1) {
                return const SizedBox.shrink();
              }
              return itemBuilder(
                  context, sortedDoctors[index - 1]);
            },
            childCount: sortedDoctors.length +
                2, // Include padding elements
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SliverToBoxAdapter(
        child: EmptyContent(
          title: 'Something went wrong',
          message: 'Can\'t load items right now',
        ),
      ),
    );
  }
}



typedef SliverItemWidgetBuilderSortHospitals<Hospital> = Widget
    Function(BuildContext context, Hospital item);

class SliverListItemsBuilderSortHospitals<T>
    extends ConsumerWidget {
  const SliverListItemsBuilderSortHospitals(
      {super.key,
      required this.data,
      required this.itemBuilder,
      required this.message,
      required this.title});

  final AsyncValue<List<Hospital>> data;
  final SliverItemWidgetBuilder<Hospital> itemBuilder;
  final String message;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return data.when(
      data: (items) {
        // Sort doctors: selected ones first, then unselected
        final sortedHospitals = items
          .where((doc) => ref
              .read(selectedHospitalsProvider)
              .any((selectedHos) => selectedHos.id == doc.id)) // Match by id
          .toList()
        ..addAll(items
            .where((doc) => !ref
                .read(selectedHospitalsProvider)
                .any((selectedHos) => selectedHos.id == doc.id)) // Match by id
            .toList());
        


        if (items.isEmpty) {
          return SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: EmptyContent(
              message: message,
              title: title,
            ),
          ));
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // Add padding elements at the start and end of the list
              if (index == 0 ||
                  index == sortedHospitals.length + 1) {
                return const SizedBox.shrink();
              }
              return itemBuilder(
                  context, sortedHospitals[index - 1]);
            },
            childCount: sortedHospitals.length +
                2, // Include padding elements
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SliverToBoxAdapter(
        child: EmptyContent(
          title: 'Something went wrong',
          message: 'Can\'t load items right now',
        ),
      ),
    );
  }
}
