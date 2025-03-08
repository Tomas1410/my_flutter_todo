class TodoList {
  String name;
  List<Task> tasks;

  TodoList({required this.name, required this.tasks});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  factory TodoList.fromJson(Map<String, dynamic> json) {
    return TodoList(
      name: json['name'],
      tasks: (json['tasks'] as List).map((task) => Task.fromJson(task)).toList(),
    );
  }
}

class Task {
  String name;
  bool isCompleted;

  Task({required this.name, this.isCompleted = false});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'],
      isCompleted: json['isCompleted'],
    );
  }
}