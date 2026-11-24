/// Konfigurasi lokasi sekolah.
/// TODO: GANTI latitude/longitude dengan titik asli sekolah
/// (Google Maps -> tekan lama di gerbang sekolah -> salin koordinat).
class SchoolConfig {
  SchoolConfig._();

  static const name = 'SMK N 1 Bukateja';
  static const latitude = -7.426519689707962; // TODO: isi koordinat asli (nilai ini hanya perkiraan)
  static const longitude =  109.42312766716637; // TODO: isi koordinat asli
  static const radiusMeters = 150.0; // radius ditentukan sekolah (PRD 4.1)

  /// false = mode uji: jarak tetap ditampilkan tapi absen tidak diblokir.
  /// Ubah ke true setelah koordinat sekolah benar.
  static const enforceRadius = true;
}
