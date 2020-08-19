import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_list/pages/widgets/list_item_widget.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  List _toDoList = [];

  @override
  void initState() {
    // Read data of file.
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    //Input to new task.
                    controller: _toDoController,
                    decoration: InputDecoration(
                        labelText: 'Nova Tarefa',
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
                RaisedButton(
                  //Botton to add item.
                  color: Colors.blueAccent,
                  child: Text('ADD'),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                ),
              ],
            ),
          ),
          Expanded(
            // Refresh list.
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListItemWidget(_toDoList, _removeToDo, _saveData),
            ),
          ),
        ],
      ),
    );
  }

  // Get file save in directory of aplication.
  Future<File> _getFile() async {
    final directory =
        await getApplicationDocumentsDirectory(); // Get directory where file save.
    return File('${directory.path}/data.json'); // Return path of file.
  }

  // Save data
  Future<File> _saveData() async {
    String data =
        json.encode(_toDoList); // Reading list and convert in JSON format.
    final file = await _getFile();
    return file.writeAsString(data); // Write data in file.
  }

  // Read file data.
  Future<String> _readData() async {
    try {
      final file = await _getFile(); // Get file.
      return file.readAsString(); // Read data.
    } catch (e) {
      return null;
    }
  }

  // Add list item.
  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo['title'] =
          _toDoController.text; // Get text input and add in list.
      _toDoController.text = '';
      newToDo['ok'] = false; // Default false to checkbox.
      _toDoList.add(newToDo);
      _saveData(); // Save data in file.
    });
  }

  // Remove list item.
  void _removeToDo(int index) {
    setState(() {
      _toDoList.removeAt(index);
      _saveData();
    });
  }

  // Refresh list order
  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1)); // Delay of one second.
    setState(() {
      //Screen status update.
      _toDoList.sort((itemA, itemB) {
        if (itemA['ok'] && !itemB['ok'])
          return 1;
        else if (!itemA['ok'] && itemB['ok'])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
    return null;
  }
}
