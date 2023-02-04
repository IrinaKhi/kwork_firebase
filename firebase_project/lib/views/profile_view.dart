import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_project/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MyProfile extends StatefulWidget {
  static const routeName = '/profile';
  MyProfile({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthService _authService = AuthService();
  FirebaseUser user;

  File _image;
  final picker = ImagePicker();

  bool _emailVerified = false;

  @override
  void initState() {
    verifyEmail();
    // TO DO implement initState
    super.initState();
    getUser();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future getUser() async {
    var _user = await _authService.getCurrentUser();
    setState(() {
      user = _user;
    });
  }

  Future saveImage() async {
    user = await _authService.getCurrentUser();
    UserUpdateInfo updateInfo = UserUpdateInfo();
    final StorageReference storageReference =
        FirebaseStorage().ref().child('users/${user.uid}/avatar.jpg');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    updateInfo.photoUrl = downloadUrl;
    FirebaseUser updateUser = await _authService.updateUser(updateInfo);
    Navigator.of(context).pushNamed('/profile');
    print(updateUser.photoUrl);
  }

  Future sendEmail() async {
    FirebaseUser user = await _authService.getCurrentUser();
    user.sendEmailVerification();
  }

  Future verifyEmail() async {
    FirebaseUser user = await _authService.getCurrentUser();
    _emailVerified = user.isEmailVerified;
    print(_emailVerified);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: _image == null
                                  ? Text('')
                                  : Column(
                                      children: <Widget>[
                                        Image.file(_image),
                                        RaisedButton(
                                          child: Text('Сохранить изображение'),
                                          onPressed: saveImage,
                                        ),
                                      ],
                                    ),
                            ),
                            GestureDetector(
                              // чтоб по клику менял аватар
                              onTap: () {
                                getImage();
                              },
                              child: Container(
                                child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: (user.photoUrl == null)
                                        ? AssetImage('assets/images/camera.jpg')
                                        : NetworkImage(user.photoUrl)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                user.email,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            _emailVerified // разные страницы для верифицировавших имейл и нет
                                ? Padding(
                                    // подтвердившие могут идти к задачам
                                    padding: EdgeInsets.only(top: 40),
                                    child: FlatButton(
                                      color: Colors.transparent,
                                      child: Text('ToDo',
                                          style: TextStyle(fontSize: 16.0)),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed('/todo');
                                      },
                                    ),
                                  )
                                : Container(
                                    // не подтвердившие пока в профайле
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 20),
                                          child: Text(
                                            'Подтвердите Email  ' + user.email,
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 20),
                                          child: FlatButton(
                                            color: Colors.transparent,
                                            child: Text('Отправить Email',
                                                style:
                                                    TextStyle(fontSize: 16.0)),
                                            onPressed: () {
                                              sendEmail();
                                            },
                                          ),
                                        ),
                                        Padding(
                                          // на перелогинивание, так как без него не меняется статус верификации
                                          padding: EdgeInsets.only(top: 20),
                                          child: FlatButton(
                                            color: Colors.transparent,
                                            child: Text('Проверить',
                                                style:
                                                    TextStyle(fontSize: 16.0)),
                                            onPressed: () {
                                              _authService.signOut();
                                              Navigator.of(context)
                                                  .pushNamed('/');
                                              print(_emailVerified);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      color: Colors.transparent,
                      child: Text('Выход', style: TextStyle(fontSize: 16.0)),
                      onPressed: () {
                        _authService.signOut();
                        Navigator.of(context).pushNamed('/');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
