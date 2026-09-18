enum ContainerSecurityStatus {
  secure,
  tamperBreach,
  routeDeviated,
  awaitingUnlock,
  completed,
}

class SensorTelemetry {
  final bool isMagneticReedClosed;
  final double lightSensorLux;
  final int batteryLevel;
  final bool hasGpsLock;
  final int satelliteCount;
  final double latitude;
  final double longitude;
  final int speedKmH;
  final int gsmSignalBars;
  final bool isMqttConnected;
  final int offlineCachedPackets;
  final double routeDeviationMeters;
  final DateTime lastReportTime;

  const SensorTelemetry({
    required this.isMagneticReedClosed,
    required this.lightSensorLux,
    required this.batteryLevel,
    required this.hasGpsLock,
    required this.satelliteCount,
    required this.latitude,
    required this.longitude,
    required this.speedKmH,
    required this.gsmSignalBars,
    required this.isMqttConnected,
    required this.offlineCachedPackets,
    required this.routeDeviationMeters,
    required this.lastReportTime,
  });

  bool get isTampered => !isMagneticReedClosed || lightSensorLux > 30.0;
  bool get isDeviated => routeDeviationMeters > 50.0;

  SensorTelemetry copyWith({
    bool? isMagneticReedClosed,
    double? lightSensorLux,
    int? batteryLevel,
    bool? hasGpsLock,
    int? satelliteCount,
    double? latitude,
    double? longitude,
    int? speedKmH,
    int? gsmSignalBars,
    bool? isMqttConnected,
    int? offlineCachedPackets,
    double? routeDeviationMeters,
    DateTime? lastReportTime,
  }) {
    return SensorTelemetry(
      isMagneticReedClosed: isMagneticReedClosed ?? this.isMagneticReedClosed,
      lightSensorLux: lightSensorLux ?? this.lightSensorLux,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      hasGpsLock: hasGpsLock ?? this.hasGpsLock,
      satelliteCount: satelliteCount ?? this.satelliteCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedKmH: speedKmH ?? this.speedKmH,
      gsmSignalBars: gsmSignalBars ?? this.gsmSignalBars,
      isMqttConnected: isMqttConnected ?? this.isMqttConnected,
      offlineCachedPackets: offlineCachedPackets ?? this.offlineCachedPackets,
      routeDeviationMeters: routeDeviationMeters ?? this.routeDeviationMeters,
      lastReportTime: lastReportTime ?? this.lastReportTime,
    );
  }
}

class ContainerInfo {
  final String containerNumber;
  final String containerType;
  final String iotDeviceId;
  final String rfidLockId;
  final String physicalSealNumber;
  final ContainerSecurityStatus securityStatus;
  final SensorTelemetry telemetry;
  final String cargoDescription;
  final String consigneeName;
  final String originPort;
  final String destinationDepot;
  final String designatedCorridor;

  const ContainerInfo({
    required this.containerNumber,
    required this.containerType,
    required this.iotDeviceId,
    required this.rfidLockId,
    required this.physicalSealNumber,
    required this.securityStatus,
    required this.telemetry,
    required this.cargoDescription,
    required this.consigneeName,
    required this.originPort,
    required this.destinationDepot,
    required this.designatedCorridor,
  });

  ContainerInfo copyWith({
    String? containerNumber,
    String? containerType,
    String? iotDeviceId,
    String? rfidLockId,
    String? physicalSealNumber,
    ContainerSecurityStatus? securityStatus,
    SensorTelemetry? telemetry,
    String? cargoDescription,
    String? consigneeName,
    String? originPort,
    String? destinationDepot,
    String? designatedCorridor,
  }) {
    return ContainerInfo(
      containerNumber: containerNumber ?? this.containerNumber,
      containerType: containerType ?? this.containerType,
      iotDeviceId: iotDeviceId ?? this.iotDeviceId,
      rfidLockId: rfidLockId ?? this.rfidLockId,
      physicalSealNumber: physicalSealNumber ?? this.physicalSealNumber,
      securityStatus: securityStatus ?? this.securityStatus,
      telemetry: telemetry ?? this.telemetry,
      cargoDescription: cargoDescription ?? this.cargoDescription,
      consigneeName: consigneeName ?? this.consigneeName,
      originPort: originPort ?? this.originPort,
      destinationDepot: destinationDepot ?? this.destinationDepot,
      designatedCorridor: designatedCorridor ?? this.designatedCorridor,
    );
  }

