import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securetrack_mobile/widgets/srs_curved_header.dart';

void main() {
  testWidgets('SrsCurvedHeader does not overflow on narrow screens', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: SrsCurvedHeader(
                title: 'Driver Navigation Module',
                subtitle: null,
                statusBadge: SizedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8),
                      SizedBox(width: 6),
                      Text('LIVE CORRIDOR TELEMETRY'),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_rounded),
                    SizedBox(width: 6),
                    Icon(Icons.person),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
