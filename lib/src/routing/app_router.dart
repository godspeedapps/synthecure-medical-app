import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/features/admin/database_view.dart';
import 'package:synthecure/src/features/admin/doctors/all_doctors.dart';
import 'package:synthecure/src/features/admin/doctors/doctor_case_sheets.dart';
import 'package:synthecure/src/features/admin/doctors/doctor_page.dart';
import 'package:synthecure/src/features/admin/doctors/edit_hospitals.dart';
import 'package:synthecure/src/features/admin/hospitals/add_hospital.dart';
import 'package:synthecure/src/features/admin/hospitals/all_hospitals.dart';
import 'package:synthecure/src/features/admin/hospitals/choose_doctors.dart';
import 'package:synthecure/src/features/admin/hospitals/choose_products.dart';
import 'package:synthecure/src/features/admin/hospitals/edit_doctors.dart';
import 'package:synthecure/src/features/admin/hospitals/edit_products.dart';
import 'package:synthecure/src/features/admin/hospitals/hospital_case_sheets.dart';
import 'package:synthecure/src/features/admin/hospitals/hospital_page.dart';
import 'package:synthecure/src/features/admin/orders/all_orders.dart';
import 'package:synthecure/src/features/admin/products/add_product.dart';
import 'package:synthecure/src/features/admin/products/all_products.dart';
import 'package:synthecure/src/features/admin/products/product_hospitals.dart';
import 'package:synthecure/src/features/admin/users/accounts_view.dart';
import 'package:synthecure/src/features/admin/users/case_sheets.dart';
import 'package:synthecure/src/features/admin/users/choose_hospitals.dart';
import 'package:synthecure/src/features/admin/users/display_users.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:synthecure/src/features/admin/users/edit_user_hospitals.dart';
import 'package:synthecure/src/features/entries/entry_view.dart';
import 'package:synthecure/src/features/auth/email_password/forgot_password.dart';
import 'package:synthecure/src/features/auth/login.dart';
import 'package:synthecure/src/features/orders/add_order.dart';
import 'package:synthecure/src/routing/loading_screen.dart';
import 'package:synthecure/src/routing/scaffold_with_bottom_nav_bar.dart';
import '../repositories/firebase_auth_repository.dart';
import '../features/auth/account/account_screen.dart';
import '../features/auth/email_password/email_password_sign_in_form_type.dart';
import '../features/auth/email_password/email_password_sign_in_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/entries/entries.dart';
import '../domain/order.dart';
import 'go_router_refresh_stream.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

enum AppRoute {
  onboarding,
  loginPage,
  forgotPassword,
  signIn,
  emailPassword,
  createOrder,
  job,
  editOrder,
  entry,
  entries,
  account,
  entryView,
  dashboard,
  allOrders,
  displayUsers,
  accountView,
  userCaseSheets,
  allHospitals,
  allDoctors,
  allProducts,
  addHospital,
  chooseDoctors,
  chooseProducts,
  hospitalPage,
  editDoctors,
  editProducts,
  hospitalCaseSheets,
  doctorPage,
  doctorCaseSheets,
  editHospitals,
  productHospitals,
  addProduct,
  editUserHospitals,
  chooseUserHospitals
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final isAdmin = ref.watch(isAdminProvider);


