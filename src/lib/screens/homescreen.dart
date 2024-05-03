// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:digital_invitation_card/Components/editprofile_screen.dart';
// import 'package:digital_invitation_card/Components/imageslider.dart';
// import 'package:digital_invitation_card/Components/create_event.dart';
// import 'package:digital_invitation_card/Components/notification.dart';
// import 'package:digital_invitation_card/Components/setting_screen.dart';
// import 'package:digital_invitation_card/screens/login_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:digital_invitation_card/Components/invitations_list_screen.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class HomepageScreen extends StatefulWidget {
//   const HomepageScreen({super.key});

//   @override
//   State<HomepageScreen> createState() => _HomepageScreenState();
// }

// class _HomepageScreenState extends State<HomepageScreen> {
//   User? user;
//   DocumentSnapshot? userDetails;

//   Future getUser() async {
//     setState(() {
//       user = FirebaseAuth.instance.currentUser;
//     });
//     print("current user $user");
//     CollectionReference userCollection =
//         FirebaseFirestore.instance.collection("User");
//     DocumentSnapshot document = await userCollection.doc(user?.uid).get();
//     if (document.exists) {
//       setState(() {
//         userDetails = document;
//       });
//       debugPrint(userDetails?.get("name"));
//       // store user data in storage .... Use FlutterSecureStorage
//       final storage = new FlutterSecureStorage();
//       await storage.write(key: "username", value: userDetails?.get("name"));

//     } else {
//       setState(() {
//         userDetails = null;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getUser();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             color: const Color(0xFFF3F3F3),
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(8, 340, 8, 0),
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 children: const <Widget>[
//                   MyButton(
//                       image: 'assets/scan.png',
//                       label: "Event",
//                       label2: "Manage Events",
//                       screenToNavigate: EventScreen()),
//                   MyButton(
//                       image: 'assets/Exclude.png',
//                       label: "Invitations",
//                       label2: "Managing Invitations",
//                       screenToNavigate: InvitationsListScreen()),
//                   MyButton(
//                       image: 'assets/ic_baseline-contact-support.png',
//                       label: "Support",
//                       label2: "Get Help & Support",
//                       screenToNavigate: NotificationScreen()),
//                   MyButton(
//                       image: 'assets/Setting.png',
//                       label: "Settings",
//                       label2: "Manage App Settings",
//                       screenToNavigate: SettingScreen()),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                   image: AssetImage('assets/homepage.png'), fit: BoxFit.cover),
//             ),
//             height: MediaQuery.of(context).size.height * .4,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(6, 42, 6, 0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                     const EditProfileScreen()),
//                           );
//                         },
//                         child: const CircleAvatar(
//                           backgroundImage: AssetImage('assets/profile.jpg'),
//                           radius: 20,
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 10.0,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             userDetails?.get("name") ?? "",
//                             style: const TextStyle(
//                                 color: Color(0xFFFCB549),
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             user?.phoneNumber ?? "",
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),


//                   IconButton(
//                     color: Colors.white,
//                     icon: const Icon(Icons.notifications),
//                     onPressed: () async {

//                     },
//                   ),

//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(28, 190, 28, 0),
//             child: Container(
//               width: 380,
//               height: 170,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4), color: Colors.white),
              
//               //   child: Container(
//               //       // padding: EdgeInsets.only(top: 2),
//               //       child: Image.asset(
//               //     "assets/home1.jpg",
//               //     fit: BoxFit.cover,
//               //   )),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MyButton extends StatelessWidget {
//   final String image;
//   final String label;
//   final String label2;
//   final Widget screenToNavigate;

//   const MyButton({
//     super.key,
//     required this.image,
//     required this.label,
//     required this.label2,
//     required this.screenToNavigate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white, borderRadius: BorderRadius.circular(5)),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => screenToNavigate),
//           );
//         },
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(6),
//                 color: const Color(0xFFF1F1F1),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(15.0),
//                 child: Image.asset(
//                   image,
//                   width: 30.0,
//                   height: 30.0,
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 6.0,
//             ),
//             Text(
//               label,
//               style: const TextStyle(
//                   fontSize: 16.0,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF25252D)),
//             ),
//             const SizedBox(
//               height: 6.0,
//             ),
//             Text(
//               label2,
//               style: const TextStyle(
//                   fontSize: 11.0,
//                   fontWeight: FontWeight.normal,
//                   color: Color(0xFF616076)),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
