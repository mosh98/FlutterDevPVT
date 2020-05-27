class Validator{

  static String emailValidator(String input){
    return input.isEmpty || input.trim().isEmpty ? 'Please enter a valid e-mail adress' : null;
  }

  static String passwordValidator(String input){
    if(input.isEmpty || input.trim().isEmpty){
      return 'Please enter a password';
    }else if(input.length < 6){
      return 'Password need to be at least 6 characters long';
    }else if(input.length > 16){
      return 'Password need to be less than 16 characters long';
    }else{
      return null;
    }
  }

  static String usernameValidator(String input){
    if(input.isEmpty || input.trim().isEmpty){
      return 'Please enter a username';
    }else if(input.length > 29){
      return 'Username need to be less than 30 characters long';
    }else{
      return null;
    }
  }
}