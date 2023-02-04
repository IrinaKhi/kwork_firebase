import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_project/utils/validate_email.dart';
import 'package:firebase_project/auth_service.dart';

// тоже страница из шаблона с гитлаб для домашнего задания

class LoginForm extends StatefulWidget {
  LoginForm({Key key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthService _authService = AuthService();
  FirebaseUser user;
  bool _successMessage = false;

  void _onSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      user = await _authService.signIn(
          _controllerEmail.text, _controllerPassword.text);
      print(user.email);
      print(user.uid);
      setState(() {
        _successMessage = true;
      });
      _formKey.currentState.reset();
      Navigator.of(context).pushNamed('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            key: Key('fieldEmail'),
            validator: (value) {
              if (value == '') return 'Введите email';
              if (!validateEmail(value))
                return 'Поле email заполнено не корректно';
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            controller: _controllerEmail,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextFormField(
            key: Key('fieldPassword'),
            validator: (value) {
              if (value == '') return 'Введите пароль';
              return null;
            },
            controller: _controllerPassword,
            decoration: InputDecoration(labelText: 'Password'),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
          ),
          RaisedButton(
            child: Text('Войти'),
            onPressed: _onSubmit,
          ),
          if (_successMessage) Text('Добро пожаловать'),
        ],
      ),
    );
  }
}
