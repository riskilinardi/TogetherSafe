// =============================================================================
// api_service.dart - Singapore Government API Integration
// Handles all API calls to Singapore government data sources to provide
// real-time emergency alerts and weather information.
//
// APIs Used:
// 1. NEA Weather Forecast (data.gov.sg)
//    - 2-hour weather forecast
//    - 24-hour weather forecast
//
// 2. NEA PSI Data (data.gov.sg)
//    - Real-time PSI readings
//    - Air temperature
//    - Rainfall data

// Location-based filtering function
// Alerts are filtered based on user's postal code to provide relevant,
// personalised emergency notifications.
// =============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'db.dart';

// =============================================================================
// API Service Class
// =============================================================================
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // data.gov.sg APIs
  static const String _baseUrl = 'https://api.data.gov.sg/v1';

  // ---------------------------------------------------------------------------
  // Location Mapping for Singapore Postal Codes
  // ---------------------------------------------------------------------------
  // Maps postal code prefixes to PSI regions (north, south, east, west, central)
  static const Map<String, String> _postalToRegion = {
    // Central region
    '01': 'central', '02': 'central', '03': 'central', '04': 'central',
    '05': 'central', '06': 'central', '07': 'central', '08': 'central',
    '09': 'central', '10': 'central', '11': 'central', '12': 'central',
    '13': 'central', '14': 'central', '15': 'central', '16': 'central',
    '17': 'central', '18': 'central', '19': 'central', '20': 'central',
    '21': 'central', '22': 'central', '23': 'central', '24': 'central',
    '25': 'central', '26': 'central', '27': 'central', '28': 'central',
    '29': 'central', '30': 'central', '31': 'central', '32': 'central',
    '33': 'central', '34': 'central', '35': 'central', '36': 'central',
    '37': 'central', '56': 'central', '57': 'central',
    // East region
    '38': 'east', '39': 'east', '40': 'east', '41': 'east',
    '42': 'east', '43': 'east', '44': 'east', '45': 'east',
    '46': 'east', '47': 'east', '48': 'east', '49': 'east',
    '50': 'east', '51': 'east', '52': 'east',
    '81': 'east', '82': 'east',
    // West region
    '58': 'west', '59': 'west',
    '60': 'west', '61': 'west', '62': 'west', '63': 'west', '64': 'west',
    '65': 'west', '66': 'west', '67': 'west', '68': 'west',
    '69': 'west', '70': 'west', '71': 'west',
    '72': 'west', '73': 'west',
    '53': 'north', '54': 'north', '55': 'north',
    '75': 'north', '76': 'north',
    '77': 'north', '78': 'north',
    '79': 'north', '80': 'north',
  };

  // Postal Code to Weather Area Mapping
  // Maps postal code prefixes to area names used in 2-hour weather forecast.
  // These match the area names returned by data.gov.sg weather API.
  static const Map<String, String> _postalToArea = {
    // Ang Mo Kio area
    '56': 'Ang Mo Kio',
    // Bishan area (57 shared with Ang Mo Kio, using Bishan)
    '57': 'Bishan',
    // Bedok area
    '46': 'Bedok', '47': 'Bedok',
    // Bukit Timah area
    '58': 'Bukit Timah', '59': 'Bukit Timah',
    // Changi area
    '49': 'Changi', '50': 'Changi',
    // Clementi area
    '12': 'Clementi',
    // Hougang area
    '53': 'Hougang',
    // Jurong East area
    '60': 'Jurong East',
    // Jurong West area
    '64': 'Jurong West', '65': 'Jurong West',
    // Pasir Ris area
    '51': 'Pasir Ris',
    // Tampines area (52 - using Tampines as primary)
    '52': 'Tampines',
    // Punggol area
    '82': 'Punggol',
    // Sembawang area
    '75': 'Sembawang',
    // Sengkang area
    '54': 'Sengkang', '55': 'Sengkang',
    // Woodlands area
    '73': 'Woodlands',
    // Yishun area (76 - using Yishun as primary)
    '76': 'Yishun',
    // Toa Payoh area
    '31': 'Toa Payoh',
  };

  // Flood-prone Postal Code Prefixes
  // Known flood-prone areas based on PUB data.
  static const List<String> _floodPronePostalPrefixes = [
    '58', '59', // Bukit Timah area
    '46', '47', // Bedok area
    '52', '53', // Tampines low-lying areas
    '72', '73', // Jurong low-lying areas
  ];

  // Get 2-Hour Weather Forecast
  // Returns the weather forecast for the next 2 hours for different areas
  // in Singapore. This is useful for immediate weather awareness.
  // API: https://api.data.gov.sg/v1/environment/2-hour-weather-forecast
  Future<WeatherForecast?> get2HourForecast() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/environment/2-hour-weather-forecast'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherForecast.from2Hour(data);
      } else {
        debugPrint('2-hour forecast error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Forecast error: $e');
      return null;
    }
  }

  // Get 24-Hour Weather Forecast
  // Returns the weather outlook for the next 24 hours including
  // temperature range and humidity levels.
  // API: https://api.data.gov.sg/v1/environment/24-hour-weather-forecast
  Future<WeatherForecast24Hour?> get24HourForecast() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/environment/24-hour-weather-forecast'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherForecast24Hour.fromJson(data);
      } else {
        debugPrint('24-hour forecast error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('24-hour forecast error: $e');
      return null;
    }
  }

  // Get PSI Data
  // Returns real-time PSI readings for different regions in Singapore.
  // PSI levels indicate air quality:
  // - 0-50: Good
  // - 51-100: Moderate
  // - 101-200: Unhealthy
  // - 201-300: Very Unhealthy
  // - 300+: Hazardous
  // API: https://api.data.gov.sg/v1/environment/psi
  Future<PsiData?> getPsiData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/environment/psi'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PsiData.fromJson(data);
      } else {
        debugPrint('PSI API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('PSI error: $e');
      return null;
    }
  }

  // Get Real-time Weather Readings
  // Returns current temperature readings from weather stations across Singapore.
  // API: https://api.data.gov.sg/v1/environment/air-temperature
  Future<double?> getCurrentTemperature() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/environment/air-temperature'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Get average temperature from all stations
        final readings = data['items']?[0]?['readings'] as List?;
        if (readings != null && readings.isNotEmpty) {
          double total = 0;
          for (var reading in readings) {
            total += (reading['value'] as num).toDouble();
          }
          return total / readings.length;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Temperature error: $e');
      return null;
    }
  }

  // Get Rainfall Data
  // Returns current rainfall readings. High rainfall may indicate flood risk.
  // API: https://api.data.gov.sg/v1/environment/rainfall
  Future<RainfallData?> getRainfallData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/environment/rainfall'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RainfallData.fromJson(data);
      } else {
        debugPrint('Rainfall API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Rainfall error: $e');
      return null;
    }
  }

  // Get All Environment Data (Combined)
  // Fetches all relevant environment data in parallel for efficiency.
  Future<EnvironmentData> getAllEnvironmentData() async {
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        get2HourForecast(),
        get24HourForecast(),
        getPsiData(),
        getCurrentTemperature(),
        getRainfallData(),
      ]);

      return EnvironmentData(
        forecast2Hour: results[0] as WeatherForecast?,
        forecast24Hour: results[1] as WeatherForecast24Hour?,
        psi: results[2] as PsiData?,
        temperature: results[3] as double?,
        rainfall: results[4] as RainfallData?,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error fetching environment data: $e');
      return EnvironmentData(lastUpdated: DateTime.now());
    }
  }

  // Get User's Region from Postal Code
  // Returns the PSI region (north, south, east, west, central) based on
  // the user's postal code prefix.
  String? _getRegionFromPostalCode(String? postalCode) {
    if (postalCode == null || postalCode.length < 2) return null;
    String prefix = postalCode.substring(0, 2);
    return _postalToRegion[prefix];
  }

  // Get User's Weather Area from Postal Code
  // Returns the weather forecast area name based on postal code prefix.
  String? _getAreaFromPostalCode(String? postalCode) {
    if (postalCode == null || postalCode.length < 2) return null;
    String prefix = postalCode.substring(0, 2);
    return _postalToArea[prefix];
  }

  // Check if User is in Flood-Prone Area
  // Returns true if user's postal code is in a known flood-prone area.
  bool _isInFloodProneArea(String? postalCode) {
    if (postalCode == null || postalCode.length < 2) return false;
    String prefix = postalCode.substring(0, 2);
    return _floodPronePostalPrefixes.contains(prefix);
  }

  // Check for Emergency Conditions (Location-Filtered)
  //
  // Analyzes current data to determine if emergency mode should be triggered.
  // Location filtering logic:
  // 1. PSI alerts: Check user's regional PSI, not just national average
  // 2. Rainfall alerts: Prioritize users in flood-prone postal codes
  // 3. Weather alerts: Check forecast for user's specific area
  //
  // Returns an EmergencyAlert if conditions warrant, null otherwise.
  Future<EmergencyAlert?> checkForEmergencies() async {
    final envData = await getAllEnvironmentData();

    // Get user's location data for filtering
    UserProfile? userProfile;
    try {
      userProfile = await DatabaseHelper.instance.getUserProfile();
    } catch (e) {
      debugPrint('Could not get user profile for location filtering: $e');
    }

    String? userPostalCode = userProfile?.postalCode;
    String? userRegion = _getRegionFromPostalCode(userPostalCode);
    String? userArea = _getAreaFromPostalCode(userPostalCode);
    bool isFloodProne = _isInFloodProneArea(userPostalCode);

    // 1. Check PSI levels (Location-filtered)
    // If user has location, check their regional PSI first.
    // Fall back to national PSI if regional data unavailable.
    if (envData.psi != null) {
      int psiToCheck = envData.psi!.nationalPsi;
      String locationLabel = 'Nationwide';

      // Try to get user's regional PSI for more accurate alert
      if (userRegion != null && envData.psi!.regionPsi.containsKey(userRegion)) {
        psiToCheck = envData.psi!.regionPsi[userRegion]!;
        locationLabel = '${userRegion[0].toUpperCase()}${userRegion.substring(1)} region';
      }

      if (psiToCheck >= 101) {
        String severity = 'Unhealthy';
        if (psiToCheck >= 201) severity = 'Very Unhealthy';
        if (psiToCheck >= 301) severity = 'Hazardous';

        return EmergencyAlert(
          type: 'HAZE ALERT',
          severity: severity,
          message: 'PSI has reached $psiToCheck ($severity level) in your area. '
              'Reduce outdoor activities and wear N95 mask if going outside.',
          location: locationLabel,
          issuedTime: DateTime.now(),
        );
      }
    }

    // 2. Check for heavy rainfall (Location-filtered)
    if (envData.rainfall != null) {
      double rainfallThreshold = isFloodProne ? 50.0 : 70.0;

      if (envData.rainfall!.maxRainfall >= rainfallThreshold) {
        String alertType = isFloodProne ? 'FLOOD WARNING' : 'HEAVY RAIN WARNING';
        String severityLevel = isFloodProne ? 'High' : 'Moderate';

        String message = isFloodProne
            ? 'Heavy rainfall detected (${envData.rainfall!.maxRainfall.toStringAsFixed(1)}mm). '
            'Your area is flood-prone. Move to higher ground if water levels rise. '
            'Avoid underground areas and low-lying roads.'
            : 'Heavy rainfall detected (${envData.rainfall!.maxRainfall.toStringAsFixed(1)}mm). '
            'Flash floods may occur in low-lying areas. Stay alert.';

        return EmergencyAlert(
          type: alertType,
          severity: severityLevel,
          message: message,
          location: envData.rainfall!.maxRainfallLocation,
          issuedTime: DateTime.now(),
        );
      }
    }

    // 3. Check weather forecast (Location-filtered)
    // Check user's specific area forecast if available.
    // Fall back to general forecast if area not found.
    if (envData.forecast2Hour != null) {
      String forecastToCheck = envData.forecast2Hour!.generalForecast.toLowerCase();
      String locationLabel = 'Various areas';

      // Try to find user's specific area forecast
      if (userArea != null) {
        for (var areaForecast in envData.forecast2Hour!.areaForecasts) {
          if (areaForecast.area.toLowerCase() == userArea.toLowerCase()) {
            forecastToCheck = areaForecast.forecast.toLowerCase();
            locationLabel = userArea;
            break;
          }
        }
      }

      if (forecastToCheck.contains('thundery') || forecastToCheck.contains('heavy rain')) {
        String severity = isFloodProne ? 'High' : 'Moderate';
        String extraWarning = isFloodProne
            ? ' Your area is flood-prone - prepare for possible flooding.'
            : '';

        return EmergencyAlert(
          type: 'WEATHER ALERT',
          severity: severity,
          message: 'Thunderstorms expected in $locationLabel. Stay indoors if possible and '
              'avoid open areas. Flash floods may occur.$extraWarning',
          location: locationLabel,
          issuedTime: DateTime.now(),
        );
      }
    }

    return null;
  }
}


