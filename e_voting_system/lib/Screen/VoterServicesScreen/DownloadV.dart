import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Main entry point for the Flutter application
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voter ID Download',
      theme: ThemeData(
        // Set brightness to dark for an overall dark theme
        brightness: Brightness.dark,
        // Ensure Material 2 design is used for consistency with existing code's implicit style.
        useMaterial3: false,
        // Primary color for various widgets (like ElevatedButton background, progress indicators)
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Explicitly set scaffold background color to pure black
        scaffoldBackgroundColor: Colors.black,
        // AppBar theme for a black app bar with white text
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        // Input field decoration theme for dark background
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white54),
          // Enabled border for text fields
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
          ),
          // Focused border for text fields
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          // Default border (e.g., error border)
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
          ),
          fillColor: Colors.white10, // Subtle fill color for text fields background
          filled: true,
        ),
        // Icon theme for icons in the app (e.g., date picker icon)
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        // ElevatedButton theme for consistent button styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Text color on button
            backgroundColor: Colors.blue, // Button background color
          ),
        ),
        // TextButton theme (used in dialogs)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue, // Text color for text buttons
          ),
        ),
      ),
      home: const DownloadVoterIDScreen(),
    );
  }
}

class DownloadVoterIDScreen extends StatefulWidget {
  const DownloadVoterIDScreen({super.key});

  @override
  State<DownloadVoterIDScreen> createState() => _DownloadVoterIDScreenState();
}

class _DownloadVoterIDScreenState extends State<DownloadVoterIDScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _epicController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();

  String? _selectedState;

  final List<String> _states = <String>[
    "Andhra Pradesh",
    "Bihar",
    "Delhi",
    "Goa",
    "Gujarat",
    "Haryana",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Tamil Nadu",
    "Telangana",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
  ];

  // Show Date Picker
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      // Ensure the DatePicker itself uses a light theme for readability,
      // as date pickers are often not fully adapted to dark themes by default.
      builder: (BuildContext context, Widget? child) {
        return Theme(
          // Use Material 2 to match existing app style
          data: ThemeData.light(useMaterial3: false),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  // Show Success Dialog
  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Download Successful"),
        content: const Text("Your digital voter ID has been downloaded successfully."),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add file open logic here
            },
            child: const Text("Open File"),
          ),
        ],
      ),
    );
  }

  // Show Error Dialog
  void _showErrorDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: const Text("Details not found. Please check and try again."),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Submit Form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Simulating a check
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (_epicController.text == "ABC1234567") {
          _showSuccessDialog();
        } else {
          _showErrorDialog();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Downloading...")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Download Voter ID"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    "You can download your digital voter ID (EPIC) by entering the required details below.",
                    style: TextStyle(fontSize: 16), // Text color will be white from overall theme
                  ),
                  const SizedBox(height: 20),

                  // EPIC Number
                  TextFormField(
                    controller: _epicController,
                    style: const TextStyle(color: Colors.white), // Explicitly set input text color
                    decoration: const InputDecoration(
                      labelText: "EPIC Number",
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter EPIC Number";
                      }
                      if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(value)) {
                        return "Invalid EPIC Number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white), // Explicitly set input text color
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                    ),
                    validator: (String? value) =>
                        value == null || value.isEmpty ? "Please enter full name" : null,
                  ),
                  const SizedBox(height: 16),

                  // DOB
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white), // Explicitly set input text color
                    decoration: InputDecoration(
                      labelText: "Date of Birth",
                      suffixIcon: IconButton( // Removed const here
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                        // Icon color inherited from IconThemeData defined in MyApp's theme
                      ),
                    ),
                    validator: (String? value) =>
                        value == null || value.isEmpty ? "Please select Date of Birth" : null,
                  ),
                  const SizedBox(height: 16),

                  // State Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedState,
                    style: const TextStyle(color: Colors.white), // Text color for the selected value
                    decoration: const InputDecoration(
                      labelText: "Select State",
                    ),
                    items: _states.map<DropdownMenuItem<String>>((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        // Explicitly set text color for items in the dropdown menu
                        // as the dropdown overlay typically has a light background,
                        // even in a dark overall theme, for better readability.
                        child: Text(state, style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedState = value;
                      });
                    },
                    validator: (String? value) =>
                        value == null ? "Please select a state" : null,
                  ),
                  const SizedBox(height: 16),

                  // Captcha
                  TextFormField(
                    controller: _captchaController,
                    style: const TextStyle(color: Colors.white), // Explicitly set input text color
                    decoration: const InputDecoration(
                      labelText: "Enter Captcha",
                    ),
                    validator: (String? value) =>
                        value == null || value.isEmpty ? "Please enter captcha" : null,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  Align(
                    alignment: isDesktop ? Alignment.centerRight : Alignment.center,
                    child: SizedBox(
                      width: isDesktop ? 200 : double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text("Download"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _epicController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _captchaController.dispose();
    super.dispose();
  }
}