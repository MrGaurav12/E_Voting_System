import 'package:flutter/material.dart';





class ElectionResultsScreen extends StatefulWidget {
  const ElectionResultsScreen({super.key});

  @override
  State<ElectionResultsScreen> createState() => _ElectionResultsScreenState();
}

class _ElectionResultsScreenState extends State<ElectionResultsScreen> {
  final List<PartyResult> _partyResults = [];
  final List<ConstituencyResult> _constituencyResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    setState(() {
      _partyResults.clear();
      _constituencyResults.clear();
      
      _partyResults.addAll([
        PartyResult(
          name: 'Democratic Alliance',
          color: Colors.blue,
          seatsWon: 120,
          seatsLeading: 15,
          totalContested: 200,
          logo: Icons.flag,
        ),
        PartyResult(
          name: 'National Front',
          color: Colors.red,
          seatsWon: 95,
          seatsLeading: 8,
          totalContested: 200,
          logo: Icons.balance,
        ),
        PartyResult(
          name: 'Green Progressives',
          color: Colors.green,
          seatsWon: 45,
          seatsLeading: 5,
          totalContested: 150,
          logo: Icons.eco,
        ),
        PartyResult(
          name: 'United Centrists',
          color: Colors.amber,
          seatsWon: 30,
          seatsLeading: 3,
          totalContested: 100,
          logo: Icons.handshake,
        ),
      ]);
      
      _constituencyResults.addAll([
        ConstituencyResult(
          candidateName: 'Sarah Johnson',
          partyName: 'Democratic Alliance',
          partyColor: Colors.blue,
          votes: 42563,
          status: ResultStatus.won,
          partyLogo: Icons.flag,
        ),
        ConstituencyResult(
          candidateName: 'Michael Chen',
          partyName: 'National Front',
          partyColor: Colors.red,
          votes: 38742,
          status: ResultStatus.leading,
          partyLogo: Icons.balance,
        ),
        ConstituencyResult(
          candidateName: 'Emma Rodriguez',
          partyName: 'Green Progressives',
          partyColor: Colors.green,
          votes: 35421,
          status: ResultStatus.trailing,
          partyLogo: Icons.eco,
        ),
        ConstituencyResult(
          candidateName: 'David Smith',
          partyName: 'United Centrists',
          partyColor: Colors.amber,
          votes: 28765,
          status: ResultStatus.won,
          partyLogo: Icons.handshake,
        ),
        ConstituencyResult(
          candidateName: 'James Wilson',
          partyName: 'Democratic Alliance',
          partyColor: Colors.blue,
          votes: 41230,
          status: ResultStatus.leading,
          partyLogo: Icons.flag,
        ),
        ConstituencyResult(
          candidateName: 'Linda Brown',
          partyName: 'National Front',
          partyColor: Colors.red,
          votes: 39875,
          status: ResultStatus.trailing,
          partyLogo: Icons.balance,
        ),
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalSeats = _partyResults.fold(0, (sum, party) => sum + party.seatsWon + party.seatsLeading);
    final leadingParty = _partyResults.reduce((a, b) => 
      (a.seatsWon + a.seatsLeading) > (b.seatsWon + b.seatsLeading) ? a : b);
    final secondParty = _partyResults.where((p) => p != leadingParty).reduce((a, b) => 
      (a.seatsWon + a.seatsLeading) > (b.seatsWon + b.seatsLeading) ? a : b);
    final margin = (leadingParty.seatsWon + leadingParty.seatsLeading) - 
                  (secondParty.seatsWon + secondParty.seatsLeading);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Election Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Section
                    _buildSummarySection(totalSeats, leadingParty, margin),
                    const SizedBox(height: 24),
                    
                    // Party Results
                    const Text(
                      'Party Results',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildPartyResults(),
                    const SizedBox(height: 24),
                    
                    // Constituency Results
                    const Text(
                      'Constituency Results',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildConstituencyResults(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummarySection(int totalSeats, PartyResult leadingParty, int margin) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Total Seats:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(totalSeats.toString(), style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: _partyResults.map((party) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: party.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${party.name}: ${party.seatsWon + party.seatsLeading}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: leadingParty.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: leadingParty.color,
                    ),
                  ),
                  const TextSpan(text: ' is leading by '),
                  TextSpan(
                    text: '$margin seats',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyResults() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _partyResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final party = _partyResults[index];
        final percentage = (party.seatsWon + party.seatsLeading) / party.totalContested;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(party.logo, color: party.color),
                    const SizedBox(width: 12),
                    Text(
                      party.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      '${party.seatsWon + party.seatsLeading} seats',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Won: ${party.seatsWon}',
                      style: TextStyle(color: party.color),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Leading: ${party.seatsLeading}',
                      style: TextStyle(color: party.color.withOpacity(0.8)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Contested: ${party.totalContested}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey.shade200,
                  color: party.color,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(percentage * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConstituencyResults(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 1000;
    
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
    final childAspectRatio = isMobile ? 1.8 : 1.5;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _constituencyResults.length,
      itemBuilder: (context, index) {
        final result = _constituencyResults[index];
        return _buildConstituencyCard(result);
      },
    );
  }

  Widget _buildConstituencyCard(ConstituencyResult result) {
    Color statusColor;
    switch (result.status) {
      case ResultStatus.won:
        statusColor = Colors.green;
        break;
      case ResultStatus.leading:
        statusColor = Colors.blue;
        break;
      case ResultStatus.trailing:
        statusColor = Colors.orange;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(result.partyLogo, color: result.partyColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.candidateName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              result.partyName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Votes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  result.votes.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            LinearProgressIndicator(
              value: 0.65, // Placeholder for actual vote percentage
              backgroundColor: Colors.grey.shade200,
              color: result.partyColor,
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class PartyResult {
  final String name;
  final Color color;
  final int seatsWon;
  final int seatsLeading;
  final int totalContested;
  final IconData logo;

  PartyResult({
    required this.name,
    required this.color,
    required this.seatsWon,
    required this.seatsLeading,
    required this.totalContested,
    required this.logo,
  });
}

class ConstituencyResult {
  final String candidateName;
  final String partyName;
  final Color partyColor;
  final int votes;
  final ResultStatus status;
  final IconData partyLogo;

  ConstituencyResult({
    required this.candidateName,
    required this.partyName,
    required this.partyColor,
    required this.votes,
    required this.status,
    required this.partyLogo,
  });
}

enum ResultStatus { won, leading, trailing }

extension ResultStatusExtension on ResultStatus {
  String get name {
    switch (this) {
      case ResultStatus.won: return 'Won';
      case ResultStatus.leading: return 'Leading';
      case ResultStatus.trailing: return 'Trailing';
    }
  }
}