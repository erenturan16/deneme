import 'package:flutter/material.dart';
import 'models/todo_item.dart'; // Görev modelini içe aktar

class TodoListScreen extends StatefulWidget {
  final Function(Color) onColorChange;

  const TodoListScreen({super.key, required this.onColorChange});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<TodoItem> _todoList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yapılacaklar Listesi'),
      ),
      body: ListView.builder(
        itemCount: _todoList.length,
        itemBuilder: (context, index) {
          final item = _todoList[index];
          return ListTile(
            title: Text(item.title),
            trailing: Checkbox(
              value: item.isDone,
              onChanged: (bool? value) {
                setState(() {
                  item.isDone = value ?? false;
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTask() {
    setState(() {
      _todoList.add(TodoItem(
          id: DateTime.now().millisecondsSinceEpoch, title: 'Yeni Görev'));
    });
  }
}
