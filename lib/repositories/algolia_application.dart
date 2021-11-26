import 'package:algolia/algolia.dart';

import '../utils/flavors.dart';

class AlgoliaApplication {
  static Algolia get algolia {
    switch (F.appFlavor) {
      case Flavor.prod:
        return Algolia.init(
          applicationId: '',
          apiKey: '',
        );
      case Flavor.staging:
        return Algolia.init(
          applicationId: '',
          apiKey: '',
        );
      default:
        return Algolia.init(
          applicationId: '',
          apiKey: '',
        );
    }
  }
}
