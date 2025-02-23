import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/controllers/hospital_controller.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/features/admin/hospitals/add_hospital.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';
import 'package:url_launcher/url_launcher.dart';

final hospitalPageProvider =
    StateProvider<Hospital?>((ref) => null);

class HospitalPage extends ConsumerWidget {
  const HospitalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Hospital model = ref.watch(hospitalPageProvider)!;

    ref.listen<AsyncValue>(
      adminHospitalDeleteControllerProvider,
      (_, state) => state.showAlertDialogDelete(context,
          title: "Hospital deleted!",
          message:
              "${model.name} has been successfully deleted."),
    );

    String formatProductNames(List<Part> products) {
      if (products.isEmpty) return "No products";

      if (products.length <= 2) {
        return products.map((p) => p.part).join(", ");
      }

      final othersCount = products.length - 2;
      final othersText = othersCount == 1
          ? "1 other"
          : "$othersCount others";

      return "${products[0].part}, ${products[1].part} (and $othersText)";
    }

    String formatDoctorNames(List<Doctor> doctors) {
      if (doctors.isEmpty) return "No doctors";

      if (doctors.length <= 2) {
        return doctors.map((d) => d.name).join(", ");
      }

      final othersCount = doctors.length - 2;
      final othersText = othersCount == 1
          ? "1 other"
          : "$othersCount others";

      return "Dr.${doctors[0].name}, Dr.${doctors[1].name} (and $othersText)";
    }

