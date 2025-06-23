import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:enc/main.dart' as app;
import 'package:enc/services/encryption_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Password Encrypter Integration Tests', () {
    testWidgets('Complete app flow: setup master password and add passwords', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for initial loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      // Should show master password setup screen
      expect(find.text('Setup Master Password'), findsOneWidget);
      expect(find.text('Create Your Master Password'), findsOneWidget);

      // Enter master password
      final passwordField = find.byType(TextFormField).first;
      final confirmField = find.byType(TextFormField).last;
      
      await tester.enterText(passwordField, 'MyMasterPassword123');
      await tester.enterText(confirmField, 'MyMasterPassword123');
      
      // Create master password
      final createButton = find.text('Create Master Password');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should now show the main screen
      expect(find.text('Password Manager'), findsOneWidget);
      expect(find.text('Add New Password'), findsOneWidget);
    });

    testWidgets('Add new password flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for initial loading
      await tester.pumpAndSettle();

      // If no master password exists, create one
      if (find.text('Setup Master Password').evaluate().isNotEmpty) {
        final passwordField = find.byType(TextFormField).first;
        final confirmField = find.byType(TextFormField).last;
        
        await tester.enterText(passwordField, 'TestMasterPassword123');
        await tester.enterText(confirmField, 'TestMasterPassword123');
        
        final createButton = find.text('Create Master Password');
        await tester.tap(createButton);
        await tester.pumpAndSettle();
      }

      // Tap add new password button
      final addButton = find.text('Add New Password');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Should show add password form
      expect(find.text('Add New Password'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Fill in the form
      final titleField = find.byType(TextFormField).at(0);
      final usernameField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);

      await tester.enterText(titleField, 'Test Account');
      await tester.enterText(usernameField, 'testuser@example.com');
      await tester.enterText(passwordField, 'MySecretPassword123');

      // Save the password
      final saveButton = find.text('Save Password');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should return to main screen and show the saved password
      expect(find.text('Test Account'), findsOneWidget);
      expect(find.text('testuser@example.com'), findsOneWidget);
    });

    testWidgets('View and decrypt password', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for initial loading
      await tester.pumpAndSettle();

      // If no master password exists, create one
      if (find.text('Setup Master Password').evaluate().isNotEmpty) {
        final passwordField = find.byType(TextFormField).first;
        final confirmField = find.byType(TextFormField).last;
        
        await tester.enterText(passwordField, 'TestMasterPassword123');
        await tester.enterText(confirmField, 'TestMasterPassword123');
        
        final createButton = find.text('Create Master Password');
        await tester.tap(createButton);
        await tester.pumpAndSettle();
      }

      // Add a password first
      final addButton = find.text('Add New Password');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      final titleField = find.byType(TextFormField).at(0);
      final usernameField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);

      await tester.enterText(titleField, 'Integration Test Account');
      await tester.enterText(usernameField, 'integration@test.com');
      await tester.enterText(passwordField, 'IntegrationPassword123');

      final saveButton = find.text('Save Password');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Tap on the saved password to view details
      final savedPasswordTile = find.text('Integration Test Account');
      await tester.tap(savedPasswordTile);
      await tester.pumpAndSettle();

      // Should show password details
      expect(find.text('Integration Test Account'), findsOneWidget);
      expect(find.text('integration@test.com'), findsOneWidget);
      expect(find.text('Show Password'), findsOneWidget);

      // Tap show password button
      final showPasswordButton = find.text('Show Password');
      await tester.tap(showPasswordButton);
      await tester.pumpAndSettle();

      // Should show the decrypted password
      expect(find.text('IntegrationPassword123'), findsOneWidget);
    });

    testWidgets('Delete password', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for initial loading
      await tester.pumpAndSettle();

      // If no master password exists, create one
      if (find.text('Setup Master Password').evaluate().isNotEmpty) {
        final passwordField = find.byType(TextFormField).first;
        final confirmField = find.byType(TextFormField).last;
        
        await tester.enterText(passwordField, 'TestMasterPassword123');
        await tester.enterText(confirmField, 'TestMasterPassword123');
        
        final createButton = find.text('Create Master Password');
        await tester.tap(createButton);
        await tester.pumpAndSettle();
      }

      // Add a password first
      final addButton = find.text('Add New Password');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      final titleField = find.byType(TextFormField).at(0);
      final usernameField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);

      await tester.enterText(titleField, 'Delete Test Account');
      await tester.enterText(usernameField, 'delete@test.com');
      await tester.enterText(passwordField, 'DeletePassword123');

      final saveButton = find.text('Save Password');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify password was added
      expect(find.text('Delete Test Account'), findsOneWidget);

      // Long press to delete
      final passwordTile = find.text('Delete Test Account');
      await tester.longPress(passwordTile);
      await tester.pumpAndSettle();

      // Should show delete confirmation
      expect(find.text('Delete Password'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this password?'), findsOneWidget);

      // Confirm deletion
      final confirmDeleteButton = find.text('Delete');
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle();

      // Password should be removed
      expect(find.text('Delete Test Account'), findsNothing);
    });
  });
} 