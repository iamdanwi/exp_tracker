import 'package:exp_tracker/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _svgController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late AnimationController _backgroundController;

  late Animation<double> _svgScaleAnimation;
  late Animation<double> _svgRotationAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _subtitleOpacityAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonOpacityAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _svgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Initialize animations
    _svgScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _svgController, curve: Curves.elasticOut),
    );

    _svgRotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _svgController, curve: Curves.easeOutBack),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _subtitleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeIn),
      ),
    );

    _buttonScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.bounceOut),
    );

    _buttonOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeIn));

    _backgroundColorAnimation =
        ColorTween(begin: Colors.white, end: const Color(0xFFF8F9FA)).animate(
          CurvedAnimation(
            parent: _backgroundController,
            curve: Curves.easeInOut,
          ),
        );

    _startAnimations();
  }

  void _startAnimations() async {
    // Start background animation
    _backgroundController.forward();

    // Delay and start SVG animation
    await Future.delayed(const Duration(milliseconds: 300));
    _svgController.forward();

    // Delay and start text animations
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    // Delay and start button animation
    await Future.delayed(const Duration(milliseconds: 1000));
    _buttonController.forward();

    // Add a subtle continuous floating animation to SVG
    _addFloatingAnimation();
  }

  void _addFloatingAnimation() {
    _mainController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundColorAnimation,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundColorAnimation.value ?? Colors.white,
                  Colors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated SVG
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _svgScaleAnimation,
                            _svgRotationAnimation,
                            _mainController,
                          ]),
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _mainController.value * 10 - 5),
                              child: Transform.rotate(
                                angle: _svgRotationAnimation.value,
                                child: Transform.scale(
                                  scale: _svgScaleAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF58CC02,
                                          ).withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/images/onboarding.svg',
                                      height: 200,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Animated Content
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Title
                          SlideTransition(
                            position: _titleSlideAnimation,
                            child: FadeTransition(
                              opacity: _titleOpacityAnimation,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (0.2 * value),
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                            colors: [
                                              Color(0xFF58CC02),
                                              Color(0xFF4CAF50),
                                            ],
                                          ).createShader(bounds),
                                      child: const Text(
                                        "Track your expenses",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 32,
                                          letterSpacing: -0.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Animated Subtitle
                          SlideTransition(
                            position: _subtitleSlideAnimation,
                            child: FadeTransition(
                              opacity: _subtitleOpacityAnimation,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 1200),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, (1 - value) * 20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 15,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF58CC02,
                                            ).withOpacity(0.2),
                                          ),
                                        ),
                                        child: const Text(
                                          "Track your daily spending, understand your habits, and reach your financial aspirations effortlessly.",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            height: 1.5,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Animated Button
                          ScaleTransition(
                            scale: _buttonScaleAnimation,
                            child: FadeTransition(
                              opacity: _buttonOpacityAnimation,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      width: double.infinity,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF58CC02),
                                            Color(0xFF4CAF50),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF58CC02,
                                            ).withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          onTap: () => _navigateToHome(context),
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                TweenAnimationBuilder<double>(
                                                  tween: Tween(
                                                    begin: 0,
                                                    end: 1,
                                                  ),
                                                  duration: const Duration(
                                                    milliseconds: 1500,
                                                  ),
                                                  builder:
                                                      (
                                                        context,
                                                        iconValue,
                                                        child,
                                                      ) {
                                                        return Transform.translate(
                                                          offset: Offset(
                                                            (1 - iconValue) *
                                                                20,
                                                            0,
                                                          ),
                                                          child: const Text(
                                                            "LET'S BEGIN",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              letterSpacing:
                                                                  1.2,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                ),
                                                const SizedBox(width: 8),
                                                TweenAnimationBuilder<double>(
                                                  tween: Tween(
                                                    begin: 0,
                                                    end: 1,
                                                  ),
                                                  duration: const Duration(
                                                    milliseconds: 1000,
                                                  ),
                                                  curve: Curves.elasticOut,
                                                  builder:
                                                      (
                                                        context,
                                                        arrowValue,
                                                        child,
                                                      ) {
                                                        return Transform.translate(
                                                          offset: Offset(
                                                            (1 - arrowValue) *
                                                                30,
                                                            0,
                                                          ),
                                                          child: Transform.scale(
                                                            scale: arrowValue,
                                                            child: const Icon(
                                                              Icons
                                                                  .arrow_forward,
                                                              color:
                                                                  Colors.white,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Animated Progress Indicators
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 2000),
                        builder: (context, value, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              final delay = index * 0.3;
                              final animValue = (value - delay).clamp(0.0, 1.0);

                              return AnimatedContainer(
                                duration: Duration(
                                  milliseconds: 300 + (index * 100),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: index == 0 ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: index == 0
                                      ? Color(0xFF58CC02)
                                      : Color(0xFF58CC02).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                transform: Matrix4.identity()
                                  ..scale(animValue, animValue),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToHome(BuildContext context) async {
    // Add a button press animation before navigation
    await _buttonController.reverse();
    await _buttonController.forward();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _svgController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }
}
