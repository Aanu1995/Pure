enum Flavor { dev, staging, prod }

class F {
  static late Flavor appFlavor;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Pure Dev';
      case Flavor.staging:
        return 'Pure Beta';
      case Flavor.prod:
        return 'Pure';
    }
  }

  static String get appId {
    switch (appFlavor) {
      case Flavor.dev:
        return 'com.annulus.pure.dev';
      case Flavor.staging:
        return 'com.annulus.pure.stg';
      case Flavor.prod:
        return 'com.annulus.pure';
    }
  }

  static String? get dynamicLinkUriPrefix {
    switch (appFlavor) {
      case Flavor.dev:
        return 'https://puredev.page.link';
      case Flavor.staging:
        return 'https://purebeta.page.link';
      case Flavor.prod:
        return 'https://pure.page.link';
    }
  }

  // only for IOS
  static String get appStoreId {
    switch (appFlavor) {
      case Flavor.dev:
        return '0123456789';
      case Flavor.staging:
        return '0123456789';
      case Flavor.prod:
        return '0123456789';
    }
  }
}
