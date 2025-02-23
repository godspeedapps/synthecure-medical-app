import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:synthecure/src/controllers/account_controller.dart';
import 'package:synthecure/src/controllers/doctor_controller.dart';
import 'package:synthecure/src/controllers/hospital_controller.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:synthecure/src/repositories/orders_repository.dart';
import 'package:synthecure/src/services/hospitals_service.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';
import 'package:synthecure/src/utils/format.dart';
import 'package:synthecure/src/widgets/list_items_builder.dart';

class EditUserHospitals extends ConsumerStatefulWidget {
  final AppUser model;
  const EditUserHospitals({super.key, required this.model});

  @override
  EditUserHospitalsState createState() =>
      EditUserHospitalsState();
}

class EditUserHospitalsState
    extends ConsumerState<EditUserHospitals> {
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
    ref.listen<AsyncValue>(
      userUpdateHospitalsControllerProvider,
      (_, state) {
        state.showAlertDialogUpdate(context,
            message:
                "${widget.model.firstName}'s hospitals have been successfully updated.",
            title: "User updated!");
      },
    );

    return Material(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SafeArea(
            child: SuperScaffold(
              appBar: SuperAppBar(
                previousPageTitle: widget.model.firstName,
                title: Text("Edit Hospitals"),
                largeTitle: SuperLargeTitle(
                  enabled: true,
                  largeTitle: "Edit Hospitals",
                ),
                searchBar: SuperSearchBar(
                  // Pass the FocusNode here
                  onSubmitted: (value) {
                    _searchFocusNode.requestFocus();
                  },
                  onChanged: (query) {
                    // Update the search query manually (if using Riverpod)
                    ref
                        .read(hospitalSearchQueryProvider
                            .notifier)
                        .state = query;
                  },
                  searchController:
                      _searchController, // Pass the controller here
                  searchFocusNode: _searchFocusNode,
                  resultBehavior: SearchBarResultBehavior
                      .visibleOnInput,
                  searchResult: Material(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final hospitalStream = ref.watch(
                            filteredHospitalsProvider);
                        // Sort doctors: selected ones first, then unselected

                        return CustomScrollView(
                          slivers: [
                            SliverListItemsBuilderSortHospitals<
                                Hospital>(
                              title: "No Hospitals found",
                              message:
                                  "Try searching again ⤴️",
                              data: hospitalStream,
                              itemBuilder:
                                  (context, model) =>
                                      HospitalTile(
                                          model: model),
                            ),
                          ],
                        );
                      },
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

                      return SliverListItemsBuilderSortHospitals<
                          Hospital>(
                        title: "No Hospitals found",
                        message: "Try searching again ⤴️",
                        data: hospitalStream,
                        itemBuilder: (context, model) =>
                            HospitalTile(model: model),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            child: Consumer(
              builder: (context, ref, child) {
                final hospitals =
                    ref.watch(selectedHospitalsProvider);
                    

                final state = ref.watch(
                    userUpdateHospitalsControllerProvider);

                return !state.isLoading
                    ? TextButton(
                        onPressed: hospitals.isNotEmpty
                            ? () async {
                              

                                await ref
                                    .read(
                                        userUpdateHospitalsControllerProvider
                                            .notifier)
                                    .updateUsersHospitals(userToUpdate: widget.model,
                                        updatedHospitals:
                                            hospitals);
                              }
                            : null,
                        child: Text(
                          "Submit Changes",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: hospitals.isNotEmpty
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                    : Colors.grey,
                              ),
                        ),
                      )
                    : CupertinoActivityIndicator();
              },
            ),
          ),
        ],
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
    // Get selected doctors from Riverpod provider

    // Determine the hospital display text


    return ListTile(
      onTap: () {
        ref
            .read(selectedHospitalsProvider.notifier)
            .toggleHospitalSelection(model);
      },
      trailing: Consumer(
        builder: (context, ref, child) {
          final selectedHospitals =
              ref.watch(selectedHospitalsProvider);

          // Determine if the current doctor is selected
          final isSelected = selectedHospitals
              .any((item) => item.id == model.id);

          return CupertinoRadio(
            toggleable: true,
            value: true,
            groupValue: isSelected,
            onChanged: (value) {
              // Toggle selection using Riverpod
            },
          );
        },
      ),
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
      subtitle: Text(Format.getHospitalUsersText(model.users ?? []),
          style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