// =============================================================================
// DATA MODELS
// =============================================================================

// Weather Forecast (2-Hour
class WeatherForecast {
  final String generalForecast;
  final List<AreaForecast> areaForecasts;
  final DateTime validFrom;
  final DateTime validTo;

  WeatherForecast({
    required this.generalForecast,
    required this.areaForecasts,
    required this.validFrom,
    required this.validTo,
  });

  factory WeatherForecast.from2Hour(Map<String, dynamic> json) {
    final items = json['items'] as List?;
    if (items == null || items.isEmpty) {
      return WeatherForecast(
        generalForecast: 'Data unavailable',
        areaForecasts: [],
        validFrom: DateTime.now(),
        validTo: DateTime.now(),
      );
    }

    final item = items[0];
    final forecasts = item['forecasts'] as List? ?? [];
    final validPeriod = item['valid_period'] ?? {};

    Map<String, int> forecastCounts = {};
    for (var f in forecasts) {
      String forecast = f['forecast'] ?? '';
      forecastCounts[forecast] = (forecastCounts[forecast] ?? 0) + 1;
    }
    String generalForecast = 'Fair';
    int maxCount = 0;
    forecastCounts.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        generalForecast = key;
      }
    });

    return WeatherForecast(
      generalForecast: generalForecast,
      areaForecasts: forecasts.map((f) => AreaForecast(
        area: f['area'] ?? '',
        forecast: f['forecast'] ?? '',
      )).toList(),
      validFrom: DateTime.tryParse(validPeriod['start'] ?? '') ?? DateTime.now(),
      validTo: DateTime.tryParse(validPeriod['end'] ?? '') ?? DateTime.now(),
    );
  }

  // Get weather icon based on forecast
  String get weatherIcon {
    final forecast = generalForecast.toLowerCase();
    if (forecast.contains('thundery') || forecast.contains('thunder')) return '⛈️';
    if (forecast.contains('heavy rain')) return '🌧️';
    if (forecast.contains('rain') || forecast.contains('showers')) return '🌦️';
    if (forecast.contains('cloudy')) return '☁️';
    if (forecast.contains('partly cloudy')) return '⛅';
    if (forecast.contains('fair') || forecast.contains('sunny')) return '☀️';
    if (forecast.contains('hazy')) return '🌫️';
    if (forecast.contains('windy')) return '💨';
    return '🌤️';
  }
}

