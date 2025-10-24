import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const PollingStationApp());
}

class PollingStationApp extends StatelessWidget {
  const PollingStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Locate Polling Station",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // Ensure AppBar uses the primary color
          foregroundColor: Colors.white, // Text color for AppBar
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true, // Ensure fields are filled
          fillColor: Colors.white, // Default fill color for input fields
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData( // Changed from CardTheme to CardThemeData
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          secondary: Colors.blueAccent, // Accent color for the app
          surface: Colors.blue.shade50, // Light background color for the app body
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black87, // Default text color for body
          displayColor: Colors.black87, // Default text color for display elements
        ),
      ),
      home: const LocatePollingStationPage(),
    );
  }
}

class LocatePollingStationPage extends StatefulWidget {
  const LocatePollingStationPage({super.key});

  @override
  State<LocatePollingStationPage> createState() => _LocatePollingStationPageState();
}

class _LocatePollingStationPageState extends State<LocatePollingStationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _epicController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedState;
  String? _selectedDistrict;

  bool _showResult = false;

  final List<String> states = <String>["Delhi", "Maharashtra", "Uttar Pradesh", "Bihar"];
  final List<String> districts = <String>["District A", "District B", "District C"];

  @override
  void dispose() {
    _epicController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Locate Polling Station"),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface, // Use background color from theme
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _epicController,
                            decoration: const InputDecoration(
                              labelText: "EPIC Number / Voter ID",
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Enter EPIC Number";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: "Full Name",
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Enter your name";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Date of Birth",
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Theme.of(context).primaryColor, // Header background color
                                        onPrimary: Colors.white, // Header text color
                                        onSurface: Colors.black, // Body text color
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                _dobController.text =
                                    DateFormat("dd-MM-yyyy").format(picked);
                              }
                            },
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Select DOB";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedState,
                            dropdownColor: Theme.of(context).inputDecorationTheme.fillColor, // Use fill color for consistency
                            decoration: const InputDecoration(
                              labelText: "State",
                            ),
                            items: states
                                .map<DropdownMenuItem<String>>((String state) =>
                                    DropdownMenuItem<String>(value: state, child: Text(state)))
                                .toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _selectedState = value;
                              });
                            },
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Select State";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedDistrict,
                            dropdownColor: Theme.of(context).inputDecorationTheme.fillColor, // Use fill color for consistency
                            decoration: const InputDecoration(
                              labelText: "District / Constituency",
                            ),
                            items: districts
                                .map<DropdownMenuItem<String>>((String dist) =>
                                    DropdownMenuItem<String>(value: dist, child: Text(dist)))
                                .toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _selectedDistrict = value;
                              });
                            },
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Select District";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  _formKey.currentState!.reset();
                                  _epicController.clear();
                                  _nameController.clear();
                                  _dobController.clear();
                                  setState(() {
                                    _selectedState = null;
                                    _selectedDistrict = null;
                                    _showResult = false;
                                  });
                                },
                                child: const Text("Reset"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _showResult = true;
                                    });
                                  }
                                },
                                child: const Text("Search Location"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_showResult) ...<Widget>[
                      const SizedBox(height: 32),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Polling Station Details",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              const Text("Polling Station: Govt. School - Booth 45"),
                              const Text("Address: Near Main Market, District A, Delhi"),
                              const Text("Booth Level Officer: +91-9876543210"),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: Image.network(
                                  "https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg",
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                    return const ColoredBox(
                                      color: Colors.blueGrey, // Fallback color if image fails
                                      child: Center(
                                        child: Text(
                                          "Map Image Placeholder",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}