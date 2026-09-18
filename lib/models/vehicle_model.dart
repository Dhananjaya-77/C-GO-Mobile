class VehicleInfo {
  final String plateNumber; // Truck Registration Number
  final String modelName; // Truck Model
  final String assignedLockId;
  final String assignedIotDeviceId;
  final String lockStatus;
  final int lockBatteryPercentage;
  final bool hasGpsLock;
  final String containerNumber;
  final String physicalSealNumber;

  // Legacy truck fields kept optional for backward compatibility
  final String vehicleType;
  final double fuelPercentage; // 0.0 to 1.0
  final int odometerKm;
  final double batteryVoltage;
  final int engineTemperatureC;
  final int tirePressurePsi;
  final bool isPreTripPassed;
  final String lastInspectionTime;
  final String insuranceExpiry;
  final String status;
  final String haulageCapacity;

  const VehicleInfo({
    required this.plateNumber,
    required this.modelName,
    this.assignedLockId = 'SL-RFID-99214',
    this.assignedIotDeviceId = 'ST-ESP32-094',
    this.lockStatus = 'Armed & Locked',
    this.lockBatteryPercentage = 88,
    this.hasGpsLock = true,
    this.containerNumber = 'MSCU-742910-8',
    this.physicalSealNumber = 'CUS-SL-778219',
    this.vehicleType = 'Prime Mover',
    this.fuelPercentage = 0.78,
    this.odometerKm = 89450,
    this.batteryVoltage = 24.4,
    this.engineTemperatureC = 84,
    this.tirePressurePsi = 110,
    this.isPreTripPassed = true,
    this.lastInspectionTime = 'Today, 08:15 AM (Insp. Kamal Wickramasinghe)',
    this.insuranceExpiry = '24 Nov 2026',
    this.status = 'Corridor Transit • GPS Locked',
    this.haulageCapacity = '45,000 kg',
  });

  VehicleInfo copyWith({
    String? plateNumber,
    String? modelName,
    String? assignedLockId,
    String? assignedIotDeviceId,
    String? lockStatus,
    int? lockBatteryPercentage,
    bool? hasGpsLock,
    String? containerNumber,
    String? physicalSealNumber,
    String? vehicleType,
    double? fuelPercentage,
    int? odometerKm,
    double? batteryVoltage,
    int? engineTemperatureC,
    int? tirePressurePsi,
    bool? isPreTripPassed,
    String? lastInspectionTime,
    String? insuranceExpiry,
    String? status,
    String? haulageCapacity,
  }) {
    return VehicleInfo(
      plateNumber: plateNumber ?? this.plateNumber,
      modelName: modelName ?? this.modelName,
      assignedLockId: assignedLockId ?? this.assignedLockId,
      assignedIotDeviceId: assignedIotDeviceId ?? this.assignedIotDeviceId,
      lockStatus: lockStatus ?? this.lockStatus,
      lockBatteryPercentage:
          lockBatteryPercentage ?? this.lockBatteryPercentage,
      hasGpsLock: hasGpsLock ?? this.hasGpsLock,
      containerNumber: containerNumber ?? this.containerNumber,
      physicalSealNumber: physicalSealNumber ?? this.physicalSealNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      fuelPercentage: fuelPercentage ?? this.fuelPercentage,
      odometerKm: odometerKm ?? this.odometerKm,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      engineTemperatureC: engineTemperatureC ?? this.engineTemperatureC,
      tirePressurePsi: tirePressurePsi ?? this.tirePressurePsi,
      isPreTripPassed: isPreTripPassed ?? this.isPreTripPassed,
      lastInspectionTime: lastInspectionTime ?? this.lastInspectionTime,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      status: status ?? this.status,
      haulageCapacity: haulageCapacity ?? this.haulageCapacity,
    );
  }

  static VehicleInfo mockVehicle = const VehicleInfo(
    plateNumber: 'WP LY-4821',
    modelName: 'Volvo FMX 440 Heavy Prime Mover',
    assignedLockId: 'SL-RFID-99214',
    assignedIotDeviceId: 'ST-ESP32-094',
    lockStatus: 'Armed & Locked',
    lockBatteryPercentage: 88,
    hasGpsLock: true,
    containerNumber: 'MSCU-742910-8',
    physicalSealNumber: 'CUS-SL-778219',
  );
}
