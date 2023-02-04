import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DialogDrawer {
  GlobalKey<FormState> _formEditKey = GlobalKey<FormState>();
  TextEditingController _titleEditController = TextEditingController();
  TextEditingController _descriptionEditController = TextEditingController();
  String _mydocumentID;
  final dbRef = Firestore.instance;

  void _submitEdit() {
    if (_formEditKey.currentState.validate()) {
      _formEditKey.currentState.save();
      _updateTodo();
      //   _formEditKey.currentState.reset(); убрали чтоб не стирал
      // до начального текста
    }
  }

  void _updateTodo() async {
    await dbRef.collection('todos').document(_mydocumentID).updateData({
      'title': _titleEditController.text,
      'description': _descriptionEditController.text
    });
  }

  void _deleteTodo() async {
    // удаляем задачи
    await dbRef.collection('todos').document(_mydocumentID).delete();
  }

  getDrawer(context, todo) {
    return Drawer(
      child: Card(
        margin: EdgeInsets.only(top: 100, bottom: 100),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 20, left: 10, right: 10),
          child: Form(
            // форма для правки - такая же как и для добавления
            key: _formEditKey,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Редактирование',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      TextFormField(
                        // в поле формы добавляем начальный текст задачи
                        controller: _titleEditController..text = todo['title'],
                        onChanged: (text) => {},
                        decoration: InputDecoration(labelText: 'Задача'),
                        validator: (value) {
                          if (value == '')
                            return 'Введите текст';
                          else
                            return null;
                        },
                      ),
                      TextFormField(
                        controller: _descriptionEditController
                          ..text = todo['description'],
                        onChanged: (text) => {},
                        decoration: InputDecoration(labelText: 'Описание'),
                        validator: (value) {
                          if (value == '')
                            return 'Введите текст';
                          else
                            return null;
                        },
                      ),
                      Row(
                        // две кнопки рядом - для удобства
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FlatButton(
                              color: Colors.transparent,
                              child: Text('Отправить',
                                  style: TextStyle(fontSize: 18.0)),
                              onPressed: () {
                                _mydocumentID = todo.documentID;
                                print(_titleEditController.text);
                                print(_descriptionEditController.text);
                                print(_mydocumentID);
                                _submitEdit();
                                if (_formEditKey
                                    .currentState //отправляем на обновлением и закрываем окно
                                    .validate()) {
                                  Navigator.of(context).pop();
                                }
                              }),
                          FlatButton(
                              color: Colors.transparent,
                              child: Text(
                                  'Вернуться', // иногда удобнее кликнуть рядом
                                  style: TextStyle(fontSize: 18.0)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  // удаляем задачу и закрываем окно
                  color: Colors.transparent,
                  child: Text('Удалить', style: TextStyle(fontSize: 18.0)),
                  onPressed: () {
                    _mydocumentID = todo.documentID;
                    _deleteTodo();
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
