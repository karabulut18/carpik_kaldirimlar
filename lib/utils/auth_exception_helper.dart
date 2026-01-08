import 'package:firebase_auth/firebase_auth.dart';

class AuthExceptionHelper {
  static String generateErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'invalid-credential':
          return 'Kullanıcı bulunamadı veya bilgiler hatalı.';
        case 'wrong-password':
          return 'Hatalı şifre. Lütfen tekrar deneyin.';
        case 'email-already-in-use':
          return 'Bu e-posta adresi zaten kullanımda.';
        case 'invalid-email':
          return 'Geçersiz e-posta formatı.';
        case 'weak-password':
          return 'Şifre çok zayıf. En az 6 karakter olmalı.';
        case 'operation-not-allowed':
          return 'Bu giriş yöntemi şu an devre dışı.';
        case 'network-request-failed':
          return 'İnternet bağlantınızı kontrol edin.';
        case 'too-many-requests':
          return 'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin.';
        case 'user-disabled':
          return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
        default:
          return 'Bir hata oluştu: ${error.message}';
      }
    }
    return 'Beklenmedik bir hata oluştu: ${error.toString()}';
  }
}
