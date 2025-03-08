import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'dart:convert';

Future<List<TodoList>> loadTodoLists() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? listsJson = prefs.getString('todoLists');
  if (listsJson != null) {
    return (json.decode(listsJson) as List)
        .map((list) => TodoList.fromJson(list))
        .toList();
  }
  return [];
}

Future<void> saveTodoLists(List<TodoList> lists) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String listsJson = json.encode(lists.map((list) => list.toJson()).toList());
  prefs.setString('todoLists', listsJson);
}