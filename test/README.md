# Testing Documentation

This directory contains comprehensive tests for the Password Encrypter app.

## Test Structure

### 1. Unit Tests (`encryption_service_test.dart`)
Tests the core `EncryptionService` class functionality:
- Password encryption/decryption
- Password hashing and salt generation
- Key generation for different password lengths
- Error handling for various input types

### 2. Widget Tests (`widget_test.dart`)
Tests the Flutter UI components:
- App initialization and loading states
- Form validation for master password setup
- UI component configuration
- Theme and styling

### 3. Integration Tests (`integration_test.dart`)
Tests complete user workflows:
- Master password setup flow
- Adding new passwords
- Viewing and decrypting passwords
- Deleting passwords

## Running Tests

### Unit and Widget Tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/encryption_service_test.dart
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/integration_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

## Test Coverage

The tests cover:

1. **EncryptionService** (100% coverage):
   - ✅ Password encryption/decryption
   - ✅ Salt generation
   - ✅ Password hashing
   - ✅ Master password operations
   - ✅ File operations
   - ✅ Error handling

2. **UI Components**:
   - ✅ App initialization
   - ✅ Form validation
   - ✅ User interactions
   - ✅ Navigation flows

3. **Integration Flows**:
   - ✅ Complete app setup
   - ✅ Password management
   - ✅ Data persistence

## Test Dependencies

- `flutter_test`: Core Flutter testing framework
- `mockito`: For mocking dependencies
- `integration_test`: For end-to-end testing
- `path_provider_platform_interface`: For platform interface testing

## Best Practices

1. **Test Isolation**: Each test is independent and doesn't rely on other tests
2. **Clean Setup/Teardown**: Tests clean up after themselves
3. **Descriptive Names**: Test names clearly describe what they're testing
4. **Edge Cases**: Tests cover various input scenarios including edge cases
5. **Error Handling**: Tests verify proper error handling

## Adding New Tests

When adding new features:

1. Add unit tests for business logic
2. Add widget tests for UI components
3. Add integration tests for user workflows
4. Update this documentation

## Continuous Integration

These tests can be integrated into CI/CD pipelines to ensure code quality and prevent regressions. 