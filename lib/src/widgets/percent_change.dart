import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PercentChange extends StatelessWidget {
  final double percentChange;
  final String? content;
  const PercentChange(
      {required this.percentChange,
      this.content,
       super.key, });

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600),
      children: [
        if(content != null)
        TextSpan(
          text: "$content ",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        WidgetSpan(
          child: Icon(
            percentChange >= 0
                ? CupertinoIcons.up_arrow
                : CupertinoIcons.down_arrow,
            color: percentChange >= 0
                ? Colors.green
                : Colors.red,
            size: 14,
          ),
        ),
        TextSpan(
          text:
              "${percentChange.abs().toStringAsFixed(1)}%",
          style: TextStyle(
            color: percentChange >= 0
                ? Colors.green
                : Colors.red,
          ),
        ),
      ],
    ));
  }
}
