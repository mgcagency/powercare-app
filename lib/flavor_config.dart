enum Flavor {
  dev,
  prod,
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final String baseUrl;
  final String socketBaseUrl;

  static FlavorConfig? _instance;

  FlavorConfig._internal(this.flavor, this.name, this.baseUrl, this.socketBaseUrl);

  static void setFlavor(Flavor flavor, String name, String baseUrl, String socketBaseUrl) {
    _instance = FlavorConfig._internal(flavor, name, baseUrl, socketBaseUrl);
  }

  static FlavorConfig get instance {
    return _instance!;
  }

  static bool isDev() => _instance?.flavor == Flavor.dev;
  static bool isProd() => _instance?.flavor == Flavor.prod;
}
