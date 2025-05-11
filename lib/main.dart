import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'dart:math';
import 'dart:math' show pi, sin;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Greek For Geeks',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(), // Start with splash screen first
    );
  }
}

// 1. SPLASH SCREEN (FIRST SCREEN - LOGO ONLY)
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // After 2 seconds, go to loading screen
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoadingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/appicon.jpg', height: 150), // Your logo
            SizedBox(height: 20),
            Text(
              '',
              style: TextStyle(
                fontSize: 30,
                color: Colors.amber,
                fontFamily: 'Cinzel',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. LOADING SCREEN (SECOND SCREEN)
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _progressController;
  late VideoPlayerController _videoController;
  bool _navigating = false;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();

    // Set up fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Set up progress animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(() {
      setState(() {
        // Force rebuild to update progress bar
      });
    });

    // Start progress animation
    _progressController.animateTo(1.0, curve: Curves.easeInOut);

    // Set up video controller
    _videoController = VideoPlayerController.asset('videos/loadingscreen.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _videoInitialized = true;
            _videoController.play();
            _videoController.setLooping(true);
          });
        }
      });

    Timer(const Duration(seconds: 8), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (mounted && !_navigating) {
      setState(() => _navigating = true);
      _fadeController.reverse().then((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => StartMenuScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeController.value,
            child: child,
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Black background (shown before video loads)
            Container(color: Colors.black),

            // MP4 Video filling the entire screen
            _videoInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
                : const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            ),

            // Loading text and progress bar with fully transparent background
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Loading Olympus...',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.amber.withOpacity(0.8),
                        fontFamily: 'Cinzel',
                        shadows: [
                          Shadow(
                            blurRadius: 12,
                            color: Colors.amber.withOpacity(0.8),
                            offset: const Offset(0, 0),
                          ),
                          Shadow(
                            blurRadius: 4,
                            color: Colors.deepOrange.withOpacity(0.6),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // Background track
                            Container(
                              height: 6,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            // Animated progress bar
                            AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return Container(
                                  height: 6,
                                  width: constraints.maxWidth * _progressController.value,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.5),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. START MENU SCREEN (THIRD SCREEN)
class StartMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with Greek temple imagery
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/greekbg.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // Subtle ambient particle effects - now properly constrained
          Positioned.fill(
            child: ClipRect(
              child: GreekParticleOverlay(),
            ),
          ),

          // Column layout with proper spacing
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Title area with clickable helmet
                  GreekTitle(
                    onHelmetTap: () => _showOracleDialog(context),
                  ),

                  SizedBox(height: 60),

                  // Menu buttons styled as separate rounded yellow buttons
                  Column(
                    children: [
                      MythicButton(
                        text: 'Challenge Yourself',
                        icon: Icons.local_police,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QuizPage()),
                        ),
                      ),
                      SizedBox(height: 20),
                      MythicButton(
                        text: 'Explore Olympus',
                        icon: Icons.terrain,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainMenuScreen()),
                        ),
                      ),
                      SizedBox(height: 20),
                      MythicButton(
                        text: 'Credits',
                        icon: Icons.auto_stories,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreditsPage()),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Text(
                      'CREATED WITH WISDOM FROM ATHENS • V1.0',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Cinzel',
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOracleDialog(BuildContext context) {
    final List<String> prophecies = [
      "Your quest for wisdom shall be rewarded.",
      "Knowledge of the ancients awaits those who persevere.",
      "Even Athena would be impressed by your wisdom.",
      "The threads of fate are woven by your actions.",
      "Your journey shall be blessed by the gods of Olympus.",
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.amber[700]!, width: 2),
        ),
        title: Text(
          'The Oracle Speaks',
          style: TextStyle(
            color: Colors.amber[300],
            fontFamily: 'Cinzel',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.amber[300],
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              prophecies[DateTime.now().millisecond % prophecies.length],
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Cinzel',
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              'I ACCEPT MY FATE',
              style: TextStyle(
                color: Colors.amber[300],
                fontFamily: 'Cinzel',
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class GreekTitle extends StatelessWidget {
  final VoidCallback onHelmetTap;

  const GreekTitle({required this.onHelmetTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Greek helmet icon (clickable)
          GestureDetector(
            onTap: onHelmetTap,
            child: Image.asset(
              'images/greek_helmet.png',
              height: 120,
            ),
          ),
          SizedBox(height: 16),
          // Title text with authentic Greek styling
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.amber[300]!,
                Colors.amber[700]!,
                Colors.amber[300]!,
              ],
              stops: [0.2, 0.5, 0.8],
            ).createShader(bounds),
            child: Text(
              'GREEK FOR GEEKS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cinzel',
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    blurRadius: 15,
                    color: Colors.amber[700]!.withOpacity(0.8),
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          // Simple subtitle without pattern
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'KNOW THY MYTHS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontFamily: 'Cinzel',
                letterSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MythicButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const MythicButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate button width based on content, ensuring text has enough space
    double buttonWidth;
    if (text == 'Credits') {
      buttonWidth = 220;
    } else if (text == 'Explore Olympus') {
      buttonWidth = 300;
    } else {
      // Increased width for "Challenge Yourself" to prevent text cutoff
      buttonWidth = 340;
    }

    return Container(
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFCCE46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.brown[800]!.withOpacity(0.8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.amber[700]!,
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.amber[300],
                size: 16,
              ),
            ),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Cinzel',
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GreekParticleOverlay extends StatefulWidget {
  @override
  _GreekParticleOverlayState createState() => _GreekParticleOverlayState();
}

class _GreekParticleOverlayState extends State<GreekParticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_controller.value),
          child: Container(),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  final Random random = Random(42);

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Reduced particle count and better bounds checking
    for (int i = 0; i < 30; i++) {
      final seedX = random.nextDouble() * size.width;
      final seedY = random.nextDouble() * size.height;

      // Constrained movement
      final x = seedX + sin(animationValue * 2 * pi + i) * 15;
      final y = (seedY - animationValue * size.height) % (size.height * 1.2);

      final paint = Paint()
        ..color = Colors.amber.withOpacity(random.nextDouble() * 0.1 + 0.05)
        ..strokeWidth = random.nextDouble() * 2 + 1
        ..strokeCap = StrokeCap.round;

      final particleSize = random.nextDouble() * 2 + 1;
      if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
        canvas.drawCircle(Offset(x, y), particleSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}


class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> with SingleTickerProviderStateMixin {
  final List<TeamMember> team = [
    TeamMember("FRANZ AGUINALDO", "PROGRAMMER", "images/aguinaldo.JPG", Colors.red),
    TeamMember("JUNJIFIL CASTRO", "VIDEO EDITOR", "images/castro.JPG", Colors.blue),
    TeamMember("ARC DANIER GAYON", "PROGRAMMER", "images/gayon.JPG", Colors.green),
    TeamMember("KIRK CHRISTIAN MADERAS", "UI/UX DESIGNER", "images/maderas.JPG", Colors.yellow),
    TeamMember("IVAN PEREZ", "UI/UX DESIGNER", "images/perez.JPG", Colors.purple),
  ];

  final Random _random = Random();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentPage = 0;
  double _dragOffset = 0.0;
  bool _isDragging = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Offset> _generateRandomOffsets(int count) {
    return List.generate(count, (index) {
      return Offset(
        (_random.nextDouble() * 60 - 30),
        (_random.nextDouble() * 40 - 20),
      );
    });
  }

  List<double> _generateRandomRotations(int count) {
    return List.generate(count, (index) {
      return (_random.nextDouble() * 0.2 - 0.1);
    });
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _controller.stop();
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isAnimating) return;

    final double swipeThreshold = 100;
    final double velocityThreshold = 500;
    final double velocity = details.velocity.pixelsPerSecond.dx.abs();

    if (_dragOffset.abs() > swipeThreshold || velocity > velocityThreshold) {
      _isAnimating = true;
      final bool swipeRight = _dragOffset > 0;

      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(swipeRight ? 500 : -500, 0),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );

      _rotationAnimation = Tween<double>(
        begin: 0,
        end: swipeRight ? 0.2 : -0.2,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );

      _controller.forward().then((_) {
        setState(() {
          _currentPage = swipeRight
              ? (_currentPage - 1) % team.length
              : (_currentPage + 1) % team.length;
          _dragOffset = 0;
          _isDragging = false;
          _isAnimating = false;
        });

        // Reset animations
        _controller.reset();
        _slideAnimation = Tween<Offset>(
          begin: const Offset(-500, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack,
          ),
        );

        _rotationAnimation = Tween<double>(
          begin: swipeRight ? -0.2 : 0.2,
          end: 0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack,
          ),
        );

        _controller.forward();
      });
    } else {
      // Return to center if not swiped far enough
      _slideAnimation = Tween<Offset>(
        begin: Offset(_dragOffset, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ),
      );

      _rotationAnimation = Tween<double>(
        begin: _dragOffset / 1000,
        end: 0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ),
      );

      _controller.forward().then((_) {
        setState(() {
          _dragOffset = 0;
          _isDragging = false;
        });
        _controller.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final offsets = _generateRandomOffsets(team.length);
    final rotations = _generateRandomRotations(team.length);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0a0a0a),
                    Color(0xFF1a1a1a),
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo centered at the top
                Center(
                  child: Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      // Optional border for debugging
                      // border: Border.all(color: Colors.red),
                    ),
                    child: Image.asset(
                      'images/wonderpets.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.broken_image, color: Colors.white, size: 40),
                            SizedBox(height: 5),
                            Text(
                              'Image not found',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Team members cards
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background cards
                        for (int i = 0; i < team.length; i++)
                          if (i != _currentPage)
                            Transform.translate(
                              offset: offsets[i],
                              child: Transform.rotate(
                                angle: rotations[i],
                                child: _buildMagazineCard(
                                  team[i],
                                  index: i,
                                  isTop: false,
                                ),
                              ),
                            ),

                        // Main draggable card
                        GestureDetector(
                          onHorizontalDragStart: _onDragStart,
                          onHorizontalDragUpdate: _onDragUpdate,
                          onHorizontalDragEnd: _onDragEnd,
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: _isDragging
                                    ? Offset(_dragOffset, 0)
                                    : _slideAnimation.value,
                                child: Transform.rotate(
                                  angle: _isDragging
                                      ? _dragOffset / 1000
                                      : _rotationAnimation.value,
                                  child: Transform.scale(
                                    scale: _isDragging
                                        ? 1.0 + (_dragOffset.abs() / 1000)
                                        : _scaleAnimation.value,
                                    child: _buildMagazineCard(
                                      team[_currentPage],
                                      index: _currentPage,
                                      isTop: true,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Page indicator
                SizedBox(
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(team.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentPage == index ? 12 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                // Back to Menu Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'BACK TO MENU',
                      style: TextStyle(
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagazineCard(TeamMember member, {
    required int index,
    required bool isTop,
  }) {
    return Material(
      elevation: isTop ? 8.0 : 2.0,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 280,
        height: 380,
        decoration: BoxDecoration(
          color: member.color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          image: DecorationImage(
            image: AssetImage(member.image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: Transform.rotate(
                angle: -0.05,
                child: Text(
                  "TEAM\nMAGAZINE",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    height: 0.9,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    member.role,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Text(
                "MEMBER\n0${index + 1}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: member.color.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamMember {
  final String name;
  final String role;
  final String image;
  final Color color;

  TeamMember(this.name, this.role, this.image, this.color);
}


class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool isDarkMode = false;
  bool _isTransitioning = false;
  late ImageProvider _currentBackground;
  late ImageProvider _nextBackground;

  @override
  void initState() {
    super.initState();
    _currentBackground = const AssetImage('images/homepage_lightmode.jpeg');
    _nextBackground = const AssetImage('images/homepage_darkmode.jpeg');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(_currentBackground, context);
    precacheImage(_nextBackground, context);
  }

  Future<void> _toggleTheme() async {
    if (_isTransitioning) return;

    setState(() => _isTransitioning = true);

    // Load the new background before switching
    final newBackground = isDarkMode
        ? const AssetImage('images/homepage_lightmode.jpeg')
        : const AssetImage('images/homepage_darkmode.jpeg');

    await precacheImage(newBackground, context);

    setState(() {
      isDarkMode = !isDarkMode;
      _currentBackground = newBackground;
      _nextBackground = isDarkMode
          ? const AssetImage('images/homepage_darkmode.jpeg')
          : const AssetImage('images/homepage_lightmode.jpeg');
      _isTransitioning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with perfect transition
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _currentBackground,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Theme toggle button
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  key: ValueKey<bool>(isDarkMode),
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              onPressed: _toggleTheme,
            ),
          ),

          // Character button
          AnimatedCharacterButton(
            left: 30,
            top: 250,
            image: 'images/character_resize.jpg',
            label: 'Characters',
            destination: CharacterCategoryScreen(),
            isDarkMode: isDarkMode,
          ),

          // Story button
          AnimatedCharacterButton(
            left: 200,
            top: 480,
            image: 'images/story_resize.jpg',
            label: 'Fun Facts',
            destination: FactPage(),
            isDarkMode: isDarkMode,
          ),

          // Quiz button
          AnimatedCharacterButton(
            left: 120,
            top: 730,
            image: 'images/quiz_resize.jpg',
            label: 'Quiz',
            destination: QuizPage(),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}

class AnimatedCharacterButton extends StatefulWidget {
  final double left;
  final double top;
  final String image;
  final String label;
  final Widget destination;
  final bool isDarkMode;

  const AnimatedCharacterButton({
    required this.left,
    required this.top,
    required this.image,
    required this.label,
    required this.destination,
    required this.isDarkMode,
  });

  @override
  _AnimatedCharacterButtonState createState() => _AnimatedCharacterButtonState();
}

class _AnimatedCharacterButtonState extends State<AnimatedCharacterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = _controller.value * 10;
          return Transform.translate(
            offset: Offset(0, -offset),
            child: child,
          );
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                  widget.destination,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  transform: isHovered
                      ? (Matrix4.identity()..scale(1.1))
                      : Matrix4.identity(),
                  child: Image.asset(widget.image, width: 160, height: 120),
                ),
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: isHovered ? 20 : 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black87,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Text(widget.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class CharacterCategoryScreen extends StatelessWidget {
  final List<String> categories = [
    'Greek Gods',
    'Titans',
    'Chthonic & Primordial Deities',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // This makes the body extend behind the AppBar
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent, // Make background transparent
        elevation: 0, // Remove shadow
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.transparent, // Ensure the container is transparent
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/greekbg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 20), // Add extra space for the AppBar
            Text(
              'Select a Category',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.white.withOpacity(0.85),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CharacterListScreen(category: categories[index]),
                          ),
                        );
                      },
                      child: Text(
                        categories[index],
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}








class Character {
  final String name;
  final String description;
  final String imageUrl;
  final String details;
  final String category;
  final String id;
  final Map<String, double> powerStats; // Add power stats

  Character({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.details,
    required this.category,
    required this.id,
    required this.powerStats, // Add to constructor
  });

  // Sample data converted from your original code with power stats added
  static List<Character> get allCharacters {
    final List<Character> characters = [];

    // Greek Gods
    characters.addAll([
      Character(
        id: 'zeus',
        name: 'Zeus',
        description: 'King of the gods, god of sky and thunder.',
        imageUrl: 'zeus.jpg',
        details: 'Zeus is the king of the gods, ruler of Mount Olympus, and god of the sky, lightning, and thunder. He wields a thunderbolt and is the most powerful of the Olympians.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 1.0,
          'Wisdom': 0.8,
          'Leadership': 0.9,
          'Influence': 0.95,
        },
      ),
      Character(
        id: 'hera',
        name: 'Hera',
        description: 'Queen of the gods, goddess of marriage and family.',
        imageUrl: 'hera.jpg',
        details: 'Hera is the wife and sister of Zeus. She is the goddess of marriage and family, often portrayed as majestic and solemn.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 0.7,
          'Wisdom': 0.8,
          'Leadership': 0.6,
          'Influence': 0.85,
        },
      ),
      Character(
        id: 'poseidon',
        name: 'Poseidon',
        description: 'God of the sea, earthquakes, and horses.',
        imageUrl: 'poseidon.jpg',
        details: 'Poseidon is the god of the sea, known for causing earthquakes and wielding a powerful trident. He is the brother of Zeus and Hades.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 0.9,
          'Wisdom': 0.7,
          'Leadership': 0.8,
          'Influence': 0.75,
        },
      ),
      Character(
        id: 'demeter',
        name: 'Demeter',
        description: 'Goddess of agriculture and harvest.',
        imageUrl: 'demeter.jpg',
        details: 'Demeter is the goddess of agriculture, grain, and fertility. She is the mother of Persephone and is deeply connected to the changing seasons.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 0.6,
          'Wisdom': 0.8,
          'Leadership': 0.5,
          'Influence': 0.7,
        },
      ),
      Character(
        id: 'athena',
        name: 'Athena',
        description: 'Goddess of wisdom and strategy.',
        imageUrl: 'athena.jpg',
        details: 'Athena, born from the head of Zeus, is the goddess of wisdom, war strategy, and crafts. She is symbolized by the owl and olive tree.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 0.7,
          'Wisdom': 1.0,
          'Leadership': 0.9,
          'Influence': 0.8,
        },
      ),
      Character(
        id: 'apollo',
        name: 'Apollo',
        description: 'God of sun, music, and healing.',
        imageUrl: 'apollo.jpg',
        details: 'Apollo is the god of the sun, music, prophecy, and healing. He is the twin brother of Artemis and often associated with the lyre and the bow.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 0.8,
          'Wisdom': 0.9,
          'Leadership': 0.7,
          'Influence': 0.85,
        },
      ),
      Character(
        id: 'artemis',
        name: 'Artemis',
        description: 'Goddess of the hunt and moon.',
        imageUrl: 'artemis.jpg',
        details: 'Artemis is the goddess of the hunt, wilderness, and the moon. She is the twin sister of Apollo and a protector of young women.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 0.8,
          'Wisdom': 0.7,
          'Leadership': 0.6,
          'Influence': 0.7,
        },
      ),
      Character(
        id: 'ares',
        name: 'Ares',
        description: 'God of war and violence.',
        imageUrl: 'ares.jpg',
        details: 'Ares is the god of war, known for his aggressive and violent nature. He represents the brutal aspect of conflict and battle.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 0.9,
          'Wisdom': 0.4,
          'Leadership': 0.5,
          'Influence': 0.6,
        },
      ),
      Character(
        id: 'aphrodite',
        name: 'Aphrodite',
        description: 'Goddess of love and beauty.',
        imageUrl: 'aphrodite.jpg',
        details: 'Aphrodite is the goddess of love, beauty, and desire. She was born from the sea foam and is often associated with the dove and rose.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 0.5,
          'Wisdom': 0.6,
          'Leadership': 0.4,
          'Influence': 0.95,
        },
      ),
      Character(
        id: 'hephaestus',
        name: 'Hephaestus',
        description: 'God of fire and blacksmiths.',
        imageUrl: 'hephaestus.jpg',
        details: 'Hephaestus is the god of fire, metalworking, and craftsmanship. He forges weapons for the gods and is known for his creativity.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 0.7,
          'Wisdom': 0.9,
          'Leadership': 0.5,
          'Influence': 0.6,
        },
      ),
      Character(
        id: 'hermes',
        name: 'Hermes',
        description: 'Messenger god, god of trade.',
        imageUrl: 'hermes.jpg',
        details: 'Hermes is the messenger of the gods and the god of travel, commerce, and thieves. He is known for his winged sandals and quick wit.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 0.6,
          'Wisdom': 0.8,
          'Leadership': 0.7,
          'Influence': 0.8,
        },
      ),
      Character(
        id: 'hestia',
        name: 'Hestia',
        description: 'Goddess of hearth and home.',
        imageUrl: 'hestia.jpg',
        details: 'Hestia is the goddess of the hearth, home, and domestic life. She is known for her calm and gentle nature.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 0.5,
          'Wisdom': 0.7,
          'Leadership': 0.4,
          'Influence': 0.6,
        },
      ),
      Character(
        id: 'dionysus',
        name: 'Dionysus',
        description: 'God of wine and festivity.',
        imageUrl: 'dionysus.jpg',
        details: 'Dionysus is the god of wine, pleasure, and theater. He is a patron of the arts and known for his wild celebrations.',
        category: 'Greek Gods',
        powerStats: {
          'Power': 0.6,
          'Wisdom': 0.5,
          'Leadership': 0.7,
          'Influence': 0.8,
        },
      ),
    ]);

    // Chthonic & Primordial Deities
    characters.addAll([
      Character(
        id: 'hades',
        name: 'Hades',
        description: 'God of the underworld.',
        imageUrl: 'hades.jpg',
        details: 'Hades is the god of the underworld and the dead. He is the brother of Zeus and Poseidon, ruling over the realm of the dead with his queen Persephone.',
        category: 'Chthonic & Primordial Deities',
        powerStats: {
          'Power': 0.9,
          'Wisdom': 0.8,
          'Leadership': 0.7,
          'Influence': 0.6,
        },
      ),
      Character(
        id: 'persephone',
        name: 'Persephone',
        description: 'Queen of the underworld, goddess of spring.',
        imageUrl: 'persephone.jpg',
        details: 'Persephone is the daughter of Demeter and queen of the underworld. She represents the cycle of life and rebirth, and the coming of spring.',
        category: 'Chthonic & Primordial Deities',
        powerStats: {
          'Power': 0.7,
          'Wisdom': 0.8,
          'Leadership': 0.6,
          'Influence': 0.7,
        },
      ),
      Character(
        id: 'gaia',
        name: 'Gaia',
        description: 'Primordial goddess of Earth.',
        imageUrl: 'gaia.jpg',
        details: 'Gaia is the personification of Earth and the ancestral mother of all life. She emerged at the dawn of creation.',
        category: 'Chthonic & Primordial Deities',
        powerStats: {
          'Power': 1.0,
          'Wisdom': 0.9,
          'Leadership': 0.8,
          'Influence': 0.9,
        },
      ),
      Character(
        id: 'uranus',
        name: 'Uranus',
        description: 'Primordial god of the sky.',
        imageUrl: 'uranus.jpg',
        details: 'Uranus is the sky god and the father of the Titans. He was overthrown by his son Cronus.',
        category: 'Chthonic & Primordial Deities',
        powerStats: {
          'Power': 0.9,
          'Wisdom': 0.7,
          'Leadership': 0.6,
          'Influence': 0.7,
        },
      ),
    ]);

    // Titans
    characters.addAll([
      Character(
        id: 'cronus',
        name: 'Cronus',
        description: 'Leader of the Titans, god of time.',
        imageUrl: 'cronus.jpg',
        details: 'Cronus was the leader of the Titans and the god of time. He ruled during the Golden Age until overthrown by his son Zeus.',
        category: 'Titans',
        powerStats: {
          'Power': 0.9,
          'Wisdom': 0.7,
          'Leadership': 0.8,
          'Influence': 0.7,
        },
      ),
      Character(
        id: 'rhea',
        name: 'Rhea',
        description: 'Titaness of fertility and motherhood.',
        imageUrl: 'rhea.jpg',
        details: 'Rhea is the Titaness of fertility, motherhood, and generation. She is the mother of the first Olympians.',
        category: 'Titans',
        powerStats: {
          'Power': 0.7,
          'Wisdom': 0.8,
          'Leadership': 0.7,
          'Influence': 0.7,
        },
      ),
      Character(
        id: 'oceanus',
        name: 'Oceanus',
        description: 'Titan god of the ocean.',
        imageUrl: 'oceanus.jpg',
        details: 'Oceanus is the Titan god of the great ocean that encircles the world. He is considered the source of all the Earth\'s freshwater.',
        category: 'Titans',
        powerStats: {
          'Power': 0.8,
          'Wisdom': 0.7,
          'Leadership': 0.6,
          'Influence': 0.6,
        },
      ),
      Character(
        id: 'hyperion',
        name: 'Hyperion',
        description: 'Titan of light.',
        imageUrl: 'hyperion.jpg',
        details: 'Hyperion is the Titan of light, and father of the sun (Helios), moon (Selene), and dawn (Eos).',
        category: 'Titans',
        powerStats: {
          'Power': 0.8,
          'Wisdom': 0.7,
          'Leadership': 0.6,
          'Influence': 0.6,
        },
      ),
      Character(
        id: 'prometheus',
        name: 'Prometheus',
        description: 'Titan who gave fire to humanity.',
        imageUrl: 'prometheus.jpg',
        details: 'Prometheus is the Titan of foresight, known for defying Zeus by stealing fire and giving it to humans. He is a symbol of intelligence and rebellion.',
        category: 'Titans',
        powerStats: {
          'Power': 0.7,
          'Wisdom': 0.9,
          'Leadership': 0.8,
          'Influence': 0.7,
        },
      ),
    ]);

    return characters;
  }

  static List<String> get categories => ['Greek Gods', 'Chthonic & Primordial Deities', 'Titans'];

  static List<Character> getCharactersByCategory(String category) {
    return allCharacters.where((character) => character.category == category).toList();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final pageController = PageController(viewportFraction: 0.8);
  final ValueNotifier<double> pageNotifier = ValueNotifier(0);
  final ValueNotifier<int> categorySelectNotifier = ValueNotifier(-1);

  @override
  void initState() {
    pageController.addListener(pageListener);
    super.initState();
  }

  @override
  void dispose() {
    pageController
      ..removeListener(pageListener)
      ..dispose();
    super.dispose();
  }

  void pageListener() {
    pageNotifier.value = pageController.page ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "GREEK MYTHOLOGY",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/greekbgm.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                "SELECT A CATEGORY",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    CategoryPageView(
                      pageNotifier: pageNotifier,
                      categorySelectNotifier: categorySelectNotifier,
                      controller: pageController,
                    ),
                    Positioned.fill(
                      top: null,
                      child: Column(
                        children: [
                          CategoryPageIndicators(
                            categorySelectNotifier: categorySelectNotifier,
                            pageNotifier: pageNotifier,
                          ),
                          BottomNavigationWidget(
                            categorySelectNotifier: categorySelectNotifier,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryPageView extends StatelessWidget {
  const CategoryPageView({
    super.key,
    required this.pageNotifier,
    required this.categorySelectNotifier,
    required this.controller,
  });

  final ValueNotifier<double> pageNotifier;
  final ValueNotifier<int> categorySelectNotifier;
  final PageController controller;

  double _getOffsetX(double percent) => percent.isNegative ? 30.0 : -30.0;

  Matrix4 _getOutTranslate(double percent, int selected, int index) {
    final x = selected != index && selected != -1 ? _getOffsetX(percent) : 0.0;
    return Matrix4.translationValues(x, 0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: pageNotifier,
      builder: (_, page, __) => ValueListenableBuilder(
        valueListenable: categorySelectNotifier,
        builder: (_, selected, __) => PageView.builder(
          clipBehavior: Clip.none,
          itemCount: Character.categories.length,
          controller: controller,
          itemBuilder: (_, index) {
            final percent = page - index;
            final isSelected = selected == index;
            final category = Character.categories[index];

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              transform: _getOutTranslate(percent, selected, index),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CategoryCard(
                percent: percent,
                expand: isSelected,
                category: category,
                onSwipeUp: () => categorySelectNotifier.value = index,
                onSwipeDown: () => categorySelectNotifier.value = -1,
                onTap: () async {
                  if (isSelected) {
                    await Navigator.push(
                      context,
                      PageRouteBuilder<void>(
                        transitionDuration: const Duration(milliseconds: 800),
                        reverseTransitionDuration: const Duration(milliseconds: 800),
                        pageBuilder: (_, animation, __) => FadeTransition(
                          opacity: animation,
                          child: CharacterListScreen(category: category),
                        ),
                      ),
                    );
                    categorySelectNotifier.value = -1;
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.percent,
    required this.expand,
    required this.category,
    required this.onSwipeUp,
    required this.onSwipeDown,
    required this.onTap,
  });

  final double percent;
  final bool expand;
  final String category;
  final VoidCallback onSwipeUp;
  final VoidCallback onSwipeDown;
  final VoidCallback onTap;

  String _getCategoryImage() {
    switch (category) {
      case 'Greek Gods':
        return 'zeus.jpg';
      case 'Chthonic & Primordial Deities':
        return 'hades.jpg';
      case 'Titans':
        return 'cronus.jpg';
      default:
        return 'greekbgm.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = 1 - (percent.abs() * 0.1).clamp(0.0, 0.1);
    final backgroundOpacity = 1 - percent.abs();
    final expandedHeight = MediaQuery.of(context).size.height * 0.6;
    final normalHeight = MediaQuery.of(context).size.height * 0.45;

    return GestureDetector(
      onTap: onTap,
      onVerticalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy < -200) {
          onSwipeUp();
        } else if (details.velocity.pixelsPerSecond.dy > 200) {
          onSwipeDown();
        }
      },
      child: AnimatedContainer(
        height: expand ? expandedHeight : normalHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(scale),
        alignment: Alignment.center,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage('images/${_getCategoryImage()}'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.7),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: backgroundOpacity.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      if (expand) ...[
                        const SizedBox(height: 16),
                        const Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white,
                          size: 36,
                        ),
                        const Text(
                          "SWIPE UP TO VIEW",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Explore the ${Character.getCharactersByCategory(category).length} ${category.toLowerCase()}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CharacterListScreen extends StatelessWidget {
  final String category;

  const CharacterListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final characters = Character.getCharactersByCategory(category);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          category.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('images/greekbgm.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 100, 12, 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 4,
          ),
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final character = characters[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder<void>(
                    transitionDuration: const Duration(milliseconds: 800),
                    reverseTransitionDuration: const Duration(milliseconds: 800),
                    pageBuilder: (_, animation, __) => FadeTransition(
                      opacity: animation,
                      child: CharacterDetailScreen(character: character),
                    ),
                  ),
                );
              },
              child: Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Hero(
                        tag: character.id,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.asset(
                            'images/${character.imageUrl}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              character.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              character.description,
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CharacterDetailScreen extends StatelessWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CharacterDetailView(
        character: character,
        topPadding: MediaQuery.of(context).padding.top,
      ),
    );
  }
}

class CharacterDetailView extends StatelessWidget {
  const CharacterDetailView({
    super.key,
    required this.character,
    required this.topPadding,
    this.animation = const AlwaysStoppedAnimation<double>(1),
  });

  final Character character;
  final double topPadding;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: character.id,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/${character.imageUrl}'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    height: 250,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'images/${character.imageUrl}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.4, 1, curve: Curves.easeOut),
                    )),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.4, 1, curve: Curves.easeOut),
                      ),
                      child: Text(
                        character.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.5, 1, curve: Curves.easeOut),
                    )),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.5, 1, curve: Curves.easeOut),
                      ),
                      child: Text(
                        character.description,
                        style: const TextStyle(fontSize: 18, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.6, 1, curve: Curves.easeOut),
                    )),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.6, 1, curve: Curves.easeOut),
                      ),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          character.details,
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.7, 1, curve: Curves.easeOut),
                    )),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.7, 1, curve: Curves.easeOut),
                      ),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "POWERS & ABILITIES",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...character.powerStats.entries.map((entry) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: entry.value,
                                    minHeight: 8,
                                    backgroundColor: Colors.white12,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            )).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryPageIndicators extends StatelessWidget {
  const CategoryPageIndicators({
    super.key,
    required this.categorySelectNotifier,
    required this.pageNotifier,
  });

  final ValueNotifier<int> categorySelectNotifier;
  final ValueNotifier<double> pageNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: categorySelectNotifier,
      builder: (_, value, child) => AnimatedOpacity(
        opacity: value != -1 ? 0 : 1,
        duration: value != -1
            ? const Duration(milliseconds: 1)
            : const Duration(milliseconds: 400),
        child: child,
      ),
      child: ValueListenableBuilder<double>(
        valueListenable: pageNotifier,
        builder: (_, value, __) => Center(
          child: PageViewDotIndicators(
            length: Character.categories.length,
            pageIndex: value,
          ),
        ),
      ),
    );
  }
}

class PageViewDotIndicators extends StatelessWidget {
  const PageViewDotIndicators({
    required this.length,
    required this.pageIndex,
    super.key,
  });

  final int length;
  final double pageIndex;

  @override
  Widget build(BuildContext context) {
    final index = pageIndex;
    return SizedBox(
      height: 12,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < length; i++) ...[
                const _Dot(),
                if (i < length - 1) const SizedBox(width: 16),
              ],
            ],
          ),
          Positioned(
            left: (16 * index) + (6 * index),
            child: const _BorderDot(),
          )
        ],
      ),
    );
  }
}

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({
    super.key,
    required this.categorySelectNotifier,
  });

  final ValueNotifier<int> categorySelectNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: categorySelectNotifier,
      builder: (_, value, __) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: value == -1 ? 80 : 0,
          child: AnimatedOpacity(
            opacity: value == -1 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavButton(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isSelected: true,
                    onTap: () {},
                  ),
                  _NavButton(
                    icon: Icons.search_outlined,
                    label: 'Search',
                    isSelected: false,
                    onTap: () {},
                  ),
                  _NavButton(
                    icon: Icons.favorite_outline,
                    label: 'Favorites',
                    isSelected: false,
                    onTap: () {},
                  ),
                  _NavButton(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    isSelected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.orange : Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 6,
      height: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white54,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _BorderDot extends StatelessWidget {
  const _BorderDot();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange, width: 2),
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}






class FactPage extends StatelessWidget {
  final Map<String, List<Map<String, String>>> mythologicalData = {
    'Greek Gods': [
      {
        'name': 'Zeus',
        'desc': 'King of the gods, god of sky and thunder.',
        'img': 'zeus.jpg', // Cropped for circle
        'background_img': 'uncroppedzeus.jpg', // Full background
        'details': 'Zeus once turned into a swan, a bull, and even a shower of gold to woo mortals—talk about dramatic entrances!'
      },
      {
        'name': 'Hera',
        'desc': 'Queen of the gods, goddess of marriage and family.',
        'img': 'hera.jpg',
        'background_img': 'uncroppedhera.jpg',
        'details': 'Hera was known to hold grudges—especially against Zeus\'s many lovers. She even turned one into a cow!'
      },
      {
        'name': 'Poseidon',
        'desc': 'God of the sea, earthquakes, and horses.',
        'img': 'poseidon.jpg',
        'background_img': 'uncroppedposeidon.jpg',
        'details': 'Poseidon created the first horse as part of a contest to impress Demeter—talk about overachieving!'
      },
      {
        'name': 'Demeter',
        'desc': 'Goddess of agriculture and harvest.',
        'img': 'demeter.jpg',
        'background_img': 'uncroppeddemeter.jpg',
        'details': 'Thanks to Demeter\'s heartbreak over losing Persephone, we have winter. Now that\'s motherly love!'
      },
      {
        'name': 'Athena',
        'desc': 'Goddess of wisdom and strategy.',
        'img': 'athena.jpg',
        'background_img': 'uncroppeddemeter.jpg',
        'details': 'Athena popped out of Zeus\'s head—fully grown and armored! Not your typical birth story.'
      },
      {
        'name': 'Apollo',
        'desc': 'God of sun, music, and healing.',
        'img': 'apollo.jpg',
        'background_img': 'uncroppedapollo.jpg',
        'details': 'Apollo could play music so beautifully that even rocks and trees would dance. Total rockstar energy.'
      },
      {
        'name': 'Artemis',
        'desc': 'Goddess of the hunt and moon.',
        'img': 'artemis.jpg',
        'background_img': 'uncroppedartemis.jpg',
        'details': 'Artemis made a vow to stay forever young and wild—she even turned a guy into a stag for spying on her bath!'
      },
      {
        'name': 'Ares',
        'desc': 'God of war and violence.',
        'img': 'ares.jpg',
        'background_img': 'uncroppedares.jpg',
        'details': 'Ares was so intense in battle that even his fellow gods were scared of him... and a little annoyed.'
      },
      {
        'name': 'Aphrodite',
        'desc': 'Goddess of love and beauty.',
        'img': 'aphrodite.jpg',
        'background_img': 'uncroppedaphrodite.jpg',
        'details': 'Aphrodite was born from sea foam—literally! Beauty from bubbles, anyone?'
      },
      {
        'name': 'Hephaestus',
        'desc': 'God of fire and blacksmiths.',
        'img': 'hephaestus.jpg',
        'background_img': 'uncroppedhephaestus.jpg',
        'details': 'Hephaestus made thrones, weapons, and even robotic helpers—basically the OG tech genius.'
      },
      {
        'name': 'Hermes',
        'desc': 'Messenger god, god of trade.',
        'img': 'hermes.jpg',
        'background_img': 'uncroppedhermes.jpg',
        'details': 'Hermes once stole Apollo\'s cows as a baby and sweet-talked his way out of trouble with a lyre.'
      },
      {
        'name': 'Hestia',
        'desc': 'Goddess of hearth and home.',
        'img': 'hestia.jpg',
        'background_img': 'uncroppedhestia.jpg',
        'details': 'Hestia kept the Olympic hearth burning—literally the goddess of "home sweet home."'
      },
      {
        'name': 'Dionysus',
        'desc': 'God of wine and festivity.',
        'img': 'dionysus.jpg',
        'background_img': 'uncroppeddionysus.jpg',
        'details': 'Dionysus could turn water into wine and make vines grow anywhere—party god unlocked!'
      },
    ],
    'Chthonic & Primordial Deities': [
      {
        'name': 'Hades',
        'desc': 'God of the underworld.',
        'img': 'hades.jpg',
        'background_img': 'uncroppedhades.jpg',
        'details': 'Hades had a three-headed dog named Cerberus guarding his gates—good luck sneaking past that guy.'
      },
      {
        'name': 'Persephone',
        'desc': 'Queen of the underworld, goddess of spring.',
        'img': 'persephone.jpg',
        'background_img': 'uncroppedpersephone.jpg',
        'details': 'Persephone ate six pomegranate seeds in the underworld—so she has to return each year, causing winter!'
      },
      {
        'name': 'Gaia',
        'desc': 'Primordial goddess of Earth.',
        'img': 'gaia.jpg',
        'background_img': 'uncroppedgaia.jpg',
        'details': 'Gaia was literally the Earth itself—talk about being grounded!'
      },
      {
        'name': 'Uranus',
        'desc': 'Primordial god of the sky.',
        'img': 'uranus.jpg',
        'background_img': 'uncroppedgaia.jpg',
        'details': 'Uranus was overthrown by his own son Cronus—family drama runs deep in the cosmos!'
      },
    ],
    'Titans': [
      {
        'name': 'Cronus',
        'desc': 'Leader of the Titans, god of time.',
        'img': 'cronus.jpg',
        'background_img': 'uncroppedcronus.jpg',
        'details': 'Cronus ate his own kids to stop them from overthrowing him... didn\'t work out.'
      },
      {
        'name': 'Rhea',
        'desc': 'Titaness of fertility and motherhood.',
        'img': 'rhea.jpg',
        'background_img': 'uncroppedrhea.jpg',
        'details': 'Rhea saved baby Zeus by tricking Cronus with a rock—classic switcheroo!'
      },
      {
        'name': 'Oceanus',
        'desc': 'Titan god of the ocean.',
        'img': 'oceanus.jpg',
        'background_img': 'uncroppedoceanus.jpg',
        'details': 'Oceanus was imagined as a giant river circling the Earth—not just a sea god, but a full-on water world.'
      },
      {
        'name': 'Hyperion',
        'desc': 'Titan of light.',
        'img': 'hyperion.jpg',
        'background_img': 'uncroppedhyperion.jpg',
        'details': 'Hyperion was the original light-bringer, fathering the sun, moon, and dawn like a cosmic family trio.'
      },
      {
        'name': 'Prometheus',
        'desc': 'Titan who gave fire to humanity.',
        'img': 'prometheus.jpg',
        'background_img': 'uncroppedprometheus.jpg',
        'details': 'Prometheus stole fire from the gods for humans and got chained to a rock for it—talk about a hot rebellion.'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/greekbg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "MYTHOLOGICAL FACTS",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: mythologicalData.length,
                  itemBuilder: (context, categoryIndex) {
                    final category = mythologicalData.keys.elementAt(categoryIndex);
                    final characters = mythologicalData[category]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ExpansionTile(
                        initiallyExpanded: categoryIndex == 0,
                        collapsedBackgroundColor: Colors.transparent,
                        backgroundColor: Colors.black.withOpacity(0.3),
                        iconColor: Colors.orange,
                        textColor: Colors.white,
                        tilePadding: EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: characters.length,
                            itemBuilder: (context, index) {
                              return _buildFactCard(characters[index], context);
                            },
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFactCard(Map<String, String> character, BuildContext context) {
    return GestureDetector(
      onTap: () => _showFactDetails(character, context),
      child: Hero(
        tag: 'fact-${character['name']}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'images/${character['img']}',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          character['name']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          character['desc']!,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'FUN FACT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFactDetails(Map<String, String> character, BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        reverseTransitionDuration: Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: FactDetailPage(character: character),
        ),
      ),
    );
  }
}

class FactDetailPage extends StatelessWidget {
  final Map<String, String> character;

  const FactDetailPage({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Full background image
          Positioned.fill(
            child: Image.asset(
              'images/${character['background_img']}',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),

                  // Circle avatar
                  Hero(
                    tag: 'fact-${character['name']}',
                    child: Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            )
                          ],
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'images/${character['img']}',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      character['name']!,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      character['desc']!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black,
                            offset: Offset(1, 1),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Colors.orange, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'FUN FACT',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          character['details']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int score = 0;
  bool quizEnded = false;
  Map<String, Color> optionColors = {};
  bool answerSelected = false;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Who is the king of the Greek gods?',
      'options': ['Zeus', 'Poseidon', 'Hades', 'Apollo'],
      'answer': 'Zeus',
    },
    {
      'question': 'Who is the goddess of wisdom and war strategy?',
      'options': ['Artemis', 'Athena', 'Hera', 'Aphrodite'],
      'answer': 'Athena',
    },
    {
      'question': 'Who is the god of the sea?',
      'options': ['Poseidon', 'Zeus', 'Hades', 'Apollo'],
      'answer': 'Poseidon',
    },
    {
      'question': 'Which god is known for his music and healing powers?',
      'options': ['Apollo', 'Hermes', 'Ares', 'Hephaestus'],
      'answer': 'Apollo',
    },
    {
      'question': 'Who is the goddess of the hunt and the moon?',
      'options': ['Artemis', 'Athena', 'Hera', 'Demeter'],
      'answer': 'Artemis',
    },
    {
      'question': 'Which goddess was born from the sea foam?',
      'options': ['Aphrodite', 'Hera', 'Athena', 'Persephone'],
      'answer': 'Aphrodite',
    },
    {
      'question': 'Who is the god of war?',
      'options': ['Ares', 'Zeus', 'Poseidon', 'Hades'],
      'answer': 'Ares',
    },
    {
      'question': 'Who is the goddess of agriculture and harvest?',
      'options': ['Demeter', 'Hestia', 'Persephone', 'Aphrodite'],
      'answer': 'Demeter',
    },
    {
      'question': 'Who is the god of fire and blacksmiths?',
      'options': ['Hephaestus', 'Apollo', 'Ares', 'Poseidon'],
      'answer': 'Hephaestus',
    },
    {
      'question': 'Which goddess is known for her role in marriage and family?',
      'options': ['Hera', 'Aphrodite', 'Athena', 'Demeter'],
      'answer': 'Hera',
    },
    {
      'question': 'Who is the god of the underworld?',
      'options': ['Hades', 'Zeus', 'Poseidon', 'Cronus'],
      'answer': 'Hades',
    },
    {
      'question': 'Who is the mother of Persephone?',
      'options': ['Demeter', 'Hestia', 'Gaia', 'Rhea'],
      'answer': 'Demeter',
    },
    {
      'question': 'Which Titan is known for giving fire to humanity?',
      'options': ['Prometheus', 'Cronus', 'Oceanus', 'Hyperion'],
      'answer': 'Prometheus',
    },
    {
      'question': 'Which primordial goddess is the personification of Earth?',
      'options': ['Gaia', 'Hera', 'Demeter', 'Persephone'],
      'answer': 'Gaia',
    },
    {
      'question': 'Which Titan is known as the god of time?',
      'options': ['Cronus', 'Hyperion', 'Oceanus', 'Rhea'],
      'answer': 'Cronus',
    },
    {
      'question': 'Who is the god of wine and festivity?',
      'options': ['Dionysus', 'Apollo', 'Ares', 'Zeus'],
      'answer': 'Dionysus',
    },
    {
      'question': 'Who is the queen of the underworld?',
      'options': ['Persephone', 'Hera', 'Athena', 'Demeter'],
      'answer': 'Persephone',
    },
    {
      'question': 'Who is the god of the sky and the father of the Titans?',
      'options': ['Uranus', 'Cronus', 'Zeus', 'Poseidon'],
      'answer': 'Uranus',
    },
    {
      'question': 'Who is the goddess of the hearth and home?',
      'options': ['Hestia', 'Hera', 'Athena', 'Demeter'],
      'answer': 'Hestia',
    },
    {
      'question': 'Which primordial god represents the sky?',
      'options': ['Uranus', 'Gaia', 'Chaos', 'Nyx'],
      'answer': 'Uranus',
    },
    {
      'question': 'Who was overthrown by his son, Zeus?',
      'options': ['Cronus', 'Hyperion', 'Oceanus', 'Rhea'],
      'answer': 'Cronus',
    },
    {
      'question': 'Who is the Titan of light?',
      'options': ['Hyperion', 'Prometheus', 'Oceanus', 'Cronus'],
      'answer': 'Hyperion',
    },
    {
      'question': 'Who is the god of prophecy and healing?',
      'options': ['Apollo', 'Hermes', 'Ares', 'Hephaestus'],
      'answer': 'Apollo',
    },
  ];

  void checkAnswer(String selected) {
    if (answerSelected) return;

    bool isCorrect = selected == questions[currentQuestion]['answer'];

    setState(() {
      answerSelected = true;
      if (isCorrect) {
        optionColors[selected] = Colors.green;
        score++;
      } else {
        optionColors[selected] = Colors.red;
        optionColors[questions[currentQuestion]['answer']] = Colors.green;
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.of(context).pop();
          if (currentQuestion < questions.length - 1) {
            Future.delayed(Duration(milliseconds: 300), () {
              goToNextQuestion();
            });
          } else {
            setState(() {
              quizEnded = true;
            });
          }
        });

        return Dialog(
          backgroundColor: isCorrect
              ? Colors.green.withOpacity(0.7)
              : Colors.red.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 60,
                ),
                SizedBox(height: 10),
                Text(
                  isCorrect ? "Correct!" : "Wrong!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isCorrect) SizedBox(height: 10),
                if (!isCorrect)
                  Text(
                    "Correct answer: ${questions[currentQuestion]['answer']}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void goToNextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        answerSelected = false;
        optionColors.clear();
      });
    } else {
      setState(() {
        quizEnded = true;
      });
    }
  }

  void resetQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      quizEnded = false;
      optionColors.clear();
      answerSelected = false;
    });
  }

  void goBackToMenu() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Leave Quiz?"),
                  content: Text("Your progress will be lost. Are you sure you want to go back?"),
                  actions: [
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text("Leave"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        title: Text("Quiz", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/quiz_background.JPG',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: quizEnded
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your Score: $score / ${questions.length}',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: resetQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: Text('Try Again'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: goBackToMenu,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: Text('Back to Menu'),
                      ),
                    ],
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
                      // Progress indicator
                      Text(
                        'Question ${currentQuestion + 1} of ${questions.length}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: (currentQuestion + 1) / questions.length,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                      SizedBox(height: 20),
                      Text(
                        questions[currentQuestion]['question'],
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      ...(questions[currentQuestion]['options'] as List<String>).map((option) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: optionColors[option] ?? Colors.white.withOpacity(0.9),
                              foregroundColor: optionColors.containsKey(option) ? Colors.white : Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              minimumSize: Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => checkAnswer(option),
                            child: Text(
                              option,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}