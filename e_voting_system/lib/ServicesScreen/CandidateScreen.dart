import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';


class CandidateApp extends StatelessWidget {
  const CandidateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candidate Information',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CandidateListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Candidate {
  final String id;
  final String name;
  final String party;
  final String constituency;
  final int age;
  final String gender;
  final String photoUrl;
  final String bio;
  final String education;
  final String criminalCases;
  final String pastResults;
  final String assets;
  final String liabilities;

  Candidate({
    required this.id,
    required this.name,
    required this.party,
    required this.constituency,
    required this.age,
    required this.gender,
    required this.photoUrl,
    required this.bio,
    required this.education,
    required this.criminalCases,
    required this.pastResults,
    required this.assets,
    required this.liabilities,
  });
}

final dummyCandidates = [
  Candidate(
    id: '1',
    name: 'Rajesh Kumar',
    party: 'National Unity Party',
    constituency: 'Mumbai South',
    age: 45,
    gender: 'Male',
    photoUrl: 'https://example.com/photo1.jpg',
    bio: 'Experienced politician with 10 years in public service...',
    education: 'MBA, Harvard University',
    criminalCases: 'None',
    pastResults: '2019: Won with 52% votes',
    assets: '₹5.2 Crore',
    liabilities: '₹32 Lakh',
  ),
  // Add more candidates here
];

class CandidateListScreen extends StatefulWidget {
  const CandidateListScreen({super.key});

  @override
  State<CandidateListScreen> createState() => _CandidateListScreenState();
}

class _CandidateListScreenState extends State<CandidateListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Candidate> _filteredCandidates = dummyCandidates;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCandidates);
  }

  void _filterCandidates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCandidates = dummyCandidates.where((candidate) {
        return candidate.name.toLowerCase().contains(query) ||
            candidate.party.toLowerCase().contains(query) ||
            candidate.constituency.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidate Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : 16,
              vertical: 16,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, party, or constituency',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (isDesktop) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 1200 ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: _filteredCandidates.length,
                    itemBuilder: (context, index) => CandidateCard(
                      candidate: _filteredCandidates[index],
                      onTap: () => _navigateToDetail(_filteredCandidates[index]),
                    ),
                  );
                } else if (isTablet) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.7,
                    ),
                    itemCount: _filteredCandidates.length,
                    itemBuilder: (context, index) => CandidateCard(
                      candidate: _filteredCandidates[index],
                      onTap: () => _navigateToDetail(_filteredCandidates[index]),
                    ),
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredCandidates.length,
                    itemBuilder: (context, index) => CandidateCard(
                      candidate: _filteredCandidates[index],
                      onTap: () => _navigateToDetail(_filteredCandidates[index]),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Candidate candidate) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CandidateDetailScreen(candidate: candidate),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final VoidCallback onTap;

  const CandidateCard({
    super.key,
    required this.candidate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: isMobile ? 30 : 40,
                    backgroundImage: CachedNetworkImageProvider(candidate.photoUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          candidate.party,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Constituency: ${candidate.constituency}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${candidate.age} years • ${candidate.gender}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CandidateDetailScreen extends StatelessWidget {
  final Candidate candidate;

  const CandidateDetailScreen({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(candidate.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 80 : isTablet ? 40 : 16,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: candidate.id,
                child: CircleAvatar(
                  radius: isDesktop ? 100 : 80,
                  backgroundImage: CachedNetworkImageProvider(candidate.photoUrl),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                candidate.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                candidate.party,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoSection('Biography', candidate.bio),
            _buildInfoSection('Education', candidate.education),
            _buildInfoSection('Criminal Cases', candidate.criminalCases),
            _buildInfoSection('Past Election Results', candidate.pastResults),
            _buildInfoSection('Assets', candidate.assets),
            _buildInfoSection('Liabilities', candidate.liabilities),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 18, height: 1.5),
          ),
        ],
      ),
    );
  }
}