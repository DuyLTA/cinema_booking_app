import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      imagePath: ImageConstant.imgOnboardingTheater,
      title: 'PREMIERE ACCESS',
      description:
          'Step into a world where every screening is an event. Experience cinema the way it was meant to be seen.',
    ),
    _OnboardingSlide(
      imagePath: ImageConstant.imgOnboardingSeats,
      title: 'CHOOSE YOUR SEAT',
      description:
          'Find the perfect view, reserve your spot, and make every movie night feel effortless.',
    ),
    _OnboardingSlide(
      imagePath: ImageConstant.imgOnboardingConcessions,
      title: 'CINEMA MOMENTS',
      description:
          'Pair every ticket with offers, combos, and the little rituals that make the show unforgettable.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _continueToApp() async {
    final navigator = Navigator.of(context);
    final authProvider = context.read<AuthProvider>();

    await authProvider.checkSession();
    if (!mounted) return;

    navigator.pushReplacementNamed(
      authProvider.isLoggedIn
          ? AppRoutes.cinemaHomeScreen
          : AppRoutes.cinemaLoginScreen,
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.cinemaLoginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.black_900,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _OnboardingSlideView(slide: _slides[index]);
            },
          ),
          Positioned(
            top: 22.h,
            right: 20.h,
            child: SafeArea(
              child: GestureDetector(
                onTap: _continueToApp,
                child: Padding(
                  padding: EdgeInsets.all(8.h),
                  child: Text(
                    'SKIP',
                    style: TextStyleHelper.instance.label10RegularBebasNeue
                        .copyWith(
                          color: appTheme.gray_300,
                          fontSize: 12.fSize,
                          letterSpacing: 1.2,
                        ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16.h,
            right: 16.h,
            bottom: 26.h,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDots(),
                  SizedBox(height: 20.h),
                  _buildGetStartedButton(),
                  SizedBox(height: 19.h),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: isActive ? 7.h : 5.h,
          height: isActive ? 7.h : 5.h,
          margin: EdgeInsets.symmetric(horizontal: 3.h),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? appTheme.bookRedBorder : appTheme.gray_500,
          ),
        );
      }),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 58.h,
      child: ElevatedButton(
        onPressed: _continueToApp,
        style: ElevatedButton.styleFrom(
          backgroundColor: appTheme.bookRedDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.h),
          ),
        ),
        child: Text(
          'GET STARTED',
          style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
            color: Colors.white,
            fontSize: 22.fSize,
            letterSpacing: 2,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: _goToLogin,
      child: RichText(
        text: TextSpan(
          style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
            color: appTheme.gray_500,
            fontSize: 12.fSize,
            letterSpacing: 1,
          ),
          children: [
            const TextSpan(text: 'ALREADY A MEMBER? '),
            TextSpan(
              text: 'LOG IN',
              style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
                color: appTheme.orange_100,
                fontSize: 12.fSize,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlideView extends StatelessWidget {
  const _OnboardingSlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          slide.imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                appTheme.black_900.withValues(alpha: 0.1),
                appTheme.black_900.withValues(alpha: 0.08),
                appTheme.black_900.withValues(alpha: 0.72),
                appTheme.black_900.withValues(alpha: 0.98),
              ],
              stops: const [0.0, 0.38, 0.68, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 20.h,
          right: 20.h,
          bottom: 170.h,
          child: Column(
            children: [
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.display48RegularBebasNeue
                    .copyWith(
                      color: const Color(0xFFFFD21E),
                      fontSize: 37.fSize,
                      letterSpacing: 1.2,
                      height: 1,
                    ),
              ),
              SizedBox(height: 18.h),
              Text(
                slide.description,
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                  color: appTheme.gray_300,
                  fontSize: 16.fSize,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  final String imagePath;
  final String title;
  final String description;
}
