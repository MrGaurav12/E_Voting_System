import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';



class UpdateVoterDetailsScreen extends StatefulWidget {
  const UpdateVoterDetailsScreen({super.key});

  @override
  _UpdateVoterDetailsScreenState createState() => _UpdateVoterDetailsScreenState();
}

class _UpdateVoterDetailsScreenState extends State<UpdateVoterDetailsScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // State management
  String _gender = 'M';
  String _state = 'Maharashtra';
  String _nationality = 'Indian';
  bool _isLoading = false;
  bool _isFetching = false;
  bool _dataLoaded = false;
  String _voterId = '';
  Map<String, dynamic>? _originalVoterData;
  Map<String, dynamic>? _currentVoterData;
  String _errorMessage = '';
  String _successMessage = '';

  // State codes mapping (same as CreateVoterIdScreen)
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
      end: Colors.orange.shade700,
    ).animate(_animationController!);

    // Auto-fetch voter data for logged-in user
    _fetchUserVoterData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _fetchUserVoterData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Please login to update voter details';
        });
        return;
      }

      setState(() {
        _isFetching = true;
        _errorMessage = '';
        _successMessage = '';
      });

      final query = await _firestore
          .collection('voters')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final voterDoc = query.docs.first;
        final voterData = voterDoc.data();
        
        setState(() {
          _voterId = voterDoc.id;
          _originalVoterData = Map<String, dynamic>.from(voterData);
          _currentVoterData = Map<String, dynamic>.from(voterData);
          _dataLoaded = true;
        });

        // Populate form fields
        _populateFormFields(voterData);
      } else {
        setState(() {
          _errorMessage = 'No voter ID found for your account. Please register first.';
        });
      }
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = 'Database error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch voter data: $e';
      });
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  void _populateFormFields(Map<String, dynamic> voterData) {
    _nameController.text = voterData['name'] ?? '';
    
    if (voterData['dob'] != null) {
      final dob = (voterData['dob'] as Timestamp).toDate();
      _dobController.text = DateFormat('yyyy-MM-dd').format(dob);
    }
    
    _gender = voterData['gender'] ?? 'M';
    _nationality = voterData['nationality'] ?? 'Indian';
    
    final address = voterData['address'] ?? {};
    _addressLineController.text = address['line'] ?? '';
    _cityController.text = address['city'] ?? '';
    _state = address['state'] ?? 'Maharashtra';
    _pincodeController.text = address['pincode'] ?? '';
  }

  Future<void> _updateVoterDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if any changes were made
    if (!_hasChanges()) {
      setState(() {
        _successMessage = 'No changes detected. Your details are up to date.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    // Button animation
    _animationController?.forward();
    await Future.delayed(Duration(milliseconds: 300));
    _animationController?.reverse();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Verify user still owns this voter ID
      final doc = await _firestore.collection('voters').doc(_voterId).get();
      if (!doc.exists || doc.data()?['userId'] != user.uid) {
        throw Exception('Unauthorized access to voter data');
      }

      // Prepare updated data
      final updatedData = {
        'name': _nameController.text.trim(),
        'address': {
          'line': _addressLineController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _state,
          'pincode': _pincodeController.text.trim(),
        },
        'gender': _gender,
        'nationality': _nationality,
        'updatedAt': Timestamp.now(),
      };

      // Update in Firestore
      await _firestore.collection('voters').doc(_voterId).update(updatedData);

      // Update local state
      setState(() {
        _originalVoterData = Map<String, dynamic>.from(_currentVoterData!);
        _currentVoterData!.addAll(updatedData);
        _successMessage = 'Voter details updated successfully!';
      });

      // Show success dialog
      _showSuccessDialog();

    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = 'Update failed: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Update failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _hasChanges() {
    if (_originalVoterData == null) return false;

    return 
      _nameController.text.trim() != _originalVoterData!['name'] ||
      _addressLineController.text.trim() != _originalVoterData!['address']['line'] ||
      _cityController.text.trim() != _originalVoterData!['address']['city'] ||
      _state != _originalVoterData!['address']['state'] ||
      _pincodeController.text.trim() != _originalVoterData!['address']['pincode'] ||
      _gender != _originalVoterData!['gender'] ||
      _nationality != _originalVoterData!['nationality'];
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Success!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your voter details have been updated successfully.'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Changes will be verified by election officials',
                      style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    if (_originalVoterData != null) {
      _populateFormFields(_originalVoterData!);
      setState(() {
        _successMessage = '';
        _errorMessage = '';
      });
    }
  }

  void _showChangeLog() {
    if (_originalVoterData == null || _currentVoterData == null) return;

    final changes = <String>[];

    if (_nameController.text.trim() != _originalVoterData!['name']) {
      changes.add('Name: ${_originalVoterData!['name']} → ${_nameController.text.trim()}');
    }

    final originalAddress = _originalVoterData!['address'];
    if (_addressLineController.text.trim() != originalAddress['line']) {
      changes.add('Address: ${originalAddress['line']} → ${_addressLineController.text.trim()}');
    }
    if (_cityController.text.trim() != originalAddress['city']) {
      changes.add('City: ${originalAddress['city']} → ${_cityController.text.trim()}');
    }
    if (_state != originalAddress['state']) {
      changes.add('State: ${originalAddress['state']} → $_state');
    }
    if (_pincodeController.text.trim() != originalAddress['pincode']) {
      changes.add('Pincode: ${originalAddress['pincode']} → ${_pincodeController.text.trim()}');
    }
    if (_gender != _originalVoterData!['gender']) {
      changes.add('Gender: ${_originalVoterData!['gender']} → $_gender');
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changes Made'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: changes.length,
            itemBuilder: (context, index) => ListTile(
              leading: Icon(Icons.edit, color: Colors.blue, size: 20),
              title: Text(changes[index], style: TextStyle(fontSize: 14)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
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

  Widget _buildVoterInfoHeader() {
    if (!_dataLoaded || _currentVoterData == null) return SizedBox();

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.credit_card, color: Colors.blue, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voter ID: ${_currentVoterData!['voterId']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Registered on: ${DateFormat('dd MMM yyyy').format((_currentVoterData!['createdAt'] as Timestamp).toDate())}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                if (_currentVoterData!['updatedAt'] != null)
                  Text(
                    'Last updated: ${DateFormat('dd MMM yyyy').format((_currentVoterData!['updatedAt'] as Timestamp).toDate())}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (_hasChanges()) 
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Unsaved Changes',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                            Icons.edit_document,
                            size: 64,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Update Voter Details',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Keep your voter information up to date',
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

                    if (_isFetching) ...[
                      Container(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 20),
                            Text(
                              'Loading your voter details...',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_errorMessage.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            Icon(Icons.error_outline, size: 64, color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _fetchUserVoterData,
                              child: Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_dataLoaded) ...[
                      // Voter Info Header
                      _buildVoterInfoHeader(),

                      // Update Form
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
                              // Success Message
                              if (_successMessage.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.all(16),
                                  margin: EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green),
                                      SizedBox(width: 12),
                                      Expanded(child: Text(_successMessage)),
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

                              // Date of Birth (Read-only)
                              TextFormField(
                                controller: _dobController,
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                                readOnly: true,
                                enabled: false,
                              ),
                              SizedBox(height: 16),

                              // Gender
                              DropdownButtonFormField<String>(
                                initialValue: _gender,
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

                              // Nationality (Read-only)
                              TextFormField(
                                initialValue: _nationality,
                                decoration: InputDecoration(
                                  labelText: 'Nationality',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.flag),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                                readOnly: true,
                                enabled: false,
                              ),
                              SizedBox(height: 24),

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
                                initialValue: _state,
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
                              SizedBox(height: 30),

                              // Action Buttons
                              Row(
                                children: [
                                  if (_hasChanges()) ...[
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _resetForm,
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: 16),
                                          side: BorderSide(color: Colors.grey.shade400),
                                        ),
                                        child: Text(
                                          'Reset Changes',
                                          style: TextStyle(color: Colors.grey.shade700),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                  ],
                                  Expanded(
                                    child: AnimatedBuilder(
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
                                              onPressed: _isLoading ? null : _updateVoterDetails,
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
                                                        Icon(Icons.save_rounded),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          'Update Details',
                                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              if (_hasChanges()) ...[
                                SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: _showChangeLog,
                                  icon: Icon(Icons.list_alt, size: 18),
                                  label: Text('View Changes Made'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Security Notice
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
                                    'Security Notice',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'All changes are logged and subject to verification by election officials. Certain fields like Date of Birth and Nationality cannot be changed for security reasons.',
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