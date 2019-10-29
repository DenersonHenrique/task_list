import 'dart:io';
import 'dart:convert';
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
  final _toDoController = TextEditingController();
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved; //Last item Removed
  int _lastRemovedPos; //Index last removed index.

  @override
  void initState() {
    //Read data of file.
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo['title'] = _toDoController.text; //Get text input and add in list.
      _toDoController.text = '';
      newToDo['ok'] = false; //Default false to checkbox.
      _toDoList.add(newToDo);
      _saveData(); //Save data in file.
    });
  }

  //Refresh list order
  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));//Delay of one second.
    setState(() {//Screen status update.
     _toDoList.sort((itemA, itemB){
      if (itemA['ok'] && !itemB['ok'])  return 1;
      else if (!itemA['ok'] && itemB['ok']) return -1;
      else return 0;
    });
    _saveData(); 
    });
    return null;
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
                )),
                RaisedButton(
                  //Botton to add item.
                  color: Colors.blueAccent,
                  child: Text('ADD'),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _toDoList.length,
                  itemBuilder: buildItem),
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      // Move item to delete.
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]['title']),
        value: _toDoList[index]['ok'],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]['ok'] ? Icons.check : Icons.error),
        ),
        onChanged: (check) {
          setState(() {
            //Update status of checkbox.
            _toDoList[index]['ok'] = check;
            _saveData(); //Save data in file.
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);
          _saveData();
          //Create SnackBar
          final snack = SnackBar(
            content: Text('Tarefa ${_lastRemoved["title"]} removida!'),
            action: SnackBarAction(
                label: 'Desfazer',
                onPressed: () {
                  setState(() {
                    //Screen status update.
                    _toDoList.insert(_lastRemovedPos,
                        _lastRemoved); //Insert last item removed of list.
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 3),
          );
          Scaffold.of(context).removeCurrentSnackBar();//Remove snackbar activated.
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  //Get file save in directory of aplication.
  Future<File> _getFile() async {
    final directory =
        await getApplicationDocumentsDirectory(); //Get directory where file save.
    return File('${directory.path}/data.json'); //Return path of file.
  }

  //Save data
  Future<File> _saveData() async {
    String data =
        json.encode(_toDoList); //Reading list and convert in JSON format.
    final file = await _getFile();
    return file.writeAsString(data); //Write data in file.
  }

  //Read file data.
  Future<String> _readData() async {
    try {
      final file = await _getFile(); //Get file.
      return file.readAsString(); //Read data.
    } catch (e) {
      return null;
    }
  }
}
