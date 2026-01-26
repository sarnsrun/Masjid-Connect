import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerService {
  static const String _baseUrl = "https://www.e-solat.gov.my/index.php?r=esolatApi/TakwimSolat";

  /// Fetches prayer times from JAKIM based on the city name
  Future<List<Map<String, String>>> getPrayerTimes(String city) async {
    String zoneCode = _mapCityToZone(city);

    final url = Uri.parse("$_baseUrl&period=today&zone=$zoneCode");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Validate API Status
        if (data['status'] == 'OK!' && data['prayerTime'] != null) {
          final times = data['prayerTime'][0];

          return [
            {"name": "Fajr", "time": _cleanTime(times['fajr'])},
            {"name": "Syuruk", "time": _cleanTime(times['syuruk'])},
            {"name": "Dhuhr", "time": _cleanTime(times['dhuhr'])},
            {"name": "Asr", "time": _cleanTime(times['asr'])},
            {"name": "Maghrib", "time": _cleanTime(times['maghrib'])},
            {"name": "Isha", "time": _cleanTime(times['isha'])},
          ];
        } else {
          throw Exception("API Error: ${data['status'] ?? 'Unknown error'}");
        }
      } else {
        throw Exception("Failed to load prayer times (HTTP ${response.statusCode})");
      }
    } catch (e) {
      print("JAKIM API Error: $e");
      rethrow; 
    }
  }

  String _cleanTime(String fullTime) {
    if (fullTime.length >= 5) return fullTime.substring(0, 5);
    return fullTime;
  }

  /// Maps a city name to the correct JAKIM Zone Code
  String _mapCityToZone(String city) {
    String c = city.toLowerCase();

    // Iterate through the map to find a matching keyword
    for (var entry in _zoneMap.entries) {
      for (var keyword in entry.value) {
        if (c.contains(keyword)) {
          return entry.key;
        }
      }
    }

    // Default Fallback (Kuala Lumpur) if no match found
    return "WLY01"; 
  }

  static final Map<String, List<String>> _zoneMap = {
    // WILAYAH PERSEKUTUAN
    "WLY01": ["kuala lumpur", "putrajaya"],
    "WLY02": ["labuan"],

    // SELANGOR
    "SGR01": ["gombak", "petaling", "sepang", "hulu langat", "hulu selangor", "shah alam", "subang", "kajang", "bangi"],
    "SGR02": ["kuala selangor", "sabak bernam"],
    "SGR03": ["klang", "kuala langat"],

    // JOHOR
    "JHR01": ["pulau aur", "pulau pemanggil"],
    "JHR02": ["johor bahru", "kota tinggi", "mersing", "kulai", "iskandar puteri", "pasir gudang"],
    "JHR03": ["kluang", "pontian"],
    "JHR04": ["batu pahat", "muar", "segamat", "gemas", "tangkak"],

    // KEDAH
    "KDH01": ["kota setar", "kubang pasu", "pokok sena"],
    "KDH02": ["kuala muda", "yan", "pendang", "sungai petani"],
    "KDH03": ["padang terap", "sik"],
    "KDH04": ["baling"],
    "KDH05": ["bandar baharu", "kulim"],
    "KDH06": ["langkawi"],
    "KDH07": ["gunung jerai"],

    // KELANTAN
    "KTN01": ["bachok", "kota bharu", "machang", "pasir mas", "pasir puteh", "tanah merah", "tumpat", "kuala krai", "chiku"],
    "KTN03": ["gua musang", "galas", "bertam", "jeli"],

    // MELAKA
    "MLK01": ["melaka", "alor gajah", "jasin"],

    // NEGERI SEMBILAN
    "NGS01": ["tampin", "jempol"],
    "NGS02": ["jelebu", "kuala pilah", "port dickson", "rembau", "seremban", "nilai"],

    // PAHANG
    "PHG01": ["pulau tioman"],
    "PHG02": ["kuantan", "pekan", "rompin", "muadzam shah"],
    "PHG03": ["jerantut", "temerloh", "maran", "bera", "chenor", "jengka"],
    "PHG04": ["bentong", "lipis", "raub"],
    "PHG05": ["genting", "janda baik", "bukit tinggi"],
    "PHG06": ["cameron highlands", "bukit fraser"],

    // PERAK
    "PRK01": ["tapah", "slim river", "tanjung malim"],
    "PRK02": ["kuala kangsar", "sungai siput", "ipoh", "batu gajah", "kampar"],
    "PRK03": ["lenggong", "pengkalan hulu", "grik"],
    "PRK04": ["temengor", "belum"],
    "PRK05": ["kampung gajah", "teluk intan", "bagan datuk", "seri iskandar", "beruas", "parit", "lumut", "sitiawan", "pulau pangkor"],
    "PRK06": ["selama", "taiping", "bagan serai", "parit buntar"],
    "PRK07": ["bukit larut"],

    // PERLIS
    "PLS01": ["kangar", "padang besar", "arau"],

    // PULAU PINANG
    "PNG01": ["pulau pinang", "georgetown", "butterworth", "bukit mertajam", "nibong tebal"],

    // SABAH
    "SBH01": ["sandakan", "bukit garam", "semawang", "temanggong", "tambisan"],
    "SBH02": ["beluran", "telupid", "pinangah", "terusan", "kuamut"],
    "SBH03": ["lahad datu", "silabukan", "kunak", "sahabat", "semporna", "tungku"],
    "SBH04": ["tawau", "balong", "merotai", "kalabakan"],
    "SBH05": ["kudat", "kota marudu", "pitas", "pulau banggi"],
    "SBH06": ["gunung kinabalu"],
    "SBH07": ["kota kinabalu", "ranau", "kota belud", "tuaran", "penampang", "papar", "putatan"],
    "SBH08": ["pensiangan", "keningau", "tambunan", "nabawan"],
    "SBH09": ["beaufort", "kuala penyu", "sipitang", "tenom", "long pa sia", "membakut", "weston"],

    // SARAWAK
    "SWK01": ["limbang", "lawas", "sundar", "trusan"],
    "SWK02": ["miri", "niah", "bekenu", "sibuti", "marudi"],
    "SWK03": ["pandan", "belaga", "suai", "tatau", "sebauh", "bintulu"],
    "SWK04": ["sibu", "mukah", "dalat", "song", "igan", "oya", "balingian", "kanowit", "kapit"],
    "SWK05": ["sarikei", "matu", "julau", "rajang", "daro", "bintangor", "belawai"],
    "SWK06": ["lubok antu", "sri aman", "roban", "debak", "kabong", "lingga", "engkelili", "betong", "spaoh", "pusa", "saratok"],
    "SWK07": ["serian", "simunjan", "samarahan", "sebuyau", "meludam"],
    "SWK08": ["kuching", "bau", "lundu", "sematan"],
    "SWK09": ["kampung patarikan"],

    // TERENGGANU
    "TRG01": ["kuala terengganu", "marang", "kuala nerus"],
    "TRG02": ["besut", "setiu"],
    "TRG03": ["hulu terengganu"],
    "TRG04": ["dungun", "kemaman"],
  };
}