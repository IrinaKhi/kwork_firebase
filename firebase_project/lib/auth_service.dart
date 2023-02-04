import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<FirebaseUser> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    FirebaseUser user = result.user;
    return user;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  Future<FirebaseUser> updateUser(UserUpdateInfo info) async {
    FirebaseUser _user = await _firebaseAuth.currentUser();
    await _user.updateProfile(info);
    await _user.reload();
    FirebaseUser updatedUser = await _firebaseAuth.currentUser();
    return updatedUser;
  }

  Future<FirebaseUser> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    FirebaseUser user = result.user;
    return user;
  }
}
