import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/controllers/doctor_controller.dart';
import 'package:synthecure/src/controllers/hospital_controller.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';

final doctorPageProvider =
    StateProvider<Doctor?>((ref) => null);

class DoctorPage extends ConsumerWidget {
  const DoctorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Doctor model = ref.watch(doctorPageProvider)!;

     ref.listen<AsyncValue>(
      adminDoctorDeleteControllerProvider,
      (_, state) => state.showAlertDialogDelete(context, title: "Doctor deleted!", message: "${model.name} has been successfully deleted."),

    );


    String getHospitalDisplayText(List<HospitalInfo> hospitals) {
  if (hospitals.isEmpty) return "No hospitals";

  hospitals.shuffle(); // Shuffle to pick a random hospital
  final randomHospital = hospitals.first;
  final othersCount = hospitals.length - 1;

  return othersCount > 0
      ? "${randomHospital.name} (and $othersCount other${othersCount > 1 ? 's' : ''})"
      : randomHospital.name;
}



    String formatActiveHospitals(
        List<HospitalInfo> hospitals) {
      if (model.hospitals.isEmpty) {
        return "Active at no hospitals";
      }

      return "Active at ${model.hospitals[Random().nextInt(model.hospitals.length)].name}";
    }


    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        border: Border.all(color: Colors.transparent),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double
                .infinity, // Ensure the container expands across the full width
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical:
                    16.0), // Padding inside the container
            //margin: const EdgeInsets.symmetric(vertical: 8.0), // Optional: margin around the container
            decoration: BoxDecoration(
              color: Colors.white, // White background
              borderRadius: BorderRadius.circular(
                  8.0), // Optional: rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(
                      0.1), // Optional: subtle shadow
                  blurRadius: 5.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: .5,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    radius: 50,
                    child: const LottieAvatar(),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Dr. ${model.name}",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),
                SizedBox(height: 4),
                Text(
                  formatActiveHospitals(model.hospitals),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Section 1: Profile Section
                CupertinoListSection.insetGrouped(
                  backgroundColor: Theme.of(context)
                      .scaffoldBackgroundColor,
                  header: Text(
                    'DOCTOR',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                  children: [
                    CupertinoListTile(
                      padding: const EdgeInsets.all(12),
                      leading: Icon(
                          CupertinoIcons.person_circle,
                          size: 25,
                          color: Theme.of(context)
                              .colorScheme
                              .primary),
                      title: Text('Hospitals',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall),
                      subtitle: Text(
                          getHospitalDisplayText(
                              model.hospitals),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall),
                      trailing:
                          const CupertinoListTileChevron(),
                      onTap: () async {
                        ref
                            .read(selectedHospitalsProvider
                                .notifier)
                            .setHospitals(model.hospitals.map((e) => Hospital(id: e.id, name: e.name, email: e.id)).toList());

                        context.pushNamed(
                            AppRoute.editHospitals.name,
                            extra: model)  .whenComplete(() {
                          ref
                              .read(selectedHospitalsProvider
                                  .notifier)
                              .clear(); // Clears the provider when returning
                        });;
                      },
                    ),
                  ],
                ),

                // Section 2: Account Settings Section
                CupertinoListSection.insetGrouped(
                  backgroundColor: Theme.of(context)
                      .scaffoldBackgroundColor,
                  header: Text(
                    'LOGS',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                  children: [
                    CupertinoListTile(
                      leading: const Icon(
                          CupertinoIcons.doc_on_clipboard,
                          size: 22,
                          color:
                              CupertinoColors.systemGrey),
                      title: Text('Case Sheets',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall),
                      trailing:
                          const CupertinoListTileChevron(),
                      onTap: () async {
                        context.pushNamed(
                            AppRoute.doctorCaseSheets.name,
                            extra: model);
                      },
                    ),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  backgroundColor: Theme.of(context)
                      .scaffoldBackgroundColor,
                  topMargin: 0,
                  children: [
                    CupertinoListTile(
                      leading: const Icon(
                          CupertinoIcons.trash,
                          size: 22,
                          color: CupertinoColors.systemRed),
                      title: Text('Delete Doctor',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  color: CupertinoColors
                                      .systemRed)),
                      trailing:
                          const CupertinoListTileChevron(),
                      onTap: () {
                        showCupertinoDialog(
                            context: context,
                            builder:
                                (context) =>
                                    CupertinoAlertDialog(
                                      title: Text(
                                          'Delete Dr.${model.name}'),
                                      content: Text(
                                          "Are you sure you want to delete ${model.name}' All case sheet data will persist, but the doctor will lose their info"),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: () =>
                                              Navigator.pop(
                                                  context),
                                          child: const Text(
                                              'Cancel'),
                                        ),
                                        Consumer(
                                          builder: (context,
                                              ref, child) {
                                            final state =
                                                ref.watch(
                                                    adminDoctorControllerProvider);

                                            return CupertinoDialogAction(
                                              isDestructiveAction:
                                                  true,
                                              onPressed: state
                                                      .isLoading
                                                  ? null // Disable button during loading
                                                  : () async {
                                                      await ref
                                                          .read(adminDoctorDeleteControllerProvider.notifier)
                                                          .deleteDoctor(doctor: model);
                                                    },
                                              child: state
                                                      .isLoading
                                                  ? const CupertinoActivityIndicator() // Show loader
                                                  : const Text(
                                                      'Delete'), // Default text
                                            );
                                          },
                                        ),
                                      ],
                                    ));
                      },
                    ),
                  ],
                ),

                // Logout Button Section

                gapH16,

                Opacity(
                  opacity: 0.8,
                  child: Column(
                    children: [
                      Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            "assets/Synthecure_Logo.jpg",
                            scale: 2.2,
                          )),
                      gapH12,
                      Opacity(
                        opacity: 0.4,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons
                                  .check_mark_circled,
                              size: 15,
                            ),
                            gapW4,
                            Text(
                              "Version 1.0.2",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),
                          ],
                        ),
                      ),
                      gapH4,
                      Opacity(
                          opacity: 0.4,
                          child: Text(
                            "powered by Godspeed Apps LLC 🚀",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          )),
                    ],
                  ),
                ),

                gapH32
              ],
            ),
          ),


        ],
      ),
    );
  }
}

class LottieAvatar extends StatefulWidget {
  const LottieAvatar({super.key});

  @override
  State<LottieAvatar> createState() =>
      _LottieNetworkExampleState();
}

class _LottieNetworkExampleState extends State<LottieAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the Animation Controller for looping
    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 120,
      child: Lottie.asset(
        'assets/avatar_anim.json', // Correct JSON link for DNA animation
        backgroundLoading: true,
        controller: _controller,
        repeat: true, // Ensures the animation repeats
        animate: true, // Starts animating automatically
        onLoaded: (composition) {
          _controller
            ..duration = composition.duration
            ..repeat(); // Infinite looping
        },
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
