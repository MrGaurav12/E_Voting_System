import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// DATA_MODEL
/// Manages the state and logic for the Voter ID status application.
class VoterIDStatusData extends ChangeNotifier {
  String? _applicationNumber;
  DateTime? _dateOfBirth;
  String? _selectedState;

  String? _applicantName;
  String? _currentStatus;
  String? _expectedDeliveryDate;
  String? _formStatusMessage; // Message for general form/API feedback
  bool _isLoading = false;

  // Initializing with a comprehensive list of Indian states for realism
  final List<String> _states = const <String>[
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal'
  ];

  List<String> get states => _states;
  String? get applicationNumber => _applicationNumber;
  DateTime? get dateOfBirth => _dateOfBirth;
  String? get selectedState => _selectedState;
  String? get applicantName => _applicantName;
  String? get currentStatus => _currentStatus;
  String? get expectedDeliveryDate => _expectedDeliveryDate;
  String? get formStatusMessage => _formStatusMessage;
  bool get isLoading => _isLoading;

  void updateApplicationNumber(String? value) {
    _applicationNumber = value;
  }

  void updateDateOfBirth(DateTime? value) {
    _dateOfBirth = value;
    notifyListeners(); // Notify to update UI for selected date immediately
  }

  void updateSelectedState(String? value) {
    _selectedState = value;
  }

  void updateFormStatusMessage(String? message) {
    _formStatusMessage = message;
    notifyListeners();
  }

  /// Simulates an asynchronous status check.
  Future<void> simulateStatusCheck() async {
    _isLoading = true;
    _formStatusMessage = null; // Clear previous messages
    _applicantName = null;
    _currentStatus = null;
    _expectedDeliveryDate = null;
    notifyListeners(); // Notify to show loading state and clear old results

    // Simulate network delay
    await Future<void>.delayed(const Duration(seconds: 2));

    // Simulate different outcomes based on application number for demonstration
    if (_applicationNumber == 'VOTER12345' && _dateOfBirth != null && _selectedState == 'Maharashtra') {
      _applicantName = "John Doe";
      _currentStatus = "Approved";
      _expectedDeliveryDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7)));
      _formStatusMessage = "Status retrieved successfully!";
    } else if (_applicationNumber == 'VOTER67890' && _dateOfBirth != null && _selectedState == 'Uttar Pradesh') {
      _applicantName = "Jane Smith";
      _currentStatus = "Under Review";
      _expectedDeliveryDate = null; // Still under review, no delivery date yet
      _formStatusMessage = "Application is currently under review. Please check back later.";
    } else {
      _applicantName = null;
      _currentStatus = "Rejected"; // Explicitly set to rejected for demonstration
      _expectedDeliveryDate = null;
      _formStatusMessage = "No record found or details do not match. Please verify your inputs.";
    }

    _isLoading = false;
    notifyListeners(); // Notify listeners again with the new status
  }
}

void main() {
  runApp(const VoterIDStatusApp());
}

class VoterIDStatusApp extends StatelessWidget {
  const VoterIDStatusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VoterIDStatusData>(
      create: (BuildContext context) => VoterIDStatusData(),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'Voter ID Status Tracker',
          theme: ThemeData(
            brightness: Brightness.dark, // Set theme to dark
            primarySwatch: Colors.blue, // Primary color for theming
            scaffoldBackgroundColor: Colors.black, // Main background color
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black, // Dark app bar
              foregroundColor: Colors.white,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[800], // Darker fill for input fields
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              labelStyle: const TextStyle(color: Colors.white70), // Light label text
              hintStyle: const TextStyle(color: Colors.white54), // Lighter hint text
              prefixIconColor: Colors.blueAccent, // Icons in input fields
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.grey[850], // Darker card background
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.all(8.0),
            ),
          ),
          home: const VoterIDStatusPage(),
        );
      },
    );
  }
}

class VoterIDStatusPage extends StatefulWidget {
  const VoterIDStatusPage({super.key});

