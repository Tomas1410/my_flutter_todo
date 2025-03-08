import 'package:flutter/material.dart';
import 'todo_list_screen.dart';
import 'models.dart';
import 'utils.dart';

class ListSelectionScreen extends StatefulWidget {
  @override
  _ListSelectionScreenState createState() => _ListSelectionScreenState();
}

class _ListSelectionScreenState extends State<ListSelectionScreen> {
  List<TodoList> todoLists = [];
  TextEditingController listNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  void _loadLists() async {
    todoLists = await loadTodoLists();
    setState(() {});
  }

  void addList(String name) {
    if (name.isNotEmpty) {
      setState(() {
        todoLists.add(TodoList(name: name, tasks: []));
        saveTodoLists(todoLists);
      });
    }
  }

  void deleteList(int index) {
    setState(() {
      todoLists.removeAt(index);
      saveTodoLists(todoLists);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moje listy'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: todoLists.length + 1, // +1 dla kafelka z plusem
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddListTile();
          } else {
            return _buildListTile(todoLists[index - 1], index - 1);
          }
        },
      ),
    );
  }

  Widget _buildAddListTile() {
    return Card(
      child: InkWell(
        onTap: () {
          _showAddListDialog();
        },
        child: Center(
          child: Icon(Icons.add, size: 48, color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildListTile(TodoList list, int index) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoListScreen(list: list, onUpdate: () {
                _loadLists(); // Odśwież listy po powrocie
              }),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(list.name, style: TextStyle(fontSize: 18)),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                deleteList(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddListDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Dodaj nową listę'),
          content: TextField(
            controller: listNameController,
            decoration: InputDecoration(
              labelText: 'Nazwa listy',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                addList(listNameController.text);
                listNameController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }
}