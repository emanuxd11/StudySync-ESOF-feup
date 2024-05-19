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
          _imageUrl = userDoc.data()!['profileImageUrl'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Back',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Text(
                    'Edit',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Upper Container
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            color: Colors.green,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profilePic(),
                  const SizedBox(height: 8),
                  Text(
                    user?.displayName ?? 'No Username',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? 'No Email',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding:const  EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.black54),
                      SizedBox(width: 5.0),
                      Expanded(
                        child: Text(
                          "About Us",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                 const  SizedBox(height: 20.0,),
                 const  Row(
                    children: [
                      Icon(Icons.feedback, color: Colors.black54),
                         SizedBox(width: 5.0),
                      Expanded(
                        child: Text(
                          "Feedback & Rating",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0,),                  GestureDetector(
                    onTap: () {
                     _logout(context);
                    },
                    child:const  Row(
                      children: [
                        Icon(Icons.logout, color: Colors.black54),
                           SizedBox(width: 5.0),
                      Expanded(
                          child: Text(
                            "Logout",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget profilePic() {
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
                  builder: (context) => bottomSheet(),
                );
              },
              icon: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: <Widget>[
          const Text(
            "Choose Profile photo",
            style: TextStyle(fontSize: 20.0),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                icon: const Icon(Icons.camera),
                onPressed: () {
                  takePhoto(ImageSource.camera);
                },
                label: const Text("Camera"),
              ),
              TextButton.icon(
                icon: const Icon(Icons.image),
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                },
                label: const Text("Gallery"),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> takePhoto(ImageSource source) async {
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
      final fileExtension = file.path.split('.').last; // Extract the file extension
      final ref = _storage.ref().child('userImages').child('${user.uid}.$fileExtension'); // Use the file extension
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
}

 void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushNamed('/login');
      // You can use your preferred navigation method, like GoRouter
      print('Signed out successfully!');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