  @override
  _VoterIDStatusPageState createState() => _VoterIDStatusPageState();
}

class _VoterIDStatusPageState extends State<VoterIDStatusPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateOfBirthController;

  @override
  void initState() {
    super.initState();
    _dateOfBirthController = TextEditingController();
  }

  @override
  void dispose() {
    _dateOfBirthController.dispose();
    super.dispose();
  }

  /// Shows a date picker and updates the data model and text controller.
  Future<void> _selectDateOfBirth(BuildContext context, VoterIDStatusData data) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: data.dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith( // Ensure date picker is dark theme compatible
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != data.dateOfBirth) {
      data.updateDateOfBirth(pickedDate);
      _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  /// Initiates the status check after form validation.
  void _checkStatus(VoterIDStatusData data) {
    if (_formKey.currentState!.validate()) {
      data.simulateStatusCheck();
    } else {
      data.updateFormStatusMessage("Please fill in all required fields correctly.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in VoterIDStatusData
    final VoterIDStatusData voterIDData = context.watch<VoterIDStatusData>();

    // Update date controller text if the model's date changes externally
    // (e.g., initial load or if date was pre-filled)
    if (voterIDData.dateOfBirth != null && _dateOfBirthController.text.isEmpty) {
      _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(voterIDData.dateOfBirth!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter ID Status Tracker'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isLargeScreen = constraints.maxWidth > 700;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Flex(
              direction: isLargeScreen ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Form Section
                Expanded(
                  flex: isLargeScreen ? 2 : 0,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text(
                              'Enter your details to track your Voter ID application status.',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70), // Adjusted text color
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Application Number',
                                hintText: 'e.g., VOTER12345',
                                prefixIcon: Icon(Icons.confirmation_number), // Color handled by theme
                              ),
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your application number';
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                // Update data model on change
                                voterIDData.updateApplicationNumber(value);
                                // Validate field immediately if user makes changes
                                _formKey.currentState?.validate();
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _dateOfBirthController,
                              decoration: const InputDecoration(
                                labelText: 'Date of Birth (YYYY-MM-DD)',
                                prefixIcon: Icon(Icons.calendar_today), // Color handled by theme
                              ),
                              readOnly: true,
                              onTap: () => _selectDateOfBirth(context, voterIDData),
                              validator: (String? value) {
                                if (voterIDData.dateOfBirth == null) {
                                  return 'Please select your date of birth';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Select State',
                                prefixIcon: Icon(Icons.location_on), // Color handled by theme
                              ),
                              initialValue: voterIDData.selectedState,
                              dropdownColor: Colors.grey[800], // Darker dropdown background
                              items: voterIDData.states.map<DropdownMenuItem<String>>((String state) {
                                return DropdownMenuItem<String>(
                                  value: state,
                                  child: Text(state, style: const TextStyle(color: Colors.white)), // White text for items
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                voterIDData.updateSelectedState(value);
                                // The form's internal validation state needs to be re-evaluated
                                _formKey.currentState?.validate();
                              },
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a state';
                                }
                                return null;
                              },
                              hint: const Text('Choose your state', style: TextStyle(color: Colors.white54)), // Lighter hint text
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: voterIDData.isLoading ? null : () => _checkStatus(voterIDData),
                                icon: voterIDData.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.search),
                                label: Text(voterIDData.isLoading ? 'Checking Status...' : 'Check Status'),
                              ),
                            ),
                            if (voterIDData.formStatusMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  voterIDData.formStatusMessage!,
                                  style: TextStyle(
                                    color: voterIDData.currentStatus == "Approved"
                                        ? Colors.green.shade400 // Adjusted for dark theme
                                        : Colors.red.shade400, // Adjusted for dark theme
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Add some spacing between form and result on large screens
                if (isLargeScreen) const SizedBox(width: 24),
                // Result Section
                Expanded(
                  flex: isLargeScreen ? 3 : 0,
                  child: voterIDData.isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent), // Ensure visibility
                            ),
                          ),
                        )
                      : const VoterIDStatusResultCard(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Displays the result of the voter ID status check.
class VoterIDStatusResultCard extends StatelessWidget {
  const VoterIDStatusResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for changes in VoterIDStatusData
    final VoterIDStatusData voterIDData = context.watch<VoterIDStatusData>();

    // Show initial message if no data or form message is present
    if (voterIDData.applicantName == null &&
        voterIDData.currentStatus == null &&
        voterIDData.formStatusMessage == null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.info_outline, size: 60, color: Colors.blueGrey[400]), // Adjusted icon color
            const SizedBox(height: 16),
            Text(
              'Your application status will appear here after you submit your details.',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey[300]), // Adjusted text color
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;
    String statusHeaderText;

    switch (voterIDData.currentStatus) {
      case "Approved":
        statusColor = Colors.green.shade400; // Adjusted for dark theme
        statusIcon = Icons.check_circle;
        statusHeaderText = "Application Approved!";
        break;
      case "Under Review":
        statusColor = Colors.orange.shade400; // Adjusted for dark theme
        statusIcon = Icons.hourglass_empty;
        statusHeaderText = "Under Review";
        break;
      case "Rejected":
        statusColor = Colors.red.shade400; // Adjusted for dark theme
        statusIcon = Icons.cancel;
        statusHeaderText = "Application Rejected";
        break;
      default:
        // This case handles when a form status message exists but no specific application status
        statusColor = Colors.blueGrey[400]!; // Adjusted for dark theme
        statusIcon = Icons.help_outline;
        statusHeaderText = "No Status Available";
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Application Status Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), // Adjusted text color
            ),
            const Divider(height: 24, thickness: 1, color: Colors.white24), // Darker divider
            // Display details only if applicantName is available (i.e., status check was successful)
            if (voterIDData.applicantName != null) ...<Widget>[
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blueAccent),
                title: Text('Applicant Name', style: TextStyle(color: Colors.white70)), // Adjusted text color
                subtitle: Text(voterIDData.applicantName!, style: const TextStyle(fontSize: 16, color: Colors.white)), // Adjusted text color
              ),
              ListTile(
                leading: const Icon(Icons.confirmation_number, color: Colors.blueAccent),
                title: Text('Application Number', style: TextStyle(color: Colors.white70)), // Adjusted text color
                subtitle: Text(voterIDData.applicationNumber!, style: const TextStyle(fontSize: 16, color: Colors.white)), // Adjusted text color
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                title: Text('Date of Birth', style: TextStyle(color: Colors.white70)), // Adjusted text color
                subtitle: Text(voterIDData.dateOfBirth != null
                    ? DateFormat('yyyy-MM-dd').format(voterIDData.dateOfBirth!)
                    : 'N/A', style: const TextStyle(fontSize: 16, color: Colors.white)), // Adjusted text color
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.blueAccent),
                title: Text('State', style: TextStyle(color: Colors.white70)), // Adjusted text color
                subtitle: Text(voterIDData.selectedState!, style: const TextStyle(fontSize: 16, color: Colors.white)), // Adjusted text color
              ),
              const Divider(height: 24, thickness: 1, color: Colors.white24), // Darker divider
            ],
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    voterIDData.currentStatus != null ? statusHeaderText : (voterIDData.formStatusMessage ?? "No Status Available"),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: voterIDData.currentStatus != null ? statusColor : Colors.white70, // Adjusted for clarity
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    voterIDData.currentStatus != null ? statusIcon : Icons.info_outline,
                    color: voterIDData.currentStatus != null ? statusColor : Colors.blueGrey[400], // Adjusted for clarity
                    size: 80,
                  ),
                  if (voterIDData.expectedDeliveryDate != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      'Expected Delivery: ${voterIDData.expectedDeliveryDate!}',
                      style: TextStyle(fontSize: 16, color: Colors.white70), // Adjusted text color
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}