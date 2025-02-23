import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/features/admin/hospitals/hospital_page.dart';
import 'package:synthecure/src/repositories/orders_repository.dart';
import 'package:synthecure/src/controllers/account_controller.dart';
import 'package:synthecure/src/services/hospitals_service.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';
import 'package:synthecure/src/widgets/list_items_builder.dart';

final firstNameProvider =
    StateProvider.autoDispose<String>((ref) => '');

final lastNameProvider =
    StateProvider.autoDispose<String>((ref) => '');

final emailProvider =
    StateProvider.autoDispose<String>((ref) => '');

final isAdminCreateProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class AddHospital extends ConsumerWidget {
  const AddHospital({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(firstNameProvider);

    final email = ref.watch(emailProvider);

    final state = ref.watch(userAccountControllerProvider);

    final isFormValid = name.isNotEmpty && email.isNotEmpty;

    ref.listen<AsyncValue>(
      userAccountControllerProvider,
      (_, state) =>
          state.showAlertDialogAddUser(context, email),
    );

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: Text(
                          "Cancel",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color: Theme.of(context)
                                      .primaryColor),
                        )),
                  ),
                  Flexible(
                    child: Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        "Add Hospital",
                        maxLines: 1,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextButton(
                        onPressed: isFormValid
                            ? () async {
                                // await ref
                                //     .read(
                                //         userAccountControllerProvider
                                //             .notifier)
                                //     .addUser(
                                //         firstName: firstName,
                                //         lastName: lastName,
                                //         email: email,
                                //         isAdmin: isAdmin);
                              }
                            : null,
                        child: state.isLoading
                            ? CupertinoActivityIndicator()
                            : Text(
                                "Submit",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        color: Theme.of(
                                                context)
                                            .primaryColor
                                            .withOpacity(
                                                isFormValid
                                                    ? 1
                                                    : .5)),
                              )),
                  ),
                ],
              ),
            ),
          ),
          gapH12,
          Container(
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                CupertinoListTile(
                  title: CupertinoTextField(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      // ✅ No border, no background
                      color: Colors.transparent,
                      border: Border.all(
                          color: Colors.transparent),
                    ),
                    placeholder: 'Hospital Name',
                    onChanged: (value) => ref
                        .read(firstNameProvider.notifier)
                        .state = value,
                  ),
                ),
                CupertinoListTile(
                  title: CupertinoTextField(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      // ✅ No border, no background
                      color: Colors.transparent,
                      border: Border.all(
                          color: Colors.transparent),
                    ),
                    placeholder: 'Email',
                    onChanged: (value) => ref
                        .read(emailProvider.notifier)
                        .state = value,
                  ),
                ),
                CupertinoListTile(
                  title: const Text('Select Doctors'),
                  trailing:
                      const CupertinoListTileChevron(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The main UI widgetimport 'package:flutter/material.dart';

class AllHospitals extends ConsumerStatefulWidget {
  const AllHospitals({super.key});

  @override
  AllHospitalsState createState() => AllHospitalsState();
}

class AllHospitalsState
    extends ConsumerState<AllHospitals> {
  // Declare the FocusNode and TextEditingController
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void dispose() {
    // Dispose of the focus node and controller when the widget is disposed
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SuperScaffold(
        appBar: SuperAppBar(
          previousPageTitle: "Dashboard",
          title: Text("All Hospitals"),
          largeTitle: SuperLargeTitle(
            enabled: true,
            largeTitle: "Your Hospitals",
          ),
          searchBar: SuperSearchBar(
            searchController:
                _searchController, // Attach the controller
            searchFocusNode:
                _searchFocusNode, // Attach the FocusNode
            onSubmitted: (value) {
              _searchFocusNode.requestFocus();
            },
            onChanged: (query) {
              // Update the search query using Riverpod
              ref
                  .read(
                      hospitalSearchQueryProvider.notifier)
                  .state = query;
            },
            resultBehavior:
                SearchBarResultBehavior.visibleOnInput,
            searchResult: Material(
              child: Consumer(
                builder: (context, ref, child) {
                  final hospitalStream =
                      ref.watch(filteredHospitalsProvider);

                  return CustomScrollView(
                    slivers: [
                      SliverListItemsBuilder<Hospital>(
                        data: hospitalStream,
                        title: "No hospitals found",
                        message: "Try searching again ⤴️",
                        itemBuilder: (context, model) =>
                            HospitalTile(model: model),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          actions: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0),
            child: IconButton(
              onPressed: () {
                // showCupertinoSheet<void>(
                //   context: context,
                //   pageBuilder: (BuildContext context) => Material(child: AddHospital()),
                // );

                context
                    .pushNamed(AppRoute.addHospital.name);
              },
              icon: Icon(
                CupertinoIcons.add,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            Consumer(
              builder: (context, ref, child) {
                final hospitalStream = ref.watch(
                    hospitalsTileModelStreamProvider);

                return SliverListItemsBuilder<Hospital>(
                  data: hospitalStream,
                  title: "No hospitals found",
                  message: "Try searching again ⤴️",
                  itemBuilder: (context, model) =>
                      HospitalTile(model: model),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

String getHospitalInitials(String name) {
  List<String> words =
      name.trim().split(RegExp(r'\s+')); // Split by spaces
  if (words.length >= 2) {
    return words[0][0].toUpperCase() +
        words[1][0]
            .toUpperCase(); // First letter of first two words
  } else if (words.isNotEmpty) {
    return words[0]
        .substring(0, min(2, words[0].length))
        .toUpperCase(); // First two letters of a single word
  }
  return ""; // Default empty string for safety
}

class HospitalTile extends ConsumerWidget {
  final Hospital model;

  const HospitalTile({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onLongPress: () async {
        // print("deleting hospital...");

        // await ref
        //     .read(adminHospitalControllerProvider.notifier)
        //     .deleteHospital(hospitalId: model.id);
      },
      onTap: () {
        ref.read(hospitalPageProvider.notifier).state =
            model;

        context.pushNamed(AppRoute.hospitalPage.name,
            extra: model);
      },
      tileColor: Colors.white,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(0.1),
        radius: 35,
        child: Text(
          getHospitalInitials(model.name),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 18,
          ),
        ),
      ),
      title: Text(
        model.name,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(model.email!,
          style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
