class InvoiceNumbering {
  static String format(String prefix, int sequence) =>
      '${prefix.trim().isEmpty ? 'INV' : prefix.trim().toUpperCase()}-${sequence.toString().padLeft(4, '0')}';
}

String todayIso() {
  final now = DateTime.now();
  return _iso(now);
}

String isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _iso(DateTime d) => isoDate(d);

DateTime? parseIso(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

DateTime dateTimeFor(String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed != null) return parsed;
  final now = DateTime.now();
  if (iso.length >= 10) {
    final parts = iso.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]) ?? now.year;
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2].split(' ').first);
      if (m != null && d != null) return DateTime(y, m, d);
    }
  }
  return DateTime(now.year, now.month, now.day);
}

String displayDate(String? iso) {
  final parsed = parseIso(iso);
  if (parsed == null) return iso ?? '';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
}

String humanTime(String? iso) {
  final parsed = parseIso(iso);
  if (parsed == null) return iso ?? '';
  final h = parsed.hour.toString().padLeft(2, '0');
  final m = parsed.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String timestampNow() {
  final now = DateTime.now();
  final date = isoDate(now);
  final h = now.hour.toString().padLeft(2, '0');
  final m = now.minute.toString().padLeft(2, '0');
  final s = now.second.toString().padLeft(2, '0');
  return '$date $h:$m:$s';
}