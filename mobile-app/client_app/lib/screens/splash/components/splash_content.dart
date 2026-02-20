import 'package:flutter/material.dart';


class SplashContent extends StatefulWidget {
  const SplashContent({
    Key? key,
    this.title,
    this.description,
    this.image,
    this.isActive = false,
  }) : super(key: key);
  
  final String? title, description, image;
  final bool isActive;

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _foregroundImageAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _descriptionAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Only animate foreground content (image, title, description)
    _foregroundImageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _descriptionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(SplashContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isActive && _animationController.status == AnimationStatus.dismissed) {
      _animationController.forward();
    }

    return Column(
      children: <Widget>[
        // Image section - only foreground image (background is static in parent)
        Expanded(
          flex: 8,
          child: AnimatedBuilder(
            animation: _foregroundImageAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _foregroundImageAnimation.value,
                child: widget.image != null
                    ? Image.asset(
                        widget.image!,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      )
                    : const SizedBox(),
              );
            },
          ),
        ),
        
        // Text section - animated
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 20,  // Reduced from 40 to prevent overflow
            ),
            child: SingleChildScrollView(  // Added scroll in case of overflow
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,  // Changed: only take needed space
                    children: [
                      // Title
                      Opacity(
                        opacity: _titleAnimation.value,
                        child: Text(
                          widget.title ?? "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Color(0xFFFF4D4D), // Red color
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      Opacity(
                        opacity: _descriptionAnimation.value,
                        child: Text(
                          widget.description ?? "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}