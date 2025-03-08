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
  FocusNode focusNode = FocusNode(); // FocusNode do zarządzania focusem

  // Paginacja
  int currentPage = 0; // Aktualna strona
  int tasksPerPage = 5; // Liczba zadań na stronę (domyślnie 5)

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Wczytaj zadania przy starcie aplikacji
  }

  @override
  void dispose() {
    focusNode.dispose(); // Zwolnij zasoby FocusNode
    super.dispose();
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
      focusNode.requestFocus(); // Utrzymaj focus na polu tekstowym
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

  // Pobierz zadania dla aktualnej strony
  List<Task> get tasksForCurrentPage {
    int startIndex = currentPage * tasksPerPage;
    int endIndex = startIndex + tasksPerPage;
    if (endIndex > tasks.length) {
      endIndex = tasks.length;
    }
    return tasks.sublist(startIndex, endIndex);
  }

  // Czy istnieje poprzednia strona?
  bool get hasPreviousPage {
    return currentPage > 0;
  }

  // Czy istnieje następna strona?
  bool get hasNextPage {
    return (currentPage + 1) * tasksPerPage < tasks.length;
  }

  // Przejdź do następnej strony
  void nextPage() {
    setState(() {
      if (hasNextPage) {
        currentPage++;
      }
    });
  }

  // Przejdź do poprzedniej strony
  void previousPage() {
    setState(() {
      if (hasPreviousPage) {
        currentPage--;
      }
    });
  }

  // Oblicz postęp paginacji (0.0 - 1.0)
  double get paginationProgress {
    if (tasks.isEmpty) return 0.0;
    return (currentPage + 1) / ((tasks.length / tasksPerPage).ceil());
  }

  // Oblicz liczbę zadań na stronę na podstawie wysokości ekranu
  int calculateTasksPerPage(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double taskHeight = 72.0; // Przybliżona wysokość jednego zadania (ListTile)
    final double otherWidgetsHeight = 200.0; // Wysokość innych widgetów (np. AppBar, przyciski)

    // Oblicz dostępną wysokość dla zadań
    final double availableHeight = screenHeight - otherWidgetsHeight;

    // Oblicz liczbę zadań, które zmieszczą się na ekranie
    return (availableHeight / taskHeight).floor();
  }

  @override
  Widget build(BuildContext context) {
    // Oblicz liczbę zadań na stronę na podstawie wysokości ekranu
    tasksPerPage = calculateTasksPerPage(context);

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
                    onSubmitted: (value) {
                      addTask(); // Dodaj zadanie po naciśnięciu Enter
                    },
                    focusNode: focusNode, // Przypisz FocusNode do pola tekstowego
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
              itemCount: tasksForCurrentPage.length,
              itemBuilder: (context, index) {
                final task = tasksForCurrentPage[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: InkWell(
                    onTap: () {
                      toggleTaskCompletion(tasks.indexOf(task)); // Zaznacz/odznacz po kliknięciu kafelka
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
                          toggleTaskCompletion(tasks.indexOf(task)); // Zaznacz/odznacz po kliknięciu checkboxa
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Paginacja (widoczna tylko, gdy jest więcej niż jedna strona)
          if (hasPreviousPage || hasNextPage)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasPreviousPage)
                        ElevatedButton(
                          onPressed: previousPage,
                          child: Text('<'),
                        ),
                      if (hasPreviousPage && hasNextPage)
                        SizedBox(width: 16), // Odstęp między przyciskami
                      if (hasNextPage)
                        ElevatedButton(
                          onPressed: nextPage,
                          child: Text('>'),
                        ),
                    ],
                  ),
                  SizedBox(height: 8), // Odstęp między przyciskami a paskiem postępu
                  LinearProgressIndicator(
                    value: paginationProgress, // Postęp paginacji
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ],
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