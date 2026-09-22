import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'auth_service.dart';

/// Supported device biometric sensor hardware types
enum DeviceBiometricCapability {
  fingerprintOnly,
  faceOnly,
  both,
  none,
}

/// Active scan mode during biometric authentication
enum BiometricScanMode {
  fingerprint,
  face,
}

/// Model storing saved biometric login credential information
class BiometricCredential {
  final String email;
  final String password;
  final String userName;
  final String roleName;
  final DateTime savedAt;
  final String preferredSensor; // 'fingerprint', 'face', or 'both'
  final bool enrolledOnDevice;

  const BiometricCredential({
    required this.email,
    this.password = '',
    required this.userName,
    required this.roleName,
    required this.savedAt,
    this.preferredSensor = 'both',
    this.enrolledOnDevice = true,
  });

  String get formattedDate {
    return '${savedAt.year}-${savedAt.month.toString().padLeft(2, '0')}-${savedAt.day.toString().padLeft(2, '0')}';
  }
}

/// Comprehensive Biometric Authentication Service
/// Handles ongoing device biometric detection (Fingerprint, Touch ID, Face ID),
/// requesting device access using default settings, and enrolling/saving login info.
class BiometricService {
  BiometricService._privateConstructor() {
    // By default, pre-enroll demo account with biometrics for instant testing
    _savedCredentials['dhananjaya1@gmail.com'] = BiometricCredential(
      email: 'dhananjaya1@gmail.com',
      password: '',
      userName: 'Kasun Perera',
      roleName: 'Truck Driver',
      savedAt: DateTime.now().subtract(const Duration(days: 2)),
      preferredSensor: 'both',
      enrolledOnDevice: true,
    );
  }

  static final BiometricService instance = BiometricService._privateConstructor();

  final LocalAuthentication _localAuth = LocalAuthentication();

  // Current device capability (Defaults to 'both' to showcase fingerprint & face recognition)
  // Web does not support the local_auth plugin, so keep the capability disabled there.
  DeviceBiometricCapability _deviceCapability = kIsWeb
      ? DeviceBiometricCapability.none
      : DeviceBiometricCapability.both;

  // Map of email -> saved BiometricCredential
  final Map<String, BiometricCredential> _savedCredentials = {};

  DeviceBiometricCapability get deviceCapability => _deviceCapability;

  void setDeviceCapability(DeviceBiometricCapability capability) {
    _deviceCapability = capability;
  }

  bool get hasFingerprint =>
      _deviceCapability == DeviceBiometricCapability.fingerprintOnly ||
      _deviceCapability == DeviceBiometricCapability.both;

  bool get hasFaceId =>
      _deviceCapability == DeviceBiometricCapability.faceOnly ||
      _deviceCapability == DeviceBiometricCapability.both;

  bool get hasBoth => _deviceCapability == DeviceBiometricCapability.both;

  bool get isBiometricSupported => _deviceCapability != DeviceBiometricCapability.none;

  /// Returns user-friendly name of the available biometric hardware
  String get biometricHardwareName {
    switch (_deviceCapability) {
      case DeviceBiometricCapability.both:
        return 'Fingerprint & Face ID';
      case DeviceBiometricCapability.fingerprintOnly:
        return 'Fingerprint Scanner';
      case DeviceBiometricCapability.faceOnly:
        return 'Face Identification';
      case DeviceBiometricCapability.none:
        return 'Not Supported';
    }
  }

  /// Returns user-friendly description for saving credentials
  String get saveBiometricsLabel {
    switch (_deviceCapability) {
      case DeviceBiometricCapability.both:
        return 'Save login with Fingerprint & Face ID';
      case DeviceBiometricCapability.fingerprintOnly:
        return 'Save login with Fingerprint';
      case DeviceBiometricCapability.faceOnly:
        return 'Save login with Face Identification';
      case DeviceBiometricCapability.none:
        return 'Biometrics Unavailable';
    }
  }

