import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Future<void> signOut() async {
  //   await _firebaseAuth.signOut();
  // }

  Future<String?> signInWithPhoneNumber(String phoneNumber,
      {required Function(String?) onVerificationId, required Function(String) onError}) async {
    String? verificationIdGen;
    try {
      final PhoneVerificationCompleted verificationCompleted = (AuthCredential phoneAuthCredential) async {
        await _firebaseAuth.signInWithCredential(phoneAuthCredential);
      };
      final PhoneVerificationFailed verificationFailed = (FirebaseAuthException authException) {
        onError('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
        print('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      };
      final PhoneCodeSent codeSent = (String? verificationId, [int? forceResendingToken]) {
        print('Please check your phone for the verification code.');
        verificationIdGen = verificationId;
        onVerificationId(verificationId);
      };
      final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
        // verificationIdGen = verificationId;
        // onVerificationId(verificationId);
      };
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 25),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      print(e.toString());
      // TODO: Handle error
    }
    return verificationIdGen;
  }

  Future<bool> signInWithSmsCode(String smsCode, String verificationId) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      await _firebaseAuth.signInWithCredential(credential);
      return true;
    } catch (e) {
      print(e.toString());
      // TODO: Handle error
    }
    return false;
  }
}
