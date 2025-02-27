import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/features/onboarding/presentation/onboarding_controller.dart';
import 'package:synthecure/src/localization/string_hardcoded.dart';

import '../../../widgets/primary_button.dart';
import '../../../routing/app_router.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Image(
              image: AssetImage("assets/Synthecure_Logo.jpg")
            ,),
            const SizedBox(height: 50),
            Text(
              'Infected site management\nis complicated.',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
         
            // FractionallySizedBox(
            //   widthFactor: 0.5,
            //   child: SvgPicture.asset('assets/time-tracking.svg',
            //       semanticsLabel: 'Time tracking logo'),
            // ),
            const SizedBox(height: 50),
            PrimaryButton(
              text: 'FILL THE VOID'.hardcoded,
              isLoading: state.isLoading,
              onPressed: state.isLoading
                  ? null
                  : () async {
                      await ref
                          .read(onboardingControllerProvider.notifier)
                          .completeOnboarding();
                      if (context.mounted) {
                        // go to sign in page after completing onboarding
                        context.goNamed(AppRoute.loginPage.name);
                        
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}


// class OnBoardingPage extends StatefulWidget {
//   const OnBoardingPage({Key? key}) : super(key: key);

//   @override
//   OnBoardingPageState createState() => OnBoardingPageState();
// }

// class OnBoardingPageState extends State<OnBoardingPage> {
//   final introKey = GlobalKey<IntroductionScreenState>();

//   void _onIntroEnd(context) {
   



//   }

//   Widget _buildFullscreenImage() {
//     return Image.asset(
//       'assets/syn_home.png',
//       fit: BoxFit.cover,
//       height: double.infinity,
//       width: double.infinity,
//       alignment: Alignment.center,
//     );
//   }

//   Widget _buildImage(String assetName, [double width = 350]) {
//     return Image.asset('assets/$assetName', width: width);
//   }

//   @override
//   Widget build(BuildContext context) {
//     const bodyStyle = TextStyle(fontSize: 19.0);

//     const pageDecoration = PageDecoration(
//       titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
//       bodyTextStyle: bodyStyle,
//       bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
//       pageColor: Colors.white,
//       imagePadding: EdgeInsets.zero,
//     );

//     return IntroductionScreen(
//       key: introKey,
//       globalBackgroundColor: Colors.white,
//       allowImplicitScrolling: true,
//      // autoScrollDuration: 3000,
//       // globalHeader: Align(
//       //   alignment: Alignment.center,
//       //   child: SafeArea(
//       //     child: Padding(
//       //       padding: const EdgeInsets.only(top: 16, right: 16),
//       //       child: _buildImage('Synthecure_Logo.jpg', 200),
//       //     ),
//       //   ),
//       // ),
//       // globalFooter: SizedBox(
//       //   width: double.infinity,
//       //   height: 60,
//       //   child: ElevatedButton(
//       //     child: const Text(
//       //       'Let\'s go right away!',
//       //       style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
//       //     ),
//       //     onPressed: () => _onIntroEnd(context),
//       //   ),
//       // ),
//       pages: [
//         PageViewModel(
//           title: "Fractional shares",
//           body:
//               "Instead of having to buy an entire share, invest any amount you want.",
//           image: _buildImage('img1.jpg'),
//           decoration: pageDecoration,
//         ),
//         PageViewModel(
//           title: "Learn as you go",
//           body:
//               "Download the Stockpile app and master the market with our mini-lesson.",
//           image: _buildImage('img2.jpg'),
//           decoration: pageDecoration,
//         ),
//         PageViewModel(
//           title: "Kids and teens",
//           body:
//               "Kids and teens can track their stocks 24/7 and place trades that you approve.",
//           image: _buildImage('img3.jpg'),
//           decoration: pageDecoration,
//         ),
//         PageViewModel(
//           title: "Full Screen Page",
//           body:
//               "Pages can be full screen as well.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id euismod lectus, non tempor felis. Nam rutrum rhoncus est ac venenatis.",
//           image: _buildFullscreenImage(),
//           decoration: pageDecoration.copyWith(
//             contentMargin: const EdgeInsets.symmetric(horizontal: 16),
//             fullScreen: true,
//             bodyFlex: 2,
//             imageFlex: 3,
//             safeArea: 100,
//           ),
//         ),
//         PageViewModel(
//           title: "Another title page",
//           body: "Another beautiful body text for this example onboarding",
//           image: _buildImage('img2.jpg'),
//           footer: ElevatedButton(
//             onPressed: () {
//               introKey.currentState?.animateScroll(0);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.lightBlue,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//             ),
//             child: const Text(
//               'FooButton',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//           decoration: pageDecoration.copyWith(
//             bodyFlex: 6,
//             imageFlex: 6,
//             safeArea: 80,
//           ),
//         ),
//         PageViewModel(
//           title: "Title of last page - reversed",
//           bodyWidget: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               Text("Click on ", style: bodyStyle),
//               Icon(Icons.edit),
//               Text(" to edit a post", style: bodyStyle),
//             ],
//           ),
//           decoration: pageDecoration.copyWith(
//             bodyFlex: 2,
//             imageFlex: 4,
//             bodyAlignment: Alignment.bottomCenter,
//             imageAlignment: Alignment.topCenter,
//           ),
//           image: _buildImage('img1.jpg'),
//           reverse: true,
//         ),
//       ],
//       onDone: () => _onIntroEnd(context),
//       //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
//       showSkipButton: false,
//       skipOrBackFlex: 0,
//       nextFlex: 0,
//       showBackButton: true,
//       //rtl: true, // Display as right-to-left
//       back: const Icon(Icons.arrow_back),
//       skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
//       next: const Icon(Icons.arrow_forward),
//       done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
//       curve: Curves.fastLinearToSlowEaseIn,
//       controlsMargin: const EdgeInsets.all(16),
//       controlsPadding: kIsWeb
//           ? const EdgeInsets.all(12.0)
//           : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
//       dotsDecorator: const DotsDecorator(
//         size: Size(10.0, 10.0),
//         color: Color(0xFFBDBDBD),
//         activeSize: Size(22.0, 10.0),
//         activeShape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(25.0)),
//         ),
//       ),
//       dotsContainerDecorator: const ShapeDecoration(
//         color: Colors.black87,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(8.0)),
//         ),
//       ),
//     );
//   }
// }
