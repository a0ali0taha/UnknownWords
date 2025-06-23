# 🔐 UnknownWords - Secure Password Manager

A robust Flutter application for securely storing and managing passwords with advanced encryption capabilities and comprehensive error handling.

[![Flutter](https://img.shields.io/badge/Flutter-3.29.3-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.4.0-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen.svg)](https://github.com/a0ali0taha/UnknownWords)

## 🚀 Features

### 🔒 Security Features
- **AES-256 Encryption**: Military-grade encryption for password storage
- **Master Password Protection**: Single master password to access all stored passwords
- **Salt-based Hashing**: Secure password hashing with unique salts
- **Local Storage**: All data stored locally on device for maximum privacy

### 🛡️ Error Handling & Validation
- **Comprehensive Input Validation**: Validates all user inputs with meaningful error messages
- **File System Error Handling**: Robust handling of file operations and data corruption
- **Data Integrity Checks**: Validates stored data format and structure
- **Graceful Error Recovery**: Detailed error messages for debugging and user feedback

### 📱 User Experience
- **Intuitive Interface**: Clean and modern Flutter UI
- **Password Organization**: Store passwords with titles and usernames
- **Duplicate Prevention**: Prevents duplicate entries with case-insensitive matching
- **Whitespace Handling**: Automatic trimming of input fields

## 🏗️ Architecture

### Core Components

```
lib/
├── services/
│   └── encryption_service.dart    # Core encryption and storage logic
├── main.dart                      # Application entry point
└── ...
```

### Key Services

#### EncryptionService
- **Password Encryption/Decryption**: AES-256 encryption with IV
- **Master Password Management**: Creation, verification, and secure storage
- **File Operations**: Secure reading/writing of encrypted data
- **Data Validation**: Comprehensive input and data integrity validation

## 🛠️ Installation

### Prerequisites
- Flutter SDK (3.29.3 or higher)
- Dart SDK (3.4.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/a0ali0taha/UnknownWords.git
   cd UnknownWords
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## 📦 Dependencies

### Core Dependencies
- **crypto**: For SHA-256 hashing and salt generation
- **encrypt**: For AES-256 encryption/decryption
- **path_provider**: For secure file system access

### Development Dependencies
- **flutter_test**: For unit and widget testing
- **integration_test**: For end-to-end testing

## 🧪 Testing

The project includes comprehensive test coverage:

### Test Categories
- **Unit Tests**: Core functionality testing
- **Error Handling Tests**: Comprehensive error scenario validation
- **Integration Tests**: End-to-end workflow testing

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/encryption_service_test.dart

# Run error handling tests
flutter test test/encryption_service_error_test.dart
```

## 🔧 Usage

### First Time Setup
1. Launch the application
2. Create a master password (minimum 8 characters)
3. The master password is securely hashed and stored locally

### Managing Passwords
1. **Add Password**: Enter title, username, and password
2. **View Passwords**: Access stored passwords using master password
3. **Delete Password**: Remove specific password entries
4. **Security**: All operations require master password verification

### Security Best Practices
- Use a strong, unique master password
- Never share your master password
- Regularly backup your device
- Keep the application updated

## 🛡️ Security Implementation

### Encryption Details
- **Algorithm**: AES-256 in CBC mode
- **Key Derivation**: Master password padded to 32 bytes
- **IV Generation**: Secure random initialization vectors
- **Data Format**: Base64 encoded IV + encrypted data

### Password Hashing
- **Algorithm**: SHA-256
- **Salt**: 32-byte cryptographically secure random salt
- **Storage**: Salt + hash stored in JSON format

### File Security
- **Location**: Application documents directory
- **Format**: JSON with encrypted data
- **Access**: Local device only, no cloud sync

## 🐛 Error Handling

### Input Validation
- Empty field detection
- Minimum length requirements
- Format validation
- Duplicate entry prevention

### File System Errors
- Missing directory handling
- Corrupted file detection
- JSON format validation
- Permission error handling

### Encryption Errors
- Invalid key handling
- Corrupted data detection
- Base64 decoding errors
- IV extraction failures

## 📊 Project Structure

```
UnknownWords/
├── lib/
│   ├── services/
│   │   └── encryption_service.dart
│   └── main.dart
├── test/
│   ├── encryption_service_test.dart
│   ├── encryption_service_error_test.dart
│   ├── integration_test.dart
│   └── widget_test.dart
├── android/
├── ios/
├── web/
├── pubspec.yaml
└── README.md
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart coding conventions
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/a0ali0taha/UnknownWords/issues) page
2. Create a new issue with detailed information
3. Include error messages and steps to reproduce

## 🔄 Version History

### Current Version
- **v1.0.0**: Initial release with comprehensive error handling
- Enhanced encryption service with robust error management
- Comprehensive test suite with error scenario coverage
- Professional documentation and project structure

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Crypto and encryption package maintainers
- Open source community for inspiration and tools

---

**⚠️ Disclaimer**: This application is for educational and personal use. Always follow security best practices and never store highly sensitive information without additional security measures.

**🔗 Repository**: [https://github.com/a0ali0taha/UnknownWords](https://github.com/a0ali0taha/UnknownWords)







