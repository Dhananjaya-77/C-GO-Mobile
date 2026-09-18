enum ShiftStatus {
  onDuty,
  offDuty,
  onBreak,
}

class DriverProfile {
  final String id;
  final String fullName;
  final String employeeId;
  final String customsBadgeId;
  final String licenseNumber;
  final String phoneNumber;
  final String email;
  final double rating;
  final int totalTrips;
  final int incidentFreeDays;
  final ShiftStatus status;
  final String assignedVehiclePlate;
  final String assignedContainerNumber;

  const DriverProfile({
    required this.id,
    required this.fullName,
    required this.employeeId,
    required this.customsBadgeId,
    required this.licenseNumber,
    required this.phoneNumber,
    required this.email,
    required this.rating,
    required this.totalTrips,
    required this.incidentFreeDays,
    required this.status,
    required this.assignedVehiclePlate,
    required this.assignedContainerNumber,
  });

  DriverProfile copyWith({
    String? id,
    String? fullName,
    String? employeeId,
    String? customsBadgeId,
    String? licenseNumber,
    String? phoneNumber,
    String? email,
    double? rating,
    int? totalTrips,
    int? incidentFreeDays,
    ShiftStatus? status,
    String? assignedVehiclePlate,
    String? assignedContainerNumber,
  }) {
    return DriverProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      employeeId: employeeId ?? this.employeeId,
      customsBadgeId: customsBadgeId ?? this.customsBadgeId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      incidentFreeDays: incidentFreeDays ?? this.incidentFreeDays,
      status: status ?? this.status,
      assignedVehiclePlate: assignedVehiclePlate ?? this.assignedVehiclePlate,
      assignedContainerNumber: assignedContainerNumber ?? this.assignedContainerNumber,
    );
  }

  static DriverProfile mockDriver = const DriverProfile(
    id: 'drv_101',
    fullName: 'Kasun Perera',
    employeeId: 'ST-DRV-0428',
    customsBadgeId: 'SLC-DRV-8821',
    licenseNumber: 'B-8923412 (Heavy Articulated)',
    phoneNumber: '+94 77 123 4567',
    email: 'kasun.perera@securetrack.lk',
    rating: 4.96,
    totalTrips: 342,
    incidentFreeDays: 240,
    status: ShiftStatus.onDuty,
    assignedVehiclePlate: 'WP LY-4821',
    assignedContainerNumber: 'MSCU-742910-8',
  );
}
