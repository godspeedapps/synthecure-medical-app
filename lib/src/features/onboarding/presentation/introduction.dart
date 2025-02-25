import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/repositories/onboarding_repository.dart';

class Onboarding extends ConsumerWidget {

  const Onboarding({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoOnboarding(
      onPressedOnLastPage: () async {

          context.pop();
          
          await ref
                    .read(onboardingRepositoryProvider)
                    .setOnboardingComplete();
      },
      pages: [
        WhatsNewPage(
          scrollPhysics: const BouncingScrollPhysics(),
          title: const Text("What's New in Synthecure"),
          features: const [
            WhatsNewFeature(
              title:
                  Text('Streamlined Case Sheet Management'),
              description: Text(
                  'Effortlessly create, edit, and manage case sheets with a user-friendly interface designed for efficiency.'),
              icon: Icon(CupertinoIcons.doc_text),
            ),
            WhatsNewFeature(
              title: Text("Automated Emailing"),
              description: Text(
                  "Save time with automated emails that log and send orders directly to assigned hospitals with just a few taps."),
              icon: Icon(CupertinoIcons.mail),
            ),
           
            WhatsNewFeature(
              title: Text('Optimized for Reps'),
              description: Text(
                  'Designed specifically for reps, the app simplifies the order process and improves workflow efficiency.'),
              icon: Icon(CupertinoIcons.person_crop_circle),
            ),
          ],
        ),
        // CupertinoOnboardingPage(
        //       title: Text('Create Case Sheets'),
        //       body: Padding(
        //         padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 48.0),
        //         child: ClipRRect(
        //           borderRadius: BorderRadius.circular(12.0), // Adjust the corner radius as needed
        //           child: Image.asset(
        //             "assets/brochure_1.png",
        //             fit: BoxFit.cover, // Ensures the image scales correctly
        //           ),
        //         ),
        //       ),
        //     ),
        // CupertinoOnboardingPage(
        //       title: Text('Send purchase orders to your hospitals'),
        //       body: Padding(
        //         padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 48.0),
        //         child: ClipRRect(
        //           borderRadius: BorderRadius.circular(12.0), // Adjust the corner radius as needed
        //           child: Image.asset(
        //             "assets/brochure_2.png",
        //             fit: BoxFit.cover, // Ensures the image scales correctly
        //           ),
        //         ),
        //       ),
        //     ),
        // CupertinoOnboardingPage(
        //       title: Text('Track and Analyze your Impact'),
        //       body: Padding(
        //         padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 48.0),
        //         child: ClipRRect(
        //           borderRadius: BorderRadius.circular(12.0), // Adjust the corner radius as needed
        //           child: Image.asset(
        //             "assets/brochure_3.png",
        //             fit: BoxFit.cover, // Ensures the image scales correctly
        //           ),
        //         ),
        //       ),
        //     ),
      ],
    );
  }
}
