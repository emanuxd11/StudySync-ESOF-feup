import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_sync/screens/profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key});

  static const routeName = 'EditprofileScreen';
  static const fullPath = '/$routeName';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _fieldOfStudyController = TextEditingController();

  Map<String, dynamic> _updateData = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        setState(() {
          _usernameController.text = userDoc.data()?['username'] ?? '';
          _bioController.text = userDoc.data()?['bio'] ?? '';
          _ageController.text = userDoc.data()?['age'] ?? '';
          _universityController.text = userDoc.data()?['university'] ?? '';
          _fieldOfStudyController.text = userDoc.data()?['fieldOfStudy'] ?? '';
        });
      }
    }
  }

  Future<bool> _isUsernameTaken(String username) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // If there is no current user, return false
      return false;
    }

    final querySnapshot = await FirebaseFirestore.instance.collection('users')
        .where('username', isEqualTo: username)
        .get();

    // Exclude the current user's document ID from the query results
    final currentUserDocId = currentUser.uid;
    final takenUsernames = querySnapshot.docs
        .map((doc) => doc.id) // Get the document ID of each user
        .where((docId) => docId != currentUserDocId) // Exclude the current user's ID
        .toList();

    return takenUsernames.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(
              controller: _usernameController,
              labelText: 'Username',
              icon: Icons.person,
              hintText: 'Enter your username',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _bioController,
              labelText: 'Bio',
              maxLines: 3,
              icon: Icons.info,
              hintText: 'Enter your bio',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _ageController,
              labelText: 'Age',
              keyboardType: TextInputType.number,
              icon: Icons.cake,
              hintText: 'Enter your age',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _universityController,
              labelText: 'University',
              icon: Icons.school,
              hintText: 'Enter your university',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _fieldOfStudyController,
              labelText: 'Field of Study',
              icon: Icons.book,
              hintText: 'Enter your field of study',
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;

                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update profile: User not found'),
                    ),
                  );
                  return;
                }

                try {
                  // Check if username is taken
                  final newUsername = _usernameController.text;
                  if (newUsername.isNotEmpty && newUsername != user.displayName) {
                    final isTaken = await _isUsernameTaken(newUsername);
                    if (isTaken) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Username is already taken'),
                        ),
                      );
                      return;
                    }
                    _updateData['username'] = newUsername;
                  }

                  // Update Firestore
                  if (_updateData.isNotEmpty) {
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).update(_updateData);
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
                        {'bio': _bioController.text, 'age': _ageController.text, 'university': _universityController.text, 'fieldOfStudy': _fieldOfStudyController.text});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No changes were made'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update profile: $e'),
                    ),
                  );
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required IconData icon,
    required String hintText,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: (value) {
        if (value != controller.text) {
          _updateData[labelText.toLowerCase()] = value;
        } else {
          _updateData.remove(labelText.toLowerCase());
        }
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.green),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        hintText: hintText,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}
