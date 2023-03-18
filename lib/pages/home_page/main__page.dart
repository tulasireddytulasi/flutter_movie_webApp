import 'dart:ui';

import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double blurImage = 0;
  double blurBox = 0.8;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            buildBlurredImage(),
            const SizedBox(height: 32),
            Slider(
              value: blurImage,
              max: 30,
              onChanged: (value) => setState(() => blurImage = value),
            ),
            const SizedBox(height: 32),
            buildImageOverlay(),
            const SizedBox(height: 32),
            Slider(
              value: blurBox,
              max: 0.8,
              onChanged: (value) {
                setState(() => blurBox = value);
                print("blurBox:  $blurBox");
              },
            ),
            const SizedBox(height: 200),
          ],
        ),
      );

  Widget buildBlurredImage() => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1606569371439-56b1e393a06b?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2134&q=80',
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurImage,
                  sigmaY: blurImage,
                ),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),
          ],
        ),
      );

  Widget buildImageOverlay() => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1606569371439-56b1e393a06b?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2134&q=80',
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 32,
              left: 0,
              right: 0,
              child: Center(
                child: buildBlur(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white.withOpacity(blurBox),
                    child: const Text(
                      'This is text is blurred',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildBlur({
    required Widget child,
    BorderRadius? borderRadius,
    double sigmaX = 10,
    double sigmaY = 10,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: child,
      ),
    );
  }
}
