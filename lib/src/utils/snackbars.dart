import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(
        message,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
      ),
      backgroundColor: CupertinoColors.systemGreen,
     
     
    ),
  );
}

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
       duration: const Duration(seconds: 2),
      content: Text(
        message,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
      ),
      backgroundColor: CupertinoColors.destructiveRed,
     
    ),
  );
}



  void showCustomSnackbar(
      BuildContext context, String text) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top +
            10, // ✅ Positioning at the top
        left: 20,
        right: 20,
        child: FadeTransitionSnackbar(message: text),
      ),
    );

    overlay.insert(overlayEntry);

    // ✅ Remove the snackbar after a delay
    Future.delayed(const Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }



class FadeTransitionSnackbar extends StatefulWidget {
  final String message;

  const FadeTransitionSnackbar(
      {super.key, required this.message});

  @override
  State<FadeTransitionSnackbar> createState() =>
      _FadeTransitionSnackbarState();
}

class _FadeTransitionSnackbarState
    extends State<FadeTransitionSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Animation setup for fade in and fade out
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // ✅ Fade out after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(5),
        color: CupertinoColors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 12),
          child: Text(
            widget.message,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
    );
  }
}

