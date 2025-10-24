import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Define the VoterIDPreview widget in the same file
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set Scaffold background to black
      appBar: AppBar(
        title: const Text(
          "Voter ID Preview",
          style: TextStyle(color: Colors.white), // Set AppBar title color to white
        ),
        backgroundColor: Colors.black, // Set AppBar background to black
        iconTheme: const IconThemeData(color: Colors.white), // Set AppBar icon color to white
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow("EPIC Number:", epicNumber),
                  _buildDetailRow("Name:", name),
                  _buildDetailRow("Date of Birth:", dob),
                  _buildDetailRow("State:", state),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // In a real app, this would trigger a download.
                        // For this example, we just show a snackbar.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Downloading Voter ID...")),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text("Download as PDF"),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black), // Text color inside Card is black by default
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 16, color: Colors.black), // Text color inside Card is black by default
            ),
          ),
        ],
      ),
    );
  }
}

class DownloadVoterIDForm extends StatefulWidget {
  const DownloadVoterIDForm({super.key});

  @override
  State<DownloadVoterIDForm> createState() => _DownloadVoterIDFormState();
}

class _DownloadVoterIDFormState extends State<DownloadVoterIDForm> {
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
    "West Bengal"
  ];

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Your accent color
              onPrimary: Colors.white, // Text color on primary
              surface: Colors.white, // Dialog background color
              onSurface: Colors.black, // Text color on dialog background
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      _dobController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => VoterIDPreview(
            epicNumber: _epicController.text,
            name: _nameController.text,
            dob: _dobController.text,
            state: _selectedState!,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _epicController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.black, // Set Scaffold background to black
      appBar: AppBar(
        title: const Text(
          "Download Voter ID",
          style: TextStyle(color: Colors.white), // Set AppBar title color to white
        ),
        backgroundColor: Colors.black, // Set AppBar background to black
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _epicController,
                    style: const TextStyle(color: Colors.white), // Text input color
                    decoration: const InputDecoration(
                      labelText: "EPIC Number",
                      labelStyle: TextStyle(color: Colors.white), // Label color
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Border color when enabled
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue), // Border color when focused
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red), // Border color on error
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red), // Border color on error when focused
                      ),
                    ),
                    validator: (String? value) =>
                        value == null || value.isEmpty ? "Please enter EPIC Number" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white), // Text input color
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      labelStyle: TextStyle(color: Colors.white), // Label color
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Border color when enabled
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue), // Border color when focused
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red), // Border color on error
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red), // Border color on error when focused
                      ),
                    ),
                    validator: (String? value) =>
                        value == null || value.isEmpty ? "Please enter full name" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white), // Text input color
                    decoration: InputDecoration(
                      labelText: "Date of Birth",
                      labelStyle: const TextStyle(color: Colors.white), // Label color
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Border color when enabled
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue), // Border color when focused
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red), // Border color on error
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red), // Border color on error when focused
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.white), // Icon color
                        onPressed: _selectDate,
                      ),
                    ),
                    validator: (String? value) =>
                        value == null || value.isEmpty ? "Please select Date of Birth" : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Select State",
                      labelStyle: TextStyle(color: Colors.white), // Label color
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Border color when enabled
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue), // Border color when focused
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red), // Border color on error
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red), // Border color on error when focused
                      ),
                    ),
                    dropdownColor: Colors.grey[800], // Dropdown menu background color
                    iconEnabledColor: Colors.white, // Dropdown icon color
                    style: const TextStyle(color: Colors.white), // Selected item text color
                    initialValue: _selectedState,
                    items: _states.map<DropdownMenuItem<String>>((String s) => DropdownMenuItem<String>(
                      value: s,
                      child: Text(s, style: const TextStyle(color: Colors.white)), // Item text color in dropdown
                    )).toList(),
                    onChanged: (String? val) => setState(() => _selectedState = val),
                    validator: (String? val) => val == null ? "Please select a state" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _captchaController,
                    style: const TextStyle(color: Colors.white), // Text input color
                    decoration: const InputDecoration(
                      labelText: "Enter Captcha",
                      labelStyle: TextStyle(color: Colors.white), // Label color
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Border color when enabled
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue), // Border color when focused
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red), // Border color on error
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red), // Border color on error when focused
                      ),
                    ),
                    validator: (String? value) =>
                        value == null || value.isEmpty ? "Please enter captcha" : null,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: isDesktop ? Alignment.centerRight : Alignment.center,
                    child: SizedBox(
                      width: isDesktop ? 200 : double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, // Text color
                          backgroundColor: Colors.blue, // Button background color
                        ),
                        child: const Text("Submit"),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: DownloadVoterIDForm(),
    debugShowCheckedModeBanner: false,
  ));
}