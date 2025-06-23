import 'package:flutter_test/flutter_test.dart';
import 'package:enc/services/encryption_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('EncryptionService Error Handling Tests', () {
    setUp(() async {
      // Clear any existing test data before each test
      try {
        await EncryptionService.clearAllPasswords();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await EncryptionService.clearAllPasswords();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    group('Input Validation Errors', () {
      test('hashPassword should throw error for empty password', () {
        expect(
          () => EncryptionService.hashPassword('', 'salt'),
          throwsA(predicate((e) => e.toString().contains('Password cannot be empty')))
        );
      });

      test('hashPassword should throw error for empty salt', () {
        expect(
          () => EncryptionService.hashPassword('password', ''),
          throwsA(predicate((e) => e.toString().contains('Salt cannot be empty')))
        );
      });

      test('encryptPassword should throw error for empty master password', () {
        expect(
          () => EncryptionService.encryptPassword('testPassword', ''),
          throwsA(predicate((e) => e.toString().contains('Master password cannot be empty for encryption')))
        );
      });

      test('decryptPassword should throw error for empty master password', () {
        expect(
          () => EncryptionService.decryptPassword('encryptedData', ''),
          throwsA(predicate((e) => e.toString().contains('Master password cannot be empty for decryption')))
        );
      });

      test('createMasterPassword should throw error for empty password', () async {
        expect(
          () => EncryptionService.createMasterPassword(''),
          throwsA(predicate((e) => e.toString().contains('Master password cannot be empty')))
        );
      });

      test('createMasterPassword should throw error for short password', () async {
        expect(
          () => EncryptionService.createMasterPassword('short'),
          throwsA(predicate((e) => e.toString().contains('Master password must be at least 8 characters long')))
        );
      });

      test('verifyMasterPassword should throw error for empty password', () async {
        expect(
          () => EncryptionService.verifyMasterPassword(''),
          throwsA(predicate((e) => e.toString().contains('Password cannot be empty')))
        );
      });

      test('savePassword should throw error for empty title', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        
        expect(
          () => EncryptionService.savePassword('', 'username', 'password', 'masterPassword123'),
          throwsA(predicate((e) => e.toString().contains('Title cannot be empty')))
        );
      });

      test('savePassword should throw error for empty username', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        
        expect(
          () => EncryptionService.savePassword('title', '', 'password', 'masterPassword123'),
          throwsA(predicate((e) => e.toString().contains('Username cannot be empty')))
        );
      });

      test('savePassword should throw error for empty password', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        
        expect(
          () => EncryptionService.savePassword('title', 'username', '', 'masterPassword123'),
          throwsA(predicate((e) => e.toString().contains('Password cannot be empty')))
        );
      });

      test('savePassword should throw error for empty master password', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        
        expect(
          () => EncryptionService.savePassword('title', 'username', 'password', ''),
          throwsA(predicate((e) => e.toString().contains('Master password cannot be empty')))
        );
      });

      test('deletePassword should throw error for empty title', () async {
        expect(
          () => EncryptionService.deletePassword('', 'username'),
          throwsA(predicate((e) => e.toString().contains('Title cannot be empty')))
        );
      });

      test('deletePassword should throw error for empty username', () async {
        expect(
          () => EncryptionService.deletePassword('title', ''),
          throwsA(predicate((e) => e.toString().contains('Username cannot be empty')))
        );
      });
    });

    group('File System and Data Corruption Errors', () {
      test('verifyMasterPassword should throw error when master password file not found', () async {
        expect(
          () => EncryptionService.verifyMasterPassword('anyPassword'),
          throwsA(predicate((e) => e.toString().contains('Master password file not found')))
        );
      });

      test('createMasterPassword should throw error when master password already exists', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        
        expect(
          () => EncryptionService.createMasterPassword('anotherPassword123'),
          throwsA(predicate((e) => e.toString().contains('Master password already exists')))
        );
      });

      test('should handle corrupted master password file', () async {
        // Create a corrupted master password file
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/master_password.hash');
        await file.writeAsString('invalid json content');
        
        expect(
          () => EncryptionService.verifyMasterPassword('anyPassword'),
          throwsA(predicate((e) => e.toString().contains('Invalid JSON format')))
        );
      });

      test('should handle empty master password file', () async {
        // Create an empty master password file
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/master_password.hash');
        await file.writeAsString('');
        
        expect(
          () => EncryptionService.verifyMasterPassword('anyPassword'),
          throwsA(predicate((e) => e.toString().contains('Master password file is empty or corrupted')))
        );
      });

      test('should handle master password file with missing fields', () async {
        // Create a master password file with missing required fields
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/master_password.hash');
        await file.writeAsString('{"hash": "somehash"}'); // Missing salt
        
        expect(
          () => EncryptionService.verifyMasterPassword('anyPassword'),
          throwsA(predicate((e) => e.toString().contains('Master password file format is invalid or corrupted')))
        );
      });

      test('should handle corrupted passwords file', () async {
        // Create a corrupted passwords file
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/encrypted_passwords.json');
        await file.writeAsString('invalid json content');
        
        expect(
          () => EncryptionService.getPasswords(),
          throwsA(predicate((e) => e.toString().contains('Corrupted password file format')))
        );
      });

      test('should handle corrupted passwords file during save', () async {
        // Create a corrupted passwords file
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/encrypted_passwords.json');
        await file.writeAsString('invalid json content');
        
        await EncryptionService.createMasterPassword('masterPassword123');
        
        expect(
          () => EncryptionService.savePassword('title', 'username', 'password', 'masterPassword123'),
          throwsA(predicate((e) => e.toString().contains('Corrupted password file format')))
        );
      });
    });

    group('Encryption/Decryption Errors', () {
      test('decryptPassword should throw error for corrupted encrypted data', () {
        expect(
          () => EncryptionService.decryptPassword('invalid_base64_data', 'masterPassword'),
          throwsA(predicate((e) => e.toString().contains('Invalid base64 encoding')))
        );
      });

      test('decryptPassword should throw error for too short encrypted data', () {
        // Create valid base64 but too short data
        final shortData = base64.encode([1, 2, 3, 4, 5]); // Less than 16 bytes
        
        expect(
          () => EncryptionService.decryptPassword(shortData, 'masterPassword'),
          throwsA(predicate((e) => e.toString().contains('Encrypted data is too short or corrupted')))
        );
      });

      test('decryptSavedPassword should propagate decryption errors', () {
        expect(
          () => EncryptionService.decryptSavedPassword('invalid_data', 'masterPassword'),
          throwsA(predicate((e) => e.toString().contains('Failed to decrypt saved password')))
        );
      });
    });

    group('Duplicate Entry Errors', () {
      test('savePassword should throw error for duplicate title and username', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        
        // Save first password
        await EncryptionService.savePassword('Test Title', 'testuser', 'password1', 'masterPassword123');
        
        // Try to save duplicate
        expect(
          () => EncryptionService.savePassword('Test Title', 'testuser', 'password2', 'masterPassword123'),
          throwsA(predicate((e) => e.toString().contains('A password entry with this title and username already exists')))
        );
      });

      test('savePassword should allow same title with different username', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        
        // Save first password
        await EncryptionService.savePassword('Test Title', 'user1', 'password1', 'masterPassword123');
        
        // Should allow same title with different username
        final result = await EncryptionService.savePassword('Test Title', 'user2', 'password2', 'masterPassword123');
        expect(result, isTrue);
      });

      test('savePassword should allow same username with different title', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        
        // Save first password
        await EncryptionService.savePassword('Title 1', 'testuser', 'password1', 'masterPassword123');
        
        // Should allow same username with different title
        final result = await EncryptionService.savePassword('Title 2', 'testuser', 'password2', 'masterPassword123');
        expect(result, isTrue);
      });
    });

    group('Delete Password Errors', () {
      test('deletePassword should throw error when passwords file not found', () async {
        expect(
          () => EncryptionService.deletePassword('title', 'username'),
          throwsA(predicate((e) => e.toString().contains('No passwords file found')))
        );
      });

      test('deletePassword should throw error when passwords file is empty', () async {
        // Create empty passwords file
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/encrypted_passwords.json');
        await file.writeAsString('[]');
        
        expect(
          () => EncryptionService.deletePassword('title', 'username'),
          throwsA(predicate((e) => e.toString().contains('Passwords file is empty')))
        );
      });

      test('deletePassword should throw error when entry not found', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        await EncryptionService.savePassword('Test Title', 'testuser', 'password', 'masterPassword123');
        
        expect(
          () => EncryptionService.deletePassword('Non Existent', 'testuser'),
          throwsA(predicate((e) => e.toString().contains('Password entry not found')))
        );
      });

      test('deletePassword should handle corrupted passwords file', () async {
        // Create a corrupted passwords file
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/encrypted_passwords.json');
        await file.writeAsString('invalid json content');
        
        expect(
          () => EncryptionService.deletePassword('title', 'username'),
          throwsA(predicate((e) => e.toString().contains('Corrupted password file format')))
        );
      });
    });

    group('Whitespace Handling', () {
      test('savePassword should trim whitespace from title and username', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        
        // Save with whitespace
        await EncryptionService.savePassword('  Test Title  ', '  testuser  ', 'password', 'masterPassword123');
        
        // Should be able to retrieve with trimmed values
        final passwords = await EncryptionService.getPasswords();
        expect(passwords.length, equals(1));
        expect(passwords[0]['title'], equals('Test Title'));
        expect(passwords[0]['username'], equals('testuser'));
      });

      test('deletePassword should handle whitespace in title and username', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        await EncryptionService.savePassword('Test Title', 'testuser', 'password', 'masterPassword123');
        
        // Should be able to delete with whitespace
        final result = await EncryptionService.deletePassword('  Test Title  ', '  testuser  ');
        expect(result, isTrue);
      });
    });

    group('Case Insensitive Matching', () {
      test('savePassword should prevent duplicate entries case-insensitively', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        
        // Save first password
        await EncryptionService.savePassword('Test Title', 'testuser', 'password1', 'masterPassword123');
        
        // Try to save with different case
        expect(
          () => EncryptionService.savePassword('TEST TITLE', 'TESTUSER', 'password2', 'masterPassword123'),
          throwsA(predicate((e) => e.toString().contains('A password entry with this title and username already exists')))
        );
      });

      test('deletePassword should find entries case-insensitively', () async {
        await EncryptionService.createMasterPassword('masterPassword123');
        await EncryptionService.savePassword('Test Title', 'testuser', 'password', 'masterPassword123');
        
        // Should be able to delete with different case
        final result = await EncryptionService.deletePassword('TEST TITLE', 'TESTUSER');
        expect(result, isTrue);
      });
    });

    group('Error Message Format', () {
      test('error messages should be descriptive and actionable', () async {
        try {
          await EncryptionService.createMasterPassword('');
        } catch (e) {
          final message = e.toString();
          expect(message, contains('Master password cannot be empty'));
          expect(message, contains('Exception'));
        }
      });

      test('error messages should include original exception details', () async {
        try {
          EncryptionService.decryptPassword('invalid_data', 'masterPassword');
        } catch (e) {
          final message = e.toString();
          expect(message, contains('Failed to decrypt password'));
          expect(message, contains('Exception'));
        }
      });
    });

    group('Integration Error Scenarios', () {
      test('should handle complete workflow with error recovery', () async {
        // Test creating master password
        final createResult = await EncryptionService.createMasterPassword('masterPassword123');
        expect(createResult, isTrue);

        // Test verifying master password
        final verifyResult = await EncryptionService.verifyMasterPassword('masterPassword123');
        expect(verifyResult, isTrue);

        // Test saving password
        final saveResult = await EncryptionService.savePassword('Test Title', 'testuser', 'password', 'masterPassword123');
        expect(saveResult, isTrue);

        // Test retrieving passwords
        final passwords = await EncryptionService.getPasswords();
        expect(passwords.length, equals(1));

        // Test decrypting password
        final decrypted = EncryptionService.decryptSavedPassword(passwords[0]['password']!, 'masterPassword123');
        expect(decrypted, equals('password'));

        // Test deleting password
        final deleteResult = await EncryptionService.deletePassword('Test Title', 'testuser');
        expect(deleteResult, isTrue);

        // Verify password was deleted
        final remainingPasswords = await EncryptionService.getPasswords();
        expect(remainingPasswords.length, equals(0));
      });

      test('should handle error when trying to save password without master password', () async {
        expect(
          () => EncryptionService.savePassword('title', 'username', 'password', 'masterPassword123'),
          throwsA(predicate((e) => e.toString().contains('Master password file not found')))
        );
      });
    });
  });
} 