import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


class VoterRegistrationScreen extends StatefulWidget {
  @override
  _VoterRegistrationScreenState createState() => _VoterRegistrationScreenState();
}

class _VoterRegistrationScreenState extends State<VoterRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // State management
  String _gender = 'M';
  String _state = 'Maharashtra';
  String _nationality = 'Indian';
  bool _consent = false;
  bool _isLoading = false;
  bool _isChecking = false;
  bool _hasExistingVoter = false;
  Map<String, dynamic>? _existingVoterData;
  String _errorMessage = '';
  String _infoMessage = '';

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

  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Animation<Color?>? _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.blue.shade700,
      end: Colors.green.shade700,
    ).animate(_animationController!);

    // Check if user already has a voter ID
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
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _checkExistingVoter() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() {
        _isChecking = true;
      });

      final query = await _firestore
          .collection('voters')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final voterDoc = query.docs.first;
        setState(() {
          _hasExistingVoter = true;
          _existingVoterData = voterDoc.data();
        });
        
        // Show existing voter popup
        _showExistingVoterPopup();
      }
    } catch (e) {
      print('Error checking existing voter: $e');
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _showExistingVoterPopup() {
    if (_existingVoterData == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildExistingVoterDialog(),
      );
    });
  }

  Widget _buildExistingVoterDialog() {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info, color: Colors.blue, size: 28),
          SizedBox(width: 12),
          Text('Voter ID Already Exists', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You already have a registered Voter ID:'),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _existingVoterData!['voterId'] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 8),
                Text('Name: ${_existingVoterData!['name']}'),
                Text('Status: Active'),
                if (_existingVoterData!['createdAt'] != null)
                  Text(
                    'Registered: ${DateFormat('dd MMM yyyy').format((_existingVoterData!['createdAt'] as Timestamp).toDate())}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'You cannot create multiple Voter IDs. Please use your existing Voter ID for all voting purposes.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _navigateToVoterServices();
          },
          child: Text('Go to Voter Services'),
        ),
      ],
    );
  }

  void _navigateToVoterServices() {
    // Navigate to voter services screen
    // You can replace this with your actual navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirecting to Voter Services...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _checkDuplicateAadhaar() async {
    if (_aadhaarController.text.isEmpty) return;

    try {
      final cleanAadhaar = _aadhaarController.text.replaceAll(RegExp(r'[\s-]'), '');
      if (cleanAadhaar.length != 12) return;

      final lastFour = cleanAadhaar.substring(cleanAadhaar.length - 4);
      final query = await _firestore
          .collection('voters')
          .where('aadhaarLastFour', isEqualTo: lastFour)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        _showDuplicateAadhaarPopup(query.docs.first.data());
      }
    } catch (e) {
      print('Error checking duplicate Aadhaar: $e');
    }
  }

  void _showDuplicateAadhaarPopup(Map<String, dynamic> existingData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Aadhaar Already Registered', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Aadhaar number is already associated with an existing Voter ID:'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voter ID: ${existingData['voterId']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Name: ${existingData['name']}'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Each Aadhaar number can only be used for one Voter ID registration.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String _generateVoterId(String state) {
    final random = _Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final year = DateTime.now().year.toString();

    String stateCode = _stateCodes[state] ?? 
        state.substring(0, state.length < 3 ? state.length : 3).toUpperCase();

    String randomPart = String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );

    return 'VID-$year-$stateCode-$randomPart';
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  bool _validateEligibility(DateTime dob, String nationality) {
    final age = _calculateAge(dob);
    return age >= 18 && nationality == 'Indian';
  }

  String _maskAadhaar(String aadhaar) {
    if (aadhaar.length <= 4) return aadhaar;
    return 'XXXX-XXXX-${aadhaar.substring(aadhaar.length - 4)}';
  }

  Future<void> _registerVoter() async {
    if (_hasExistingVoter) {
      _showExistingVoterPopup();
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (!_consent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please confirm the information is true')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildConfirmationDialog(),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Button animation
    _animationController?.forward();
    await Future.delayed(Duration(milliseconds: 300));
    _animationController?.reverse();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Please login to register as voter');
      }

      // Check again for existing voter (race condition)
      final existingCheck = await _firestore
          .collection('voters')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existingCheck.docs.isNotEmpty) {
        setState(() {
          _hasExistingVoter = true;
          _existingVoterData = existingCheck.docs.first.data();
        });
        _showExistingVoterPopup();
        return;
      }

      // Check for duplicate Aadhaar
      final cleanAadhaar = _aadhaarController.text.replaceAll(RegExp(r'[\s-]'), '');
      final lastFour = cleanAadhaar.substring(cleanAadhaar.length - 4);
      final aadhaarCheck = await _firestore
          .collection('voters')
          .where('aadhaarLastFour', isEqualTo: lastFour)
          .limit(1)
          .get();

      if (aadhaarCheck.docs.isNotEmpty) {
        _showDuplicateAadhaarPopup(aadhaarCheck.docs.first.data());
        return;
      }

      // Validate eligibility
      final dob = DateTime.parse(_dobController.text);
      if (!_validateEligibility(dob, _nationality)) {
        throw Exception('You must be at least 18 years old and Indian to register');
      }

      // Generate Voter ID and prepare data
      final voterId = _generateVoterId(_state);
      final voterData = {
        'name': _nameController.text.trim(),
        'dob': Timestamp.fromDate(dob),
        'age': _calculateAge(dob),
        'gender': _gender,
        'aadhaarLastFour': lastFour,
        'maskedAadhaar': _maskAadhaar(cleanAadhaar),
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

      // Show success dialog
      _showSuccessDialog(voterId, voterData);

    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = 'Registration failed: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildConfirmationDialog() {
    return AlertDialog(
      title: Text('Confirm Registration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Please verify your details:'),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${_nameController.text}'),
                Text('DOB: ${_dobController.text}'),
                Text('Gender: ${_gender == 'M' ? 'Male' : _gender == 'F' ? 'Female' : 'Other'}'),
                Text('State: $_state'),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'By confirming, you agree that the information provided is true and accurate.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Confirm & Register'),
        ),
      ],
    );
  }

  void _showSuccessDialog(String voterId, Map<String, dynamic> voterData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Registration Successful!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Voter ID has been created successfully:'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voterId,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Name: ${voterData['name']}'),
                  Text('Status: Active'),
                  Text('Age: ${voterData['age']} years'),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Please save your Voter ID securely. You will need it for all voting-related activities.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _hasExistingVoter = true;
                _existingVoterData = voterData;
              });
              _clearForm();
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _dobController.clear();
    _aadhaarController.clear();
    _addressLineController.clear();
    _cityController.clear();
    _pincodeController.clear();
    setState(() {
      _gender = 'M';
      _state = 'Maharashtra';
      _nationality = 'Indian';
      _consent = false;
    });
  }

  String? _validateAadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhaar number is required';
    }

    final cleanAadhaar = value.replaceAll(RegExp(r'[\s-]'), '');
    if (cleanAadhaar.length != 12) {
      return 'Aadhaar must be 12 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(cleanAadhaar)) {
      return 'Aadhaar must contain only numbers';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter pincode';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Please enter valid 6-digit pincode';
    }
    return null;
  }

  Widget _buildExistingVoterBanner() {
    if (!_hasExistingVoter) return SizedBox();

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.green.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You already have a Voter ID',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _existingVoterData?['voterId'] ?? '',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showExistingVoterPopup,
            icon: Icon(Icons.info_outline, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.white,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 700,
                ),
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      padding: EdgeInsets.all(32),
                      margin: EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade700,
                            Colors.purple.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 25,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.how_to_reg_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Voter Registration',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Register as a new voter and get your Voter ID',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    if (_isChecking) ...[
                      Container(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 20),
                            Text(
                              'Checking your registration status...',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Existing Voter Banner
                      _buildExistingVoterBanner(),

                      // Registration Form
                      if (!_hasExistingVoter) ...[
                        Container(
                          padding: EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_errorMessage.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    margin: EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.red),
                                        SizedBox(width: 12),
                                        Expanded(child: Text(_errorMessage)),
                                      ],
                                    ),
                                  ),

                                Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                SizedBox(height: 20),

                                // Full Name
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  validator: _validateName,
                                ),
                                SizedBox(height: 16),

                                // Date of Birth
                                TextFormField(
                                  controller: _dobController,
                                  decoration: InputDecoration(
                                    labelText: 'Date of Birth *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now().subtract(Duration(days: 365 * 18)),
                                    );
                                    if (date != null) {
                                      _dobController.text = DateFormat('yyyy-MM-dd').format(date);
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select date of birth';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),

                                // Gender
                                DropdownButtonFormField<String>(
                                  value: _gender,
                                  decoration: InputDecoration(
                                    labelText: 'Gender *',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  items: [
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
                                SizedBox(height: 16),

                                // Aadhaar Number
                                TextFormField(
                                  controller: _aadhaarController,
                                  decoration: InputDecoration(
                                    labelText: 'Aadhaar Number *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.credit_card),
                                    hintText: 'XXXX-XXXX-XXXX',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  keyboardType: TextInputType.number,
                                  maxLength: 14,
                                  validator: _validateAadhaar,
                                  onChanged: (value) {
                                    if (value.length == 12 || value.length == 14) {
                                      _checkDuplicateAadhaar();
                                    }
                                  },
                                ),
                                SizedBox(height: 16),

                                Text(
                                  'Address Information',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Address Line
                                TextFormField(
                                  controller: _addressLineController,
                                  decoration: InputDecoration(
                                    labelText: 'Address Line *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.home),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your address';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),

                                // City
                                TextFormField(
                                  controller: _cityController,
                                  decoration: InputDecoration(
                                    labelText: 'City *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.location_city),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your city';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),

                                // State
                                DropdownButtonFormField<String>(
                                  value: _state,
                                  decoration: InputDecoration(
                                    labelText: 'State *',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
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
                                SizedBox(height: 16),

                                // Pincode
                                TextFormField(
                                  controller: _pincodeController,
                                  decoration: InputDecoration(
                                    labelText: 'Pincode *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.pin_drop),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  validator: _validatePincode,
                                ),
                                SizedBox(height: 16),

                                // Nationality
                                DropdownButtonFormField<String>(
                                  value: _nationality,
                                  decoration: InputDecoration(
                                    labelText: 'Nationality *',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  items: [DropdownMenuItem(value: 'Indian', child: Text('Indian'))],
                                  onChanged: (value) {
                                    setState(() {
                                      _nationality = value!;
                                    });
                                  },
                                ),
                                SizedBox(height: 24),

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
                                    Expanded(
                                      child: Text(
                                        'I confirm that the information provided is true and accurate. I am eligible to vote and understand that providing false information is punishable by law.',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),

                                // Register Button
                                AnimatedBuilder(
                                  animation: _animationController!,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _scaleAnimation!.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              _colorAnimation!.value!,
                                              Colors.blue.shade700,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.shade300.withOpacity(0.5),
                                              blurRadius: 15,
                                              offset: Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _isLoading ? null : _registerVoter,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            shadowColor: Colors.transparent,
                                            padding: EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.how_to_reg_rounded),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Register as Voter',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Privacy Notice
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.security_rounded, color: Colors.orange),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Privacy & Security',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Your full Aadhaar number is never stored. Only the last 4 digits are saved for verification. All data is protected and used solely for election purposes.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Already Registered Message
                        Container(
                          padding: EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.verified_user_rounded, size: 64, color: Colors.green),
                              SizedBox(height: 20),
                              Text(
                                'You Are Already Registered!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'You cannot create multiple Voter IDs. Please use your existing Voter ID for all voting-related activities.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _navigateToVoterServices,
                                child: Text('Go to Voter Services'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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

// Helper class for random number generation
class _Random {
  final _random = Random();

  int nextInt(int max) => _random.nextInt(max);
}