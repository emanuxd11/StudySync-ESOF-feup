import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key});

  static const routeName = 'EditprofileScreen';
  static const fullPath = '/$routeName';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Set initial values for email and username
    final currentUser = FirebaseAuth.instance.currentUser;
    _emailController.text = currentUser?.email ?? '';
    _usernameController.text = currentUser?.displayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            child: const Text(
              "Back",
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            // TextFormField(
            //   controller: _passwordController,
            //   obscureText: !_isPasswordVisible,
            //   decoration: InputDecoration(
            //     labelText: 'Password',
            //     suffixIcon: IconButton(
            //       icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            //       onPressed: () {
            //         setState(() {
            //           _isPasswordVisible = !_isPasswordVisible;
            //         });
            //       },
            //     ),
            //   ),
            // ),
            const SizedBox(
              height: 20.0,
            ),
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
                  // Update email
                  if (_emailController.text.isNotEmpty) {
                    await user.updateEmail(_emailController.text);
                  }

                  // Update username
                  if (_usernameController.text.isNotEmpty) {
                    await user.updateDisplayName(_usernameController.text);
                  }

                  // Update password
                  if (_passwordController.text.isNotEmpty) {
                    await user.updatePassword(_passwordController.text);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update profile: $e'),
                    ),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
