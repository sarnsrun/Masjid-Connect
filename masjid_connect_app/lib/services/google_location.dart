import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GoogleLocationService {
  
  // Get key from .env file
  String get _apiKey => dotenv.env['GOOGLE_API_KEY'] ?? "";

  /// Returns: { "address": ..., "city": ..., "state": ..., "mosqueName": ... }
  Future<Map<String, String>> getCurrentLocation() async {
    if (_apiKey.isEmpty) {
      throw Exception("GOOGLE_API_KEY not found in .env file");
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Location services disabled");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception("Location permission denied");
    }
    if (permission == LocationPermission.deniedForever) throw Exception("Location permissions permanently denied");

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    final results = await Future.wait([
      _fetchAddressFromGoogle(position.latitude, position.longitude),
      _fetchNearestMosque(position.latitude, position.longitude)
    ]);

    final addressData = results[0];
    final mosqueName = results[1]["mosqueName"]!;

    return {
      "address": addressData["address"]!,
      "city": addressData["city"]!,
      "state": addressData["state"]!,
      "mosqueName": mosqueName
    };
  }

  Future<Map<String, String>> _fetchAddressFromGoogle(double lat, double lng) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_apiKey"
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "OK" && data["results"].isNotEmpty) {
          
          List<dynamic> components = data["results"][0]["address_components"];
          String city = "";
          String state = "";

          for (var c in components) {
            List<dynamic> types = c["types"];
            if (types.contains("locality")) {
              city = c["long_name"];
            } else if (city.isEmpty && types.contains("administrative_area_level_2")) {
              city = c["long_name"];
            }
            if (types.contains("administrative_area_level_1")) {
              state = c["long_name"];
            }
          }

          return {
            "address": "$city, $state",
            "city": city,
            "state": state
          };
        }
      }
    } catch (e) {
      print("Google Geocoding API Error: $e");
    }

    return {
      "address": "Unknown Location",
      "city": "Kuala Lumpur",
      "state": "Wilayah Persekutuan"
    };
  }

  Future<Map<String, String>> _fetchNearestMosque(double lat, double lng) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&keyword=masjid&rankby=distance&key=$_apiKey"
    );
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data["status"] == "OK" && data["results"].isNotEmpty) {
          String name = data["results"][0]["name"];
          return {"mosqueName": name};
        }
      }
    } catch (e) {
      print("Google Places API Error: $e");
    }
    return {"mosqueName": "Nearby Mosque"};
  }

  // --- NEW: SEARCH MOSQUES (RETURNS MAP) ---
  Future<List<Map<String, String>>> searchMosques(String query) async {
    if (_apiKey.isEmpty) return [];

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/textsearch/json?query=masjid+$query&key=$_apiKey"
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data["status"] == "OK" && data["results"] != null) {
          // Map to a list of Dictionaries containing Name, ID, and Address
          return List<Map<String, String>>.from(data["results"].map((item) => {
            "name": item["name"].toString(),
            "id": item["place_id"].toString(),
            "address": item["formatted_address"].toString()
          }));
        }
      }
    } catch (e) {
      print("Google Places Search Error: $e");
    }
    return [];
  }
}