  return GoRouter(
    initialLocation: '/loginPage',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authRepository.currentUser != null;

      if (isLoggedIn) {
        if (isAdmin == null) {
          return '/loading'; // Redirect to a loading page
        }

        if (state.matchedLocation
            .startsWith('/loginPage')) {
          if (isAdmin == true) {
            return '/displayUsers';
          } else {
            return '/entries';
          }
        }
      } else {
        if (state.matchedLocation
                .startsWith('/createOrder') ||
            state.matchedLocation.startsWith('/entries') ||
            state.matchedLocation.startsWith('/account')) {
          return '/loginPage';
        }
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
        authRepository.authStateChanges()),
    routes: [
      GoRoute(
        path: '/loginPage',
        name: AppRoute.loginPage.name,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: LoginPage(),
        ),
        routes: [
          GoRoute(
            path: 'forgotPassword',
            name: AppRoute.forgotPassword.name,
            pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                fullscreenDialog: true,
                child: const ForgotPassword()),
          ),
        ],
      ),
      GoRoute(
        path: '/loading',
        name: 'loading',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const LoadingScreen(),
        ),
      ),
      GoRoute(
        path: '/signIn',
        name: AppRoute.signIn.name,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const SignInScreen(),
        ),
        routes: [
          GoRoute(
            path: 'emailPassword',
            name: AppRoute.emailPassword.name,
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              fullscreenDialog: true,
              child: const EmailPasswordSignInScreen(
                formType:
                    EmailPasswordSignInFormType.signIn,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/createOrder',
        name: AppRoute.createOrder.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          // return const CupertinoSheetPage(child: AddPage());
          return MaterialPage(
              key: state.pageKey,
              fullscreenDialog: true,
              child: const CaseFormPage());
        },
      ),

      GoRoute(
          path: '/addHospital',
          name: AppRoute.addHospital.name,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            // return const CupertinoSheetPage(child: AddPage());
            return MaterialPage(
                key: state.pageKey,
                fullscreenDialog: true,
                child: const AddHospitalPage());
          },
          routes: [
            GoRoute(
              path: '/chooseDoctors',
              name: AppRoute.chooseDoctors.name,
              parentNavigatorKey: _rootNavigatorKey,
              pageBuilder: (context, state) {
                // return const CupertinoSheetPage(child: AddPage());
                return CupertinoPage(
                    key: state.pageKey,
                    child: const ChooseDoctors());
              },
            ),
            GoRoute(
              path: '/chooseProducts',
              name: AppRoute.chooseProducts.name,
              parentNavigatorKey: _rootNavigatorKey,
              pageBuilder: (context, state) {
                // return const CupertinoSheetPage(child: AddPage());
                return CupertinoPage(
                    key: state.pageKey,
                    child: const ChooseProducts());
              },
            ),
          ]),

      // ShellRoute for Admin
      if (isAdmin ?? false)
        ShellRoute(
          navigatorKey:
              _shellNavigatorKey, // Use a unique navigator key
          builder: (context, state, child) {
            return ScaffoldWithBottomNavBarAdmin(
                child: child);
          },
          routes: [
            GoRoute(
              path: '/entries',
              name: AppRoute.entries.name,
              pageBuilder: (context, state) =>
                  NoTransitionPage(
                key: state.pageKey,
                child: const EntriesScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'entryView',
                  name: AppRoute.entryView.name,
                  pageBuilder: (context, state) {
                    final order = state.extra as Order?;
                    return MaterialPage(
                      key: state.pageKey,
                      child: EntryView(
                        model: order!,
                      ),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
                path: '/dashboard',
                name: AppRoute.dashboard.name,
                routes: [
                  GoRoute(
                    path: 'allOrders',
                    name: AppRoute.allOrders.name,
                    pageBuilder: (context, state) {
                      return MaterialPage(
                          key: state.pageKey,
                          child: AllOrdersScreen());
                    },
                  ),
                  GoRoute(
                      path: 'allHospitals',
                      name: AppRoute.allHospitals.name,
                      pageBuilder: (context, state) {
                        return CupertinoPage(
                            key: state.pageKey,
                            child: AllHospitals());
                      },
                      routes: [
                        GoRoute(
                            path: 'hospitalPage',
                            name:
                                AppRoute.hospitalPage.name,
                            pageBuilder: (context, state) {
                              return CupertinoPage(
                                key: state.pageKey,
                                child: HospitalPage(),
                              );
                            },
                            routes: [
                              GoRoute(
                                path: 'editDoctors',
                                name: AppRoute
                                    .editDoctors.name,
                                parentNavigatorKey:
                                    _rootNavigatorKey,
                                pageBuilder:
                                    (context, state) {
                                  // return const CupertinoSheetPage(child: AddPage());

                                  final editDoctorsHospital =
                                      state.extra
                                          as Hospital;

                                  return CupertinoPage(
                                      key: state.pageKey,
                                      child: EditDoctors(
                                        model:
                                            editDoctorsHospital,
                                      ));
                                },
                              ),
                              GoRoute(
                                path: 'editProducts',
                                name: AppRoute
                                    .editProducts.name,
                                parentNavigatorKey:
                                    _rootNavigatorKey,
                                pageBuilder:
                                    (context, state) {
                                  final editProductsHospital =
                                      state.extra
                                          as Hospital;

                                  return CupertinoPage(
                                      key: state.pageKey,
                                      child: EditProducts(
                                        model:
                                            editProductsHospital,
                                      ));
                                },
                              ),
                              GoRoute(
                                  path:
                                      'hospitalCaseSheets',
                                  name: AppRoute
                                      .hospitalCaseSheets
                                      .name,
                                  pageBuilder:
                                      (context, state) {
                                    final hospitalCaseSheets =
                                        state.extra
                                            as Hospital;

                                    return MaterialPage(
                                      key: state.pageKey,
                                      child: HospitalCaseSheets(
                                          model:
                                              hospitalCaseSheets),
                                    );
                                  })
                            ]),
                      ]),
                  GoRoute(
                      path: 'allDoctors',
                      name: AppRoute.allDoctors.name,
                      pageBuilder: (context, state) {
                        return CupertinoPage(
                            key: state.pageKey,
                            child: AllDoctors());
                      },
                      routes: [
                        GoRoute(
                          path: 'doctorPage',
                          name: AppRoute.doctorPage.name,
                          pageBuilder: (context, state) {
                            return CupertinoPage(
                              key: state.pageKey,
                              child: DoctorPage(),
                            );
                          },
                          routes: [
                            GoRoute(
                                path: 'doctorCaseSheets',
                                name: AppRoute
                                    .doctorCaseSheets.name,
                                pageBuilder:
                                    (context, state) {
                                  final doctorCaseSheets =
                                      state.extra as Doctor;

                                  return MaterialPage(
                                    key: state.pageKey,
                                    child: DoctorCaseSheets(
                                        model:
                                            doctorCaseSheets),
                                  );
                                }),
                            GoRoute(
                              path: 'editHospitals',
                              name: AppRoute
                                  .editHospitals.name,
                              parentNavigatorKey:
                                  _rootNavigatorKey,
                              pageBuilder:
                                  (context, state) {
                                // return const CupertinoSheetPage(child: AddPage());

                                final editHospitalDoctor =
                                    state.extra as Doctor;

                                return CupertinoPage(
                                    key: state.pageKey,
                                    child: EditHospitals(
                                      model:
                                          editHospitalDoctor,
                                    ));
                              },
                            ),
                          ],
                        )
                      ]),
                  GoRoute(
                      path: 'allProducts',
                      name: AppRoute.allProducts.name,
                      pageBuilder: (context, state) {
                        return CupertinoPage(
                            key: state.pageKey,
                            child: AllProducts());
                      },
                      routes: [
                        GoRoute(
                          path: '/addProduct',
                          name: AppRoute.addProduct.name,
                          parentNavigatorKey:
                              _rootNavigatorKey,
                          pageBuilder: (context, state) {
                            // return const CupertinoSheetPage(child: AddPage());
                            return MaterialPage(
                                key: state.pageKey,
                                fullscreenDialog: true,
                                child:
                                    const AddProductPage());
                          },
                        ),
                        GoRoute(
                          path: 'productHospitals',
                          name: AppRoute
                              .productHospitals.name,
                          parentNavigatorKey:
                              _rootNavigatorKey,
                          pageBuilder: (context, state) {
                            // return const CupertinoSheetPage(child: AddPage());

                            return CupertinoPage(
                                key: state.pageKey,
                                child: ProductHospitals());
                          },
                        ),
                      ]),
                ],
                pageBuilder: (context, state) =>
                    NoTransitionPage(
                      key: state.pageKey,
                      child: const DashboardGrid(),
                    )),
            GoRoute(
              path: '/account',
               parentNavigatorKey: _shellNavigatorKey,
              name: AppRoute.account.name,
              pageBuilder: (context, state) =>
                  NoTransitionPage(
                key: state.pageKey,
                child: const AccountScreen(),
              ),
            ),
            GoRoute(
              path: '/displayUsers',
              name: AppRoute.displayUsers.name,
              parentNavigatorKey: _shellNavigatorKey,
              routes: [
                        GoRoute(
                      path: '/chooseUserHospitals',
                      name: AppRoute.chooseUserHospitals.name,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) {
                        // return const CupertinoSheetPage(child: AddPage());
                        return CupertinoPage(
                            key: state.pageKey,
                            child: const ChooseUserHospitals());
                      },
                    ),
                GoRoute(
                    path: 'accountView',
                    name: AppRoute.accountView.name,
                    pageBuilder: (context, state) {
          

                      return CupertinoPage(
                        key: state.pageKey,
                        child: AccountView(
                        ),
                      );
                    },
                    routes: [
                      GoRoute(
                          path: '/userCaseSheets',
                          name:
                              AppRoute.userCaseSheets.name,
                          pageBuilder: (context, state) {
                            final userCaseSheets =
                                state.extra as AppUser;

                            return MaterialPage(
                              key: state.pageKey,
                              child: UserCaseSheets(
                                  model: userCaseSheets),
                            );
                          }),

                       GoRoute(
                              path: 'editUserHospitals',
                              name: AppRoute
                                  .editUserHospitals.name,
                              parentNavigatorKey:
                                  _rootNavigatorKey,
                              pageBuilder:
                                  (context, state) {
                                // return const CupertinoSheetPage(child: AddPage());

                                final editHospitalUser =
                                    state.extra as AppUser;

                                return CupertinoPage(
                                    key: state.pageKey,
                                    child: EditUserHospitals(
                                      model:
                                          editHospitalUser,
                                    ));
                              },
                            ),
                    ]),
              ],
              pageBuilder: (context, state) =>
                  NoTransitionPage(
                key: state.pageKey,
                child: const SalesRepsPage(),
              ),
            ),
          ],
        ),

      // ShellRoute for Non-Admin Users
      if (!(isAdmin ?? false))
        ShellRoute(
          navigatorKey: GlobalKey<
              NavigatorState>(), // Use a unique navigator key
          builder: (context, state, child) {
            return ScaffoldWithBottomNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: '/entries',
              name: AppRoute.entries.name,
              pageBuilder: (context, state) =>
                  NoTransitionPage(
                key: state.pageKey,
                child: const EntriesScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'entryView',
                  name: AppRoute.entryView.name,
                  pageBuilder: (context, state) {
                    final order = state.extra as Order?;
                    return MaterialPage(
                      key: state.pageKey,
                      child: EntryView(
                        model: order!,
                      ),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/account',
              name: AppRoute.account.name,
              pageBuilder: (context, state) =>
                  NoTransitionPage(
                key: state.pageKey,
                child: const AccountScreen(),
              ),
            ),
          ],
        ),
    ],
    //errorBuilder: (context, state) => const NotFoundScreen(),
  );
});

class CupertinoSheetPage extends Page<void> {
  const CupertinoSheetPage({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) {
    return CupertinoSheetRoute(
      settings: this,
      builder: (context) => child,
    );
  }
}

// Step 1: Define the IsAdminNotifier with a reset method
class IsAdminNotifier extends StateNotifier<bool?> {
  IsAdminNotifier() : super(null);

  Future<void> checkIsAdmin() async {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      state = null; // User is not signed in
      return;
    }

    try {
      final idTokenResult =
          await currentUser.getIdTokenResult();
      // Update the state with the 'admin' claim (defaults to false if not found)
      state = idTokenResult.claims?['admin'] ?? false;
    } catch (e) {
      state =
          false; // If there is an error, treat the user as not an admin
      throw Exception('Failed to get custom claims: $e');
    }
  }

  // Step 2: Add the reset method to set the state to false
  void reset() {
  
    state = null;
  }
}

// Step 3: Define the provider for isAdmin with StateNotifier
final isAdminProvider =
    StateNotifierProvider<IsAdminNotifier, bool?>((ref) {
  return IsAdminNotifier();
});
