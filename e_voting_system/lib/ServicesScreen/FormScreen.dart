import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernFormScreen extends StatefulWidget {
  const ModernFormScreen({super.key});

  @override
  State<ModernFormScreen> createState() => _ModernFormScreenState();
}

class _ModernFormScreenState extends State<ModernFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isSubmitting = false;
  double _formElevation = 4;
  final double _maxFormWidth = 800;

  final List<String> _genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onFocusChange);
    _phoneFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _formElevation = _emailFocus.hasFocus || _phoneFocus.hasFocus ? 8 : 4;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _clearDate() {
    setState(() => _selectedDate = null);
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF4CAF50),
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Form submitted successfully!',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
    
    setState(() => _isSubmitting = false);
    
    // Clear form after submission
    _formKey.currentState?.reset();
    setState(() {
      _selectedDate = null;
      _selectedGender = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.9),
              Theme.of(context).primaryColorDark,
              const Color(0xFF3A36DB),
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSmallScreen ? screenWidth * 0.9 : 
                    isMediumScreen ? 600 : _maxFormWidth,
              margin: const EdgeInsets.all(16),
              child: AnimatedPhysicalModel(
                duration: const Duration(milliseconds: 300),
                elevation: _formElevation,
                color: Colors.white,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(isSmallScreen),
                        const SizedBox(height: 28),
                        _buildNameField(),
                        const SizedBox(height: 20),
                        _buildEmailField(),
                        const SizedBox(height: 20),
                        _buildPhoneField(),
                        const SizedBox(height: 20),
                        _buildGenderDropdown(),
                        const SizedBox(height: 20),
                        _buildDateField(context),
                        const SizedBox(height: 20),
                        _buildAddressField(),
                        const SizedBox(height: 32),
                        _buildSubmitButton(isSmallScreen),
                        const SizedBox(height: 24),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_add_alt_1, 
                size: isSmallScreen ? 32 : 36,
                color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: isSmallScreen ? 26 : 32,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E2B8D),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Please fill in your details carefully. All fields are required.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
        const Divider(height: 40, thickness: 1, color: Colors.black12),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      decoration: _buildInputDecoration(
        context,
        'Full Name',
        Icons.person_outline,
        helperText: 'As it appears on official documents',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your full name';
        }
        if (value.split(' ').length < 2) {
          return 'Please enter first and last name';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      decoration: _buildInputDecoration(
        context,
        'Email Address',
        Icons.email_outlined,
        helperText: 'example@domain.com',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      focusNode: _phoneFocus,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
      ],
      decoration: _buildInputDecoration(
        context,
        'Phone Number',
        Icons.phone_outlined,
        helperText: 'With country code (e.g. +1)',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        if (!RegExp(r'^[+0-9]{8,15}$').hasMatch(value)) {
          return 'Enter valid phone number (8-15 digits)';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
      decoration: _buildInputDecoration(
        context,
        'Gender',
        Icons.transgender_outlined,
      ),
      items: _genders
          .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender, style: const TextStyle(fontSize: 16)),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedGender = value),
      validator: (value) => value == null ? 'Please select your gender' : null,
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: _selectedDate == null ? '' : DateFormat.yMMMMd().format(_selectedDate!),
      ),
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        prefixIcon: Icon(Icons.calendar_today_outlined, 
                         color: Theme.of(context).primaryColor),
        suffixIcon: _selectedDate != null
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _clearDate,
              )
            : null,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(color: Colors.black54),
        helperText: 'Must be at least 18 years old',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black26),
        ),
      ),
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your date of birth';
        }
        if (_selectedDate != null) {
          final age = DateTime.now().difference(_selectedDate!).inDays ~/ 365;
          if (age < 18) return 'Must be at least 18 years old';
        }
        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      maxLines: 3,
      textInputAction: TextInputAction.newline,
      decoration: _buildInputDecoration(
        context,
        'Full Address',
        Icons.home_outlined,
        helperText: 'Street, City, ZIP Code',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your address';
        }
        if (value.length < 15) {
          return 'Please enter a complete address';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                'SUBMIT FORM',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Divider(color: Colors.black12, thickness: 1),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 16, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Your information is securely encrypted',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'We never share your data with third parties',
          style: TextStyle(fontSize: 12, color: Colors.black45),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, 
    String label, 
    IconData icon, {
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(color: Colors.black54),
      helperText: helperText,
      helperStyle: const TextStyle(fontSize: 13),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 20,
      ),
    );
  }
}

class DateFormat {
  static yMMMMd() {}
}