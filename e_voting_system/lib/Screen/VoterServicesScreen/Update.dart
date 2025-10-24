import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voter Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Set the overall background to black, or adjust for dark theme
        scaffoldBackgroundColor: Colors.black, // Set scaffold background to black
        brightness: Brightness.dark, // Adjust for dark theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // AppBar background
          foregroundColor: Colors.white, // AppBar text/icon color
        ),
        // FIX: Use ThemeData.dark().textTheme as a base to ensure consistent 'inherit' values
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white, // Default text color
              displayColor: Colors.white, // Default display text color
            ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white), // Label text color
          hintStyle: TextStyle(color: Colors.grey), // Hint text color
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white), // Border color when enabled
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue), // Border color when focused
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white), // Default border color
          ),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(color: Colors.white),
        ),
        // Set button themes for dark mode visibility
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Button background
            foregroundColor: Colors.white, // Button text color
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white, // Button text color
            side: const BorderSide(color: Colors.white), // Button border color
          ),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.blue; // Selected radio button color
            }
            return Colors.white; // Unselected radio button color
          }),
        ),
      ),
      home: const UpdateVoterDetailsPage(),
    );
  }
}

class UpdateVoterDetailsPage extends StatefulWidget {
  const UpdateVoterDetailsPage({super.key});

  @override
  State<UpdateVoterDetailsPage> createState() => _UpdateVoterDetailsPageState();
}

class _UpdateVoterDetailsPageState extends State<UpdateVoterDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _gender;
  String? _selectedState;
  String? _selectedDistrict;

  final List<String> states = ["Delhi", "Maharashtra", "Uttar Pradesh", "Bihar"];
  final List<String> districts = ["District A", "District B", "District C"];

  Future<void> _selectDOB() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              surface: Colors.black, // Calendar background color
              onSurface: Colors.white, // Calendar text color
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.black), // Dialog background color
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat("dd/MM/yyyy").format(pickedDate);
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _dobController.clear();
    _mobileController.clear();
    _emailController.clear();
    _addressController.clear();
    setState(() {
      _gender = null;
      _selectedState = null;
      _selectedDistrict = null;
    });
  }

  void _submitForm() {
    // Manually validate gender as DropdownButtonFormField does for its own validator
    if (_formKey.currentState!.validate() && _gender != null) {
      showDialog<void>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          backgroundColor: Colors.black, // AlertDialog background
          title: const Text("Success", style: TextStyle(color: Colors.white)),
          content: const Text("Your voter details have been updated successfully!",
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    } else {
      // If gender is not selected, trigger validation to show error message
      setState(() {
        // This empty setState is just to rebuild and show the gender validation message if needed
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Voter Details"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Handle help action
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: _buildNameField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDOBField()),
                          ],
                        )
                      : Column(
                          children: <Widget>[
                            _buildNameField(),
                            const SizedBox(height: 16),
                            _buildDOBField(),
                          ],
                        ),
                  const SizedBox(height: 16),
                  _buildGenderField(),
                  const SizedBox(height: 16),
                  isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: _buildMobileField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildEmailField()),
                          ],
                        )
                      : Column(
                          children: <Widget>[
                            _buildMobileField(),
                            const SizedBox(height: 16),
                            _buildEmailField(),
                          ],
                        ),
                  const SizedBox(height: 16),
                  _buildAddressField(),
                  const SizedBox(height: 16),
                  isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: _buildStateDropdown()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDistrictDropdown()),
                          ],
                        )
                      : Column(
                          children: <Widget>[
                            _buildStateDropdown(),
                            const SizedBox(height: 16),
                            _buildDistrictDropdown(),
                          ],
                        ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: isDesktop
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.center,
                    children: <Widget>[
                      OutlinedButton(
                        onPressed: _resetForm,
                        child: const Text("Reset"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widgets
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: "Full Name",
        border: OutlineInputBorder(),
        hintText: "Enter your full name",
      ),
      validator: (String? value) =>
          value == null || value.isEmpty ? "Please enter your name" : null,
    );
  }

  Widget _buildDOBField() {
    return TextFormField(
      controller: _dobController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Date of Birth",
        border: const OutlineInputBorder(),
        hintText: "DD/MM/YYYY",
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _selectDOB,
        ),
      ),
      validator: (String? value) =>
          value == null || value.isEmpty ? "Please select your date of birth" : null,
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text("Gender",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
        Row(
          children: <Widget>[
            Radio<String>(
              value: "Male",
              groupValue: _gender,
              onChanged: (String? value) => setState(() => _gender = value),
            ),
            const Text("Male"),
            Radio<String>(
              value: "Female",
              groupValue: _gender,
              onChanged: (String? value) => setState(() => _gender = value),
            ),
            const Text("Female"),
            Radio<String>(
              value: "Other",
              groupValue: _gender,
              onChanged: (String? value) => setState(() => _gender = value),
            ),
            const Text("Other"),
          ],
        ),
        if (_gender == null &&
            _formKey.currentState?.validate() ==
                false) // Show error only if form is being validated and gender is null
          const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Text("Please select a gender",
                style: TextStyle(color: Colors.red, fontSize: 12)),
          )
      ],
    );
  }

  Widget _buildMobileField() {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: "Mobile Number",
        border: OutlineInputBorder(),
        hintText: "Enter 10-digit mobile number",
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return "Please enter your mobile number";
        }
        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
          return "Please enter a valid 10-digit mobile number";
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: "Email Address",
        border: OutlineInputBorder(),
        hintText: "example@domain.com",
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return "Please enter your email address";
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return "Please enter a valid email address";
        }
        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: "Address",
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
        hintText: "Enter your full address",
      ),
      validator: (String? value) =>
          value == null || value.isEmpty ? "Please enter your address" : null,
    );
  }

  Widget _buildStateDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedState,
      decoration: const InputDecoration(
        labelText: "State",
        border: OutlineInputBorder(),
      ),
      dropdownColor: Colors.black, // Dropdown menu background
      items: states
          .map<DropdownMenuItem<String>>((String s) => DropdownMenuItem<String>(
                value: s,
                child: Text(s, style: const TextStyle(color: Colors.white)),
              ))
          .toList(),
      onChanged: (String? value) => setState(() => _selectedState = value),
      validator: (String? value) => value == null ? "Please select a state" : null,
      hint: const Text("Select State"),
    );
  }

  Widget _buildDistrictDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedDistrict,
      decoration: const InputDecoration(
        labelText: "District",
        border: OutlineInputBorder(),
      ),
      dropdownColor: Colors.black, // Dropdown menu background
      items: districts
          .map<DropdownMenuItem<String>>((String d) => DropdownMenuItem<String>(
                value: d,
                child: Text(d, style: const TextStyle(color: Colors.white)),
              ))
          .toList(),
      onChanged: (String? value) => setState(() => _selectedDistrict = value),
      validator: (String? value) =>
          value == null ? "Please select a district" : null,
      hint: const Text("Select District"),
    );
  }
}