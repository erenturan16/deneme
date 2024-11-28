class TodoItem {
  final int id;
  String title;
  bool isDone;
  DateTime? reminderTime;

  TodoItem({
    required this.id,
    required this.title,
    this.isDone = false,
    this.reminderTime,
  });
}
