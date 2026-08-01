import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management/main.dart';
import 'package:notes_management/services/mock_database_service.dart';

void main() {
  testWidgets('Notes App renders initial notes in mock mode', (WidgetTester tester) async {
    // Build our app with a MockDatabaseService and trigger a frame.
    final mockDb = MockDatabaseService();
    await tester.pumpWidget(NotesApp(databaseService: mockDb));
    await tester.pumpAndSettle();

    // Verify that our app header "My Notes" renders
    expect(find.text('My Notes'), findsOneWidget);

    // Verify that the database status badge is displayed
    expect(find.text('Mock Offline'), findsOneWidget);

    // Verify that at least one of our initial mock notes renders (e.g. Welcome note)
    expect(find.text('Welcome to Premium Notes! 🚀'), findsOneWidget);
    expect(find.text('Weekly Groceries & Snacks 🥑'), findsOneWidget);

    // Verify that the Floating Action Button is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
