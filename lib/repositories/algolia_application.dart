import 'package:algolia/algolia.dart';

import '../utils/flavors.dart';

class AlgoliaApplication {
  static Algolia get algolia {
    switch (F.appFlavor) {
      case Flavor.prod:
        return Algolia.init(
          applicationId: '008HWZTMCQ',
          apiKey: 'f0a0ebe81ded9c39aefe9666ec3e81f6',
        );
      case Flavor.staging:
        return Algolia.init(
          applicationId: 'EOKG5FZ08Q',
          apiKey: '2c8b4ea038196af30f8c8539fb15501d',
        );
      default:
        return Algolia.init(
          applicationId: 'R0547NV5EC',
          apiKey: '536c516e3a6d13732b71017fa635dcfa',
        );
    }
  }
}
