import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(child: Text("Home Screen")),
          Text(user?.email ?? "No user signed in"),
          ElevatedButton(
            onPressed: () async {
              
              try {
                await FirebaseAuth.instance.signOut();
                print("User signed out successfully");
                setState(() {});
              } catch (e) {
                print("Error signing out: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error signing out: $e")),
                );
              }
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
