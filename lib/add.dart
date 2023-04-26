import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cool_alert/cool_alert.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _addTask() async {
    try {

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('User is not logged in');
        return;
      }


      await FirebaseFirestore.instance.collection('tasks').add({
        'name': _nameController.text,
        'description': _descController.text,
        'day': _selectedDate,
        'userId': user.uid,
        'done':false,
      });

      Navigator.pop(context);

    } catch (e) {
      print(e);

      // Show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while adding the task.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Task Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter task name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  hintText: 'Task Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter task description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  _selectDate(context);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: 'Task Day',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addTask();
                  }
                },
                child: Center(child: Text('Add Task')),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.orangeAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
