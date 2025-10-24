import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(home: VoterHelplinePage()));

class VoterHelplinePage extends StatefulWidget {
  const VoterHelplinePage({super.key});

  @override
  State<VoterHelplinePage> createState() => _VoterHelplinePageState();
}

class _VoterHelplinePageState extends State<VoterHelplinePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedCategory = 'Voter ID';

  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'वोटर आईडी खो जाने पर क्या करें?',
      answer: 'आप ऑनलाइन पोर्टल पर जाकर डुप्लीकेट वोटर आईडी के लिए आवेदन कर सकते हैं या हेल्पलाइन 1950 पर संपर्क करें।',
    ),
    FAQItem(
      question: 'नया वोटर पंजीकरण कैसे करें?',
      answer: 'राष्ट्रीय मतदान सेवा पोर्टल (NVSP) पर फॉर्म 6 भरें या वोटर हेल्पलाइन ऐप का उपयोग करें।',
    ),
    FAQItem(
      question: 'शिकायत कहाँ दर्ज करें?',
      answer: 'वोटर हेल्पलाइन 1950, ईमेल या अपने जिला निर्वाचन अधिकारी के कार्यालय में शिकायत दर्ज करा सकते हैं।',
    ),
    FAQItem(
      question: 'विवरण कैसे अपडेट करें?',
      answer: 'राष्ट्रीय मतदान सेवा पोर्टल पर लॉग इन करके फॉर्म 8 के माध्यम से विवरण अपडेट करें।',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter Helpline Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction Text
            const Text(
              'यदि आपको वोटर आईडी, पंजीकरण, विवरण अपडेट, मतदान केंद्र या किसी अन्य वोटर-सम्बंधित सेवा से जुड़ा प्रश्न या समस्या है, तो आप यहाँ से सहायता प्राप्त कर सकते हैं।',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Helpline Options
            const Text(
              'संपर्क विकल्प:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildContactOption(Icons.phone, 'टोल-फ्री नंबर: 1950', 'tel:1950'),
            _buildContactOption(Icons.email, 'ईमेल सपोर्ट: support@eci.gov.in', 'mailto:support@eci.gov.in'),
            _buildContactOption(Icons.chat, 'चैट सपोर्ट (WhatsApp)', 'https://wa.me/919999999999'),
            _buildContactOption(Icons.download, 'वोटर हेल्पलाइन ऐप डाउनलोड करें', 'https://eci.gov.in/voter-app'),
            const SizedBox(height: 24),

            // FAQ Section
            const Text(
              'आमतौर पर पूछे जाने वाले प्रश्न:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._faqs.map((faq) => _buildFAQ(faq)),
            const SizedBox(height: 24),

            // Contact Form
            const Text(
              'संपर्क फॉर्म:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildContactForm(),
            const SizedBox(height: 24),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String text, String url) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text),
      onTap: () => _launchUrl(url),
    );
  }

  Widget _buildFAQ(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(faq.question, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [Padding(
          padding: const EdgeInsets.all(16),
          child: Text(faq.answer),
        )],
      ),
    );
  }

  Widget _buildContactForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'नाम',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'कृपया अपना नाम दर्ज करें';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactController,
            decoration: const InputDecoration(
              labelText: 'ईमेल / फोन नंबर',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'कृपया संपर्क जानकारी दर्ज करें';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'प्रश्न का प्रकार',
              border: OutlineInputBorder(),
            ),
            items: const [
              'Voter ID',
              'Registration',
              'Polling Station',
              'Complaint',
              'Others'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _messageController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'आपका संदेश',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'कृपया अपना संदेश दर्ज करें';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('जमा करें', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'महत्वपूर्ण लिंक:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildLink('भारत निर्वाचन आयोग', 'https://eci.gov.in'),
            _buildLink('राज्य निर्वाचन कार्यालय', 'https://stateelections.nic.in'),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'हमें फॉलो करें:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildSocialIcon(Icons.facebook, 'https://facebook.com/ECI'),
            const SizedBox(width: 16),
            _buildSocialIcon(Icons.public, 'https://twitter.com/ECISVEEP'), // Changed Icons.twitter to Icons.public
            const SizedBox(width: 16),
            _buildSocialIcon(Icons.telegram, 'https://t.me/ECI'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return IconButton(
      icon: Icon(icon, size: 30, color: Colors.blue),
      onPressed: () => _launchUrl(url),
    );
  }

  Widget _buildLink(String text, String url) {
    return InkWell(
      child: Text(text, style: const TextStyle(color: Colors.blue)),
      onTap: () => _launchUrl(url),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Optionally handle the error, e.g., show a snackbar
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Could not launch $url')),
      // );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form submission logic would go here
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('सफलता!'),
          content: const Text('आपका प्रश्न सफलतापूर्वक जमा किया गया है'),
          actions: [
            TextButton(
              child: const Text('ठीक है'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      
      // Clear form after submission
      _nameController.clear();
      _contactController.clear();
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}