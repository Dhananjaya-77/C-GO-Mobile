enum TripStatus {
  scheduled,
  inProgress,
  paused,
  completed,
}

class RouteStop {
  final String name;
  final String scheduledTime;
  final bool isCompleted;
  final bool isCurrent;
  final String? checkpointNote;

  const RouteStop({
    required this.name,
    required this.scheduledTime,
    this.isCompleted = false,
    this.isCurrent = false,
    this.checkpointNote,
  });
}

class TripInfo {
  final String id;
  final String routeNumber;
  final String routeName;
  final String origin;
  final String destination;
  final String containerNumber;
  final String rfidLockId;
  final int currentSpeedKmH;
  final int speedLimitKmH;
  final double totalDistanceKm;
  final double coveredDistanceKm;
  final String nextStop;
  final double nextStopDistanceKm;
  final int nextStopEtaMinutes;
  final int safetyScore;
  final TripStatus status;
  final List<RouteStop> stops;

  const TripInfo({
    required this.id,
    required this.routeNumber,
    required this.routeName,
    required this.origin,
    required this.destination,
    required this.containerNumber,
    required this.rfidLockId,
    required this.currentSpeedKmH,
    required this.speedLimitKmH,
    required this.totalDistanceKm,
    required this.coveredDistanceKm,
    required this.nextStop,
    required this.nextStopDistanceKm,
    required this.nextStopEtaMinutes,
    required this.safetyScore,
    required this.status,
    required this.stops,
  });

  double get progressPercentage =>
      totalDistanceKm > 0 ? (coveredDistanceKm / totalDistanceKm).clamp(0.0, 1.0) : 0.0;

  String get containerId => containerNumber;

  TripInfo copyWith({
    String? id,
    String? routeNumber,
    String? routeName,
    String? origin,
    String? destination,
    String? containerNumber,
    String? rfidLockId,
    int? currentSpeedKmH,
    int? speedLimitKmH,
    double? totalDistanceKm,
    double? coveredDistanceKm,
    String? nextStop,
    double? nextStopDistanceKm,
    int? nextStopEtaMinutes,
    int? safetyScore,
    TripStatus? status,
    List<RouteStop>? stops,
  }) {
    return TripInfo(
      id: id ?? this.id,
      routeNumber: routeNumber ?? this.routeNumber,
      routeName: routeName ?? this.routeName,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      containerNumber: containerNumber ?? this.containerNumber,
      rfidLockId: rfidLockId ?? this.rfidLockId,
      currentSpeedKmH: currentSpeedKmH ?? this.currentSpeedKmH,
      speedLimitKmH: speedLimitKmH ?? this.speedLimitKmH,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      coveredDistanceKm: coveredDistanceKm ?? this.coveredDistanceKm,
      nextStop: nextStop ?? this.nextStop,
      nextStopDistanceKm: nextStopDistanceKm ?? this.nextStopDistanceKm,
      nextStopEtaMinutes: nextStopEtaMinutes ?? this.nextStopEtaMinutes,
      safetyScore: safetyScore ?? this.safetyScore,
      status: status ?? this.status,
      stops: stops ?? this.stops,
    );
  }

  static TripInfo mockActiveTrip = const TripInfo(
    id: 'COR-2026-0842',
    routeNumber: 'Corridor Alpha',
    routeName: 'Colombo Port Gate 4 ➔ Orugodawatta ICD',
    origin: 'Colombo Port - SAGT Gate 4',
    destination: 'Orugodawatta Customs Inland Container Depot',
    containerNumber: 'MSCU-742910-8',
    rfidLockId: 'SL-RFID-99214',
    currentSpeedKmH: 42,
    speedLimitKmH: 60,
    totalDistanceKm: 14.8,
    coveredDistanceKm: 9.2,
    nextStop: 'Peliyagoda Transit Flyover',
    nextStopDistanceKm: 1.8,
    nextStopEtaMinutes: 5,
    safetyScore: 99,
    status: TripStatus.inProgress,
    stops: [
      RouteStop(
        name: 'Colombo Port SAGT Gate 4',
        scheduledTime: '08:45 AM',
        isCompleted: true,
        checkpointNote: 'Exit customs gate clearance logged.',
      ),
      RouteStop(
        name: 'Port Access Elevated Highway Junction',
        scheduledTime: '09:02 AM',
        isCompleted: true,
        checkpointNote: 'Geofence corridor boundary checked (buffer 50m).',
      ),
      RouteStop(
        name: 'Peliyagoda Transit Flyover',
        scheduledTime: '09:18 AM',
        isCompleted: false,
        isCurrent: true,
        checkpointNote: 'En-route along A1 approved corridor.',
      ),
      RouteStop(
        name: 'Orugodawatta Customs ICD Gate 1',
        scheduledTime: '09:35 AM',
        isCompleted: false,
        isCurrent: false,
        checkpointNote: 'Destination checkpoint & Stage 4 Disarm.',
      ),
    ],
  );

  static List<TripInfo> mockCompletedTrips = const [
    TripInfo(
      id: 'COR-2026-0839',
      routeNumber: 'Corridor Beta',
      routeName: 'Colombo Port ➔ BIA Katunayake Air Cargo',
      origin: 'Colombo Port - JCT Terminal',
      destination: 'BIA Katunayake Cargo Village',
      containerNumber: 'CMAU-821904-2',
      rfidLockId: 'SL-RFID-98103',
      currentSpeedKmH: 0,
      speedLimitKmH: 80,
      totalDistanceKm: 34.2,
      coveredDistanceKm: 34.2,
      nextStop: 'Destination Arrived',
      nextStopDistanceKm: 0,
      nextStopEtaMinutes: 0,
      safetyScore: 98,
      status: TripStatus.completed,
      stops: [],
    ),
    TripInfo(
      id: 'COR-2026-0831',
      routeNumber: 'Corridor Alpha',
      routeName: 'Colombo Port Gate 4 ➔ Orugodawatta ICD',
      origin: 'Colombo Port Gate 4',
      destination: 'Orugodawatta ICD',
      containerNumber: 'TCKU-339201-7',
      rfidLockId: 'SL-RFID-99440',
      currentSpeedKmH: 0,
      speedLimitKmH: 60,
      totalDistanceKm: 14.8,
      coveredDistanceKm: 14.8,
      nextStop: 'Destination Arrived',
      nextStopDistanceKm: 0,
      nextStopEtaMinutes: 0,
      safetyScore: 100,
      status: TripStatus.completed,
      stops: [],
    ),
  ];
}
