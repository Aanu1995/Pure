import '../utils/image_utils.dart';

class OnBoardingModel {
  const OnBoardingModel(this.image, this.title, this.subTitle);

  final String image;
  final String title;
  final String subTitle;

  static List<OnBoardingModel> onboardingSlides(bool isDark) {
    return [
      OnBoardingModel(
        isDark ? ImageUtils.slide1Dark : ImageUtils.slide1Light,
        'Chat and communicate',
        'Communicate with your friends and find new ones based on common interests',
      ),
      OnBoardingModel(
        isDark ? ImageUtils.slide2Dark : ImageUtils.slide2Light,
        'Smartphone or a laptop',
        'Stay up to date with all events, using any device convenient for '
            'you - we are multiplatform!',
      ),
      OnBoardingModel(
        isDark ? ImageUtils.slide3Dark : ImageUtils.slide3Light,
        'Content that you’ll like',
        'Enjoy the content that we select just for you, based on your interests '
            'and hobbies, so as not to make you sad!',
      )
    ];
  }
}
