import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];
  final _controller = TextEditingController();

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPosition;

  void _addToDo() {
    setState(() {
      if (_controller.text != "") {
        Map<String, dynamic> _toDo = new Map();
        _toDo["title"] = _controller.text;
        _controller.text = "";

        _toDo["ok"] = false;
        _toDoList.add(_toDo);

        _saveData();
      }
    });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _readData().then((value) {
      setState(() {
        return _toDoList = json.decode(value);
      });
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((selecionado, naoSelecionado) {
        if (selecionado["ok"] && !naoSelecionado["ok"])
          return 1;
        else if (!selecionado["ok"] && naoSelecionado["ok"])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.red,
        centerTitle: true),
    body: Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(20, 1, 20, 1),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                      labelText: "Nova tarefa",
                      labelStyle: TextStyle(color: Colors.red)),
                ),
              ),
              RaisedButton(
                color: Colors.white,
                child: Text("ADD"),
                textColor: Colors.red,
                onPressed: _addToDo,
              )
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  itemCount: _toDoList.length,
                  itemBuilder: buildItem)
          ),
        ),
      ],
    ),
  );
}

Widget buildItem(context, index) {
  return Dismissible(
    key: Key(DateTime
        .now()
        .millisecondsSinceEpoch
        .toString()),
    background: Container(
      color: Colors.red,
      child: Align(
        child: Icon(Icons.delete, color: Colors.white),
        alignment: Alignment(-0.9, 0),
      ),
    ),
    direction: DismissDirection.startToEnd,
    child: CheckboxListTile(
      onChanged: (value) {
        setState(() {
          _toDoList[index]["ok"] = value;
          _saveData();
        });
      },
      value: _toDoList[index]["ok"],
      title: Text(_toDoList[index]["title"]),
      secondary: CircleAvatar(
        child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
      ),
    ),
    onDismissed: (direction) {
      setState(() {
        _lastRemoved = Map.from(_toDoList[index]);
        _lastRemovedPosition = index;
        _toDoList.removeAt(index);
        _saveData();

        final snack = SnackBar(
          content: Text("Tarefa ${_lastRemoved["title"]} removida!"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                _toDoList.insert(_lastRemovedPosition, _lastRemoved);
                _saveData();
              });
            },
          ),
          duration: Duration(seconds: 4),
        );
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(snack);
      });
    },
  );
}}
