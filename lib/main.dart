import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => TodoProvider(),
      child: MaterialApp(
        title: 'TODO App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TodoListScreen(),
      ),
    );
  }
}

class Todo {
  String id;
  String title;
  String description;

  Todo({
    required this.id,
    required this.title,
    required this.description,
  });
}

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  void addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void updateTodo(String id, Todo newTodo) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = newTodo;
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  Todo findById(String id) {
    return _todos.firstWhere((todo) => todo.id == id);
  }
}

class TodoListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('TODO List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => AddTodoScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: todoProvider.todos.length,
        itemBuilder: (ctx, index) {
          final todo = todoProvider.todos[index];
          return ListTile(
            title: Text(todo.title),
            subtitle: Text(todo.description),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => EditTodoScreen(todo.id),
                  ),
                );
              },
            ),
            onLongPress: () {
              todoProvider.deleteTodo(todo.id);
            },
          );
        },
      ),
    );
  }
}

class AddTodoScreen extends StatelessWidget {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add TODO'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final todo = Todo(
                  id: _uuid.v4(),
                  title: _titleController.text,
                  description: _descriptionController.text,
                );
                Provider.of<TodoProvider>(context, listen: false).addTodo(todo);
                Navigator.of(context).pop();
              },
              child: Text('Add TODO'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTodoScreen extends StatelessWidget {
  final String todoId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  EditTodoScreen(this.todoId);

  @override
  Widget build(BuildContext context) {
    final todo = Provider.of<TodoProvider>(context, listen: false).findById(todoId);
    _titleController.text = todo.title;
    _descriptionController.text = todo.description;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit TODO'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedTodo = Todo(
                  id: todo.id,
                  title: _titleController.text,
                  description: _descriptionController.text,
                );
                Provider.of<TodoProvider>(context, listen: false)
                    .updateTodo(todo.id, updatedTodo);
                Navigator.of(context).pop();
              },
              child: Text('Update TODO'),
            ),
          ],
        ),
      ),
    );
  }
}