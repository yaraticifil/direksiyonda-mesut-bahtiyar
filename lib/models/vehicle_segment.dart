/// Araç Segmenti
enum VehicleSegment {
  standard,  // ×1.0
  wide,      // ×1.2 (Geniş)
  luxury,    // ×1.5 (Lüks)
}

/// Segment katsayıları ve açılış bedelleri
class SegmentConfig {
  final double multiplier;
  final double openingFee;
  final String label;
  final String icon;

  const SegmentConfig({
    required this.multiplier,
    required this.openingFee,
    required this.label,
    required this.icon,
  });

  static const configs = {
    VehicleSegment.standard: SegmentConfig(
      multiplier: 1.0,
      openingFee: 100.0,
      label: 'Standart',
      icon: '🚗',
    ),
    VehicleSegment.wide: SegmentConfig(
      multiplier: 1.2,
      openingFee: 120.0,
      label: 'Geniş',
      icon: '🚙',
    ),
    VehicleSegment.luxury: SegmentConfig(
      multiplier: 1.5,
      openingFee: 150.0,
      label: 'Lüks',
      icon: '🏎️',
    ),
  };

  static SegmentConfig get(VehicleSegment segment) =>
      configs[segment] ?? configs[VehicleSegment.standard]!;
}
