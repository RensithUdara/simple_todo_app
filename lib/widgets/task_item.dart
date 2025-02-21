import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 159, 93, 240),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Checkbox(
           value: task.isCompleted,
           onChanged: (value) => onToggle(),            
           activeColor: const Color.fromARGB(255, 198, 198, 198), 
           checkColor: Colors.white,
           hoverColor: Colors.grey,
           side: const BorderSide(color: Colors.white, width: 2),
           ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null , decorationColor: Colors.white,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red.shade500),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
