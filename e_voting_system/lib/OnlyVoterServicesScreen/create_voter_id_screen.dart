// create_voter_id_screen.dart
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CreateVoterIdScreen extends StatefulWidget {
  const CreateVoterIdScreen({super.key});

  @override
  _CreateVoterIdScreenState createState() => _CreateVoterIdScreenState();
}

class _CreateVoterIdScreenState extends State<CreateVoterIdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String _gender = 'M';
  String _state = 'Maharashtra';
  String _nationality = 'Indian';
  bool _consent = false;
  bool _isLoading = false;
  bool _voterCreated = false;
  Map<String, dynamic>? _voterData;
  String? _generatedVoterId;

  // State codes mapping
  final Map<String, String> _stateCodes = {
    'Maharashtra': 'MH',
    'Delhi': 'DL',
    'Karnataka': 'KA',
    'Tamil Nadu': 'TN',
    'Uttar Pradesh': 'UP',
    'Gujarat': 'GJ',
    'Rajasthan': 'RJ',
    'West Bengal': 'WB',
    'Bihar': 'BR',
    'Andhra Pradesh': 'AP',
    'Telangana': 'TS',
    'Kerala': 'KL',
    'Madhya Pradesh': 'MP',
    'Punjab': 'PB',
    'Haryana': 'HR',
  };

  @override
  void initState() {
    super.initState();
    _checkExistingVoter();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _aadhaarController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  // Check if user already has a voter ID
  Future<void> _checkExistingVoter() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final query = await _firestore
            .collection('voters')
            .where('userId', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final voterDoc = query.docs.first;
          setState(() {
            _voterCreated = true;
            _voterData = voterDoc.data();
            _generatedVoterId = voterDoc.id;
          });
        }
      }
    } catch (e) {
      print('Error checking existing voter: $e');
    }
  }

  // Mask Aadhaar number - show only last 4 digits
  String maskAadhaar(String aadhaar) {
    if (aadhaar.length <= 4) return aadhaar;
    return 'XXXX-XXXX-${aadhaar.substring(aadhaar.length - 4)}';
  }

  // Aadhaar validation
  String? validateAadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhaar number is required';
    }

    String cleanAadhaar = value.replaceAll(RegExp(r'[\s-]'), '');

    if (cleanAadhaar.length != 12) {
      return 'Aadhaar must be 12 digits';
    }

    if (!RegExp(r'^\d+$').hasMatch(cleanAadhaar)) {
      return 'Aadhaar must contain only numbers';
    }

    return null;
  }

  // Calculate age from DOB
  int calculateAge(DateTime dob) {
    DateTime now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  // Validate eligibility
  bool validateEligibility(DateTime dob, String nationality) {
    int age = calculateAge(dob);
    return age >= 18 && nationality == 'Indian';
  }

  // Generate unique Voter ID
  String generateVoterId(String state) {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final year = DateTime.now().year.toString();

    String stateCode =
        _stateCodes[state] ??
        state.substring(0, min(3, state.length)).toUpperCase();

    String randomPart = String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );

    return 'VID-$year-$stateCode-$randomPart';
  }

  // Check for duplicate Aadhaar
  Future<bool> checkDuplicateAadhaar(String aadhaar) async {
    try {
      String lastFour = aadhaar.substring(aadhaar.length - 4);

      final query = await _firestore
          .collection('voters')
          .where('maskedAadhaar', isEqualTo: 'XXXX-XXXX-$lastFour')
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking duplicate Aadhaar: $e');
      return false;
    }
  }

  // Save voter data to Firestore
  Future<void> saveVoterData() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_consent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm the information is true')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Details'),
        content: const Text(
          'Are you sure the details are correct? Once generated, your voting eligibility will be recorded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to create voter ID'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String cleanAadhaar = _aadhaarController.text.replaceAll(
        RegExp(r'[\s-]'),
        '',
      );

      // Check for duplicate Aadhaar
      bool hasDuplicate = await checkDuplicateAadhaar(cleanAadhaar);
      if (hasDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A voter ID already exists with this Aadhaar number'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Parse DOB and validate eligibility
      DateTime dob = DateTime.parse(_dobController.text);
      if (!validateEligibility(dob, _nationality)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You must be at least 18 years old and Indian to register',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Generate Voter ID
      String voterId = generateVoterId(_state);

      // Prepare voter data for Firestore
      Map<String, dynamic> voterData = {
        'name': _nameController.text.trim(),
        'dob': Timestamp.fromDate(dob),
        'age': calculateAge(dob),
        'gender': _gender,
        'aadhaarLastFour': cleanAadhaar.substring(cleanAadhaar.length - 4),
        'maskedAadhaar': maskAadhaar(cleanAadhaar),
        'address': {
          'line': _addressLineController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _state,
          'pincode': _pincodeController.text.trim(),
        },
        'nationality': _nationality,
        'voterId': voterId,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'isActive': true,
        'isEligible': true,
        'consentGiven': true,
        'userId': user.uid,
        'email': user.email,
      };

      // Save to Firestore
      await _firestore.collection('voters').doc(voterId).set(voterData);

      // Update local state
      setState(() {
        _voterCreated = true;
        _generatedVoterId = voterId;
        _voterData = voterData;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voter ID created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving voter data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating Voter ID: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Generate PDF
  Future<void> downloadVoterId() async {
    if (_voterData == null) return;

    try {
      final pdf = await _generatePdf();
      await Printing.layoutPdf(onLayout: (format) => pdf);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voter ID downloaded successfully')),
      );
    } catch (e) {
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error downloading Voter ID')),
      );
    }
  }

  // Generate PDF document
  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'VOTER ID CARD',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [
                    pw.Container(
                      width: 100,
                      height: 120,
                      color: PdfColors.grey300,
                      child: pw.Center(
                        child: pw.Text(
                          'PHOTO',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Name: ${_voterData!['name']}',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                          pw.Text(
                            'Voter ID: ${_voterData!['voterId']}',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                          pw.Text(
                            'Aadhaar: ${_voterData!['maskedAadhaar']}',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                          pw.Text(
                            'DOB: ${DateFormat('dd/MM/yyyy').format((_voterData!['dob'] as Timestamp).toDate())}',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                          pw.Text(
                            'Age: ${_voterData!['age']}',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                          pw.Text(
                            'State: ${_voterData!['address']['state']}',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                          pw.Text(
                            'Issued: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      width: 80,
                      height: 80,
                      child: pw.BarcodeWidget(
                        data: _voterData!['voterId'],
                        barcode: pw.Barcode.qrCode(),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'This is an official Voter ID Card. Present this when voting.',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Voter ID'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _voterCreated
                  ? _buildVoterIdCard()
                  : _buildRegistrationForm(),
            ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Voter Registration Form',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Full Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 3) {
                return 'Name must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Date of Birth
          TextFormField(
            controller: _dobController,
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                firstDate: DateTime(1900),
                lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
              );
              if (date != null) {
                _dobController.text = date.toIso8601String().split('T')[0];
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select date of birth';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Gender
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'M', child: Text('Male')),
              DropdownMenuItem(value: 'F', child: Text('Female')),
              DropdownMenuItem(value: 'O', child: Text('Other')),
            ],
            onChanged: (value) {
              setState(() {
                _gender = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Aadhaar Number
          TextFormField(
            controller: _aadhaarController,
            decoration: const InputDecoration(
              labelText: 'Aadhaar Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
              hintText: 'XXXX-XXXX-XXXX',
            ),
            keyboardType: TextInputType.number,
            maxLength: 14,
            validator: validateAadhaar,
          ),
          const SizedBox(height: 16),

          // Address Line
          TextFormField(
            controller: _addressLineController,
            decoration: const InputDecoration(
              labelText: 'Address Line',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.home),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // City
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_city),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your city';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // State
          DropdownButtonFormField<String>(
            value: _state,
            decoration: const InputDecoration(
              labelText: 'State',
              border: OutlineInputBorder(),
            ),
            items: _stateCodes.keys.map((state) {
              return DropdownMenuItem(value: state, child: Text(state));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _state = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Pincode
          TextFormField(
            controller: _pincodeController,
            decoration: const InputDecoration(
              labelText: 'Pincode',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pin_drop),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter pincode';
              }
              if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                return 'Please enter valid 6-digit pincode';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Nationality
          DropdownButtonFormField<String>(
            value: _nationality,
            decoration: const InputDecoration(
              labelText: 'Nationality',
              border: OutlineInputBorder(),
            ),
            items: const [DropdownMenuItem(value: 'Indian', child: Text('Indian'))],
            onChanged: (value) {
              setState(() {
                _nationality = value!;
              });
            },
          ),
          const SizedBox(height: 20),

          // Consent Checkbox
          Row(
            children: [
              Checkbox(
                value: _consent,
                onChanged: (value) {
                  setState(() {
                    _consent = value!;
                  });
                },
              ),
              const Expanded(
                child: Text(
                  'I confirm the information is true and I am eligible to vote',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saveVoterData,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[700],
              ),
              child: const Text(
                'Generate Voter ID',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),

          // Privacy Notice
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy & Security Notice:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Your full Aadhaar number is never stored in our database\n'
                  '• Only masked Aadhaar (last 4 digits) is stored for verification\n'
                  '• Real Aadhaar verification should be done via official government APIs\n'
                  '• By proceeding, you consent to the collection and processing of your data',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoterIdCard() {
    return Column(
      children: [
        const Text(
          'Your Voter ID',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Voter ID Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.how_to_vote, color: Colors.white),
                    const SizedBox(width: 10),
                    const Text(
                      'VOTER ID CARD',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Card Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo Placeholder
                  Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera,
                          size: 30,
                          color: Colors.grey[600],
                        ),
                        Text(
                          'PHOTO',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Name:', _voterData!['name']),
                        _buildDetailRow('Voter ID:', _voterData!['voterId']),
                        _buildDetailRow(
                          'Aadhaar:',
                          _voterData!['maskedAadhaar'],
                        ),
                        _buildDetailRow(
                          'DOB:',
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format((_voterData!['dob'] as Timestamp).toDate()),
                        ),
                        _buildDetailRow('Age:', _voterData!['age'].toString()),
                        _buildDetailRow(
                          'State:',
                          _voterData!['address']['state'],
                        ),
                        _buildDetailRow(
                          'Issued:',
                          DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        ),
                      ],
                    ),
                  ),

                  // QR Code
                  QrImageView(
                    data: _voterData!['voterId'],
                    version: QrVersions.auto,
                    size: 80.0,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Footer Note
              Text(
                'This is an official Voter ID Card. Present this when voting.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: downloadVoterId,
                icon: const Icon(Icons.download),
                label: const Text('Download Voter ID'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/main');
                },
                child: const Text('Continue'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Text(
          'Voter ID created successfully! You can now download your card.',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}