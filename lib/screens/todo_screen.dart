import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../database/database_helper.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _dbHelper.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _addTask() async {
    if (_taskController.text.isNotEmpty) {
      Task newTask = Task(title: _taskController.text);
      await _dbHelper.insertTask(newTask);
      _taskController.clear();
      _loadTasks();
    }
  }

  Future<void> _toggleTaskCompletion(int index) async {
    Task updatedTask = _tasks[index];
    updatedTask.isCompleted = !updatedTask.isCompleted;
    await _dbHelper.updateTask(updatedTask);
    _loadTasks();
  }

  Future<void> _deleteTask(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text("Delete Task?", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Are you sure you want to delete this task? This action cannot be undone.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.deleteTask(_tasks[index].id!);
              _loadTasks();
              Navigator.pop(context);
              Fluttertoast.showToast(
                  msg: "Task deleted", gravity: ToastGravity.BOTTOM);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _editTask(int index) async {
    _taskController.text = _tasks[index].title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.blue, size: 28),
            SizedBox(width: 10),
            Text("Edit Task", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: TextField(
          controller: _taskController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter updated task...",
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _taskController.clear();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_taskController.text.isNotEmpty) {
                Task updatedTask = _tasks[index];
                updatedTask.title = _taskController.text;
                await _dbHelper.updateTask(updatedTask);
                _taskController.clear();
                Navigator.pop(context);
                _loadTasks();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade200,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 159, 93, 240),
        title: const Text(
          'Simple To-Do',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return TaskItem(
                  task: _tasks[index],
                  onToggle: () => _toggleTaskCompletion(index),
                  onDelete: () => _deleteTask(index),
                  onEdit: () => _editTask(index),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'Enter new task...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
