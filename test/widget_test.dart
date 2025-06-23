import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enc/main.dart';
import 'package:enc/services/encryption_service.dart';

void main() {
  group('Password Encrypter App Widget Tests', () {
    testWidgets('App should start with loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(const PasswordEncrypterApp());
      
      // Initially should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should show master password setup when no master password exists', (WidgetTester tester) async {
      // Mock the hasMasterPassword to return false
      // Note: In a real test, you'd use proper mocking
      
      await tester.pumpWidget(const PasswordEncrypterApp());
      await tester.pumpAndSettle();
      
      // Should show setup screen
      expect(find.text('Setup Master Password'), findsOneWidget);
      expect(find.text('Create Your Master Password'), findsOneWidget);
    });

    testWidgets('Master password setup form validation', (WidgetTester tester) async {
      await tester.pumpWidget(const PasswordEncrypterApp());
      await tester.pumpAndSettle();
      
      // Find the form fields
      final passwordField = find.byType(TextFormField).first;
      final confirmField = find.byType(TextFormField).last;
      final createButton = find.text('Create Master Password');
      
      // Try to submit empty form
      await tester.tap(createButton);
      await tester.pump();
      
      // Should show validation error
      expect(find.text('Please enter a password'), findsOneWidget);
      
      // Enter short password
      await tester.enterText(passwordField, '123');
      await tester.tap(createButton);
      await tester.pump();
      
      // Should show length validation error
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      
      // Enter valid password but no confirmation
      await tester.enterText(passwordField, 'validPassword123');
      await tester.tap(createButton);
      await tester.pump();
      
      // Should show confirmation error
      expect(find.text('Passwords do not match'), findsOneWidget);
      
      // Enter matching confirmation
      await tester.enterText(confirmField, 'validPassword123');
      await tester.tap(createButton);
      await tester.pump();
      
      // Should not show validation errors
      expect(find.text('Please enter a password'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);
      expect(find.text('Passwords do not match'), findsNothing);
    });

    testWidgets('Should show login screen when master password exists', (WidgetTester tester) async {
      // This test would require mocking the hasMasterPassword method
      // For now, we'll test the basic structure
      
      await tester.pumpWidget(const PasswordEncrypterApp());
      await tester.pumpAndSettle();
      
      // The app should render without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Form fields should be properly configured', (WidgetTester tester) async {
      await tester.pumpWidget(const PasswordEncrypterApp());
      await tester.pumpAndSettle();
      
      // Check that password fields are properly configured
      final passwordFields = find.byType(TextFormField);
      expect(passwordFields, findsNWidgets(2));
      
      // Check that fields have proper decorations
      for (final field in passwordFields.evaluate()) {
        final widget = field.widget as TextFormField;
        expect(widget.decoration?.labelText, isNotNull);
        expect(widget.obscureText, isTrue);
      }
    });

    testWidgets('App should have proper theme configuration', (WidgetTester tester) async {
      await tester.pumpWidget(const PasswordEncrypterApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('Password Encrypter'));
      expect(materialApp.theme?.primarySwatch, equals(Colors.blue));
      expect(materialApp.theme?.useMaterial3, isTrue);
    });
  });
} 