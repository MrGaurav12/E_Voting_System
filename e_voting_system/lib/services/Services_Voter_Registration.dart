import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save voter data to Firestore
  static Future<void> saveVoterData(Map<String, dynamic> voterData) async {
    try {
      // Get current user
      User? user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated. Please login first.');
      }

      // Add user UID and timestamp to voter data
      voterData['userId'] = user.uid;
      voterData['createdAt'] = FieldValue.serverTimestamp();
      voterData['updatedAt'] = FieldValue.serverTimestamp();
      voterData['status'] = 'pending'; // pending, approved, rejected

      // Save to Firestore in 'voter_registrations' collection
      await _firestore
          .collection('voter_registrations')
          .doc(user.uid)
          .set(voterData, SetOptions(merge: true));

      // Also save a copy in 'users' collection for easy access
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
            'voterData': voterData,
            'hasVoterRegistration': true,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

    } catch (e) {
      throw Exception('Failed to save voter data: $e');
    }
  }

  // Check if user already has voter registration
  static Future<bool> hasExistingRegistration() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      DocumentSnapshot doc = await _firestore
          .collection('voter_registrations')
          .doc(user.uid)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get voter data for current user
  static Future<Map<String, dynamic>?> getVoterData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('voter_registrations')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update voter data
  static Future<void> updateVoterData(Map<String, dynamic> updates) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('voter_registrations')
          .doc(user.uid)
          .update(updates);

    } catch (e) {
      throw Exception('Failed to update voter data: $e');
    }
  }

  // Delete voter registration
  static Future<void> deleteVoterRegistration() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('voter_registrations')
          .doc(user.uid)
          .delete();

      // Update user document
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
            'hasVoterRegistration': false,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

    } catch (e) {
      throw Exception('Failed to delete voter registration: $e');
    }
  }

  // Get all voter registrations (admin function)
  static Stream<QuerySnapshot> getAllVoterRegistrations() {
    return _firestore
        .collection('voter_registrations')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update registration status (admin function)
  static Future<void> updateRegistrationStatus(
      String userId, String status, String? remarks) async {
    try {
      Map<String, dynamic> updates = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (remarks != null) {
        updates['adminRemarks'] = remarks;
      }

      await _firestore
          .collection('voter_registrations')
          .doc(userId)
          .update(updates);

    } catch (e) {
      throw Exception('Failed to update registration status: $e');
    }
  }
}