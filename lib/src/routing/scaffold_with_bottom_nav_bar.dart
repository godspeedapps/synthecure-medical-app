import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/localization/string_hardcoded.dart';
import 'package:synthecure/src/routing/app_router.dart';

// This is a temporary implementation
// https://github.com/flutter/packages/pull/2650
class ScaffoldWithBottomNavBarAdmin extends StatefulWidget {
  const ScaffoldWithBottomNavBarAdmin({super.key, required this.child});
  final Widget child;

  @override
  State<ScaffoldWithBottomNavBarAdmin> createState() =>
      _ScaffoldWithBottomNavBarAdminState();
}

class _ScaffoldWithBottomNavBarAdminState extends State<ScaffoldWithBottomNavBarAdmin> {
  // used for the currentIndex argument of BottomNavigationBar
  int _selectedIndex = 0;

  void _tap(BuildContext context, int index) {
    if (index == _selectedIndex) {
      // If the tab hasn't changed, do nothing
      return;
    }
    setState(() => _selectedIndex = index);
    if (index == 0) {
      // Note: this won't remember the previous state of the route
      // More info here:
      // https://github.com/flutter/flutter/issues/99124
      context.goNamed(AppRoute.displayUsers.name);
    }
    else if( index == 1) {

           context.goNamed(AppRoute.dashboard.name);
    } 
    
    else if (index == 2) {
      context.goNamed(AppRoute.account.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
     
        selectedItemColor: Theme.of(context).colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        items: [
          // products
          // BottomNavigationBarItem(
          //   activeIcon: const Icon(Icons.add, color:CupertinoColors.black,),
          //   icon: const Icon(Icons.add),
          //   label: 'Add'.hardcoded,
          //   backgroundColor: CupertinoColors.activeBlue

          // ),
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.person_2_alt),
             
              label: 'Users'.hardcoded,
             ),

            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.doc_chart),
             
              label: 'Database'.hardcoded,
             ),
        
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.person_circle),
            
              label: 'Account'.hardcoded,
             ),
        ],
        onTap: (index) => _tap(context, index),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.lightBlueAccent,
      //   onPressed: () {
      //     if(!context.canPop()) {
      //       context.pushNamed(AppRoute.editOrder.name);
      //     }
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(
      //     CupertinoIcons.add,
      //     color: Colors.white,
      //   ),
      // ),
    );
  }
}




// This is a temporary implementation
// https://github.com/flutter/packages/pull/2650
class ScaffoldWithBottomNavBar extends StatefulWidget {
  const ScaffoldWithBottomNavBar({super.key, required this.child});
  final Widget child;

  @override
  State<ScaffoldWithBottomNavBar> createState() =>
      _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  // used for the currentIndex argument of BottomNavigationBar
  int _selectedIndex = 0;

  void _tap(BuildContext context, int index) {
    if (index == _selectedIndex) {
      // If the tab hasn't changed, do nothing
      return;
    }
    setState(() => _selectedIndex = index);
    if (index == 0) {
      // Note: this won't remember the previous state of the route
      // More info here:
      // https://github.com/flutter/flutter/issues/99124
      context.goNamed(AppRoute.entries.name);
    }
    else {
      context.goNamed(AppRoute.account.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        items: [
          // products
          // BottomNavigationBarItem(
          //   activeIcon: const Icon(Icons.add, color:CupertinoColors.black,),
          //   icon: const Icon(Icons.add),
          //   label: 'Add'.hardcoded,
          //   backgroundColor: CupertinoColors.activeBlue

          // ),
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.doc_on_clipboard),
             
              label: 'Sheets'.hardcoded,
             ),

        
        
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.person_circle),
            
              label: 'Account'.hardcoded,
             ),
        ],
        onTap: (index) => _tap(context, index),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.lightBlueAccent,
      //   onPressed: () {
      //     if(!context.canPop()) {
      //       context.pushNamed(AppRoute.editOrder.name);
      //     }
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(
      //     CupertinoIcons.add,
      //     color: Colors.white,
      //   ),
      // ),
    );
  }
}
