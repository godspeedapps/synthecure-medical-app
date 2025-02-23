import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/routing/app_router.dart';

class DashboardGrid extends ConsumerWidget {
  const DashboardGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
         backgroundColor: Colors.white,
       middle: const Text('Dashboard'),
   
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
                
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 16, // Spacing between columns
          mainAxisSpacing: 16, // Spacing between rows
          children: [
            _DashboardItem(
              label: 'Orders',
              icon: Icons.receipt_long,
              iconColor: Colors.black,
              onTap: () => context.pushNamed(AppRoute.allOrders.name),
            ),
            _DashboardItem(
              label: 'Hospitals',
              icon: Icons.local_hospital,
              iconColor: Colors.redAccent,
              onTap: () => context.pushNamed(AppRoute.allHospitals.name),
            ),
            _DashboardItem(
              label: 'Products',
              icon: Icons.inventory,
              iconColor: Colors.deepPurple,
              onTap: () => context.pushNamed(AppRoute.allProducts.name),
            ),
            _DashboardItem(
              label: 'Doctors',
              icon: Icons.person,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () => context.pushNamed(AppRoute.allDoctors.name),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _DashboardItem({
    Key? key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white, // Background color for the container
      borderRadius: BorderRadius.circular(12), // Matches container border radius
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12), // Ensures splash effect respects corners
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2), // Custom splash color
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          
            
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: CupertinoColors.systemGrey,
                      
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
