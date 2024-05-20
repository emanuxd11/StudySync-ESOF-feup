import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_sync/screens/editprofile.dart';
import 'package:study_sync/screens/about.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = 'profile';
  static const fullPath = '/$routeName';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? _imageUrl;
  String? _username;
  String? _age;
  String? _bio;
  String? _fieldOfStudy;
  String? _university;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _imageUrl = userDoc.data()?['profileImageUrl'];
          _username = userDoc.data()?['username'];
          _bio = userDoc.data()?['bio']; // Assuming 'bio' is the field name in Firestore
          _age = userDoc.data()?['age']; // Assuming 'age' is the field name in Firestore
          _university = userDoc.data()?['university']; // Assuming 'university' is the field name in Firestore
          _fieldOfStudy = userDoc.data()?['fieldOfStudy']; // Assuming 'fieldOfStudy' is the field name in Firestore
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProfileHeader(context, user),
          _buildProfileInfo(context, user),
          _buildProfileOptions(context),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, User? user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileDetail(
            title: 'Bio',
            value: _bio ?? 'No Bio',
          ),
          _buildProfileDetail(
            title: 'Age',
            value: _age != null ? _age.toString() : 'No Age',
          ),
          _buildProfileDetail(
            title: 'University',
            value: _university ?? 'No University',
          ),
          _buildProfileDetail(
            title: 'Field of Study',
            value: _fieldOfStudy ?? 'No Field of Study',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetail({required String title, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black87,
            ),
          ),
          Divider(color: Colors.grey),
        ],
      ),
    );
  }


  Widget _buildProfileHeader(BuildContext context, User? user) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.teal],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProfilePic(),
            const SizedBox(height: 8),
            Text(
              _username ?? 'No Username',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              user?.email ?? 'No Email',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Colors.grey),
            _buildProfileOption(
              icon: Icons.feedback,
              text: 'Feedback & Rating',
              onTap: () {
                // Handle Feedback & Rating
              },
            ),
            const Divider(color: Colors.grey),
            _buildProfileOption(
              icon: Icons.logout,
              text: 'Logout',
              onTap: () => _logout(context),
            ),
            const Divider(color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildProfilePic() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _imageFile != null
                ? FileImage(File(_imageFile!.path))
                : (_imageUrl != null
                ? NetworkImage(_imageUrl!) as ImageProvider
                : const AssetImage("assets/images/logo.png")),
          ),
          Positioned(
            bottom: -15.0,
            right: 10.0,
            child: IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildBottomSheet(),
                );
              },
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: <Widget>[
          const Text(
            "Choose Profile photo",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                icon: const Icon(Icons.camera, color: Colors.green),
                onPressed: () {
                  _takePhoto(ImageSource.camera);
                },
                label: const Text("Camera", style: TextStyle(color: Colors.green)),
              ),
              TextButton.icon(
                icon: const Icon(Icons.image, color: Colors.green),
                onPressed: () {
                  _takePhoto(ImageSource.gallery);
                },
                label: const Text("Gallery", style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      await _uploadFile(pickedFile);
    }
  }

  Future<void> _uploadFile(XFile file) async {
    final user = _auth.currentUser;
    if (user != null) {
      final fileExtension = file.path.split('.').last;
      final ref = _storage.ref().child('userImages').child('${user.uid}.$fileExtension');
      await ref.putFile(File(file.path));
      final url = await ref.getDownloadURL();
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': url,
      });
      setState(() {
        _imageUrl = url;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushNamed('/login');
      print('Signed out successfully!');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