  static ContainerInfo mockPrimaryContainer = ContainerInfo(
    containerNumber: 'MSCU-742910-8',
    containerType: '40ft High-Cube Dry Freight',
    iotDeviceId: 'ST-ESP32-094',
    rfidLockId: 'SL-RFID-99214',
    physicalSealNumber: 'CUS-SL-778219',
    securityStatus: ContainerSecurityStatus.secure,
    cargoDescription: 'High-Grade Ceylon Black Tea & Textiles (Export)',
    consigneeName: 'Lanka Global Logistics & Exports Ltd',
    originPort: 'Colombo Port - SAGT Terminal Gate 4',
    destinationDepot: 'Orugodawatta Inland Container Depot (ICD)',
    designatedCorridor: 'Corridor Alpha (Colombo Port - Port Access Highway - Orugodawatta)',
    telemetry: SensorTelemetry(
      isMagneticReedClosed: true,
      lightSensorLux: 0.0,
      batteryLevel: 94,
      hasGpsLock: true,
      satelliteCount: 11,
      latitude: 6.9534,
      longitude: 79.8702,
      speedKmH: 42,
      gsmSignalBars: 4,
      isMqttConnected: true,
      offlineCachedPackets: 0,
      routeDeviationMeters: 4.2,
      lastReportTime: DateTime.now(),
    ),
  );

  static List<ContainerInfo> mockContainerFleet = [
    mockPrimaryContainer,
    ContainerInfo(
      containerNumber: 'CMAU-821904-2',
      containerType: '20ft Standard Dry Van',
      iotDeviceId: 'ST-ESP32-108',
      rfidLockId: 'SL-RFID-98103',
      physicalSealNumber: 'CUS-SL-778105',
      securityStatus: ContainerSecurityStatus.secure,
      cargoDescription: 'Apparel & Fabric Consignment',
      consigneeName: 'Brandix Garments Lanka Ltd',
      originPort: 'Colombo Port - JCT Terminal',
      destinationDepot: 'BIA Katunayake Air Cargo Village',
      designatedCorridor: 'Corridor Beta (Colombo Port - E03 Expressway - Katunayake)',
      telemetry: SensorTelemetry(
        isMagneticReedClosed: true,
        lightSensorLux: 0.0,
        batteryLevel: 88,
        hasGpsLock: true,
        satelliteCount: 9,
        latitude: 7.0210,
        longitude: 79.8920,
        speedKmH: 58,
        gsmSignalBars: 4,
        isMqttConnected: true,
        offlineCachedPackets: 0,
        routeDeviationMeters: 8.5,
        lastReportTime: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ),
    ContainerInfo(
      containerNumber: 'HLCU-902184-5',
      containerType: '40ft Refrigerated Container (Reefer)',
      iotDeviceId: 'ST-ESP32-072',
      rfidLockId: 'SL-RFID-97211',
      physicalSealNumber: 'CUS-SL-776994',
      securityStatus: ContainerSecurityStatus.tamperBreach,
      cargoDescription: 'Pharmaceuticals & Medical Equipment',
      consigneeName: 'State Pharmaceuticals Corporation of Sri Lanka',
      originPort: 'Colombo Port - CICT Terminal',
      destinationDepot: 'Peliyagoda Central Medical Warehouse',
      designatedCorridor: 'Corridor Gamma (Colombo Port - Kandy Road - Peliyagoda)',
      telemetry: SensorTelemetry(
        isMagneticReedClosed: false,
        lightSensorLux: 340.0,
        batteryLevel: 76,
        hasGpsLock: true,
        satelliteCount: 8,
        latitude: 6.9602,
        longitude: 79.8821,
        speedKmH: 0,
        gsmSignalBars: 3,
        isMqttConnected: true,
        offlineCachedPackets: 4,
        routeDeviationMeters: 62.0,
        lastReportTime: DateTime.now().subtract(const Duration(seconds: 45)),
      ),
    ),
    ContainerInfo(
      containerNumber: 'TCKU-339201-7',
      containerType: '40ft High-Cube Dry Freight',
      iotDeviceId: 'ST-ESP32-115',
      rfidLockId: 'SL-RFID-99440',
      physicalSealNumber: 'CUS-SL-779021',
      securityStatus: ContainerSecurityStatus.awaitingUnlock,
      cargoDescription: 'Precision Industrial Electronics',
      consigneeName: 'Hayleys Advantis Supply Chain Solutions',
      originPort: 'Colombo Port - Gate 4',
      destinationDepot: 'Orugodawatta Inland Container Depot (ICD)',
      designatedCorridor: 'Corridor Alpha (Colombo Port - Orugodawatta)',
      telemetry: SensorTelemetry(
        isMagneticReedClosed: true,
        lightSensorLux: 0.0,
        batteryLevel: 82,
        hasGpsLock: true,
        satelliteCount: 12,
        latitude: 6.9452,
        longitude: 79.8830,
        speedKmH: 0,
        gsmSignalBars: 4,
        isMqttConnected: true,
        offlineCachedPackets: 0,
        routeDeviationMeters: 2.1,
        lastReportTime: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ),
  ];
}
