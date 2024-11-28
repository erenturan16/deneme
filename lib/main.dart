import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'models/todo_item.dart';
import 'services/notification_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Varsayılan tema rengi
  Color _themeColor = Colors.teal;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yapılacaklar Listesi',
      theme: ThemeData(
        primarySwatch: createMaterialColor(_themeColor),
        hintColor: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoListScreen(
        onColorChange: (Color color) {
          setState(() {
            _themeColor = color;
          });
        },
      ),
    );
  }
}

// MaterialColor oluşturma fonksiyonu
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class TodoListScreen extends StatefulWidget {
  final Function(Color) onColorChange;

  const TodoListScreen({super.key, required this.onColorChange});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<TodoItem> _todoList = [];
  final NotificationService _notificationService = NotificationService();
  String _searchQuery = ''; // Arama için gerekli olan değişken

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
  }

  // Görev tamamlama yüzdesi hesaplama
  double _calculateCompletionPercentage() {
    if (_todoList.isEmpty) return 0;
    int completedTasks = _todoList.where((task) => task.isDone).length;
    return completedTasks / _todoList.length;
  }

  @override
  Widget build(BuildContext context) {
    // Aramaya göre görevleri filtrele
    List<TodoItem> filteredList = _todoList.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yapılacaklar Listesi'),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () => _showColorPicker(context),
          ),
        ],
      ),
      backgroundColor: Colors.yellow[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(hintText: 'Görev ara'),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          LinearProgressIndicator(
            value: _calculateCompletionPercentage(),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Text(
                      'Henüz bir görev eklemedin!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return ListTile(
                        tileColor: Colors.yellow[50],
                        leading: Checkbox(
                          value: item.isDone,
                          onChanged: (bool? value) {
                            setState(() {
                              item.isDone = value ?? false;
                            });
                          },
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            decoration:
                                item.isDone ? TextDecoration.lineThrough : null,
                            color: item.isDone ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: item.reminderTime != null
                            ? Text(
                                'Hatırlatıcı: ${DateFormat('HH:mm').format(item.reminderTime!)}')
                            : null,
                        onTap: () => _showTaskOptions(item, index),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayAddTodoDialog(context),
        tooltip: 'Yeni Görev Ekle',
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Görev silindi')),
    );
  }

  void _editTask(TodoItem item, int index) {
    TextEditingController textFieldController =
        TextEditingController(text: item.title);
    TimeOfDay? selectedTime =
        TimeOfDay.fromDateTime(item.reminderTime ?? DateTime.now());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Görevi Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textFieldController,
                decoration: const InputDecoration(hintText: 'Görev adı'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hatırlatma saati:'),
                  TextButton(
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime!,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                    child: Text(selectedTime!.format(context)),
                  )
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Kaydet'),
              onPressed: () {
                setState(() {
                  _todoList[index].title = textFieldController.text.trim();
                  _todoList[index].reminderTime = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                  _notificationService.scheduleNotification(
                    _todoList[index].id,
                    _todoList[index].title,
                    'Görev Hatırlatıcısı',
                    _todoList[index].reminderTime!,
                  );
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTaskOptions(TodoItem item, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.of(context).pop();
                _editTask(item, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Sil'),
              onTap: () {
                Navigator.of(context).pop();
                _deleteTask(index);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _displayAddTodoDialog(BuildContext context) async {
    TextEditingController textFieldController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Görev Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textFieldController,
                decoration: const InputDecoration(hintText: 'Görev adı'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hatırlatma saati:'),
                  TextButton(
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                    child: Text(selectedTime.format(context)),
                  )
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Kaydet'),
              onPressed: () {
                if (textFieldController.text.trim().isEmpty) return;
                setState(() {
                  final newTask = TodoItem(
                    id: DateTime.now().millisecondsSinceEpoch,
                    title: textFieldController.text.trim(),
                    reminderTime: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      selectedTime.hour,
                      selectedTime.minute,
                    ),
                  );
                  _todoList.add(newTask);
                  _notificationService.scheduleNotification(
                    newTask.id,
                    newTask.title,
                    'Görev Hatırlatıcısı',
                    newTask.reminderTime!,
                  );
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tema Rengini Seç'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: Theme.of(context).primaryColor,
              onColorChanged: (Color color) {
                widget.onColorChange(color);
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Kapat'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
