import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../blocs/onboarding_cubit.dart';
import '../../../model/onboarding.dart';
import 'onboading_body.dart';
import 'widgets/action_buttons.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late PageController _pageController;
  ValueNotifier<int> _currentIndexNotifier = ValueNotifier(0);

  List<OnBoardingModel> slides = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    slides = OnBoardingModel.onboardingSlides(isDark).toList();

    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: ValueListenableBuilder<int>(
        valueListenable: _currentIndexNotifier,
        builder: (context, currentIndex, _) {
          return Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => _currentIndexNotifier.value = index,
                  children: slides.map((slide) {
                    return OnBoardingBody(
                      title: slide.title,
                      image: slide.image,
                      subTitle: slide.subTitle,
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: currentIndex == 0
                            ? SkipButton(onPressed: getStarted)
                            : PrevButton(onPressed: () => prev(currentIndex)),
                      ),
                    ),
                    // indicators
                    Expanded(
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: slides.length,
                          effect: WormEffect(
                            activeDotColor:
                                Theme.of(context).colorScheme.primaryVariant,
                            dotWidth: 10,
                            dotHeight: 10,
                            dotColor: Theme.of(context)
                                .colorScheme
                                .primaryVariant
                                .withOpacity(0.24),
                          ),
                        ),
                      ),
                    ),
                    // Forward Button
                    SizedBox(
                      width: 150,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: currentIndex == (slides.length - 1)
                            ? GetStartedButton(onPressed: getStarted)
                            : NextButton(onPressed: () => next(currentIndex)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void next(int currentIndex) {
    if (currentIndex != slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }
  }

  void prev(int currentIndex) {
    if (currentIndex != 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }
  }

  void getStarted() {
    BlocProvider.of<OnBoardingCubit>(context).setOnBoardingStatus();
  }
}
