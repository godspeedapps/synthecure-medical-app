import 'package:flutter/material.dart';

import '../domain/hospital.dart';

class DropDownTile extends StatelessWidget {
  const DropDownTile({super.key, required this.model});

  final Hospital model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(title: Text(model.name)),
        ],
      ),
    );
  }
}
