class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class PasswordMismatchException extends ApiException {
  const PasswordMismatchException(super.message);
}

class DuplicateEmailException extends ApiException {
  const DuplicateEmailException(super.message);
}
