import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add.dart';
import 'editscrreen.dart';
import 'loginscreen.dart';
import 'done.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

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
        automaticallyImplyLeading: false,
        title: Icon(Icons.check_circle, color: Colors.white, size: 50.0),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskDone()),
              );
            },
            icon: FaIcon(FontAwesomeIcons.check),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddScreen()),
              );
            },
            icon: FaIcon(FontAwesomeIcons.plus),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text('Yes'),
                    ),
                  ],
                ),
              );
            },
            icon: FaIcon(FontAwesomeIcons.signOutAlt),
          ),
        ],


      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading tasks'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final tasks = snapshot.data?.docs ?? [];

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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: task['done'] ?? false,
                      onChanged: (value) {
                        if (value == true) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Are you finished with this task?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text('Yes'),
                                ),
                              ],
                            ),
                          ).then((isFinished) {
                            if (isFinished == true) {
                              FirebaseFirestore.instance
                                  .collection('tasks_done')
                                  .add({'userId': user!.uid, ...task.data() as Map<String, dynamic>});
                              task.reference.delete();
                            } else {
                              task.reference.update({'done': false});
                            }
                          });
                        } else {
                          task.reference.update({'done': false});
                        }
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditScreen(taskRef: task.reference),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Are you sure?'),
                            content: Text('This task will be permanently deleted.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await task.reference.delete();
                                  Navigator.pop(context, true);
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          ),
                        ).then((value) {
                          if (value == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Task deleted'),
                              ),
                            );
                          }
                        });
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );

        },
      ),
    );
  }
}
