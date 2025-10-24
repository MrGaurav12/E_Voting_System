import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VoterStatusScreen extends StatefulWidget {
  @override
  _VoterStatusScreenState createState() => _VoterStatusScreenState();
}

class _VoterStatusScreenState extends State<VoterStatusScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _voterIdController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  Map<String, dynamic>? _voterData;
  String _errorMessage = '';
  AnimationController? _animationController;
  Animation<double>? _buttonAnimation;
  Animation<Color?>? _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.blue.shade700,
      end: Colors.purple.shade700,
    ).animate(_animationController!);
  }

  @override
  void dispose() {
    _voterIdController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _checkVoterStatus() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _voterData = null;
      _errorMessage = '';
    });

    // Button animation
    _animationController?.forward();
    await Future.delayed(Duration(milliseconds: 300));
    _animationController?.reverse();

    try {
      final voterId = _voterIdController.text.trim().toUpperCase();
      
      final doc = await _firestore
          .collection('voters')
          .doc(voterId)
          .get()
          .timeout(Duration(seconds: 10));

      if (doc.exists) {
        setState(() {
          _voterData = doc.data();
        });
      } else {
        setState(() {
          _errorMessage = 'Voter ID not found in our records';
        });
      }
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = 'Database error: ${e.message}';
      });
    } on TimeoutException {
      setState(() {
        _errorMessage = 'Request timeout. Please check your internet connection.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validateVoterId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Voter ID';
    }
    if (value.length < 8) {
      return 'Voter ID must be at least 8 characters';
    }
    // Validate VID format (VID-YYYY-STATE-XXXXXX)
    if (!value.toUpperCase().startsWith('VID-')) {
      return 'Voter ID should start with VID-';
    }
    return null;
  }

  Widget _buildStatusCard() {
    if (_voterData == null && _errorMessage.isEmpty) return SizedBox();

    Color cardColor;
    Color textColor = Colors.white;
    String status;
    String statusDescription;
    IconData statusIcon;
    List<Widget> additionalInfo = [];

    if (_voterData != null) {
      bool isActive = _voterData!['isActive'] ?? false;
      bool isEligible = _voterData!['isEligible'] ?? false;
      
      if (isActive && isEligible) {
        cardColor = Colors.green.shade600;
        status = 'ACTIVE & ELIGIBLE';
        statusDescription = 'You are registered and eligible to vote';
        statusIcon = Icons.verified_user_rounded;
        
        // Add voter details
        additionalInfo.addAll([
          _buildDetailCard('Personal Information', [
            _buildInfoItem('Full Name', _voterData!['name'] ?? 'N/A'),
            _buildInfoItem('Age', _voterData!['age']?.toString() ?? 'N/A'),
            _buildInfoItem('Gender', _voterData!['gender'] ?? 'N/A'),
          ]),
          _buildDetailCard('Address Information', [
            _buildInfoItem('Address', _voterData!['address']?['line'] ?? 'N/A'),
            _buildInfoItem('City', _voterData!['address']?['city'] ?? 'N/A'),
            _buildInfoItem('State', _voterData!['address']?['state'] ?? 'N/A'),
            _buildInfoItem('Pincode', _voterData!['address']?['pincode'] ?? 'N/A'),
          ]),
          _buildDetailCard('Registration Details', [
            _buildInfoItem('Voter ID', _voterData!['voterId'] ?? 'N/A'),
            _buildInfoItem('Aadhaar', _voterData!['maskedAadhaar'] ?? 'N/A'),
            _buildInfoItem('Nationality', _voterData!['nationality'] ?? 'N/A'),
            if (_voterData!['createdAt'] != null)
              _buildInfoItem(
                'Registered On', 
                DateFormat('dd MMM yyyy').format((_voterData!['createdAt'] as Timestamp).toDate())
              ),
          ]),
        ]);
      } else {
        cardColor = Colors.orange.shade600;
        status = 'RESTRICTED';
        statusDescription = 'Your voting rights are currently restricted';
        statusIcon = Icons.warning_rounded;
        
        additionalInfo.add(
          _buildDetailCard('Status Information', [
            _buildInfoItem('Account Active', isActive ? 'Yes' : 'No'),
            _buildInfoItem('Voting Eligible', isEligible ? 'Yes' : 'No'),
            _buildInfoItem('Name', _voterData!['name'] ?? 'N/A'),
            _buildInfoItem('Voter ID', _voterData!['voterId'] ?? 'N/A'),
          ]),
        );
      }
    } else {
      cardColor = Colors.grey.shade600;
      status = 'NOT FOUND';
      statusDescription = _errorMessage;
      statusIcon = Icons.search_off_rounded;
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 600),
          curve: Curves.easeInOutBack,
          margin: EdgeInsets.symmetric(vertical: 20),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor.withOpacity(0.9),
                cardColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(0.3),
                blurRadius: 25,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  size: 48,
                  color: textColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                status,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                statusDescription,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              if (_voterData != null) ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voter ID',
                            style: TextStyle(
                              color: textColor.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _voterData!['voterId'] ?? 'N/A',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.credit_card, color: textColor),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkVoterStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor,
                  foregroundColor: cardColor,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'Check Another ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...additionalInfo,
      ],
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
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
                  maxWidth: 600,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                            Icons.how_to_vote_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Voter Status Verification',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Verify your voter registration status instantly with your Voter ID',
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

                    // Input Section
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
                          children: [
                            TextFormField(
                              controller: _voterIdController,
                              decoration: InputDecoration(
                                labelText: 'Enter Your Voter ID',
                                hintText: 'e.g., VID-2024-MH-A1B2C3',
                                prefixIcon: Icon(Icons.credit_card_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                              validator: _validateVoterId,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _checkVoterStatus,
                            ),
                            SizedBox(height: 24),
                            AnimatedBuilder(
                              animation: _animationController!,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _buttonAnimation!.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _colorAnimation!.value!,
                                          Colors.purple.shade700,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.shade300.withOpacity(0.5),
                                          blurRadius: 15,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _checkVoterStatus,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 48,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.search_rounded, size: 24),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Check Voter Status',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Enter the Voter ID generated during registration',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Result Section
                    _buildStatusCard(),

                    // Footer
                    SizedBox(height: 30),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Need Help?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Contact Voter Helpline: 1800-123-4567\nEmail: support@electioncommission.gov',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
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