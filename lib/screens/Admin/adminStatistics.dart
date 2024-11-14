// import 'dart:collection';
// import 'package:ephysicsapp/globals/colors.dart';
// import 'package:ephysicsapp/screens/Admin/annualAdminAppUsageStatistics.dart';
// import 'package:ephysicsapp/screens/Admin/monthlyAdminAppUsageStatistics.dart';
// import 'package:ephysicsapp/screens/Admin/weeklyAdminAppUsageStatistics.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:material_segmented_control/material_segmented_control.dart';

// class AdminStatistics extends StatefulWidget {
//   const AdminStatistics({super.key});

//   @override
//   _AdminStatisticsState createState() => _AdminStatisticsState();
// }

// class _AdminStatisticsState extends State<AdminStatistics> {
//   int userCount = 0;
//   int totalPdfsViewed = 0;
//   int totalVideosViewed = 0;
//   int uniqueCollegesCount = 0;
//   bool isLoading = true; // To manage loading state
//   int _currentSelection = 0; // Default to 0 for StudentLogRegister

//   Map<int, Widget> _children = {
//     0: Text('Annual'),
//     1: Text('Monthly'),
//     2: Text('Weekly'),
//   };

//   // Widget to display the current form
//   Widget _currentWidget = AnnualAdminAppUsageStatistics();

//   // Function to switch between the graphs
//   void _switchPage(int index) {
//     setState(() {
//       _currentSelection = index;
//       if (index == 0) {
//         _currentWidget = AnnualAdminAppUsageStatistics();
//       } else if (index == 1) {
//         _currentWidget = MonthlyAdminAppUsageStatistics();
//       } else if (index == 2) {
//         _currentWidget = WeeklyAdminAppUsageStatistics();
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     getUserStatsAndCount();
//   }

//   Future<void> getUserStatsAndCount() async {
//     DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Users');

//     try {
//       DataSnapshot snapshot =
//           await dbRef.once().then((event) => event.snapshot);

//       if (snapshot.exists) {
//         Set<String> uniqueColleges = HashSet<String>();

//         snapshot.children.forEach((userSnapshot) {
//           Map<dynamic, dynamic> userData =
//               userSnapshot.value as Map<dynamic, dynamic>;

//           if (userData.containsKey('pdfsViewed')) {
//             totalPdfsViewed += (userData['pdfsViewed'] as num).toInt();
//           }
//           if (userData.containsKey('videosViewed')) {
//             totalVideosViewed += (userData['videosViewed'] as num).toInt();
//           }

//           if (userData.containsKey('college')) {
//             uniqueColleges.add(userData['college']);
//           }
//         });

//         setState(() {
//           userCount = snapshot.children.length;
//           uniqueCollegesCount = uniqueColleges.length;
//           isLoading = false; // Data fetched, stop loading
//         });
//       } else {
//         setState(() {
//           isLoading = false; // No data found, stop loading
//         });
//       }
//     } catch (e) {
//       print('Error: $e');
//       setState(() {
//         isLoading = false; // Stop loading in case of error
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Admin Statistics"),
//         centerTitle: true,
//       ),
//       body: isLoading
//           ? Center(
//               child: CircularProgressIndicator(),
//             )
//           : SingleChildScrollView(
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height / 40,
//                   ),
//                   Container(
//                     width: MediaQuery.of(context).size.width,
//                     child: MaterialSegmentedControl(
//                       children: _children,
//                       selectionIndex: _currentSelection,
//                       borderColor: Colors.black,
//                       selectedColor: color5,
//                       unselectedColor: Colors.white,
//                       selectedTextStyle: TextStyle(
//                           color: color1,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16),
//                       unselectedTextStyle: TextStyle(
//                           color: color5,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16),
//                       borderWidth: 2,
//                       borderRadius: 32.0,
//                       onSegmentTapped: (index) {
//                         _switchPage(
//                             index as int); // Call the function to switch form
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height / 40,
//                   ),
//                   Container(
//                     width: double.infinity,
//                     constraints: BoxConstraints(
//                       minHeight: MediaQuery.of(context).size.height * 0.5,
//                       maxHeight: MediaQuery.of(context).size.height * 0.8,
//                     ),
//                     child: _currentWidget,
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

import 'dart:collection';
import 'package:ephysicsapp/screens/Admin/adminUserUsageStatistics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminStatistics extends StatefulWidget {
  const AdminStatistics({super.key});

  @override
  _AdminStatisticsState createState() => _AdminStatisticsState();
}

class _AdminStatisticsState extends State<AdminStatistics> {
  int userCount = 0;
  int totalPdfsViewed = 0;
  int totalVideosViewed = 0;
  int uniqueCollegesCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserStatsAndCount();
  }

  Future<void> getUserStatsAndCount() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Users');

    try {
      DataSnapshot snapshot =
          await dbRef.once().then((event) => event.snapshot);

      if (snapshot.exists) {
        Set<String> uniqueColleges = HashSet<String>();

        snapshot.children.forEach((userSnapshot) {
          Map<dynamic, dynamic> userData =
              userSnapshot.value as Map<dynamic, dynamic>;

          if (userData.containsKey('pdfsViewed')) {
            totalPdfsViewed += (userData['pdfsViewed'] as num).toInt();
          }
          if (userData.containsKey('videosViewed')) {
            totalVideosViewed += (userData['videosViewed'] as num).toInt();
          }

          if (userData.containsKey('college')) {
            uniqueColleges.add(userData['college']);
          }
        });

        setState(() {
          userCount = snapshot.children.length;
          uniqueCollegesCount = uniqueColleges.length;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Statistics'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
                childAspectRatio: 1.1,
                children: [
                  _buildStatBox(
                      Icons.people,
                      'Total Users',
                      userCount.toString(),
                      Colors.blue,
                      context,
                      AdminUserAppUsageStats()),
                  _buildStatBox(Icons.picture_as_pdf, 'PDFs Viewed',
                      totalPdfsViewed.toString(), Colors.green, context, null),
                  _buildStatBox(
                      Icons.video_library,
                      'Videos Viewed',
                      totalVideosViewed.toString(),
                      Colors.orange,
                      context,
                      null),
                  _buildStatBox(
                      Icons.school,
                      'Total Colleges',
                      uniqueCollegesCount.toString(),
                      Colors.red,
                      context,
                      null),
                ],
              ),
            ),
    );
  }

  Widget _buildStatBox(
    IconData icon,
    String label,
    String value,
    Color color,
    BuildContext context,
    Widget? pageToNavigate,
  ) {
    return GestureDetector(
      onTap: () {
        if (pageToNavigate != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pageToNavigate),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: MediaQuery.of(context).size.width / 14,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
