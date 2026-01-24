class Event {
  final String title;
  final String location;
  final String distance;
  final String date;
  final String imageUrl;
  final String organizer;
  final String description;
  final String time;

  Event({
    required this.title,
    required this.location,
    required this.distance,
    required this.date,
    required this.imageUrl,
    required this.organizer,
    required this.description,
    required this.time,
  });
}

// Sample Data based on your mockups
final List<Event> mockEvents = [
  Event(
    title: "Majlis Jamuan Raya",
    location: "Masjid Al-Salah",
    distance: "~7 KM",
    date: "24-Oct-2021",
    imageUrl: "https://via.placeholder.com/400x200", // Replace with actual asset
    organizer: "Ali Bin Abu, Pegawai Masjid",
    description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry...",
    time: "10 A.M To 12 P.M.",
  ),
  Event(
    title: "Tadarrus Al-Quran",
    location: "Masjid Al-Amin",
    distance: "~7 KM",
    date: "24-Jan-2026",
    imageUrl: "https://via.placeholder.com/400x200",
    organizer: "Ustaz Ahmad",
    description: "Join us for a spiritual session of Quran recitation...",
    time: "After Maghrib",
  ),
];