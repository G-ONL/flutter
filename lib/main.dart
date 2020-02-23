import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'model/todo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController _todoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('You Can Do It'),
      ),
      body: FutureBuilder(
        future: DatabaseHelper().getTodoList(),
        builder: (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    Todo item = snapshot.data[index];
                    return Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        DatabaseHelper().deleteTodo(item.id);
                      },
                      child: todoList(item),
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
      floatingActionButton: actionButton(),
    );
  }

  Widget actionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FloatingActionButton(
          child: Icon(Icons.remove),
          onPressed: () {
            DatabaseHelper().deleteAllTodos();
            setState(() {});
          },
        ),
        SizedBox(
          height: 16.0,
        ),
        FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return todoInput();
                });
          },
        ),
      ],
    );
  }

  Widget todoInput(){
    return AlertDialog(
      title: Text("Todo"),
      content: Form(
        key: _globalKey,
        child: TextFormField(
          controller: _todoController,
          validator: (value) {
            if (value.isEmpty) {
              return "Todo를 입력해주세요.";
            }
            return null;
          },
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Ok"),
          onPressed: () {
            if (_globalKey.currentState.validate()) {
              String todo = _todoController.text.toString();
              Todo newTodo = Todo(
                  "$todo",
                  DateTime.now().toString(),
                  false,
                  "description");
              DatabaseHelper().insertTodo(newTodo);
              _todoController.clear();
              setState(() {});
              Navigator.of(context).pop();
            }
          },
        )
      ],
    );
  }

  Widget todoList(Todo item) {
    return ListTile(
      onTap: () {
        Todo updateData = Todo.withId(item.id, item.title,
            DateTime.now().toString(), !item.complete, item.description);
        DatabaseHelper().updateTodo(updateData);
        setState(() {});
      },
      title: Text(item.title),
      leading: Text(""),
      trailing: Checkbox(
        onChanged: (bool value) {
          Todo updateData = Todo.withId(item.id, item.title,
              DateTime.now().toString(), !item.complete, item.description);
          DatabaseHelper().updateTodo(updateData);
          setState(() {});
        },
        value: item.complete,
      ),
    );
  }
}
