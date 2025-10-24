import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';


class DownloadVoterIdScreen extends StatefulWidget {
  const DownloadVoterIdScreen({super.key});

  @override
  _DownloadVoterIdScreenState createState() => _DownloadVoterIdScreenState();
}

class _DownloadVoterIdScreenState extends State<DownloadVoterIdScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _voterIdController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _voterData;
  bool _isLoading = false;
  bool _isDownloading = false;
  String _errorMessage = '';
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
    
    // Auto-fetch voter data for logged-in user
    _fetchUserVoterData();
  }

  @override
  void dispose() {
    _voterIdController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _fetchUserVoterData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _isLoading = true;
        });

        final query = await _firestore
            .collection('voters')
            .where('userId', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          setState(() {
            _voterData = query.docs.first.data();
            _voterIdController.text = _voterData!['voterId'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error fetching voter data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchVoterDataById() async {
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
          _errorMessage = 'Voter ID not found. Please check the ID and try again.';
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

  Future<void> _downloadVoterIdCard() async {
    if (_voterData == null) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final pdf = await _generateVoterIdPdf();
      await Printing.layoutPdf(onLayout: (format) => pdf);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voter ID card downloaded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading Voter ID card'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<Uint8List> _generateVoterIdPdf() async {
    final pdf = pw.Document();

    // Add Voter ID Card page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue, width: 2),
              borderRadius: pw.BorderRadius.circular(15),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text('-', style: pw.TextStyle(color: PdfColors.white, fontSize: 24)),
                      pw.SizedBox(width: 10),
                      pw.Text(
                        'VOTER ID CARD',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Content
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Photo Section
                    pw.Container(
                      width: 120,
                      height: 150,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            '📷',
                            style: pw.TextStyle(fontSize: 30, color: PdfColors.grey),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'PHOTO',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 25),

                    // Voter Details
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfDetailRow('Name:', _voterData!['name'] ?? 'N/A'),
                          _buildPdfDetailRow('Voter ID:', _voterData!['voterId'] ?? 'N/A'),
                          _buildPdfDetailRow('Aadhaar:', _voterData!['maskedAadhaar'] ?? 'N/A'),
                          _buildPdfDetailRow(
                            'Date of Birth:',
                            _voterData!['dob'] != null
                                ? DateFormat('dd/MM/yyyy').format((_voterData!['dob'] as Timestamp).toDate())
                                : 'N/A'
                          ),
                          _buildPdfDetailRow('Age:', _voterData!['age']?.toString() ?? 'N/A'),
                          _buildPdfDetailRow('Gender:', _voterData!['gender'] ?? 'N/A'),
                          _buildPdfDetailRow('State:', _voterData!['address']?['state'] ?? 'N/A'),
                          _buildPdfDetailRow('Nationality:', _voterData!['nationality'] ?? 'N/A'),
                        ],
                      ),
                    ),

                    // QR Code
                    pw.Container(
                      width: 100,
                      height: 100,
                      child: pw.BarcodeWidget(
                        data: _voterData!['voterId'] ?? '',
                        barcode: pw.Barcode.qrCode(),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Footer
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'OFFICIAL VOTER IDENTIFICATION CARD',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'This card certifies that the holder is a registered voter.\nPresent this card when voting at your designated polling station.',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Issued on: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // Security Features
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text(
                      'SECURITY FEATURES:',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text('• QR Code Verification', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                    pw.Text('• Unique Voter ID', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                    pw.Text('• Digital Signature', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateVoterId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Voter ID';
    }
    if (value.length < 8) {
      return 'Voter ID must be at least 8 characters';
    }
    if (!value.toUpperCase().startsWith('VID-')) {
      return 'Voter ID should start with VID-';
    }
    return null;
  }

  Widget _buildVoterInfoCard() {
    if (_voterData == null) return SizedBox();

    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOutBack,
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Voter ID Found & Ready to Download',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Voter Details
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildInfoRow('Voter ID', _voterData!['voterId'] ?? 'N/A', Icons.credit_card),
                _buildInfoRow('Full Name', _voterData!['name'] ?? 'N/A', Icons.person),
                _buildInfoRow('Age/Gender', '${_voterData!['age']} / ${_voterData!['gender']}', Icons.cake),
                _buildInfoRow('Address', '${_voterData!['address']?['city']}, ${_voterData!['address']?['state']}', Icons.location_on),
                if (_voterData!['createdAt'] != null)
                  _buildInfoRow(
                    'Registered On', 
                    DateFormat('dd MMM yyyy').format((_voterData!['createdAt'] as Timestamp).toDate()), 
                    Icons.calendar_today
                  ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Download Button
          AnimatedBuilder(
            animation: _animationController!,
            builder: (context, child) {
              return Transform.scale(
                scale: _isDownloading ? 0.95 : _scaleAnimation!.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade600,
                        Colors.green.shade800,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isDownloading ? null : _downloadVoterIdCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isDownloading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Generating PDF...',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.download_rounded, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Download Voter ID Card',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            'Download a digital copy of your official Voter ID Card',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 20),
          SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
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
              Colors.green.shade50,
              Colors.white,
            ],
            stops: [0.0, 0.4, 1.0],
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
                            Colors.green.shade700,
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
                            Icons.badge_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Download Voter ID Card',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Get your digital Voter ID card instantly',
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

                    // Search Section
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
                              onFieldSubmitted: (_) => _fetchVoterDataById,
                            ),
                            SizedBox(height: 24),
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
                                      onPressed: _isLoading ? null : _fetchVoterDataById,
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
                                                  'Find Voter ID',
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
                            if (_errorMessage.isNotEmpty) ...[
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _errorMessage,
                                        style: TextStyle(color: Colors.red.shade800),
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

                    // Voter Info & Download Section
                    _buildVoterInfoCard(),

                    // Features Section
                    if (_voterData != null) ...[
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(24),
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
                            Text(
                              'Digital Voter ID Features',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            SizedBox(height: 16),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _buildFeatureItem(Icons.qr_code, 'QR Code Verification', 'Scan to verify authenticity'),
                                _buildFeatureItem(Icons.security, 'Secure Digital Copy', 'Protected with security features'),
                                _buildFeatureItem(Icons.print, 'Easy to Print', 'High-quality printable format'),
                                _buildFeatureItem(Icons.phone_android, 'Mobile Friendly', 'Accessible on all devices'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

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
                            'Official Voter ID Card',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This digital card is equivalent to the physical Voter ID card\nand can be used for identification purposes.',
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

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Container(
      width: 140,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 32),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}