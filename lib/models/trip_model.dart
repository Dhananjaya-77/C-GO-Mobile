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
    routeNumber: 'Route 1',
    routeName: 'Colombo Fort ➔ Orugodawaththa',
    origin: 'Colombo Fort',
    destination: 'Orugodawaththa',
    containerNumber: 'MSCU-742910-8',
    rfidLockId: 'SL-RFID-99214',
    currentSpeedKmH: 42,
    speedLimitKmH: 60,
    totalDistanceKm: 6.8,
    coveredDistanceKm: 3.5,
    nextStop: 'Ingurukade Junction',
    nextStopDistanceKm: 1.2,
    nextStopEtaMinutes: 4,
    safetyScore: 99,
    status: TripStatus.inProgress,
    stops: [
      RouteStop(
        name: 'Colombo Fort Gate 4',
        scheduledTime: '08:45 AM',
        isCompleted: true,
        checkpointNote: 'Exit customs gate clearance logged.',
      ),
      RouteStop(
        name: 'Port Access Highway Junction',
        scheduledTime: '09:02 AM',
        isCompleted: true,
        checkpointNote: 'Geofence corridor boundary checked (buffer 50m).',
      ),
      RouteStop(
        name: 'Ingurukade Junction',
        scheduledTime: '09:18 AM',
        isCompleted: false,
        isCurrent: true,
        checkpointNote: 'En-route along designated corridor.',
      ),
      RouteStop(
        name: 'Orugodawaththa ICD Gate 1',
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
      routeNumber: 'Route 2',
      routeName: 'Colombo Fort ➔ Grayline 1',
      origin: 'Colombo Fort',
      destination: 'Grayline 1',
      containerNumber: 'CMAU-821904-2',
      rfidLockId: 'SL-RFID-98103',
      currentSpeedKmH: 0,
      speedLimitKmH: 50,
      totalDistanceKm: 4.2,
      coveredDistanceKm: 4.2,
      nextStop: 'Destination Arrived',
      nextStopDistanceKm: 0,
      nextStopEtaMinutes: 0,
      safetyScore: 98,
      status: TripStatus.completed,
      stops: [],
    ),
    TripInfo(
      id: 'COR-2026-0831',
      routeNumber: 'Route 3',
      routeName: 'Colombo Fort ➔ Grayline 2',
      origin: 'Colombo Fort',
      destination: 'Grayline 2',
      containerNumber: 'TCKU-339201-7',
      rfidLockId: 'SL-RFID-99440',
      currentSpeedKmH: 0,
      speedLimitKmH: 50,
      totalDistanceKm: 5.1,
      coveredDistanceKm: 5.1,
      nextStop: 'Destination Arrived',
      nextStopDistanceKm: 0,
      nextStopEtaMinutes: 0,
      safetyScore: 100,
      status: TripStatus.completed,
      stops: [],
    ),
  ];
}

class ApprovedRoute {
  final String id;
  final String routeNumber;
  final String name;
  final String origin;
  final String destination;
  final double totalDistanceKm;
  final int defaultEtaMinutes;
  final String nextTurnInstruction;
  final String nextTurnDistance;

  const ApprovedRoute({
    required this.id,
    required this.routeNumber,
    required this.name,
    required this.origin,
    required this.destination,
    required this.totalDistanceKm,
    required this.defaultEtaMinutes,
    required this.nextTurnInstruction,
    required this.nextTurnDistance,
  });
}

const List<ApprovedRoute> kApprovedRoutes = [
  ApprovedRoute(
    id: 'route_1',
    routeNumber: 'Route 1',
    name: 'Colombo Fort to Orugodawaththa',
    origin: 'Colombo Fort',
    destination: 'Orugodawaththa',
    totalDistanceKm: 6.8,
    defaultEtaMinutes: 18,
    nextTurnInstruction: 'Turn right onto Port Access Highway',
    nextTurnDistance: 'In 1.2 km',
  ),
  ApprovedRoute(
    id: 'route_2',
    routeNumber: 'Route 2',
    name: 'Colombo Fort to Grayline 1',
    origin: 'Colombo Fort',
    destination: 'Grayline 1',
    totalDistanceKm: 4.2,
    defaultEtaMinutes: 12,
    nextTurnInstruction: 'Turn left onto Bloemendhal Road',
    nextTurnDistance: 'In 0.8 km',
  ),
  ApprovedRoute(
    id: 'route_3',
    routeNumber: 'Route 3',
    name: 'Colombo Fort to Grayline 2',
    origin: 'Colombo Fort',
    destination: 'Grayline 2',
    totalDistanceKm: 5.1,
    defaultEtaMinutes: 15,
    nextTurnInstruction: 'Continue onto Prince of Wales Ave',
    nextTurnDistance: 'In 1.1 km',
  ),
];
