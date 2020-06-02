import 'package:dog_prototype/services/Authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth{}
class MockFirebaseUser extends Mock implements FirebaseUser{}
class MockAuthResult extends Mock implements AuthResult{}
class MockAuthCredentials extends Mock implements AuthCredential{}
class MockEmailAuthProvider extends Mock implements EmailAuthProvider{}
class MockAuthService extends Mock implements AuthService{

  final FirebaseAuth auth;

  MockAuthService.instance({this.auth}){
    auth.onAuthStateChanged.listen((event) {return event;});
  }

  Future signInWithEmailAndPassword(String email, String password) async{
    try{
      AuthResult result = await auth.signInWithEmailAndPassword(email: email, password: password);
      if(result != null){
        return true;
      }
      return false;
    }catch(e){
      print(e);
      return null;
    }
  }

  //sign out
  Future signOut() async{
    try{
      auth.signOut();
      Future.delayed(Duration.zero);
      return true;
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  resetPasswordUsingEmail(String email)async{
    try{
      await auth.sendPasswordResetEmail(email: email);
      return true;
    }catch(e){
      print(e);
      return null;
    }
  }

}

void main(){
  MockFirebaseAuth _auth = MockFirebaseAuth();
  BehaviorSubject<MockFirebaseUser> _user = BehaviorSubject<MockFirebaseUser>();
  when(_auth.onAuthStateChanged).thenAnswer((_){
    return _user;
  });
  MockAuthService _authService = MockAuthService.instance(auth:_auth);


  group('Authentication AuthService Testsuite', (){

    when(_auth.signInWithEmailAndPassword(email: "email", password: "password")).
    thenAnswer((_)async{
      _user.add(MockFirebaseUser());
      return MockAuthResult();
    });
    when(_auth.signInWithEmailAndPassword(email: "throw", password: "throw")).thenThrow((_)async{
      _user.add(MockFirebaseUser());
      return MockAuthResult();
    });

    test('sign in with correct email and password returns true', () async{
      bool signedIn = await _authService.signInWithEmailAndPassword("email", "password");
      expect(signedIn, true);
    });
    test('sign in with wrong email returns false', () async{
      bool signedIn = await _authService.signInWithEmailAndPassword("emailwrong", "password");
      expect(signedIn, false);
    });
    test('sign in with wrong password returns false', () async{
      bool signedIn = await _authService.signInWithEmailAndPassword("email", "passwordwrong");
      expect(signedIn, false);
    });
    test('sign in with wrong email and password returns false', () async{
      bool signedIn = await _authService.signInWithEmailAndPassword("emailwrong", "passwordwrong");
      expect(signedIn, false);
    });
    test('sign in method throws null', () async{
      bool signedIn = await _authService.signInWithEmailAndPassword("throw", "throw");
      expect(signedIn, null);
    });

    test('sign out', () async{
      dynamic result = await _authService.signOut();

      expect(result, true);
    });

    when(_auth.sendPasswordResetEmail(email: 'throw')).thenThrow((_) async{});

    test('reset password using email', () async{
      dynamic result = await _authService.resetPasswordUsingEmail('email');

      expect(result, true);
    });

    test('reset password throw throws null', () async{
      dynamic result = await _authService.resetPasswordUsingEmail('throw');

      expect(result, null);
    });

  });
}