class AreaForecast {
  final String area;
  final String forecast;

  AreaForecast({required this.area, required this.forecast});
}

// Weather Forecast (24-Hour)
class WeatherForecast24Hour {
  final String generalForecast;
  final int tempLow;
  final int tempHigh;
  final int humidityLow;
  final int humidityHigh;
  final String windSpeed;
  final String windDirection;

  WeatherForecast24Hour({
    required this.generalForecast,
    required this.tempLow,
    required this.tempHigh,
    required this.humidityLow,
    required this.humidityHigh,
    required this.windSpeed,
    required this.windDirection,
  });

  factory WeatherForecast24Hour.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List?;
    if (items == null || items.isEmpty) {
      return WeatherForecast24Hour(
        generalForecast: 'Data unavailable',
        tempLow: 0,
        tempHigh: 0,
        humidityLow: 0,
        humidityHigh: 0,
        windSpeed: '',
        windDirection: '',
      );
    }

    final item = items[0];
    final general = item['general'] ?? {};
    final temperature = general['temperature'] ?? {};
    final humidity = general['relative_humidity'] ?? {};
    final wind = general['wind'] ?? {};

    return WeatherForecast24Hour(
      generalForecast: general['forecast'] ?? 'Data unavailable',
      tempLow: temperature['low'] ?? 0,
      tempHigh: temperature['high'] ?? 0,
      humidityLow: humidity['low'] ?? 0,
      humidityHigh: humidity['high'] ?? 0,
      windSpeed: '${wind['speed']?['low'] ?? 0}-${wind['speed']?['high'] ?? 0} km/h',
      windDirection: wind['direction'] ?? '',
    );
  }
}

