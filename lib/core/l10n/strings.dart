class S {
  S._();

  // App
  static const String appName = 'Todoaw';
  static const String appTagline = 'Jadi lebih teratur';

  static const String settingsHapusData = 'Hapus Data';
  static const String settingsHapusDataKonfirmasi = 'Yakin hapus data?';
  static const String settingsHapusDataDeskripsi =
      'Semua tugas, catatan, kebiasaan, dan data lainnya akan dihapus permanen.';
  static const String settingsMuatContohKonfirmasi = 'Yakin muat contoh data?';
  static const String settingsMuatContohDeskripsi =
      'Data contoh akan ditambahkan ke data yang sudah ada.';
  static const String yaHapus = 'Ya, Hapus';
  static const String yaMuat = 'Ya, Muat';
  static const String settingsHapusContohData = 'Hapus Contoh Data';
  static const String settingsHapusContohKonfirmasi =
      'Yakin hapus contoh data?';
  static const String settingsHapusContohDeskripsi =
      'Hanya data contoh dari seeder yang akan dihapus. Data yang Anda buat sendiri tetap aman.';
  static const String settingsMuatContohData = 'Muat Contoh Data';
  static const String settingsDataContohBerhasil = 'Data contoh udah siap';

  static const String seedBerhasil = 'Contoh data berhasil ditambahkan';

  // Navigation
  static const String navBeranda = 'Beranda';
  static const String navKalender = 'Kalender';
  static const String navDashboard = 'Dashboard';
  static const String navCatatan = 'Catatan';
  static const String navPengaturan = 'Pengaturan';

  // Home
  static const String homeTugasHariIni = 'tugas hari ini';
  static const String homeSelesai = 'selesai';
  static const String homeTersisa = 'tersisa';
  static const String homeDaftarTugas = 'Daftar Tugas';
  static const String homeStreak = 'hari streak';
  static const String homeTidakAdaTugas = 'Hari ini santai?';
  static const String homeSemuaSelesai = 'Semua beres hari ini 🎉';
  static const String homeBuatTugasPertama = 'Yuk, bikin tugas pertama';

  // Quick Actions
  static const String quickTambahTugas = 'Tambah Tugas';
  static const String quickTambahCatatan = 'Tambah Catatan';
  static const String quickMulaiFokus = 'Mulai Fokus';
  static const String quickTambahKebiasaan = 'Tambah Kebiasaan';

  // Task
  static const String taskJudul = 'Judul';
  static const String taskJudulHint = 'Apa yang perlu dilakukan?';
  static const String taskJudulRequired = 'Judul wajib diisi';
  static const String taskDeskripsi = 'Deskripsi (opsional)';
  static const String taskDeskripsiHint = 'Tambahkan detail...';
  static const String taskPrioritas = 'Prioritas';
  static const String taskKategori = 'Kategori';
  static const String taskDeadline = 'Deadline';
  static const String taskUlangi = 'Ulangi';
  static const String taskPengingat = 'Pengingat';
  static const String taskEstimasi = 'Estimasi Waktu';
  static const String taskSubtask = 'Subtask';
  static const String taskTambahSubtask = 'Tambah subtask...';
  static const String taskArsipkan = 'Arsipkan';
  static const String taskHapus = 'Hapus Tugas';
  static const String taskSimpan = 'Simpan';
  static const String taskBatal = 'Batal';
  static const String taskSimpanSebagaiTemplate = 'Simpan sebagai Template';
  static const String taskDisimpanSebagaiTemplate = 'Disimpan sebagai template';

  static const String templatePilih = 'Pilih Template';
  static const String templateBelumAda = 'Belum ada template';
  static const String quickDariTemplate = 'Dari Template';

  static const String taskBaru = 'Tugas Baru';
  static const String taskEdit = 'Edit Tugas';
  static const String taskHariIni = 'Hari Ini';
  static const String taskBesok = 'Besok';
  static const String taskMingguIni = 'Minggu Ini';
  static const String taskTanpaTanggal = 'Tanpa Tanggal';
  static const String taskTidakBerulang = 'Tidak berulang';
  static const String taskPilihTanggal = 'Pilih tanggal';
  static const String taskTidakAdaKategori = 'Tanpa Kategori';

  // Priority
  static const String prioritasP1 = 'Urgent';
  static const String prioritasP2 = 'Tinggi';
  static const String prioritasP3 = 'Sedang';
  static const String prioritasP4 = 'Rendah';

  // Calendar
  static const String kalenderTitle = 'Kalender';
  static const String kalenderHariIni = 'Hari Ini';
  static const String kalenderTidakAdaTugas = 'Tidak ada tugas di hari ini';
  static const String kalenderTugasSelesai = 'tugas selesai';

  // Search
  static const String searchHint = 'Cari tugas...';
  static const String searchKetik = 'Ketik untuk mencari tugas';
  static const String searchTidakDitemukan = 'Tidak ada tugas untuk';
  static const String searchHasil = 'hasil untuk';

  // Filter
  static const String filterTitle = 'Filter';
  static const String filterReset = 'Reset';
  static const String filterStatus = 'Status';
  static const String filterPrioritas = 'Prioritas';
  static const String filterKategori = 'Kategori';
  static const String filterSemua = 'Semua';
  static const String filterTampilkanSelesai = 'Tampilkan selesai';
  static const String filterTampilkanArsip = 'Tampilkan arsip';
  static const String filterTerapkan = 'Terapkan';
  static const String filterTidakCocok = 'Tidak ada tugas yang cocok';
  static const String filterUbahFilter = 'Coba atur ulang filter';

  // Stats / Dashboard
  static const String dashboardTitle = 'Dashboard';
  static const String dashboardProgressHariIni = 'Progress Hari Ini';
  static const String dashboardProduktivitas = 'Produktivitas';
  static const String dashboardStatistik = 'Statistik';
  static const String dashboardKebiasaan = 'Kebiasaan';
  static const String dashboardTotalSelesai = 'Total Selesai';
  static const String dashboardTotalAktif = 'Total Aktif';
  static const String dashboardTotal = 'Total';
  static const String dashboardTargetMingguan = 'Target Mingguan';
  static const String dashboardJamFokus = 'Jam Fokus';
  static const String dashboardBelumAdaData = 'Belum ada data';
  static const String dashboardSelesaikanTugas =
      'Selesaikan tugas untuk melihat statistik';

  // Habit
  static const String habitTitle = 'Kebiasaan';
  static const String habitBaru = 'Kebiasaan Baru';
  static const String habitNama = 'Nama kebiasaan';
  static const String habitNamaHint = 'Contoh: Minum Air';
  static const String habitFrekuensi = 'Frekuensi';
  static const String habitTarget = 'Target Harian';
  static const String habitStreak = 'Streak';
  static const String habitStreakTerpanjang = 'Streak Terpanjang';
  static const String habitHariIni = 'Hari Ini';
  static const String habitKosong = 'Belum ada kebiasaan';
  static const String habitBuatPertama = 'Buat kebiasaan pertamamu';
  static const String habitLogTitle = 'Catatan Kebiasaan';
  static const String habitLogHint = 'Bagaimana harimu?';

  // Focus
  static const String focusTitle = 'Mode Fokus';
  static const String focusMulai = 'Mulai';
  static const String focusJeda = 'Jeda';
  static const String focusLanjutkan = 'Lanjutkan';
  static const String focusSelesai = 'Selesai';
  static const String focusSessionKe = 'Sesi ke-';
  static const String focusHariIni = 'hari ini';
  static const String focusTotal = 'Total';
  static const String focusMenit = 'menit';
  static const String focusTugasTerkait = 'Sedang mengerjakan';
  static const String focusPilihTugas = 'Pilih tugas';

  // Notes
  static const String notesTitle = 'Catatan';
  static const String notesBaru = 'Catatan Baru';
  static const String notesEdit = 'Edit Catatan';
  static const String notesTitleHint = 'Judul catatan';
  static const String notesContentHint = 'Mulai menulis...';
  static const String notesKosong = 'Belum ada catatan';
  static const String notesBuatPertama = 'Buat catatan pertamamu';
  static const String notesDisematkan = 'Disematkan';
  static const String notesPin = 'Sematkan';
  static const String notesLepasPin = 'Lepas sematan';
  static const String notesHapus = 'Hapus Catatan';
  static const String notesKonfirmasiHapus = 'Hapus catatan ini?';
  static const String notesKonfirmasiHapusDesc =
      'Catatan akan dipindahkan ke tempat sampah.';
  static const String notesSematkanDiForm = 'Sematkan';

  // Settings
  static const String settingsTitle = 'Pengaturan';
  static const String settingsTampilan = 'TAMPILAN';
  static const String settingsStiker = 'STIKER WIDGET';
  static const String settingsStikerNone = 'Tanpa Stiker';
  static const String settingsModeGelap = 'Mode Gelap';
  static const String settingsModeSystem = 'Sistem';
  static const String settingsModeLight = 'Terang';
  static const String settingsModeDark = 'Gelap';
  static const String settingsData = 'DATA';
  static const String settingsBackup = 'Backup Data';
  static const String settingsRestore = 'Pulihkan Data';
  static const String settingsExportJson = 'Export JSON';
  static const String settingsExportExcel = 'Export Excel';
  static const String settingsExportSqlite = 'Export SQLite';
  static const String settingsImport = 'Import Data';
  static const String settingsKategori = 'Kategori';
  static const String settingsTempatSampah = 'Tempat Sampah';
  static const String settingsTentang = 'TENTANG';
  static const String settingsVersi = 'Versi';
  static const String settingsLisensi = 'Lisensi MIT';

  // Trash
  static const String trashTitle = 'Tempat Sampah';
  static const String trashKosong = 'Tempat sampah kosong';
  static const String trashAutoDelete =
      'Tugas akan otomatis dihapus setelah 30 hari';
  static const String trashKembalikan = 'Kembalikan';
  static const String trashHapusPermanen = 'Hapus Permanen';
  static const String trashHapusSemua = 'Kosongkan Semua';
  static const String trashHariLagii = 'hari lagi';
  static const String trashAkanDihapus = 'Akan segera dihapus';
  static const String trashKonfirmasiHapus = 'Hapus permanen?';
  static const String trashKonfirmasiHapusDesc =
      'Tindakan ini tidak bisa dibatalkan.';
  static const String trashKonfirmasiKosongkan = 'Kosongkan tempat sampah?';
  static const String trashKonfirmasiKosongkanDesc =
      'Semua tugas akan dihapus permanen.';
  static const String trashBatal = 'Batal';
  static const String trashHapus = 'Hapus';
  static const String trashKosongkan = 'Kosongkan';

  // Category
  static const String categoryTitle = 'Kategori';
  static const String categoryBaru = 'Kategori baru';
  static const String categoryNama = 'Nama kategori';
  static const String categoryHapus = 'Hapus kategori?';
  static const String categoryHapusDesc =
      'Tugas dengan kategori ini akan kehilangan kategorinya.';
  static const String categoryKosong = 'Belum ada kategori';

  // General Actions
  static const String simpan = 'Simpan';
  static const String batal = 'Batal';
  static const String hapus = 'Hapus';
  static const String edit = 'Edit';
  static const String tambah = 'Tambah';
  static const String tutup = 'Tutup';
  static const String konfirmasi = 'Konfirmasi';
  static const String ya = 'Ya';
  static const String tidak = 'Tidak';
  static const String loading = 'Memuat...';
  static const String error = 'Terjadi kesalahan';
  static const String cobaLagi = 'Coba lagi';
  static const String kosong = 'Kosong';

  // Recurring
  static const String repeatTidakPernah = 'Tidak pernah';
  static const String repeatSetiapHari = 'Setiap Hari';
  static const String repeatSetiapMinggu = 'Setiap Minggu';
  static const String repeatSetiapBulan = 'Setiap Bulan';
  static const String repeatSetiapTahun = 'Setiap Tahun';
  static const String repeatHariKerja = 'Hari Kerja';
  static const String repeatCustom = 'Kustom';
  static const String repeatHapus = 'Hapus pengulangan';

  // Time
  static const String hariIni = 'Hari ini';
  static const String kemarin = 'Kemarin';
  static const String besok = 'Besok';
  static const String mingguLalu = 'Minggu lalu';
  static const String mingguDepan = 'Minggu depan';
  static const String bulanIni = 'Bulan ini';
  static const String bulanLalu = 'Bulan lalu';
  static const String bulanDepan = 'Bulan depan';

  // Empty states
  static const String emptyTidakAda = 'Tidak ada';
  static const String emptyCobaUbah = 'Coba ganti pencarian atau filter';

  // Pomodoro durations
  static const String fokus25 = '25 Menit';
  static const String fokus15 = '15 Menit';
  static const String fokus30 = '30 Menit';
  static const String fokus50 = '50 Menit';

  // Frequency
  static const String frekuensiHarian = 'Harian';
  static const String frekuensiMingguan = 'Mingguan';
  static const String frekuensiBulanan = 'Bulanan';
}
