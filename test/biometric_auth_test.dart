import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securetrack_mobile/screens/driver/driver_dashboard_screen.dart';
import 'package:securetrack_mobile/screens/login_screen.dart';
import 'package:securetrack_mobile/services/biometric_service.dart';
import 'package:securetrack_mobile/widgets/biometric_auth_dialog.dart';

void main() {
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('BiometricService - Capabilities & Credential Storage', () {
    test('Configures Fingerprint, Face ID, and Both device capabilities', () {
      final bio = BiometricService.instance;

      bio.setDeviceCapability(DeviceBiometricCapability.both);
      expect(bio.hasFingerprint, isTrue);
      expect(bio.hasFaceId, isTrue);
      expect(bio.hasBoth, isTrue);
      expect(bio.biometricHardwareName, 'Fingerprint & Face ID');
      expect(bio.saveBiometricsLabel, 'Save login with Fingerprint & Face ID');

      bio.setDeviceCapability(DeviceBiometricCapability.fingerprintOnly);
      expect(bio.hasFingerprint, isTrue);
      expect(bio.hasFaceId, isFalse);
      expect(bio.hasBoth, isFalse);
      expect(bio.biometricHardwareName, 'Fingerprint Scanner');
      expect(bio.saveBiometricsLabel, 'Save login with Fingerprint');

      bio.setDeviceCapability(DeviceBiometricCapability.faceOnly);
      expect(bio.hasFingerprint, isFalse);
      expect(bio.hasFaceId, isTrue);
      expect(bio.hasBoth, isFalse);
      expect(bio.biometricHardwareName, 'Face Identification');
      expect(bio.saveBiometricsLabel, 'Save login with Face Identification');
    });

    test('Saves, retrieves, and clears biometric credentials', () {
      final bio = BiometricService.instance;
      bio.clearAllCredentials();
      expect(bio.hasAnySavedCredential, isFalse);

      bio.saveLoginCredential(
        email: 'dhananjaya1@gmail.com',
        userName: 'Kasun Perera',
        roleName: 'Truck Driver',
      );

      expect(bio.hasSavedCredential('dhananjaya1@gmail.com'), isTrue);
      final cred = bio.getSavedCredential('dhananjaya1@gmail.com');
      expect(cred?.userName, 'Kasun Perera');
      expect(cred?.roleName, 'Truck Driver');

      bio.removeSavedCredential('dhananjaya1@gmail.com');
      expect(bio.hasSavedCredential('dhananjaya1@gmail.com'), isFalse);
    });
  });

  group('LoginScreen - Biometric Authentication UI & Flow', () {
    testWidgets('Shows biometric save option and Sign In with Fingerprint & Face ID button without sensor support card', (tester) async {
      setScreenSize(tester);
      final bio = BiometricService.instance;
      bio.setDeviceCapability(DeviceBiometricCapability.both);

      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      // Verify biometric save checkbox is visible
      expect(find.text('Save login with Fingerprint & Face ID'), findsOneWidget);

      // Verify dedicated Sign In with Fingerprint & Face ID button is present
      expect(find.text('Sign In with Fingerprint & Face ID'), findsOneWidget);

      // Verify phone biometric sensor support card was removed
      expect(find.text('Phone Biometric Sensor Support:'), findsNothing);
      expect(find.text('👆 Fingerprint'), findsNothing);
      expect(find.text('👤 Face ID'), findsNothing);
    });

    testWidgets('BiometricAuthDialog verifies user and logs into dashboard', (tester) async {
      setScreenSize(tester);
      final bio = BiometricService.instance;
      bio.setDeviceCapability(DeviceBiometricCapability.both);
      bio.fallbackToDialogDirectly = true;
      addTearDown(() => bio.fallbackToDialogDirectly = false);

      bio.saveLoginCredential(
        email: 'dhananjaya1@gmail.com',
        userName: 'Kasun Perera',
        roleName: 'Truck Driver',
      );

      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      // Open Biometric Dialog via Quick Biometric Sign In button
      await tester.tap(find.textContaining('Sign In with'));
      await tester.pump();
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byType(BiometricAuthDialog), findsOneWidget);
      expect(find.text('Sign in for Kasun Perera'), findsOneWidget);

      // Tap Verify Now
      await tester.tap(find.text('Verify Now'));
      await tester.pump();
      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verifies navigation to Driver Dashboard
      expect(find.byType(DriverDashboardScreen), findsOneWidget);
    });
  });
}
