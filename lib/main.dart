import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Do konwersji listy na JSON i odwrotnie

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ToDoListScreen(),
    );
  }
}

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  List<Task> tasks = []; // Lista zadań
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Wczytaj zadania przy starcie aplikacji
  }

  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        tasks = (json.decode(tasksJson) as List)
            .map((task) => Task.fromJson(task))
            .toList();
      });
    }
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tasksJson = json.encode(tasks.map((task) => task.toJson()).toList());
    prefs.setString('tasks', tasksJson);
  }

  void addTask() {
    if (taskController.text.isNotEmpty) {
      setState(() {
        tasks.add(Task(name: taskController.text, isCompleted: false));
        taskController.clear();
        _saveTasks(); // Zapisz zadania po dodaniu
      });
    }
  }

  void toggleTaskCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      _saveTasks(); // Zapisz zadania po zmianie stanu
    });
  }

  void removeSelectedTasks() {
    setState(() {
      tasks.removeWhere((task) => task.isCompleted);
      _saveTasks(); // Zapisz zadania po usunięciu
    });
  }

  bool get hasCompletedTasks {
    return tasks.any((task) => task.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo List'),
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
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: InkWell(
                    onTap: () {
                      toggleTaskCompletion(index); // Zaznacz/odznacz po kliknięciu kafelka
                    },
                    child: ListTile(
                      title: Text(
                        tasks[index].name,
                        style: TextStyle(
                          decoration: tasks[index].isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      leading: Checkbox(
                        value: tasks[index].isCompleted,
                        onChanged: (value) {
                          toggleTaskCompletion(index); // Zaznacz/odznacz po kliknięciu checkboxa
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
                color: Colors.purple, // Fioletowy śmietnik
              ),
              tooltip: 'Usuń zaznaczone zadania',
              backgroundColor: Colors.white, // Białe tło
              elevation: 4, // Cień
            )
          : null, // FAB jest niewidoczny, gdy nie ma zaznaczonych zadań
    );
  }
}

class Task {
  String name;
  bool isCompleted;

  Task({required this.name, this.isCompleted = false});

  // Konwersja do JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompleted': isCompleted,
    };
  }

  // Konwersja z JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'],
      isCompleted: json['isCompleted'],
    );
  }
}