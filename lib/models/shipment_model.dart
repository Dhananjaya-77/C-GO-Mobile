enum ShipmentStatus {
  initialized,
  inTransit,
  atCheckpoint,
  tamperAlert,
  completed,
}

class CheckpointMilestone {
  final String title;
  final String locationName;
  final String time;
  final bool isCompleted;
  final bool isCurrent;
  final String? inspectorNote;

  const CheckpointMilestone({
    required this.title,
    required this.locationName,
    required this.time,
    this.isCompleted = false,
    this.isCurrent = false,
    this.inspectorNote,
  });
}

class ShipmentInfo {
  final String cusDecNumber;
  final String billOfLading;
  final String containerNumber;
  final String vehiclePlate;
  final String driverName;
  final String inspectorName;
  final String cargoDescription;
  final String cargoCategory;
  final String declaredValueLkr;
  final double cargoWeightKg;
  final String origin;
  final String destination;
  final String corridorName;
  final double totalDistanceKm;
  final double coveredDistanceKm;
  final int etaMinutes;
  final ShipmentStatus status;
  final List<CheckpointMilestone> milestones;

  const ShipmentInfo({
    required this.cusDecNumber,
    required this.billOfLading,
    required this.containerNumber,
    required this.vehiclePlate,
    required this.driverName,
    required this.inspectorName,
    required this.cargoDescription,
    required this.cargoCategory,
    required this.declaredValueLkr,
    required this.cargoWeightKg,
    required this.origin,
    required this.destination,
    required this.corridorName,
    required this.totalDistanceKm,
    required this.coveredDistanceKm,
    required this.etaMinutes,
    required this.status,
    required this.milestones,
  });

  double get progressPercentage =>
      totalDistanceKm > 0 ? (coveredDistanceKm / totalDistanceKm).clamp(0.0, 1.0) : 0.0;

  double get remainingDistanceKm =>
      (totalDistanceKm - coveredDistanceKm).clamp(0.0, totalDistanceKm);

  String get smartLockId => 'SL-RFID-99214';

  ShipmentInfo copyWith({
    String? cusDecNumber,
    String? billOfLading,
    String? containerNumber,
    String? vehiclePlate,
    String? driverName,
    String? inspectorName,
    String? cargoDescription,
    String? cargoCategory,
    String? declaredValueLkr,
    double? cargoWeightKg,
    String? origin,
    String? destination,
    String? corridorName,
    double? totalDistanceKm,
    double? coveredDistanceKm,
    int? etaMinutes,
    ShipmentStatus? status,
    List<CheckpointMilestone>? milestones,
  }) {
    return ShipmentInfo(
      cusDecNumber: cusDecNumber ?? this.cusDecNumber,
      billOfLading: billOfLading ?? this.billOfLading,
      containerNumber: containerNumber ?? this.containerNumber,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      driverName: driverName ?? this.driverName,
      inspectorName: inspectorName ?? this.inspectorName,
      cargoDescription: cargoDescription ?? this.cargoDescription,
      cargoCategory: cargoCategory ?? this.cargoCategory,
      declaredValueLkr: declaredValueLkr ?? this.declaredValueLkr,
      cargoWeightKg: cargoWeightKg ?? this.cargoWeightKg,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      corridorName: corridorName ?? this.corridorName,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      coveredDistanceKm: coveredDistanceKm ?? this.coveredDistanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      status: status ?? this.status,
      milestones: milestones ?? this.milestones,
    );
  }

  static ShipmentInfo mockActiveShipment = const ShipmentInfo(
    cusDecNumber: 'CD-2026-COL-0842',
    billOfLading: 'BL-MSK-90284192',
    containerNumber: 'MSCU-742910-8',
    vehiclePlate: 'WP LY-4821',
    driverName: 'Kasun Perera',
    inspectorName: 'Insp. Kamal Wickramasinghe',
    cargoDescription: 'High-Grade Ceylon Black Tea & Export Apparel',
    cargoCategory: 'Export Commodities (High Value)',
    declaredValueLkr: 'LKR 48,500,000',
    cargoWeightKg: 24500.0,
    origin: 'Colombo Fort',
    destination: 'Orugodawaththa',
    corridorName: 'Colombo Fort to Orugodawaththa',
    totalDistanceKm: 6.8,
    coveredDistanceKm: 3.5,
    etaMinutes: 18,
    status: ShipmentStatus.inTransit,
    milestones: [
      CheckpointMilestone(
        title: 'Shipment Initialization & Arming',
        locationName: 'Colombo Fort Gate 4',
        time: '08:30 AM',
        isCompleted: true,
        inspectorNote: 'Smart Lock SL-RFID-99214 armed by Insp. Kamal. Door seal verified.',
      ),
      CheckpointMilestone(
        title: 'Port Exit & Corridor Verification',
        locationName: 'Colombo Fort Exit Gate',
        time: '08:45 AM',
        isCompleted: true,
        inspectorNote: 'Geofence corridor active. GPS telemetry lock confirmed.',
      ),
      CheckpointMilestone(
        title: 'Port Access Highway Corridor',
        locationName: 'Port Access Highway Junction',
        time: '09:05 AM',
        isCompleted: true,
        inspectorNote: 'Corridor boundary compliant (buffer 50m). Speed 42 km/h.',
      ),
      CheckpointMilestone(
        title: 'Ingurukade Transit Sector',
        locationName: 'Ingurukade Junction',
        time: '09:18 AM',
        isCompleted: false,
        isCurrent: true,
      ),
      CheckpointMilestone(
        title: 'Destination ICD Checkpoint & Disarm',
        locationName: 'Orugodawaththa ICD Gate 1',
        time: '09:35 AM (ETA)',
        isCompleted: false,
        isCurrent: false,
        inspectorNote: 'Pending arrival & 6-digit disarm authentication.',
      ),
    ],
  );
}
