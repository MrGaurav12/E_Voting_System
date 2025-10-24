import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VotingScreen extends StatefulWidget {
  @override
  _VotingScreenState createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _voterIdController = TextEditingController();

  // State management
  bool _isLoading = false;
  bool _isVerifying = false;
  bool _isVoting = false;
  bool _voterVerified = false;
  bool _hasVoted = false;
  String _errorMessage = '';
  String _voterName = '';
  String _voterId = '';

  // Voting state
  Map<String, String?> _selectedCandidates = {
    'National Level': null,
    'State Level': null,
    'Local Level': null,
  };

  // Hardcoded candidates data
  final Map<String, List<Candidate>> _candidates = {
    'National Level': [
      Candidate(
        id: 'narendra_modi',
        name: 'Narendra Modi',
        party: 'BJP',
        partySymbol: 'Lotus',
        photoUrl:
            'https://images.unsplash.com/photo-1580137189272-c9379f8864fd?w=400&h=400&fit=crop',
        description: 'Prime Minister Candidate - Development & Growth Focus',
        votes: 0,
      ),
      Candidate(
        id: 'rahul_gandhi',
        name: 'Rahul Gandhi',
        party: 'Congress',
        partySymbol: 'Hand',
        photoUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        description: 'Youth Leadership - Social Justice Advocate',
        votes: 0,
      ),
      Candidate(
        id: 'arvind_kejriwal',
        name: 'Arvind Kejriwal',
        party: 'AAP',
        partySymbol: 'Broom',
        photoUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop',
        description: 'Anti-Corruption - Education & Healthcare Reforms',
        votes: 0,
      ),
      Candidate(
        id: 'mamata_banerjee',
        name: 'Mamata Banerjee',
        party: 'TMC',
        partySymbol: 'Flowers & Grass',
        photoUrl:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop',
        description: 'Women Empowerment - Regional Development',
        votes: 0,
      ),
    ],
    'State Level': [
      Candidate(
        id: 'yogi_adityanath',
        name: 'Yogi Adityanath',
        party: 'BJP',
        partySymbol: 'Lotus',
        photoUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
        description: 'Chief Minister - Law & Order Specialist',
        votes: 0,
      ),
      Candidate(
        id: 'akhilesh_yadav',
        name: 'Akhilesh Yadav',
        party: 'SP',
        partySymbol: 'Cycle',
        photoUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        description: 'Youth Development - Infrastructure Projects',
        votes: 0,
      ),
      Candidate(
        id: 'mayawati',
        name: 'Mayawati',
        party: 'BSP',
        partySymbol: 'Elephant',
        photoUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
        description: 'Social Justice - Dalit Empowerment Leader',
        votes: 0,
      ),
      Candidate(
        id: 'tejashwi_yadav',
        name: 'Tejashwi Yadav',
        party: 'RJD',
        partySymbol: 'Lantern',
        photoUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        description: 'Young Leader - Employment Generation Focus',
        votes: 0,
      ),
    ],
    'Local Level': [
      Candidate(
        id: 'local_bjp_candidate',
        name: 'Rajesh Kumar',
        party: 'BJP',
        partySymbol: 'Lotus',
        photoUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop',
        description: 'Local Development - Infrastructure & Sanitation',
        votes: 0,
      ),
      Candidate(
        id: 'local_congress_candidate',
        name: 'Priya Singh',
        party: 'Congress',
        partySymbol: 'Hand',
        photoUrl:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop',
        description: 'Women & Child Welfare - Education Reforms',
        votes: 0,
      ),
      Candidate(
        id: 'local_aap_candidate',
        name: 'Amit Sharma',
        party: 'AAP',
        partySymbol: 'Broom',
        photoUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
        description: 'Anti-Corruption - Transparent Governance',
        votes: 0,
      ),
      Candidate(
        id: 'local_independent',
        name: 'Dr. Anjali Mehta',
        party: 'Independent',
        partySymbol: 'Independent',
        photoUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
        description: 'Healthcare & Education - Community Development',
        votes: 0,
      ),
    ],
  };

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkUserVoterStatus();
  }

  @override
  void dispose() {
    _voterIdController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkUserVoterStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() {
        _isVerifying = true;
      });

      final query = await _firestore
          .collection('voters')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final voterData = query.docs.first.data();
        setState(() {
          _voterId = query.docs.first.id;
          _voterName = voterData['name'] ?? '';
          _hasVoted = voterData['hasVoted'] ?? false;
          _voterVerified = true;
        });
      }
    } catch (e) {
      print('Error checking voter status: $e');
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _verifyVoter() async {
    if (_voterIdController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your Voter ID';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      final voterId = _voterIdController.text.trim().toUpperCase();
      final doc = await _firestore.collection('voters').doc(voterId).get();

      if (doc.exists) {
        final voterData = doc.data()!;
        final isActive = voterData['isActive'] ?? false;
        final hasVoted = voterData['hasVoted'] ?? false;

        if (!isActive) {
          setState(() {
            _errorMessage = 'Your voter account is not active';
          });
        } else if (hasVoted) {
          setState(() {
            _errorMessage = 'You have already voted in this election';
            _hasVoted = true;
          });
        } else {
          setState(() {
            _voterVerified = true;
            _voterId = voterId;
            _voterName = voterData['name'] ?? '';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Voter ID not found';
        });
      }
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = 'Verification failed: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed: $e';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _selectCandidate(String level, String candidateId) {
    setState(() {
      _selectedCandidates[level] = candidateId;
    });
  }

  bool get _canSubmitVote {
    return _selectedCandidates['National Level'] != null &&
        _selectedCandidates['State Level'] != null &&
        _selectedCandidates['Local Level'] != null;
  }

  Future<void> _submitVote() async {
    if (!_canSubmitVote) {
      setState(() {
        _errorMessage = 'Please select one candidate for each election level';
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildConfirmationDialog(),
    );

    if (confirmed != true) return;

    setState(() {
      _isVoting = true;
      _errorMessage = '';
    });

    try {
      // Start a batch write for atomic operations
      final batch = _firestore.batch();

      // Update candidate votes in Firebase for each level
      for (final level in _selectedCandidates.keys) {
        final candidateId = _selectedCandidates[level];
        if (candidateId != null) {
          final candidateRef = _firestore
              .collection('Candidate')
              .doc(level)
              .collection('Candidates')
              .doc(candidateId);

          // Get the candidate data from hardcoded list
          final candidate = _candidates[level]?.firstWhere(
            (c) => c.id == candidateId,
            orElse: () => Candidate(
              id: '',
              name: 'Unknown Candidate',
              party: 'Independent',
              partySymbol: '',
              photoUrl: '',
              description: '',
              votes: 0,
            ),
          );

          // Update or create the candidate document in Firebase
          batch.set(candidateRef, {
            'name': candidate?.name,
            'party': candidate?.party,
            'partySymbol': candidate?.partySymbol,
            'photoUrl': candidate?.photoUrl,
            'description': candidate?.description,
            'votes': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
            'level': level,
          }, SetOptions(merge: true));
        }
      }

      // Mark voter as voted
      final voterRef = _firestore.collection('voters').doc(_voterId);
      batch.update(voterRef, {
        'hasVoted': true,
        'votedAt': FieldValue.serverTimestamp(),
        'votedInElection': '2024-general',
      });

      // Record vote transaction
      final voteRecordRef = _firestore.collection('votes').doc();
      batch.set(voteRecordRef, {
        'voterId': _voterId,
        'voterName': _voterName,
        'selections': _selectedCandidates,
        'timestamp': FieldValue.serverTimestamp(),
        'electionId': '2024-general',
      });

      // Commit the batch
      await batch.commit();

      // Show success screen
      _showSuccessScreen();
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = 'Vote submission failed: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Vote submission failed: $e';
      });
    } finally {
      setState(() {
        _isVoting = false;
      });
    }
  }

  Widget _buildConfirmationDialog() {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Text(
            'Confirm Your Vote',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Please review your selections:'),
          SizedBox(height: 16),
          ..._selectedCandidates.entries.map((entry) {
            final level = entry.key;
            final candidateId = entry.value;
            if (candidateId == null) return SizedBox();

            final candidate = _candidates[level]?.firstWhere(
              (c) => c.id == candidateId,
              orElse: () => Candidate(
                id: '',
                name: 'Unknown Candidate',
                party: 'Independent',
                partySymbol: '',
                photoUrl: '',
                description: '',
                votes: 0,
              ),
            );

            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(_getLevelIcon(level), color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$level Election',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${candidate?.name} (${candidate?.party})',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              'Once submitted, your vote cannot be changed. This action is final.',
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Review Again'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text('Confirm & Submit Vote'),
        ),
      ],
    );
  }

  void _showSuccessScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VoteSuccessScreen(voterName: _voterName),
      ),
    );
  }

  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'National Level':
        return Icons.flag_rounded;
      case 'State Level':
        return Icons.location_city_rounded;
      case 'Local Level':
        return Icons.home_work_rounded;
      default:
        return Icons.how_to_vote_rounded;
    }
  }

  String _getShortLevelName(String level) {
    switch (level) {
      case 'National Level':
        return 'National';
      case 'State Level':
        return 'State';
      case 'Local Level':
        return 'Local';
      default:
        return level;
    }
  }

  Color _getPartyColor(String party) {
    switch (party.toLowerCase()) {
      case 'bjp':
        return Colors.orange;
      case 'congress':
        return Colors.blue;
      case 'aap':
        return Colors.blue.shade300;
      case 'tmc':
        return Colors.green;
      case 'sp':
        return Colors.red;
      case 'bsp':
        return Colors.blue.shade900;
      case 'rjd':
        return Colors.green.shade800;
      case 'independent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildVerificationScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(seconds: 1),
              curve: Curves.elasticOut,
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.how_to_vote_rounded,
                size: 70,
                color: Color(0xFF667eea),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Secure Digital Voting',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Verify your identity to cast your vote securely',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _voterIdController,
                    decoration: InputDecoration(
                      labelText: 'Voter ID',
                      hintText: 'Enter your unique voter ID',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_errorMessage.isNotEmpty) SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _isVerifying
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF667eea),
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _verifyVoter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            child: Text(
                              'Verify & Proceed',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingScreen() {
    return Column(
      children: [
        // Voter Info Card
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade50, Colors.blue.shade50],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Colors.green, size: 32),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verified Voter',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    Text(
                      _voterName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Voter ID: $_voterId',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Ready to Vote',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Election Tabs
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue.shade700,
            unselectedLabelColor: Colors.grey.shade600,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.purple.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            tabs: [
              Tab(icon: Icon(Icons.flag_rounded), text: 'National'),
              Tab(icon: Icon(Icons.location_city_rounded), text: 'State'),
              Tab(icon: Icon(Icons.home_work_rounded), text: 'Local'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCandidateList('National Level'),
              _buildCandidateList('State Level'),
              _buildCandidateList('Local Level'),
            ],
          ),
        ),

        // Submit Button
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            children: [
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: _canSubmitVote
                      ? LinearGradient(
                          colors: [
                            Colors.green.shade600,
                            Colors.green.shade800,
                          ],
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade600],
                        ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _canSubmitVote
                      ? [
                          BoxShadow(
                            color: Colors.green.shade300.withOpacity(0.5),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: _canSubmitVote && !_isVoting ? _submitVote : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isVoting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.how_to_vote_rounded),
                            SizedBox(width: 8),
                            Text(
                              'Submit Your Vote',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please select one candidate from each election level',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCandidateList(String level) {
    final candidates = _candidates[level] ?? [];
    final selectedCandidateId = _selectedCandidates[level];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        final isSelected = candidate.id == selectedCandidateId;

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? _getPartyColor(candidate.party).withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? _getPartyColor(candidate.party)
                  : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _selectCandidate(level, candidate.id),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Candidate Photo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey.shade100,
                        image: DecorationImage(
                          image: NetworkImage(candidate.photoUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),

                    // Candidate Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _getPartyColor(candidate.party),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                candidate.party,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          if (candidate.partySymbol.isNotEmpty)
                            Text(
                              'Symbol: ${candidate.partySymbol}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          SizedBox(height: 8),
                          Text(
                            candidate.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selection Checkmark
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getPartyColor(candidate.party),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _hasVoted
            ? AlreadyVotedScreen(voterName: _voterName)
            : _voterVerified
            ? DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text('E-Voting Booth'),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade700,
                            Colors.purple.shade700,
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: _buildVotingScreen(),
                ),
              )
            : _buildVerificationScreen(),
      ),
    );
  }
}

class Candidate {
  final String id;
  final String name;
  final String party;
  final String partySymbol;
  final String photoUrl;
  final String description;
  final int votes;

  Candidate({
    required this.id,
    required this.name,
    required this.party,
    required this.partySymbol,
    required this.photoUrl,
    required this.description,
    required this.votes,
  });
}

class VoteSuccessScreen extends StatelessWidget {
  final String voterName;

  const VoteSuccessScreen({Key? key, required this.voterName})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 80,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    'Vote Submitted Successfully!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Thank you for participating in the democratic process, $voterName!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your vote has been securely recorded and will be counted in the election results.',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50),
                  SizedBox(
                    width: 200,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF667eea),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: Text(
                        'Return to Home',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AlreadyVotedScreen extends StatelessWidget {
  final String voterName;

  const AlreadyVotedScreen({Key? key, required this.voterName})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.how_to_vote_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'You Have Already Voted',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Dear $voterName,',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Our records show that you have already cast your vote in this election.',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      'To ensure election integrity, each voter can only vote once. Thank you for participating in the democratic process!',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF667eea),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: Text(
                        'Return to Home',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
