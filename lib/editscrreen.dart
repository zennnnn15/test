import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditScreen extends StatefulWidget {
  final DocumentReference taskRef;

  const EditScreen({Key? key, required this.taskRef}) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    // Fetch the task data from Firestore
    widget.taskRef.get().then((taskSnapshot) {
      if (taskSnapshot.exists) {
        final taskData = taskSnapshot.data() as Map<String, dynamic>;

        // Initialize the local state with the task data
        setState(() {
          _nameController = TextEditingController(text: taskData['name']);
          _descriptionController = TextEditingController(text: taskData['description']);
        });
      }
    });

    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Task name',
              ),
              onChanged: (value) {},
              controller: _nameController,
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                hintText: 'Task description',
              ),
              onChanged: (value) {},
              controller: _descriptionController,
            ),
            SizedBox(height: 56.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Update the task in Firestore
                  await widget.taskRef.update({
                    'name': _nameController.text,
                    'description': _descriptionController.text,
                  });

                  // Navigate back to the main screen
                  Navigator.pop(context);
                },
                child: Text('Save Changes'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.orangeAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