// PSI Data
class PsiData {
  final int nationalPsi;
  final int pm25;
  final Map<String, int> regionPsi; // PSI by region (north, south, east, west, central)
  final DateTime timestamp;

  PsiData({
    required this.nationalPsi,
    required this.pm25,
    required this.regionPsi,
    required this.timestamp,
  });

  factory PsiData.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List?;
    if (items == null || items.isEmpty) {
      return PsiData(
        nationalPsi: 0,
        pm25: 0,
        regionPsi: {},
        timestamp: DateTime.now(),
      );
    }

    final item = items[0];
    final readings = item['readings'] ?? {};

    // Get PSI (24-hour) reading
    final psi24h = readings['psi_twenty_four_hourly'] ?? {};
    int nationalPsi = psi24h['national'] ?? 0;

    // If national is 0, calculate average
    if (nationalPsi == 0) {
      List<int> values = [];
      psi24h.forEach((key, value) {
        if (value is int) values.add(value);
      });
      if (values.isNotEmpty) {
        nationalPsi = (values.reduce((a, b) => a + b) / values.length).round();
      }
    }

    // Get PM2.5 (use national or average)
    final pm25_1h = readings['pm25_one_hourly'] ?? {};
    int pm25 = pm25_1h['national'] ?? 0;
    if (pm25 == 0) {
      List<int> values = [];
      pm25_1h.forEach((key, value) {
        if (value is int) values.add(value);
      });
      if (values.isNotEmpty) {
        pm25 = (values.reduce((a, b) => a + b) / values.length).round();
      }
    }

