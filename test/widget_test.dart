import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resqnet/main.dart';
import 'package:resqnet/features/home/widgets/emergency_card.dart';
import 'package:resqnet/features/home/widgets/sos_button.dart';
import 'package:resqnet/core/constants/app_colors.dart';

void main() {
  testWidgets('ResQnetApp builds and displays login or main screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ResQnetApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('EmergencyCard renders with correct title and icon', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmergencyCard(
            title: 'Medical Emergency',
            icon: Icons.medical_services,
            color: AppColors.medical,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Medical Emergency'), findsOneWidget);
    expect(find.byIcon(Icons.medical_services), findsOneWidget);

    await tester.tap(find.text('Medical Emergency'));
    expect(tapped, isTrue);
  });

  testWidgets('SosButton renders with label', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SosButton(
            label: 'PRESS AND HOLD FOR SOS',
            onTriggered: () {},
          ),
        ),
      ),
    );

    expect(find.text('SOS'), findsOneWidget);
    expect(find.text('PRESS AND HOLD FOR SOS'), findsOneWidget);
  });
}
