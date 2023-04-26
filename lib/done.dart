import 'add.dart';
import 'editscrreen.dart';
import 'loginscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum SortBy { name, date }

class TaskDone extends StatefulWidget {
  const TaskDone({Key? key}) : super(key: key);

  @override
  _TaskDoneState createState() => _TaskDoneState();
}

class _TaskDoneState extends State<TaskDone> {
  SortBy _sortBy = SortBy.name;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text('Completed Tasks'),
        actions: [
          PopupMenuButton<SortBy>(
            onSelected: (SortBy result) {
              setState(() {
                _sortBy = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortBy>>[
              const PopupMenuItem<SortBy>(
                value: SortBy.name,
                child: Text('Sort by name'),
              ),
              const PopupMenuItem<SortBy>(
                value: SortBy.date,
                child: Text('Sort by date'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks_done')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!.docs;

          if (tasks.isEmpty) {
            return Center(
              child: Text('No completed tasks yet.'),
            );
          }

          if (_sortBy == SortBy.date) {
            tasks.sort((a, b) =>
                (a['day'] as Timestamp).compareTo(b['day'] as Timestamp));
          } else {
            tasks.sort((a, b) => a['name'].compareTo(b['name']));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(
                  '${task['name']} - ${DateFormat.yMMMd().format(task['day'].toDate())}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  task['description'],

                ),
              );
            },
          );
        },
      ),

    );
  }
}
