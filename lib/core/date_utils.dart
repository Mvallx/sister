const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

String two(int n) => n.toString().padLeft(2, '0');
String dayName(DateTime d) => _days[d.weekday - 1];
String monthName(int m) => _months[m - 1];
String monthShort(int m) => _months[m - 1].substring(0, 3);
String fullDate(DateTime d) =>
    '${dayName(d)}, ${d.day} ${monthName(d.month)} ${d.year}';
String shortDate(DateTime d) => '${d.day} ${monthShort(d.month)} ${d.year}';
String hm(DateTime d) => '${two(d.hour)}.${two(d.minute)}';
String dateKey(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
