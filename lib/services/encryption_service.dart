import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';

class EncryptionService {
  static const String _fileName = 'encrypted_passwords.json';
  static const String _masterPasswordFile = 'master_password.hash';
  
  // Generate a salt for password hashing
  static String generateSalt() {
    try {
      final random = Random.secure();
      final bytes = List<int>.generate(32, (i) => random.nextInt(256));
      return base64Url.encode(bytes);
    } catch (e) {
      throw Exception('Failed to generate salt: ${e.toString()}');
    }
  }
  
  // Hash the master password with salt
  static String hashPassword(String password, String salt) {
    try {
      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }
      if (salt.isEmpty) {
        throw Exception('Salt cannot be empty');
      }
      
      final bytes = utf8.encode(password + salt);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw Exception('Failed to hash password: ${e.toString()}');
    }
  }
  
  // Check if master password exists
  static Future<bool> hasMasterPassword() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_masterPasswordFile');
      return await file.exists();
    } on MissingPlatformDirectoryException catch (e) {
      throw Exception('Failed to access application directory: ${e.toString()}');
    } on FileSystemException catch (e) {
      throw Exception('File system error while checking master password: ${e.toString()}');
    } catch (e) {
      throw Exception('Unexpected error while checking master password: ${e.toString()}');
    }
  }
  
  // Create master password
  static Future<bool> createMasterPassword(String password) async {
    try {
      if (password.isEmpty) {
        throw Exception('Master password cannot be empty');
      }
      if (password.length < 8) {
        throw Exception('Master password must be at least 8 characters long');
      }
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_masterPasswordFile');
      
      // Check if master password already exists
      if (await file.exists()) {
        throw Exception('Master password already exists. Cannot create a new one.');
      }
      
      final salt = generateSalt();
      final hashedPassword = hashPassword(password, salt);
      
      final data = {
        'hash': hashedPassword,
        'salt': salt,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await file.writeAsString(jsonEncode(data));
      return true;
    } on MissingPlatformDirectoryException catch (e) {
      throw Exception('Failed to access application directory: ${e.toString()}');
    } on FileSystemException catch (e) {
      throw Exception('File system error while creating master password: ${e.toString()}');
    } on FormatException catch (e) {
      throw Exception('Data format error while creating master password: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to create master password: ${e.toString()}');
    }
  }
  
  // Verify master password
  static Future<bool> verifyMasterPassword(String password) async {
    try {
      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_masterPasswordFile');
      
      if (!await file.exists()) {
        throw Exception('Master password file not found. Please create a master password first.');
      }
      
      final content = await file.readAsString();
      if (content.isEmpty) {
        throw Exception('Master password file is empty or corrupted');
      }
      
      final data = jsonDecode(content);
      if (data == null || data['hash'] == null || data['salt'] == null) {
        throw Exception('Master password file format is invalid or corrupted');
      }
      
      final storedHash = data['hash'];
      final salt = data['salt'];
      
      final hashedPassword = hashPassword(password, salt);
      return hashedPassword == storedHash;
    } on MissingPlatformDirectoryException catch (e) {
      throw Exception('Failed to access application directory: ${e.toString()}');
    } on FileSystemException catch (e) {
      throw Exception('File system error while verifying master password: ${e.toString()}');
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format in master password file: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to verify master password: ${e.toString()}');
    }
  }
  
  // Encrypt a password
  static String encryptPassword(String password, String masterPassword) {
    try {
      if (password.isEmpty) {
        return '';
      }
      if (masterPassword.isEmpty) {
        throw Exception('Master password cannot be empty for encryption');
      }
      
      final key = Key.fromUtf8(masterPassword.padRight(32, '0').substring(0, 32));
      final iv = IV.fromSecureRandom(16);
      
      final encrypter = Encrypter(AES(key));
      final encrypted = encrypter.encrypt(password, iv: iv);
      
      // Return IV + encrypted data as base64
      final combined = iv.bytes + encrypted.bytes;
      return base64.encode(combined);
    } on ArgumentError catch (e) {
      throw Exception('Invalid encryption parameters: ${e.toString()}');
    } on FormatException catch (e) {
      throw Exception('Encoding error during encryption: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to encrypt password: ${e.toString()}');
    }
  }
  
  // Decrypt a password
  static String decryptPassword(String encryptedPassword, String masterPassword) {
    try {
      if (encryptedPassword.isEmpty) {
        return '';
      }
      if (masterPassword.isEmpty) {
        throw Exception('Master password cannot be empty for decryption');
      }
      
      final key = Key.fromUtf8(masterPassword.padRight(32, '0').substring(0, 32));
      
      final combined = base64.decode(encryptedPassword);
      if (combined.length < 16) {
        throw Exception('Encrypted data is too short or corrupted');
      }
      
      final iv = IV(combined.sublist(0, 16));
      final encrypted = Encrypted(combined.sublist(16));
      
      final encrypter = Encrypter(AES(key));
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      return decrypted;
    } on FormatException catch (e) {
      throw Exception('Invalid base64 encoding in encrypted password: ${e.toString()}');
    } on ArgumentError catch (e) {
      throw Exception('Invalid decryption parameters: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to decrypt password: ${e.toString()}');
    }
  }
  
  // Save encrypted password
  static Future<bool> savePassword(String title, String username, String password, String masterPassword) async {
    try {
      if (title.trim().isEmpty) {
        throw Exception('Title cannot be empty');
      }
      if (username.trim().isEmpty) {
        throw Exception('Username cannot be empty');
      }
      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }
      if (masterPassword.isEmpty) {
        throw Exception('Master password cannot be empty');
      }
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      
      List<Map<String, String>> passwords = [];
      
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          try {
            passwords = List<Map<String, String>>.from(
              jsonDecode(content).map((item) => Map<String, String>.from(item))
            );
          } on FormatException catch (e) {
            throw Exception('Corrupted password file format: ${e.toString()}');
          }
        }
      }
      
      // Check for duplicate entries
      final existingIndex = passwords.indexWhere((p) => 
        p['title']?.toLowerCase() == title.toLowerCase() && 
        p['username']?.toLowerCase() == username.toLowerCase()
      );
      
      if (existingIndex != -1) {
        throw Exception('A password entry with this title and username already exists');
      }
      
      final encryptedPassword = encryptPassword(password, masterPassword);
      
      passwords.add({
        'title': title.trim(),
        'username': username.trim(),
        'password': encryptedPassword,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await file.writeAsString(jsonEncode(passwords));
      return true;
    } on MissingPlatformDirectoryException catch (e) {
      throw Exception('Failed to access application directory: ${e.toString()}');
    } on FileSystemException catch (e) {
      throw Exception('File system error while saving password: ${e.toString()}');
    } on FormatException catch (e) {
      throw Exception('Data format error while saving password: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to save password: ${e.toString()}');
    }
  }
  
  // Get all saved passwords (encrypted)
  static Future<List<Map<String, String>>> getPasswords() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      
      if (!await file.exists()) return [];
      
      final content = await file.readAsString();
      if (content.isEmpty) return [];
      
      try {
        return List<Map<String, String>>.from(
          jsonDecode(content).map((item) => Map<String, String>.from(item))
        );
      } on FormatException catch (e) {
        throw Exception('Corrupted password file format: ${e.toString()}');
      }
    } on MissingPlatformDirectoryException catch (e) {
      throw Exception('Failed to access application directory: ${e.toString()}');
    } on FileSystemException catch (e) {
      throw Exception('File system error while reading passwords: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to retrieve passwords: ${e.toString()}');
    }
  }
  
  // Decrypt a specific password
  static String decryptSavedPassword(String encryptedPassword, String masterPassword) {
    try {
      return decryptPassword(encryptedPassword, masterPassword);
    } catch (e) {
      throw Exception('Failed to decrypt saved password: ${e.toString()}');
    }
  }
  
  // Delete a specific password entry
  static Future<bool> deletePassword(String title, String username) async {
    try {
      if (title.trim().isEmpty) {
        throw Exception('Title cannot be empty');
      }
      if (username.trim().isEmpty) {
        throw Exception('Username cannot be empty');
      }
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      
      if (!await file.exists()) {
        throw Exception('No passwords file found');
      }
      
      final content = await file.readAsString();
      if (content.isEmpty) {
        throw Exception('Passwords file is empty');
      }
      
      List<Map<String, String>> passwords;
      try {
        passwords = List<Map<String, String>>.from(
          jsonDecode(content).map((item) => Map<String, String>.from(item))
        );
      } on FormatException catch (e) {
        throw Exception('Corrupted password file format: ${e.toString()}');
      }
      
      final initialLength = passwords.length;
      passwords.removeWhere((p) => 
        p['title']?.toLowerCase() == title.toLowerCase() && 
        p['username']?.toLowerCase() == username.toLowerCase()
      );
      
      if (passwords.length == initialLength) {
        throw Exception('Password entry not found');
      }
      
      await file.writeAsString(jsonEncode(passwords));
      return true;
    } on MissingPlatformDirectoryException catch (e) {
      throw Exception('Failed to access application directory: ${e.toString()}');
    } on FileSystemException catch (e) {
      throw Exception('File system error while deleting password: ${e.toString()}');
    } on FormatException catch (e) {
      throw Exception('Data format error while deleting password: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to delete password: ${e.toString()}');
    }
  }
  
  // Clear all passwords (for testing or reset purposes)
  static Future<bool> clearAllPasswords() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final passwordsFile = File('${directory.path}/$_fileName');
      final masterPasswordFile = File('${directory.path}/$_masterPasswordFile');
      
      if (await passwordsFile.exists()) {
        await passwordsFile.delete();
      }
      
      if (await masterPasswordFile.exists()) {
        await masterPasswordFile.delete();
      }
      
      return true;
    } on MissingPlatformDirectoryException catch (e) {
      throw Exception('Failed to access application directory: ${e.toString()}');
    } on FileSystemException catch (e) {
      throw Exception('File system error while clearing passwords: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to clear passwords: ${e.toString()}');
    }
  }
} 