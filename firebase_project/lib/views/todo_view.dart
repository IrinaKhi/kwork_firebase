import 'package:firebase_project/utils/dialog.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MyTodo extends StatefulWidget {
  static const routeName = '/todo';
  MyTodo({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyTodoState createState() => _MyTodoState();
}

class _MyTodoState extends State<MyTodo> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final dbRef = Firestore.instance;

  _saveTodo() async {
    DocumentReference ref = await dbRef.collection('todos').add(
      {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isDone': false,
      },
    );
    print(ref.documentID);
  }

  String _mydocumentID; // понадобится ID задач

  void _updateIsDoneTrue() async {
    //  переключает в базе IsDone в одну сторону
    await dbRef // подчеркивание не знаю как убрать
        .collection('todos')
        .document(_mydocumentID)
        .updateData({'isDone': true});
  }

  void _updateIsDoneFalse() async {
    // переключает в другую сторону
    await dbRef
        .collection('todos')
        .document(_mydocumentID)
        .updateData({'isDone': false});
  }

  void _submit() {
    // проверка валидности и сохранение задач
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _saveTodo();
      _formKey.currentState.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('ToDo'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    // форма добавления задач
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _titleController,
                          decoration:
                              InputDecoration(labelText: 'Новая задача'),
                          validator: (value) {
                            if (value == '')
                              return 'Введите текст';
                            else
                              return null;
                          },
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(labelText: 'Описание'),
                          validator: (value) {
                            if (value == '')
                              return 'Введите текст';
                            else
                              return null;
                          },
                        ),
                        RaisedButton(
                          onPressed: _submit,
                          child: Text('Создать'),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  // развертывание задач в списке
                  child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection('todos').snapshots(),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot,
                    ) {
                      print(snapshot.connectionState);
                      return ListView(
                        children: <Widget>[
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            Center(child: CircularProgressIndicator()),
                          if (snapshot.hasData)
                            ...snapshot.data.documents
                                .map(
                                  (todo) => GestureDetector(
                                    // каждая задача долгим нажатием открывается для правки в всплывающем окне
                                    onLongPress: () {
                                      print('исправление');

                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return DialogDrawer()
                                                .getDrawer(context, todo);
                                          });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue),
                                      ),
                                      child: CheckboxListTile(
                                        // с этим я разобралась, а Dismissible слишком сложный, хоть и красивый :-)
                                        title: Text(todo['title']),
                                        subtitle: Text('${todo['isDone']}'),
                                        secondary: Text(todo['description']),
                                        value: todo[
                                            'isDone'], // галочки соответствуют переменным в базе
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        onChanged: (bool value) {
                                          setState(() {
                                            print(value);
                                            print(todo['title']);
                                            print(todo.documentID);
                                            print('${todo['isDone']}');
                                            _mydocumentID = todo.documentID;

                                            todo['isDone'] ==
                                                    false // по клику переключает переменную на противоположную
                                                ? _updateIsDoneTrue()
                                                : _updateIsDoneFalse();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