    // Build region PSI map
    Map<String, int> regionPsi = {};
    psi24h.forEach((key, value) {
      if (key != 'national' && value is int) {
        regionPsi[key] = value;
      }
    });

    return PsiData(
      nationalPsi: nationalPsi,
      pm25: pm25,
      regionPsi: regionPsi,
      timestamp: DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  // Get PSI status text and color
  String get status {
    if (nationalPsi <= 50) return 'Good';
    if (nationalPsi <= 100) return 'Moderate';
    if (nationalPsi <= 200) return 'Unhealthy';
    if (nationalPsi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  int get statusColor {
    if (nationalPsi <= 50) return 0xFF4CAF50; // Green
    if (nationalPsi <= 100) return 0xFF2196F3; // Blue
    if (nationalPsi <= 200) return 0xFFFF9800; // Orange
    if (nationalPsi <= 300) return 0xFFF44336; // Red
    return 0xFF9C27B0; // Purple
  }
}

// Rainfall Data
class RainfallData {
  final double maxRainfall;
  final String maxRainfallLocation;
  final double averageRainfall;
  final int stationsWithRain;
  final DateTime timestamp;

  RainfallData({
    required this.maxRainfall,
    required this.maxRainfallLocation,
    required this.averageRainfall,
    required this.stationsWithRain,
    required this.timestamp,
  });

  factory RainfallData.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List?;
    final stations = json['metadata']?['stations'] as List? ?? [];

    if (items == null || items.isEmpty) {
      return RainfallData(
        maxRainfall: 0,
        maxRainfallLocation: '',
        averageRainfall: 0,
        stationsWithRain: 0,
        timestamp: DateTime.now(),
      );
    }

    final readings = items[0]['readings'] as List? ?? [];

    double maxRainfall = 0;
    String maxRainfallStationId = '';
    double totalRainfall = 0;
    int stationsWithRain = 0;

    for (var reading in readings) {
      double value = (reading['value'] as num?)?.toDouble() ?? 0;
      if (value > 0) {
        stationsWithRain++;
        totalRainfall += value;
        if (value > maxRainfall) {
          maxRainfall = value;
          maxRainfallStationId = reading['station_id'] ?? '';
        }
      }
    }

    // Find station name
    String maxRainfallLocation = maxRainfallStationId;
    for (var station in stations) {
      if (station['id'] == maxRainfallStationId) {
        maxRainfallLocation = station['name'] ?? maxRainfallStationId;
        break;
      }
    }

    return RainfallData(
      maxRainfall: maxRainfall,
      maxRainfallLocation: maxRainfallLocation,
      averageRainfall: readings.isNotEmpty ? totalRainfall / readings.length : 0,
      stationsWithRain: stationsWithRain,
      timestamp: DateTime.tryParse(items[0]['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  // Check if there's significant rainfall
  bool get hasSignificantRain => maxRainfall >= 10;
  bool get hasHeavyRain => maxRainfall >= 50;
}

// Combined Environment Data
class EnvironmentData {
  final WeatherForecast? forecast2Hour;
  final WeatherForecast24Hour? forecast24Hour;
  final PsiData? psi;
  final double? temperature;
  final RainfallData? rainfall;
  final DateTime lastUpdated;

  EnvironmentData({
    this.forecast2Hour,
    this.forecast24Hour,
    this.psi,
    this.temperature,
    this.rainfall,
    required this.lastUpdated,
  });

  bool get hasData =>
      forecast2Hour != null ||
          forecast24Hour != null ||
          psi != null ||
          temperature != null ||
          rainfall != null;
}

// Emergency Alert
class EmergencyAlert {
  final String type;
  final String severity;
  final String message;
  final String location;
  final DateTime issuedTime;

  EmergencyAlert({
    required this.type,
    required this.severity,
    required this.message,
    required this.location,
    required this.issuedTime,
  });

  String get formattedTime {
    return '${issuedTime.hour.toString().padLeft(2, '0')}:${issuedTime.minute.toString().padLeft(2, '0')}';
  }
}