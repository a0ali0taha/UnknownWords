import 'package:flutter_test/flutter_test.dart';
import 'package:enc/services/encryption_service.dart';
import 'dart:convert';

void main() {
  group('EncryptionService Tests', () {
    group('Password Encryption/Decryption', () {
      const testPassword = 'mySecretPassword123';
      const masterPassword = 'masterPassword456';

      test('encryptPassword should encrypt password successfully', () {
        final encrypted = EncryptionService.encryptPassword(testPassword, masterPassword);
        
        expect(encrypted, isA<String>());
        expect(encrypted.length, greaterThan(0));
        expect(encrypted, isNot(equals(testPassword)));
      });

      test('decryptPassword should decrypt password correctly', () {
        final encrypted = EncryptionService.encryptPassword(testPassword, masterPassword);
        final decrypted = EncryptionService.decryptPassword(encrypted, masterPassword);
        
        expect(decrypted, equals(testPassword));
      });

      test('encryptPassword should produce different results for same input', () {
        final encrypted1 = EncryptionService.encryptPassword(testPassword, masterPassword);
        final encrypted2 = EncryptionService.encryptPassword(testPassword, masterPassword);
        
        expect(encrypted1, isNot(equals(encrypted2)));
      });

      test('decryptPassword should fail with wrong master password', () {
        final encrypted = EncryptionService.encryptPassword(testPassword, masterPassword);
        
        expect(() {
          EncryptionService.decryptPassword(encrypted, 'wrongMasterPassword');
        }, throwsA(anything));
      });

      test('decryptSavedPassword should work correctly', () {
        final encrypted = EncryptionService.encryptPassword(testPassword, masterPassword);
        final decrypted = EncryptionService.decryptSavedPassword(encrypted, masterPassword);
        
        expect(decrypted, equals(testPassword));
      });

      test('should handle empty password', () {
        final encrypted = EncryptionService.encryptPassword('', masterPassword);
        final decrypted = EncryptionService.decryptPassword(encrypted, masterPassword);
        
        expect(decrypted, equals(''));
      });

      test('should handle special characters in password', () {
        const specialPassword = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
        final encrypted = EncryptionService.encryptPassword(specialPassword, masterPassword);
        final decrypted = EncryptionService.decryptPassword(encrypted, masterPassword);
        
        expect(decrypted, equals(specialPassword));
      });

      test('should handle unicode characters in password', () {
        const unicodePassword = '🔐密码123ñáéíóú';
        final encrypted = EncryptionService.encryptPassword(unicodePassword, masterPassword);
        final decrypted = EncryptionService.decryptPassword(encrypted, masterPassword);
        
        expect(decrypted, equals(unicodePassword));
      });

      test('should handle very long password', () {
        final longPassword = 'a' * 1000;
        final encrypted = EncryptionService.encryptPassword(longPassword, masterPassword);
        final decrypted = EncryptionService.decryptPassword(encrypted, masterPassword);
        
        expect(decrypted, equals(longPassword));
      });
    });

    group('Password Hashing', () {
      test('hashPassword should produce consistent results', () {
        const password = 'testPassword';
        const salt = 'testSalt';
        
        final hash1 = EncryptionService.hashPassword(password, salt);
        final hash2 = EncryptionService.hashPassword(password, salt);
        
        expect(hash1, equals(hash2));
        expect(hash1, isA<String>());
        expect(hash1.length, greaterThan(0));
      });

      test('hashPassword should produce different results for different salts', () {
        const password = 'testPassword';
        const salt1 = 'salt1';
        const salt2 = 'salt2';
        
        final hash1 = EncryptionService.hashPassword(password, salt1);
        final hash2 = EncryptionService.hashPassword(password, salt2);
        
        expect(hash1, isNot(equals(hash2)));
      });

      test('generateSalt should produce different salts', () {
        final salt1 = EncryptionService.generateSalt();
        final salt2 = EncryptionService.generateSalt();
        
        expect(salt1, isNot(equals(salt2)));
        expect(salt1, isA<String>());
        expect(salt1.length, greaterThan(0));
      });
    });

    group('Key Generation', () {
      test('should handle short master password', () {
        const shortMasterPassword = 'short';
        const testPassword = 'testPassword';
        
        final encrypted = EncryptionService.encryptPassword(testPassword, shortMasterPassword);
        final decrypted = EncryptionService.decryptPassword(encrypted, shortMasterPassword);
        
        expect(decrypted, equals(testPassword));
      });

      test('should handle long master password', () {
        final longMasterPassword = 'a' * 100;
        const testPassword = 'testPassword';
        
        final encrypted = EncryptionService.encryptPassword(testPassword, longMasterPassword);
        final decrypted = EncryptionService.decryptPassword(encrypted, longMasterPassword);
        
        expect(decrypted, equals(testPassword));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle null-like empty strings', () {
        const masterPassword = 'masterPassword';
        
        final encrypted = EncryptionService.encryptPassword('', masterPassword);
        final decrypted = EncryptionService.decryptPassword(encrypted, masterPassword);
        
        expect(decrypted, equals(''));
      });

      test('should handle single character passwords', () {
        const masterPassword = 'masterPassword';
        const testPassword = 'a';
        
        final encrypted = EncryptionService.encryptPassword(testPassword, masterPassword);
        final decrypted = EncryptionService.decryptPassword(encrypted, masterPassword);
        
        expect(decrypted, equals(testPassword));
      });

      test('should handle very short master password', () {
        const masterPassword = 'a';
        const testPassword = 'testPassword';
        
        final encrypted = EncryptionService.encryptPassword(testPassword, masterPassword);
        final decrypted = EncryptionService.decryptPassword(encrypted, masterPassword);
        
        expect(decrypted, equals(testPassword));
      });

      test('should handle master password with only special characters', () {
        const masterPassword = '!@#\$%^&*()';
        const testPassword = 'testPassword';
        
        final encrypted = EncryptionService.encryptPassword(testPassword, masterPassword);
        final decrypted = EncryptionService.decryptPassword(encrypted, masterPassword);
        
        expect(decrypted, equals(testPassword));
      });
    });
  });
} 