    final double screenHeight =
        MediaQuery.of(context).size.height;

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
                  model.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),
                SizedBox(height: 4),
                Text(
                  model.email!,
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
                    'HOSPITAL',
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
                      title: Text('Doctors',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall),
                      subtitle: Text(
                          formatDoctorNames(model.doctors!),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall),
                      trailing:
                          const CupertinoListTileChevron(),
                      onTap: () async {
                        ref
                            .read(selectedDoctorsProvider
                                .notifier)
                            .setDoctors(model.doctors!);

                        context
                            .pushNamed(
                                AppRoute.editDoctors.name,
                                extra: model)
                            .whenComplete(() {
                          ref
                              .read(selectedDoctorsProvider
                                  .notifier)
                              .clear();
                        });
                      },
                    ),
                    CupertinoListTile(
                      padding: const EdgeInsets.all(12),
                      leading: const Icon(
                          CupertinoIcons.circle_grid_hex,
                          size: 22,
                          color:
                              CupertinoColors.systemGrey),
                      title: Text('Products',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall),
                      subtitle: Text(
                          formatProductNames(
                              model.products!),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall),
                      trailing:
                          const CupertinoListTileChevron(),
                      onTap: () {
                        ref
                            .read(selectedProductsProvider
                                .notifier)
                            .setProducts(model.products!);

                        context
                            .pushNamed(
                                AppRoute.editProducts.name,
                                extra: model)
                            .whenComplete(() {
                          ref
                              .read(selectedProductsProvider
                                  .notifier)
                              .clear(); // Clears the provider when returning
                        });
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
                            AppRoute
                                .hospitalCaseSheets.name,
                            extra: model);
                      },
                    ),
                    // CupertinoListTile(
                    //   leading: const Icon(
                    //       CupertinoIcons.question_circle,
                    //       size: 22,
                    //       color:
                    //           CupertinoColors.systemGrey),
                    //   title: Text('Help & Support',
                    //       style: Theme.of(context)
                    //           .textTheme
                    //           .titleSmall),
                    //   trailing:
                    //       const CupertinoListTileChevron(),
                    //   onTap: () async {
                    //     await sendEmail();
                    //   },
                    // ),
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
                      title: Text('Delete Hospital',
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
                                          'Delete ${model.email}'),
                                      content: Text(
                                          "Are you sure you want to delete ${model.name}' All case sheet data will persist, but the hospital, doctors, and products will lose their info"),
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
                                                    adminHospitalDeleteControllerProvider);

                                            return CupertinoDialogAction(
                                              isDestructiveAction:
                                                  true,
                                              onPressed: state
                                                      .isLoading
                                                  ? null // Disable button during loading
                                                  : () async {
                                                      await ref
                                                          .read(adminHospitalDeleteControllerProvider.notifier)
                                                          .deleteHospital(hospitalId: model.id);
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

          // Lottie.network(
          //   'https://lottie.host/124be562-495e-40c1-aaf8-43787bd97242/22WPk0dTcs.json',

          // )

          // Expanded(
          //   child: Consumer(
          //     builder: (context, ref, child) {
          //       // * This data is combined from two streams, so it can't be returned
          //       // * directly as a Query object from the repository.
          //       // * As a result, we can't use FirestoreListView here.

          //       // return Container(); }

          //       final entriesTileModelStream =
          //           ref.watch(pastEntriesModelStreamProvider);

          //       return ListItemsBuilder<Order>(
          //         data: entriesTileModelStream,
          //         itemBuilder: (context, model) =>
          //             PastEntriesListTile(model: model),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}

// class PastEntriesListTile extends StatelessWidget {
//   const PastEntriesListTile({super.key, required this.model});

//   final Order model;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Stack(
//           alignment: Alignment.topCenter,
//           children: [
//             Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   width: double.infinity,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       RichText(
//                         text: TextSpan(
//                           text: 'Order: ',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           children: <TextSpan>[
//                             TextSpan(
//                                 text: '#${model.id}',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.w500, fontSize: 12)),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 8.0),
//                         child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               RichText(
//                                 text: TextSpan(
//                                   text: 'Date: ',
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   children: <TextSpan>[
//                                     TextSpan(
//                                         text:
//                                             '${DateFormat.yMd().format(model.date)} at ${DateFormat.jm().format(model.date)}',
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.w500,
//                                             fontSize: 12)),
//                                   ],
//                                 ),
//                               ),
//                               gapH4,
//                               RichText(
//                                 text: TextSpan(
//                                   text: 'Hospital: ',
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   children: <TextSpan>[
//                                     TextSpan(
//                                         text: model.hospital.name,
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.w500,
//                                             fontSize: 12)),
//                                   ],
//                                 ),
//                               ),
//                               gapH4,
//                               RichText(
//                                 text: TextSpan(
//                                   text: 'Doctor: ',
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   children: <TextSpan>[
//                                     TextSpan(
//                                         text: model.doctor,
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.w500,
//                                             fontSize: 12)),
//                                   ],
//                                 ),
//                               ),

//                               gapH4,
//                               RichText(
//                                 text: TextSpan(
//                                   text: 'Patient ID: ',
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   children: <TextSpan>[
//                                     TextSpan(
//                                         text: model.patient,
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.w500,
//                                             fontSize: 12)),
//                                   ],
//                                 ),
//                               ),
//                               gapH4,

//                               ListView.builder(
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 shrinkWrap: true,
//                                 itemBuilder: (context, index) {
//                                   return ListTile(
//                                     minLeadingWidth: 1,
//                                     leading:  Column(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Text(model.part[index].quantity.toString())
//                                       ],
//                                     ),
//                                     title: Text(model.part[index].description),
//                                     subtitle: Text(model.part[index].part),
//                                     trailing: Text("\$ ${model.part[index].price}"),
//                                   );
//                                 },
//                                 itemCount: model.part.length,
//                               ),

//                             ]),
//                       )
//                     ],
//                   ),
//                 )),
//             Positioned(
//                 left: MediaQuery.of(context).size.width - 50,
//                 top: 25,
//                 child: const CircleAvatar(
//                   backgroundColor: Colors.greenAccent,
//                   radius: 5,
//                 )),
//           ],
//         ),
//     );
//   }
// }

Future<void> sendEmail() async {
  const email = 'godspeedapplications@gmail.com';
  final subject = Uri.encodeComponent(
      'Help and Support'); // Optional subject
  final body =
      Uri.encodeComponent(''); // Optional body content
  final mailtoUrl =
      'mailto:$email?subject=$subject&body=$body';

  if (await canLaunchUrl(Uri.parse(mailtoUrl))) {
    await launchUrl(Uri.parse(mailtoUrl));
  } else {
    throw 'Could not launch $mailtoUrl';
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
