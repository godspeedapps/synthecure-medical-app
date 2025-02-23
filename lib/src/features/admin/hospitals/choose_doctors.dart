import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:synthecure/src/features/admin/hospitals/add_hospital.dart';
import 'package:synthecure/src/repositories/doctor_repository.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/services/doctors_service.dart';
import 'package:synthecure/src/widgets/list_items_builder.dart';

class ChooseDoctors extends ConsumerStatefulWidget {
  const ChooseDoctors({super.key});

  @override
  ChooseDoctorsState createState() => ChooseDoctorsState();
}

class ChooseDoctorsState
    extends ConsumerState<ChooseDoctors> {
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
      child: SafeArea(
        child: SuperScaffold(
          appBar: SuperAppBar(
            previousPageTitle: "Hospital",
            title: Text("Select Doctors"),
            largeTitle: SuperLargeTitle(
              enabled: true,
              largeTitle: "Select Doctors",
            ),
            searchBar: SuperSearchBar(
              // Pass the FocusNode here
              onSubmitted: (value) {
                _searchFocusNode.requestFocus();
              },
              onChanged: (query) {
                // Update the search query manually (if using Riverpod)
                ref
                    .read(
                        doctorSearchQueryProvider.notifier)
                    .state = query;
              },
              searchController:
                  _searchController, // Pass the controller here
              searchFocusNode: _searchFocusNode,
              resultBehavior:
                  SearchBarResultBehavior.visibleOnInput,
              searchResult: Material(
                child: Consumer(
                  builder: (context, ref, child) {
                    final doctorStream =
                        ref.watch(filteredDoctorsProvider);

                    return CustomScrollView(
                      slivers: [
                        SliverListItemsBuilder<Doctor>(
                          title: "No doctors found",
                          message: "Try searching again ⤴️",
                          data: doctorStream,
                          itemBuilder: (context, model) =>
                              DoctorTile(model: model),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // actions: Padding(
            //   padding: const EdgeInsets.symmetric(
            //       horizontal: 16.0),
            //   child: IconButton(
            //     onPressed: () {
            //       _showAddDoctorDialog(context);
            //     },
            //     icon: Icon(
            //       CupertinoIcons.add,
            //       color: Theme.of(context).primaryColor,
            //     ),
            //   ),
            // ),
          ),
          body: CustomScrollView(
            slivers: [
              Consumer(
                builder: (context, ref, child) {
                  final doctorStream = ref.watch(
                      doctorsTileModelStreamProvider);

                  return SliverListItemsBuilder<Doctor>(
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
    );
  }

  void _showAddDoctorDialog(BuildContext context) {
    TextEditingController nameController =
        TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (context) => Column(
        children: [
          SizedBox(
            height:
                MediaQuery.of(context).size.height / 3 - 50,
          ),
          SingleChildScrollView(
            child: CupertinoAlertDialog(
              title: Text("Add New Doctor"),
              content: Column(
                children: [
                  SizedBox(height: 10),
                  CupertinoTextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(
                          r'^[a-zA-Z\s]*$')), // Only letters and spaces
                    ],
                    controller: nameController,
                    placeholder: "Doctor's Name",
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors
                          .white, // Background color
                      borderRadius: BorderRadius.circular(
                          12), // Rounded corners
                    ),
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text("Cancel"),
                  onPressed: () =>
                      Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text("Add"),
                  onPressed: () {
                    String enteredName =
                        nameController.text.trim();
                    if (enteredName.isNotEmpty) {
                     
                      context.pop();
                    }
                  },
                ),
              ],
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
    if (model.hospitals!.isNotEmpty) {
      final randomHospital =
          (model.hospitals!..shuffle()).first;
      final othersCount = model.hospitals!.length - 1;
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
          final isSelected =
              selectedDoctors.contains(model);

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
