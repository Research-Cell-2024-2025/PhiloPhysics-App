import 'dart:collection';
import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/screens/Admin/annualAdminAppUsageStatistics.dart';
import 'package:ephysicsapp/screens/Admin/monthlyAdminAppUsageStatistics.dart';
import 'package:ephysicsapp/screens/Admin/weeklyAdminAppUsageStatistics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';

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
  bool isLoading = true; // To manage loading state
  int _currentSelection = 0; // Default to 0 for StudentLogRegister

  Map<int, Widget> _children = {
    0: Text('Annual'),
    1: Text('Monthly'),
    2: Text('Weekly'),
  };

  // Widget to display the current form
  Widget _currentWidget = AnnualAdminAppUsageStatistics();

  // Function to switch between the graphs
  void _switchPage(int index) {
    setState(() {
      _currentSelection = index;
      if (index == 0) {
        _currentWidget = AnnualAdminAppUsageStatistics();
      } else if (index == 1) {
        _currentWidget = MonthlyAdminAppUsageStatistics();
      } else if (index == 2) {
        _currentWidget = WeeklyAdminAppUsageStatistics();
      }
    });
  }

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
          isLoading = false; // Data fetched, stop loading
        });
      } else {
        setState(() {
          isLoading = false; // No data found, stop loading
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // Stop loading in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Statistics"),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 40,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: MaterialSegmentedControl(
                      children: _children,
                      selectionIndex: _currentSelection,
                      borderColor: Colors.black,
                      selectedColor: color5,
                      unselectedColor: Colors.white,
                      selectedTextStyle: TextStyle(
                          color: color1,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      unselectedTextStyle: TextStyle(
                          color: color5,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      borderWidth: 2,
                      borderRadius: 32.0,
                      onSegmentTapped: (index) {
                        _switchPage(
                            index as int); // Call the function to switch form
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 40,
                  ),
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.5,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: _currentWidget,
                  ),
                ],
              ),
            ),
    );
  }
}
