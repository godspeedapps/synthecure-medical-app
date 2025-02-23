import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:synthecure/src/controllers/doctor_controller.dart';
import 'package:synthecure/src/features/admin/doctors/doctor_page.dart';
import 'package:synthecure/src/repositories/doctor_repository.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/services/doctors_service.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';
import 'package:synthecure/src/widgets/list_items_builder.dart';

class AllDoctors extends ConsumerStatefulWidget {
  const AllDoctors({super.key});

  @override
  AllDoctorsState createState() => AllDoctorsState();
}

class AllDoctorsState extends ConsumerState<AllDoctors> {
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
    ref.listen<AsyncValue>(adminDoctorControllerProvider,
        (_, state) {

          
      state.showAlertDialogUpdate(context,
          title: "Doctor Added!",
          message:
              "New doctor has been successfully added.");
    });

    return Material(
      child: SuperScaffold(
        appBar: SuperAppBar(
          previousPageTitle: "Dashboard",
          title: Text("All Doctors"),
          largeTitle: SuperLargeTitle(
            enabled: true,
            largeTitle: "Your Doctors",
          ),
          searchBar: SuperSearchBar(
            // Pass the FocusNode here
            onSubmitted: (value) {
              _searchFocusNode.requestFocus();
            },
            onChanged: (query) {
              // Update the search query manually (if using Riverpod)
              ref
                  .read(doctorSearchQueryProvider.notifier)
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
          actions: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0),
            child: IconButton(
              onPressed: () =>
                  _showAddDoctorDialog(context),
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
                final doctorStream = ref
                    .watch(doctorsTileModelStreamProvider);

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
                    prefix: Padding(
                      padding:
                          const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Dr.",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall,
                      ),
                    ),
                    controller: nameController,
                    placeholder: "Last Name",
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
                Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(
                        adminDoctorControllerProvider);

                    return CupertinoDialogAction(
                      onPressed: !state.isLoading
                          ? () {
                              final enteredName =
                                  nameController.text
                                      .trim();

                              if (enteredName.isNotEmpty) {
                                ref
                                    .read(
                                        adminDoctorControllerProvider
                                            .notifier)
                                    .addDoctor(
                                        name: enteredName);
                              }
                            }
                          : null,
                      child: !state.isLoading
                          ? Text("Add")
                          : CupertinoActivityIndicator(),
                    );
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



    String getHospitalDisplayText(List<HospitalInfo> hospitals) {
  if (hospitals.isEmpty) return "No hospitals";

  hospitals.shuffle(); // Shuffle to pick a random hospital
  final randomHospital = hospitals.first;
  final othersCount = hospitals.length - 1;

  return othersCount > 0
      ? "${randomHospital.name} (and $othersCount other${othersCount > 1 ? 's' : ''})"
      : randomHospital.name;
}



    return ListTile(
      onLongPress: () async {
        // print("deleting user...");

        // await ref
        //     .read(userRepositoryProvider)
        //     .deleteUser(model.email);
      },
      onTap: () {
        ref.read(doctorPageProvider.notifier).state = model;

        context.pushNamed(AppRoute.doctorPage.name);
      },
      tileColor: Colors.white,
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
      subtitle: Text(getHospitalDisplayText(model.hospitals),
          style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
