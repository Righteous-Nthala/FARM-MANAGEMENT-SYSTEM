import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Title
              Padding(
                padding:
                    const EdgeInsets.only(top: 50.0, left: 24.0, right: 24.0),
                child: Text(
                  'FarmWise',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30),

              // Animation
              SizedBox(
                height: 200,
                width: 250,
                child: Lottie.asset(
                  'images/landing.json',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 30),

              // Descriptive text in shaded containers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 8,
                        offset: Offset(0, 3), // Shadow positioning
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'FarmWise is designed to support the complexities of farm life while keeping your data safe and accessible.',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Track crops, livestock, finances, labor, and farm inputs plus Recording daily operations with ease.  ',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Get Started Button with animated forward arrow
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent[10],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 24, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    AnimatedArrow(), // Custom animated arrow widget
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom animated arrow widget for "Get Started" button
class AnimatedArrow extends StatefulWidget {
  const AnimatedArrow({super.key});

  @override
  _AnimatedArrowState createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<Offset>(begin: Offset.zero, end: Offset(0.2, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Icon(Icons.arrow_forward, color: Colors.green),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
