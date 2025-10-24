import 'package:flutter/material.dart';
import 'dart:async'; // Required for Future.delayed

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voter ID App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VoterIDPreview(
        epicNumber: 'ABC1234567',
        name: 'John Doe',
        dob: '01/01/1990',
        state: 'California',
      ),
    );
  }
}

class VoterIDPreview extends StatelessWidget {
  final String epicNumber;
  final String name;
  final String dob;
  final String state;

  const VoterIDPreview({
    super.key,
    required this.epicNumber,
    required this.name,
    required this.dob,
    required this.state,
  });

  void _downloadVoterID(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text("Download Successful"),
          content: const Text("Your digital voter ID has been downloaded successfully."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement file opening logic
                Navigator.pop(dialogContext); // Close dialog after action
              },
              child: const Text("Open File"),
            ),
          ],
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Downloading...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text("Voter ID Preview")),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView( // Added SingleChildScrollView to prevent overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      "Your Voter ID Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 30),

                    ListTile(
                      title: const Text("EPIC Number"),
                      subtitle: Text(epicNumber),
                    ),
                    ListTile(
                      title: const Text("Full Name"),
                      subtitle: Text(name),
                    ),
                    ListTile(
                      title: const Text("Date of Birth"),
                      subtitle: Text(dob),
                    ),
                    ListTile(
                      title: const Text("State"),
                      subtitle: Text(state),
                    ),
                    const SizedBox(height: 20),

                    Align(
                      alignment: isDesktop ? Alignment.centerRight : Alignment.center,
                      child: SizedBox(
                        width: isDesktop ? 200 : double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          onPressed: () => _downloadVoterID(context),
                          label: const Text("Download Voter ID"),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}