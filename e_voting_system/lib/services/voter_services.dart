// vote_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if user has a voter card
  Future<bool> checkVoterCardExists() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('voterCards')
          .doc(user.uid)
          .get();
      
      return doc.exists;
    } catch (e) {
      print('Error checking voter card: $e');
      return false;
    }
  }

  // Check if user has already voted - FIXED VERSION
  Future<bool> hasUserVoted() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final query = await _firestore
          .collection('votes')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking vote: $e');
      return false;
    }
  }

  // Get user's voted party
  Future<String?> getUserVotedParty() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final query = await _firestore
          .collection('votes')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs.first['partyName'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting voted party: $e');
      return null;
    }
  }

  // Cast vote for a party - FIXED VERSION
  Future<Map<String, dynamic>> castVote(String partyName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Check if already voted
      final hasVoted = await hasUserVoted();
      if (hasVoted) {
        return {'success': false, 'message': 'already_voted'};
      }

      // Save vote with user ID as document ID for uniqueness
      await _firestore.collection('votes').doc(user.uid).set({
        'userId': user.uid,
        'partyName': partyName,
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': user.email ?? 'Unknown',
      });

      return {'success': true, 'message': 'Vote cast successfully'};
    } catch (e) {
      print('Error casting vote: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}