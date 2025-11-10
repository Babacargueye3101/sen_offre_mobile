class City {
  final int id;
  final String countryCode;
  final String name;
  final double latitude;
  final double longitude;
  final String? subadmin1Code;
  final String? subadmin2Code;
  final int population;
  final String timeZone;
  final bool active;
  final int postsCount;

  City({
    required this.id,
    required this.countryCode,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.subadmin1Code,
    this.subadmin2Code,
    required this.population,
    required this.timeZone,
    required this.active,
    required this.postsCount,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? 0,
      countryCode: json['country_code'] ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      subadmin1Code: json['subadmin1_code'],
      subadmin2Code: json['subadmin2_code'],
      population: json['population'] ?? 0,
      timeZone: json['time_zone'] ?? '',
      active: json['active'] == 1 || json['active'] == true,
      postsCount: json['posts_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country_code': countryCode,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'subadmin1_code': subadmin1Code,
      'subadmin2_code': subadmin2Code,
      'population': population,
      'time_zone': timeZone,
      'active': active,
      'posts_count': postsCount,
    };
  }
}

class CityResponse {
  final bool success;
  final String? message;
  final CityResult result;

  CityResponse({
    required this.success,
    this.message,
    required this.result,
  });

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
      success: json['success'] ?? false,
      message: json['message'],
      result: CityResult.fromJson(json['result'] ?? {}),
    );
  }
}

class CityResult {
  final List<City> data;

  CityResult({
    required this.data,
  });

  factory CityResult.fromJson(Map<String, dynamic> json) {
    return CityResult(
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => City.fromJson(item))
          .toList() ?? [],
    );
  }
}
