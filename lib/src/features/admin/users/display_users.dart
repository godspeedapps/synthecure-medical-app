import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/controllers/hospital_controller.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/features/admin/hospitals/add_hospital.dart';
import 'package:synthecure/src/features/admin/users/accounts_view.dart';
import 'package:synthecure/src/repositories/user_repository.dart';
import 'package:synthecure/src/services/user_service.dart';
import 'package:synthecure/src/controllers/account_controller.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:synthecure/src/services/entries_service.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';
import 'package:synthecure/src/utils/format.dart';
import 'package:synthecure/src/widgets/list_items_builder.dart';

final firstNameProvider =
    StateProvider.autoDispose<String>((ref) => '');

final lastNameProvider =
    StateProvider.autoDispose<String>((ref) => '');

final emailProvider =
    StateProvider.autoDispose<String>((ref) => '');

final isAdminCreateProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class AddUserPage extends ConsumerStatefulWidget {
  const AddUserPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddUserPageState();
}

class _AddUserPageState extends ConsumerState<AddUserPage> {
  final _userFirstNameFocusNode = FocusNode();
  final _userLastNameFocusNode = FocusNode();
  final _userEmailFocusNode = FocusNode();

  @override
  void dispose() {
    _userFirstNameFocusNode
        .dispose(); // ✅ Clean up focus node properly
    _userLastNameFocusNode
        .dispose(); // ✅ Clean up focus node properly
    _userEmailFocusNode
        .dispose(); // ✅ Clean up focus node properly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstName = ref.watch(firstNameProvider);
    final lastName = ref.watch(lastNameProvider);
    final email = ref.watch(emailProvider);
    final isAdmin = ref.watch(isAdminCreateProvider);

    final state = ref.watch(userAccountControllerProvider);

    final isFormValid = firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty;

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
                        "Add User",
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
                                await ref
                                    .read(
                                        userAccountControllerProvider
                                            .notifier)
                                    .addUser(
                                        firstName:
                                            firstName,
                                        lastName: lastName,
                                        email: email,
                                        isAdmin: isAdmin,
                                        selectedHospitals:
                                            ref.read(
                                                selectedHospitalsProvider));
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
                  onTap: () {
                    // ✅ Request focus programmatically

                    FocusScope.of(context).requestFocus(
                        _userFirstNameFocusNode);
                  },
                  title: Text('First Name',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium),
                  trailing: SizedBox(
                    width:
                        225, // ✅ Adjust width for better alignment
                    child: CupertinoTextField(
                      // ✅ State Management Integration
                      onChanged: (value) => ref
                          .read(firstNameProvider.notifier)
                          .state = value,
                      onSubmitted: (value) {
                        _userLastNameFocusNode
                            .requestFocus();
                      },

                      focusNode: _userFirstNameFocusNode,
                      placeholder: 'John',
                      // keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      textInputAction: TextInputAction.next,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall,
                      textAlign: TextAlign
                          .end, // ✅ Aligning text to the right for consistency
                      padding: EdgeInsets
                          .zero, // ✅ Removing internal padding
                      decoration: BoxDecoration(
                        // ✅ No border, no background
                        color: Colors.transparent,
                        border: Border.all(
                            color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
                CupertinoListTile(
                  onTap: () {
                    // ✅ Request focus programmatically

                    FocusScope.of(context).requestFocus(
                        _userLastNameFocusNode);
                  },
                  title: Text('Last Name',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium),
                  trailing: SizedBox(
                    width:
                        225, // ✅ Adjust width for better alignment
                    child: CupertinoTextField(
                      // ✅ State Management Integration
                      onChanged: (value) => ref
                          .read(lastNameProvider.notifier)
                          .state = value,
                      onSubmitted: (value) {
                        _userEmailFocusNode.requestFocus();
                      },

                      focusNode: _userLastNameFocusNode,
                      placeholder: 'Doe',
                      // keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      textInputAction: TextInputAction.next,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall,
                      textAlign: TextAlign
                          .end, // ✅ Aligning text to the right for consistency
                      padding: EdgeInsets
                          .zero, // ✅ Removing internal padding
                      decoration: BoxDecoration(
                        // ✅ No border, no background
                        color: Colors.transparent,
                        border: Border.all(
                            color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
                CupertinoListTile(
                  onTap: () {
                    // ✅ Request focus programmatically

                    FocusScope.of(context)
                        .requestFocus(_userEmailFocusNode);
                  },
                  title: Text('Email',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium),
                  trailing: SizedBox(
                    width:
                        225, // ✅ Adjust width for better alignment
                    child: CupertinoTextField(
                      // ✅ State Management Integration
                      onChanged: (value) => ref
                          .read(emailProvider.notifier)
                          .state = value,

                      focusNode: _userEmailFocusNode,
                      placeholder: 'johndoe@gmail.com',
                      // keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      textInputAction: TextInputAction.next,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall,
                      textAlign: TextAlign
                          .end, // ✅ Aligning text to the right for consistency
                      padding: EdgeInsets
                          .zero, // ✅ Removing internal padding
                      decoration: BoxDecoration(
                        // ✅ No border, no background
                        color: Colors.transparent,
                        border: Border.all(
                            color: Colors.transparent),
                      ),
                    ),
                  ),
                ),

                // Doctor Picker Tile

                CupertinoListTile(
                  title: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Admin',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall,
                      ),
                      CupertinoSwitch(
                        value: isAdmin,
                        onChanged: (value) => ref
                            .read(isAdminCreateProvider
                                .notifier)
                            .state = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  12), // Adjust the radius as needed
              child: CupertinoListTile(
                backgroundColor: Colors.white,
                title: Text(
                  'Hospitals',
                  style:
                      Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: const HospitalsChevron(),
                onTap: () {
                  context.pushNamed(
                      AppRoute.chooseUserHospitals.name);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HospitalsChevron extends ConsumerWidget {
  /// Creates a typical widget used to denote that a `CupertinoListTile` is a
  /// button with action.
  const HospitalsChevron({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedHospitals =
        ref.watch(selectedHospitalsProvider);

    // Determine the hospital display text
    String hospitalText = Format.getHospitalDisplayText(
        selectedHospitals
            .map(
                (e) => HospitalInfo(id: e.id, name: e.name))
            .toList());

    return hospitalText == "No hospitals"
        ? Icon(
            CupertinoIcons.right_chevron,
            size: CupertinoTheme.of(context)
                .textTheme
                .textStyle
                .fontSize,
            color: CupertinoColors.systemGrey2
                .resolveFrom(context),
          )
        : Text(hospitalText,
            style: Theme.of(context).textTheme.bodySmall);
  }
}

/// The main UI widget

class SalesRepsPage extends ConsumerStatefulWidget {
  const SalesRepsPage({super.key});

  @override
  SalesRepsPageState createState() => SalesRepsPageState();
}

class SalesRepsPageState
    extends ConsumerState<SalesRepsPage> {
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Material(
      child: SuperScaffold(
        appBar: SuperAppBar(
          title: Text("Team Members"),
          largeTitle: SuperLargeTitle(
            enabled: true,
            largeTitle: "Your Team",
          ),
          searchBar: SuperSearchBar(
            searchFocusNode: _searchFocusNode,
            onSubmitted: (value) {
              _searchFocusNode.requestFocus();
            },
            onChanged: (query) => ref
                .read(userSearchQueryProvider.notifier)
                .state = query,
            resultBehavior:
                SearchBarResultBehavior.visibleOnInput,
            searchResult: Material(
              child: Consumer(
                builder: (context, ref, child) {
                  final userStream =
                      ref.watch(filteredUsersProvider);
                  return CustomScrollView(
                    slivers: [
                      SliverListItemsBuilder<AppUser>(
                        title: "No users found",
                        message: "Try searching again ⤴️",
                        data: userStream,
                        itemBuilder: (context, model) =>
                            UserTile(model: model),
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
                showCupertinoSheet<void>(
                  context: context,
                  pageBuilder: (BuildContext context) =>
                      Material(child: AddUserPage()),
                );
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
                final usersStream =
                    ref.watch(allUsersStreamProvider);
                return SliverListItemsBuilder<AppUser>(
                  title: "No users found",
                  message: "Try searching again ⤴️",
                  data: usersStream,
                  itemBuilder: (context, model) =>
                      UserTile(model: model),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UserTile extends ConsumerWidget {
  final AppUser model;

  const UserTile({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
        onLongPress: () async {
          // print("deleting user...");

          // await ref
          //     .read(userRepositoryProvider)
          //     .deleteUser(model.email);
        },
        onTap: () {
          ref.read(userAccountPageProvider.notifier).state =
              model;

          context.pushNamed(AppRoute.accountView
              .name); // Pass the AppUser model);
        },
        tileColor: Colors.white,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context)
              .colorScheme
              .primary
              .withOpacity(0.1),
          radius: 35,
          child: Text(
            '${model.firstName.isNotEmpty ? model.firstName[0] : ''}${model.lastName.isNotEmpty ? model.lastName[0] : ''}'
                .toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          "${model.firstName} ${model.lastName}",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(model.email,
            style: Theme.of(context).textTheme.bodySmall),
        trailing: model.isAdmin ?? false
            ? Icon(
                Icons.admin_panel_settings,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.4),
              )
            : null);
  }
}
