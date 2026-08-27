// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ledger_pilot/main.dart';

void main() {
  testWidgets('Bill workspace loads the overview', (WidgetTester tester) async {
    await tester.pumpWidget(const BillApp());
    await tester.pumpAndSettle();

    expect(find.text('PricePilot Bill'), findsOneWidget);
    expect(find.text('Good morning, Anika'), findsOneWidget);
    expect(find.text('Create invoice'), findsOneWidget);
  });
}
