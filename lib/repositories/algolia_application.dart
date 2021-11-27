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
          applicationId: 'R0547NV5EC',
          apiKey: '536c516e3a6d13732b71017fa635dcfa',
        );
    }
  }
}
