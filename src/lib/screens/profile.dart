import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// class ProfileScreen extends StatelessWidget {


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//       ),
//       body: const Center(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Text(
//             'Profile',
//             style: TextStyle(fontSize: 18.0),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:digital_invitation_card/screens/homepage.dart';
// import 'package:digital_invitation_card/widget.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const routeName = 'profile';
 static const fullPath = '/$routeName';

//   const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // final TextEditingController username = TextEditingController();
  // final TextEditingController email = TextEditingController();
  // final TextEditingController phone = TextEditingController();
  // final TextEditingController changepas = TextEditingController();

  // bool _passwordVisible = false;

  // User? user;
  // DocumentSnapshot? userDetails;

  // Future getUser() async {
  //   setState(() {
  //     user = FirebaseAuth.instance.currentUser;
  //   });
  //   CollectionReference userCollection =
  //   FirebaseFirestore.instance.collection("User");
  //   DocumentSnapshot document = await userCollection.doc(user?.uid).get();
  //   setState(() {
  //     userDetails = document;
  //     print(document.id);
  //     print(document.get('name'));
  //     username.text = userDetails?.get("name") ?? "";
  //     email.text = user?.email??"";
  //     phone.text = user?.phoneNumber?? "";
  //     // changepas.text = user.updatePassword(newPassword) ?? "";
  //   });
  // }

  @override
  // void initState() {
  //   super.initState();
  //   getUser();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget> [
            Container(
            child: ListView(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 8),
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: AssetImage("assets/profile.jpg"),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF3D4245),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 2,
                                    style: BorderStyle.solid,
                                    color: Colors.white),
                                // color: theme.colorScheme.primary,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 24,
                                  color: Colors.white,
                                  //color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      // Text(
                      //   userDetails?.get("name") ?? "",
                      //   style: const TextStyle(fontWeight: FontWeight.w600),
                      // ),
                      // Text(user?.phoneNumber ?? "",
                      //     style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 36, left: 24, right: 24),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: TextFormField(
            
            
                          cursorColor: const Color(0xFFFCB549),
                          decoration: const InputDecoration(
                            hintText: "Username",
            
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            filled: true,
                            //fillColor: customTheme.card,
                            prefixIcon: Icon(
                              Icons.account_circle_outlined,
                            ),
                            contentPadding: EdgeInsets.all(0),
                          ),
                         // controller: username,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: TextFormField(
                          cursorColor: const Color(0xFFFCB549),
                          decoration: const InputDecoration(
                            hintText: "Email Address",
            
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            filled: true,
                            //fillColor: customTheme.card,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                            ),
                            contentPadding: EdgeInsets.all(0),
                          ),
                          keyboardType: TextInputType.emailAddress,
                         // controller: email,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: TextFormField(
                          cursorColor: const Color(0xFFFCB549),
                          decoration: const InputDecoration(
                            hintText: "Phone number",
            
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            filled: true,
                            // fillColor: customTheme.card,
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                            ),
                            contentPadding: EdgeInsets.all(0),
                          ),
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.sentences,
                          //controller: phone,
                        ),
                      ),
                      // Container(
                      //   margin: const EdgeInsets.only(top: 20),
                      //   child: TextFormField(
                      //     cursorColor: const Color(0xFFFCB549),
                      //     decoration: InputDecoration(
                      //       hintText: "Change Password",
                      //
                      //       border: const OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(8.0),
                      //           ),
                      //           borderSide: BorderSide.none),
                      //       enabledBorder: const OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(8.0),
                      //           ),
                      //           borderSide: BorderSide.none),
                      //       focusedBorder: const OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(8.0),
                      //           ),
                      //           borderSide: BorderSide.none),
                      //       filled: true,
                      //       // fillColor: customTheme.card,
                      //       prefixIcon: const Icon(
                      //         Icons.lock_outline_rounded,
                      //       ),
                      //       suffixIcon: IconButton(
                      //         icon: Icon(_passwordVisible
                      //             ? Icons.remove_red_eye_outlined
                      //             : Icons.remove_red_eye_rounded),
                      //         onPressed: () {
                      //           setState(() {
                      //             _passwordVisible = !_passwordVisible;
                      //           });
                      //         },
                      //       ),
                      //       contentPadding: const EdgeInsets.all(0),
                      //     ),
                      //     controller: changepas,
                      //     textCapitalization: TextCapitalization.sentences,
                      //     obscureText: _passwordVisible,
                      //   ),
                      // ),
                      Container(
                        margin: const EdgeInsets.only(top: 24),
                        child: ElevatedButton(
                          onPressed: () {
                            
                          },
            
                            // onPressed: () async {
                            //   loadingdialog();
                            //  user?.updateEmail(email.text.toString()).then((value) {
            
                            //  });
            
            
            
            
                            //  await FirebaseFirestore.instance.collection("User").doc(user?.uid).set(
                            //      {"name" : username.text.toString()}).then((value) {
                            //        Get.back();
            
                            //  });
            
            
                            //  // if (changepas.text.length<7) {
                            //  //   print("less length");
                            //  //   user?.updatePassword(changepas.text.toString());
                            //  // } else{
                            //  //   print("changed");
                            //  // }
                             
                            //  Get.offAll(()=>HomepageScreen());
                            
                           
                            // },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3D4245),
                            ),
                            child: const Text(
                              "Update",
                              style: TextStyle(fontSize: 14),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
           
            )
            ),
        //     Container(
        //       appBar: AppBar(
        //   backgroundColor: const Color(0xFF3D4245),
        //   leading: InkWell(
        //     onTap: () => Navigator.of(context).pop(),
        //     child: const Icon(
        //       Icons.chevron_left,
        //       size: 20,
        //     ),
        //   ),
        //   elevation: 0,
        //   actions: [
        //     IconButton(
        //       color: Colors.white,
        //       icon: const Icon(Icons.logout_outlined),
        //       onPressed: () async {
        //         // Navigator.push(
        //         //   context,
        //         //   MaterialPageRoute(
        //         //       builder: (context) => const NotificationScreen()),
        //         // )
        //         // await FirebaseAuth.instance.signOut();
        //         // Get.offAll(()=>LoginScreen());
        //       //   Navigator.push(
        //       //     context,
        //       //     MaterialPageRoute(
        //       //         builder: (context) => const LoginScreen()),
        //       //   )
        //       },
        //     ),
        //   ],
        // ),

        //     )
          ]
          ),
        );
  }
}
