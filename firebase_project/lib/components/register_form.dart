import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_project/utils/validate_email.dart';
import 'package:firebase_project/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// // тоже страница из шаблона с гитлаб

class RegisterForm extends StatefulWidget {
  RegisterForm({Key key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthService _authService = AuthService();
  FirebaseUser user;
  bool _isSuccess = false;
  void _onSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      user = await _authService.signUp(
          _controllerEmail.text, _controllerPassword.text);
      print(user.email);
      print(user.uid);
      setState(() {
        _isSuccess = true;
      });
      _formKey.currentState.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            key: Key('fieldEmail2'),
            controller: _controllerEmail,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == '') return 'Заполните поле email';
              if (!validateEmail(value)) return 'Емейл не корректный';
              return null;
            },
          ),
          TextFormField(
            key: Key('fieldPassword2'),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            controller: _controllerPassword,
            decoration: InputDecoration(labelText: 'Password'),
            validator: (value) {
              if (value == '') return 'Заполните поле пароль';
              return null;
            },
          ),
          RaisedButton(
            child: Text('Отправить'),
            onPressed: _onSubmit,
          ),
          if (_isSuccess) Text('Вы успешно зарегистрировались')
        ],
      ),
    );
  }
}