  /// Returns icon representing active biometric sensor
  IconData get primaryBiometricIcon {
    switch (_deviceCapability) {
      case DeviceBiometricCapability.both:
        return Icons.fingerprint_rounded;
      case DeviceBiometricCapability.fingerprintOnly:
        return Icons.fingerprint_rounded;
      case DeviceBiometricCapability.faceOnly:
        return Icons.face_rounded;
      case DeviceBiometricCapability.none:
        return Icons.lock_outline_rounded;
    }
  }

  /// Check if credentials are saved for given email
  bool hasSavedCredential(String email) {
    return _savedCredentials.containsKey(email.trim().toLowerCase());
  }

  /// Retrieve saved biometric credential
  BiometricCredential? getSavedCredential(String email) {
    return _savedCredentials[email.trim().toLowerCase()];
  }

  /// List of all saved biometric credentials
  List<BiometricCredential> get allSavedCredentials =>
      _savedCredentials.values.toList();

  /// Check if any credential is saved
  bool get hasAnySavedCredential => _savedCredentials.isNotEmpty;

  /// Check if ongoing device hardware supports biometric scanning
  Future<bool> get isOngoingDeviceSupported async {
    if (kIsWeb) {
      return false;
    }

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (e) {
      return false;
    }
  }

  /// If true (e.g. in widget tests or environments without biometrics),
  /// bypasses platform channel checks and directly opens the biometric fallback UI dialog.
  bool fallbackToDialogDirectly = false;

  /// Request access of ongoing device and scan fingerprint using device default settings
  Future<bool> scanFingerprintWithOngoingDevice({
    String reason = 'Scan fingerprint using device default settings to authenticate',
  }) async {
    if (kIsWeb || fallbackToDialogDirectly) {
      return false;
    }

    try {
      final canCheck = await _localAuth.canCheckBiometrics.timeout(const Duration(milliseconds: 100));
      final isSupported = await _localAuth.isDeviceSupported().timeout(const Duration(milliseconds: 100));
      if (canCheck || isSupported) {
        return await _localAuth.authenticate(
          localizedReason: reason,
          biometricOnly: true,
          persistAcrossBackgrounding: true,
        ).timeout(const Duration(milliseconds: 500));
      }
    } catch (e) {
      debugPrint('Ongoing device local_auth error: $e');
    }
    return false;
  }

  /// Check if fingerprint is enrolled on ongoing device for given email
  bool isFingerprintEnrolledOnDevice(String email) {
    final cred = getSavedCredential(email);
    return cred != null && cred.enrolledOnDevice;
  }

  /// First/default saved credential
  BiometricCredential? get defaultCredential =>
      _savedCredentials.isNotEmpty ? _savedCredentials.values.first : null;

  /// Save login information for biometric authentication, binding fingerprint to username & password
  void saveLoginCredential({
    required String email,
    String? password,
    String? userName,
    String? roleName,
    String preferredSensor = 'both',
    bool enrolledOnDevice = true,
  }) {
    final normalized = email.trim().toLowerCase();
    String resolvedUser = userName ?? 'Authorized User';
    String resolvedRole = roleName ?? 'User';

    if (normalized == 'dhananjaya1@gmail.com') {
      resolvedUser = 'Kasun Perera';
      resolvedRole = 'Truck Driver';
    } else if (normalized == 'dhananjaya2@gmail.com') {
      resolvedUser = 'Insp. Kamal Wickramasinghe';
      resolvedRole = 'Customs Inspector';
    } else if (normalized == 'dhananjaya3@gmail.com') {
      resolvedUser = 'David Silva';
      resolvedRole = 'Container Owner';
    }

    _savedCredentials[normalized] = BiometricCredential(
      email: normalized,
      password: password ?? (_savedCredentials[normalized]?.password ?? ''),
      userName: resolvedUser,
      roleName: resolvedRole,
      savedAt: DateTime.now(),
      preferredSensor: preferredSensor,
      enrolledOnDevice: enrolledOnDevice,
    );

    // Also record in AuthService recent logins
    AuthService.instance.recordLogin(normalized);
  }

  /// Remove saved biometric credential for an email
  void removeSavedCredential(String email) {
    _savedCredentials.remove(email.trim().toLowerCase());
  }

  /// Clear all saved biometric credentials
  void clearAllCredentials() {
    _savedCredentials.clear();
  }
}
