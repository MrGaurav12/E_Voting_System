import 'package:flutter/material.dart';


class EPICApp extends StatelessWidget {
  const EPICApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EPIC Services',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const EPICScreen(),
    );
  }
}

class EPICScreen extends StatelessWidget {
  const EPICScreen({super.key});

  final List<Map<String, String>> services = const [
    {
      'title': 'Download e-EPIC',
      'description': 'Get your digital voter ID instantly.',
      'icon': '📥'
    },
    {
      'title': 'Update EPIC details',
      'description': 'Correct your name, photo, or address.',
      'icon': '✏️'
    },
    {
      'title': 'Check EPIC status',
      'description': 'Track your EPIC application.',
      'icon': '🔍'
    },
    {
      'title': 'Link Aadhaar with EPIC',
      'description': 'Connect your Aadhaar number.',
      'icon': '🔗'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EPIC Services"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          int crossAxisCount = isMobile ? 1 : 2;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Banner Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.credit_card, color: Colors.white, size: 60),
                      SizedBox(height: 10),
                      Text(
                        "Your Voter ID, Anytime, Anywhere",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Services Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isMobile ? 3 / 1.2 : 3 / 1,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return _buildServiceCard(
                      icon: services[index]['icon']!,
                      title: services[index]['title']!,
                      description: services[index]['description']!,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard({
    required String icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Go"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
