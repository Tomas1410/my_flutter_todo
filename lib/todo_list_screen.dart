import 'package:flutter/material.dart';
import 'models.dart';
import 'utils.dart';

class TodoListScreen extends StatefulWidget {
  final TodoList list;
  final VoidCallback onUpdate;

  TodoListScreen({required this.list, required this.onUpdate});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  TextEditingController taskController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void addTask() {
    if (taskController.text.isNotEmpty) {
      setState(() {
        widget.list.tasks.add(Task(name: taskController.text, isCompleted: false));
        taskController.clear();
        saveTodoLists([widget.list]);
        focusNode.requestFocus();
      });
    }
  }

  void toggleTaskCompletion(int index) {
    setState(() {
      widget.list.tasks[index].isCompleted = !widget.list.tasks[index].isCompleted;
      saveTodoLists([widget.list]);
    });
  }

  void removeSelectedTasks() {
    setState(() {
      widget.list.tasks.removeWhere((task) => task.isCompleted);
      saveTodoLists([widget.list]);
    });
  }

  void editTask(int index, String newName) {
    setState(() {
      widget.list.tasks[index].name = newName;
      saveTodoLists([widget.list]);
    });
  }

  bool get hasCompletedTasks {
    return widget.list.tasks.any((task) => task.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      labelText: 'Nowe zadanie',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      addTask();
                    },
                    focusNode: focusNode,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addTask,
                  child: Text('Dodaj'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.list.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.list.tasks[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: InkWell(
                    onTap: () {
                      toggleTaskCompletion(index);
                    },
                    child: ListTile(
                      title: Text(
                        task.name,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          toggleTaskCompletion(index);
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditDialog(index);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: hasCompletedTasks
          ? FloatingActionButton(
              onPressed: removeSelectedTasks,
              child: Icon(
                Icons.delete,
                color: Colors.purple,
              ),
              tooltip: 'Usuń zaznaczone zadania',
              backgroundColor: Colors.white,
              elevation: 4,
            )
          : null,
    );
  }

  void _showEditDialog(int index) {
    final TextEditingController editController = TextEditingController(text: widget.list.tasks[index].name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edytuj zadanie'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              labelText: 'Nowa nazwa zadania',
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
                editTask(index, editController.text);
                Navigator.of(context).pop();
              },
              child: Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }
}