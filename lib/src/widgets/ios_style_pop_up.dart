
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class EventPopupMenuButton extends StatelessWidget {
  final double borderRadius;
  final Color _backgroundColor = Colors.white;
  final String selectedText;
  final List<EventPopUpItem> Function(BuildContext) itemBuilder;

  const EventPopupMenuButton({
    super.key,
    this.borderRadius = 10.0,
    required this.selectedText,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    
    
    return PopupMenuButton<String>(
      //offset: const Offset(-25, 50),
      
      elevation: 2,
      splashRadius: 10,
      itemBuilder: (context1) {
        /// give the current context and map the IosLikePopupMenuItem dtos to PopupMenuEntry while splicing in dividers
        return itemBuilder(context1)
            .map((e) => e.popupMenuItems())
            .toList()
            .fold(
                List<PopupMenuEntry<String>>.empty(growable: true),
                (p, e) => [
                      ...p,
                      ...[e, const PopupMenuDivider()]
                    ])

          /// delete the last divider
          ..removeLast();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
      ),
      color: _backgroundColor,
      shadowColor: Colors.black,
      // position: PopupMenuPosition.values.last,
      child: Row(
        children: [
          Text(selectedText),
          const SizedBox(width: 5),
          const Icon(CupertinoIcons.chevron_up_chevron_down, size: 20)
        ],
      ),
    );
  }
}

class EventPopUpItem {
  final double menuItemHeight, minSpaceBtwnTxtAndIcon;
  final String lableText;
  final Color textColor;
  final Color iconColor;
  final String value;
  final bool isSelected;
  final void Function() onTap;

  final TextStyle _textStyle =
      const TextStyle(color: Colors.black, fontSize: 22.0);

  EventPopUpItem(
      {this.menuItemHeight = 32.0,
      this.minSpaceBtwnTxtAndIcon = 64.0,
      required this.isSelected,
      required this.lableText,
      required this.onTap,
      required this.textColor,
      required this.iconColor,
      required this.value});

  PopupMenuItem<String> popupMenuItems() => PopupMenuItem<String>(
        height: menuItemHeight,
        textStyle: _textStyle,
        value: value,
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isSelected
                ? const Icon(
                    CupertinoIcons.check_mark,
                    size: 15,
                  )
                : Container(width: 13),
            Text(
              lableText,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
            ),
            SizedBox(width: minSpaceBtwnTxtAndIcon),
          ],
        ),
      );
}
