import 'loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
class RegistrationScreen extends StatefulWidget {
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmController = TextEditingController();

  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  bool _showPassword = false;
  void registerUser(BuildContext context) async {
    if (passwordController.text != confirmController.text) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Passwords do not match'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }
    try {
      await Firebase.initializeApp();
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Registration successful!'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
          ],
        ),
      );
      //delay
      Future.delayed(Duration(seconds: 1), () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('The password provided is too weak'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('The account already exists for that email'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.orangeAccent[100],
        ),
        child: Padding(
          padding: EdgeInsets.all(2.0),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 100.0),
                Text(
                  "Register",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      prefixIcon: Icon(Icons.email, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: confirmController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => registerUser(context),
                  child: Text('Register'),
                ),
                TextButton(
                  onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                  },
                  child: Text('Login'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
