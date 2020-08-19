import 'package:flutter/material.dart';

class ListItemWidget extends StatefulWidget {
  final toDoList;
  final void Function(int index) removeTask;
  final void Function() saveData;
  // Constructor
  ListItemWidget(this.toDoList, this.removeTask, this.saveData);

  @override
  _ListItemWidgetState createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<ListItemWidget> {
  Map<String, dynamic> _lastRemoved; // Last item Removed
  int _lastRemovedPos; // Index last removed index.

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10.0),
      itemCount: widget.toDoList.length,
      itemBuilder: (context, index) {
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
            title: Text(widget.toDoList[index]['title']),
            value: widget.toDoList[index]['ok'],
            secondary: CircleAvatar(
              child: Icon(
                  widget.toDoList[index]['ok'] ? Icons.check : Icons.error),
            ),
            onChanged: (check) {
              setState(() {
                // Update status of checkbox.
                widget.toDoList[index]['ok'] = check;
                widget.saveData(); // Save data in file.
              });
            },
          ),
          onDismissed: (direction) {
            setState(() {
              _lastRemoved =
                  Map.from(widget.toDoList[index]); // Duplicate item.
              _lastRemovedPos = index;
              widget.removeTask(index);
              // Create SnackBar
              final snack = SnackBar(
                content: Text('Tarefa ${_lastRemoved["title"]} removida!'),
                action: SnackBarAction(
                    label: 'Desfazer',
                    onPressed: () {
                      setState(() {
                        // Screen status update.
                        widget.toDoList.insert(_lastRemovedPos,
                            _lastRemoved); // Insert last item removed of list.
                        widget.saveData();
                      });
                    }),
                duration: Duration(seconds: 3),
              );
              Scaffold.of(context)
                  .removeCurrentSnackBar(); // Remove snackbar activated.
              Scaffold.of(context).showSnackBar(snack);
            });
          },
        );
      },
    );
  }
}
