import 'package:flutter/material.dart';
import 'package:firebase_project/views/login_view.dart';
import 'package:firebase_project/views/profile_view.dart';
import 'package:firebase_project/views/todo_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => LoginView(),
        '/profile': (BuildContext context) => MyProfile(),
        '/todo': (BuildContext context) => MyTodo(),
      },
    );
  }
}
