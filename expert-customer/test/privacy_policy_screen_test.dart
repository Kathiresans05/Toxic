import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expert_customer/screens/profile_screens.dart';

void main() {
  testWidgets('PrivacyPolicyScreen renders all privacy pillars correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrivacyPolicyScreen(),
      ),
    );

    // Verify Title
    expect(find.text('Safety & Privacy Policy'), findsOneWidget);
    expect(find.text('Your Privacy Comes First'), findsOneWidget);

    // Verify 4 Pillars
    expect(find.text('100% Anonymous & Private'), findsOneWidget);
    expect(find.text('End-to-End Encrypted'), findsOneWidget);
    expect(find.text('Zero Call Recording Policy'), findsOneWidget);
    expect(find.text('Safety Controls & Community Standards'), findsOneWidget);

    // Verify descriptions
    expect(find.textContaining('Your phone number, payment information, and personal identity are never disclosed'), findsOneWidget);
    expect(find.textContaining('We do NOT record, intercept, or save session streams'), findsOneWidget);
  });
}
