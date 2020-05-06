import 'package:flutter_test/flutter_test.dart';
import 'package:dog_prototype/pages/LoginPage.dart';

void main(){

  /**
   * TESTING USERNAME VALIDATOR AND PASSWORD VALIDATOR
   */
  test('Empty username returns error string', (){
    var result = UserNameValidator.validate('');
    expect(result, 'Username cant be empty');
  });

  test('non-empty username returns null', (){
    var result = UserNameValidator.validate('username');
    expect(result, null);
  });

  test('Empty password returns error string', (){
    var result = PasswordValidator.validate('');
    expect(result, 'Password cant be empty');
  });

  test('non-empty password returns null', (){
    var result = PasswordValidator.validate('password');
    expect(result, null);
  });
}