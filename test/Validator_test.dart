
import 'package:dog_prototype/pages/RegisterPage.dart';
import 'package:dog_prototype/services/Validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){

  group('Validators of register page', (){
    group('Email-validator of register page', (){
      test('Empty email returns error string', (){
        var result = Validator.emailValidator('');
        expect(result, 'Please enter a valid e-mail adress');
      });

      test('email with only spaces returns error string', (){
        var result = Validator.emailValidator('     ');
        expect(result, 'Please enter a valid e-mail adress');
      });
    });

    group('Username-validator of register page', (){
      test('Empty username returns error string', (){
        var result = Validator.usernameValidator('');
        expect(result, 'Please enter a username');
      });

      test('username with only spaces returns error string', (){
        var result = Validator.usernameValidator('      ');
        expect(result, 'Please enter a username');
      });

      test('username longer than 29 characters returns error string', (){
        var result = Validator.usernameValidator('123456789123456789121212121212121212121121121212121');
        expect(result, 'Username need to be less than 30 characters long');
      });
    });

    group('Password-validator of register page', (){
      test('Empty password returns error string', (){
        var result = Validator.passwordValidator('');
        expect(result, 'Please enter a password');
      });

      test('password with only spaces returns error string', (){
        var result = Validator.passwordValidator('      ');
        expect(result, 'Please enter a password');
      });

      test('password with less than 6 characters returns error string', (){
        var result = Validator.passwordValidator('12345');
        expect(result, 'Password need to be at least 6 characters long');
      });

      test('password with more than 16 characters returns error string', (){
        var result = Validator.passwordValidator('123456789123456789');
        expect(result, 'Password need to be less than 16 characters long');
      });
    });
  });


}