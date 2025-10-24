// vote_casting_screen.dart
import 'package:e_voting_system/services/voter_services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoteCastingScreen extends StatefulWidget {
  const VoteCastingScreen({super.key});

  @override
  State<VoteCastingScreen> createState() => _VoteCastingScreenState();
}

class _VoteCastingScreenState extends State<VoteCastingScreen> {
  final VoteService _voteService = VoteService();
  final List<PoliticalParty> _parties = [
    PoliticalParty(
      name: 'BJP',
      fullName: 'Bharatiya Janata Party',
      color: Colors.orange,
      logo: '🪷', // Lotus emoji as placeholder
    ),
    PoliticalParty(
      name: 'INC',
      fullName: 'Indian National Congress',
      color: Colors.blue,
      logo: '✋', // Hand emoji as placeholder
    ),
    PoliticalParty(
      name: 'AAP',
      fullName: 'Aam Aadmi Party',
      color: Colors.blueAccent,
      logo: '🧹', // Broom emoji as placeholder
    ),
    PoliticalParty(
      name: 'CPI',
      fullName: 'Communist Party of India',
      color: Colors.red,
      logo: '🌾', // Ears of rice emoji as placeholder
    ),
    PoliticalParty(
      name: 'BSP',
      fullName: 'Bahujan Samaj Party',
      color: Colors.blue[900]!,
      logo: '🐘', // Elephant emoji as placeholder
    ),
  ];

  bool _isLoading = true;
  bool _isVoter = false;
  bool _hasVoted = false;
  String? _votedParty;

  @override
  void initState() {
    super.initState();
    _checkVoterStatus();
  }

  Future<void> _checkVoterStatus() async {
    setState(() {
      _isLoading = true;
    });

    final isVoter = await _voteService.checkVoterCardExists();
    final hasVoted = await _voteService.hasUserVoted();

    setState(() {
      _isVoter = isVoter;
      _hasVoted = hasVoted;
      _isLoading = false;
    });

    if (!isVoter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNotRegisteredDialog();
      });
    }
  }

  void _showNotRegisteredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('Voter Registration Required'),
          ],
        ),
        content: const Text(
          'You are not registered as a voter. Please create your voter ID first.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _castVote(String partyName) async {
    if (!_isVoter || _hasVoted) return;

    setState(() {
      _isLoading = true;
    });

    final success = await _voteService.castVote(partyName);

    setState(() {
      _isLoading = false;
    });

    if (success == true) {
      setState(() {
        _hasVoted = true;
        _votedParty = partyName;
      });
      
      _showSuccessDialog(partyName);
    } else {
      _showAlreadyVotedDialog();
    }
  }

  void _showSuccessDialog(String partyName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Vote Cast Successfully!'),
          ],
        ),
        content: Text(
          'Your vote for $partyName has been cast successfully!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAlreadyVotedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 10),
            Text('Already Voted'),
          ],
        ),
        content: const Text('You have already cast your vote.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cast Your Vote'),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (!_isVoter) {
      return _buildNotRegisteredWidget();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildPartiesGrid(),
          if (_hasVoted) _buildVoteConfirmation(),
        ],
      ),
    );
  }

  Widget _buildNotRegisteredWidget() {
    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Voter Registration Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'You are not registered as a voter. Please create your voter ID first to cast your vote.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.how_to_vote, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              _hasVoted ? 'Vote Cast Successfully!' : 'Cast Your Vote',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasVoted 
                  ? 'Thank you for participating in democracy'
                  : 'Choose your preferred political party',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartiesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: _parties.length,
          itemBuilder: (context, index) => _buildPartyCard(_parties[index]),
        );
      },
    );
  }

  Widget _buildPartyCard(PoliticalParty party) {
    final isDisabled = !_isVoter || _hasVoted;
    final isVotedParty = _hasVoted && _votedParty == party.name;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isDisabled ? null : () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isVotedParty
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [party.color, party.color.withOpacity(0.7)],
                  )
                : null,
            color: isVotedParty ? null : Colors.white,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Party Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: party.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: party.color, width: 2),
                ),
                child: Center(
                  child: Text(
                    party.logo,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Party Name
              Text(
                party.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isVotedParty ? Colors.white : party.color,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Full Name
              Text(
                party.fullName,
                style: TextStyle(
                  fontSize: 12,
                  color: isVotedParty ? Colors.white70 : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              
              const Spacer(),
              
              // Vote Button
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isDisabled
                      ? null
                      : () => _castVote(party.name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVotedParty ? Colors.white : party.color,
                    foregroundColor: isVotedParty ? party.color : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isVotedParty) 
                        const Icon(Icons.check, size: 18),
                      if (isVotedParty) const SizedBox(width: 4),
                      Text(
                        isVotedParty ? 'VOTED' : 'VOTE',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoteConfirmation() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vote Cast Successfully!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'You voted for $_votedParty',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PoliticalParty {
  final String name;
  final String fullName;
  final Color color;
  final String logo;

  PoliticalParty({
    required this.name,
    required this.fullName,
    required this.color,
    required this.logo,
  });
}