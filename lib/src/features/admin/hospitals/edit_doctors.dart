import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:synthecure/src/controllers/hospital_controller.dart';
import 'package:synthecure/src/features/admin/hospitals/add_hospital.dart';
import 'package:synthecure/src/repositories/doctor_repository.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/services/doctors_service.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';
import 'package:synthecure/src/widgets/list_items_builder.dart';

class EditDoctors extends ConsumerStatefulWidget {
  final Hospital model;
  const EditDoctors({super.key, required this.model});

  @override
  EditDoctorsState createState() => EditDoctorsState();
}

class EditDoctorsState extends ConsumerState<EditDoctors> {
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
      adminHospitalControllerProvider,
      (_, state) {
        state.showAlertDialogUpdate(
            context, message: "${widget.model.name}'s doctors have been successfully updated", title: "Hospital updated!");
      },
    );

    return Material(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SafeArea(
            child: SuperScaffold(
              appBar: SuperAppBar(
                previousPageTitle: "Hospital",
                title: Text("Edit Doctors"),
                largeTitle: SuperLargeTitle(
                  enabled: true,
                  largeTitle: "Edit Doctors",
                ),
                searchBar: SuperSearchBar(
                  // Pass the FocusNode here
                  onSubmitted: (value) {
                    _searchFocusNode.requestFocus();
                  },
                  onChanged: (query) {
                    // Update the search query manually (if using Riverpod)
                    ref
                        .read(doctorSearchQueryProvider
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
                        final doctorStream = ref
                            .watch(filteredDoctorsProvider);
                        // Sort doctors: selected ones first, then unselected

                        return CustomScrollView(
                          slivers: [
                            SliverListItemsBuilderSortDoctors<
                                Doctor>(
                              title: "No doctors found",
                              message:
                                  "Try searching again ⤴️",
                              data: doctorStream,
                              itemBuilder: (context,
                                      model) =>
                                  DoctorTile(model: model),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                actions: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0),
                      child: IconButton(
                        onPressed: () {
                          print(ref.read(
                              selectedDoctorsProvider));
                        },
                        icon: Icon(
                          CupertinoIcons.add,
                          color: Theme.of(context)
                              .primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: CustomScrollView(
                slivers: [
                  Consumer(
                    builder: (context, ref, child) {
                      final doctorStream = ref.watch(
                          doctorsTileModelStreamProvider);

                      return SliverListItemsBuilderSortDoctors<
                          Doctor>(
                        title: "No doctors found",
                        message: "Try searching again ⤴️",
                        data: doctorStream,
                        itemBuilder: (context, model) =>
                            DoctorTile(model: model),
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
                final doctors =
                    ref.watch(selectedDoctorsProvider);

                final state = ref
                    .watch(adminHospitalControllerProvider);

                return 
                        !state.isLoading
                    ? TextButton(
                        onPressed: 
                        
                        doctors.isNotEmpty
                        ? () async {


                          await ref
                              .read(
                                  adminHospitalControllerProvider
                                      .notifier)
                              .updateHospitalDoctors(
                                  hospital: widget.model,
                                  updatedDoctors: doctors);

                       
                        } : null,
                        child: Text(
                          "Submit Changes",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: doctors.isNotEmpty
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

String getDoctorInitials(String name) {
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

class DoctorTile extends ConsumerWidget {
  final Doctor model;

  const DoctorTile({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get selected doctors from Riverpod provider

    // Determine the hospital display text
    String hospitalText = "No hospitals";
    if (model.hospitals.isNotEmpty) {
      final randomHospital =
          (model.hospitals!..shuffle()).first;
      final othersCount = model.hospitals.length - 1;
      hospitalText = othersCount > 0
          ? "${randomHospital.name} and $othersCount others"
          : randomHospital.name;
    }

    return ListTile(
      onTap: () {
        ref
            .read(selectedDoctorsProvider.notifier)
            .toggleDoctorSelection(model);
      },
      trailing: Consumer(
        builder: (context, ref, child) {
          final selectedDoctors =
              ref.watch(selectedDoctorsProvider);

          // Determine if the current doctor is selected
          final isSelected = selectedDoctors
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
          getDoctorInitials(model.name),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 18,
          ),
        ),
      ),
      title: Text(
        "Dr. ${model.name}",
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(hospitalText,
          style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
