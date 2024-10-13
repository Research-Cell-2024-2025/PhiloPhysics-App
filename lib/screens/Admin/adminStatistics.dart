import 'dart:collection';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'adminAppUsageStatistics.dart';

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
            totalPdfsViewed += (userData['pdfsViewed'] as num)
                .toInt(); // Cast to num and then to int
          }
          if (userData.containsKey('videosViewed')) {
            totalVideosViewed += (userData['videosViewed'] as num)
                .toInt(); // Cast to num and then to int
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
        title: const Text('Admin Statistics'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(), // Show loading indicator while data is fetched
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25.0, vertical: 20.0),
                child: GridView.count(
                  crossAxisCount: 2, // 2 boxes per row
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                  childAspectRatio:
                      1.2, // Aspect ratio to control the height/width ratio of the boxes
                  children: [
                    _buildStatBox(
                        Icons.people,
                        'Total Users',
                        userCount.toString(),
                        Colors.blue,
                        context,
                        'TotalUsersPage'),
                    _buildStatBox(
                        Icons.picture_as_pdf,
                        'PDFs Viewed',
                        totalPdfsViewed.toString(),
                        Colors.green,
                        context,
                        'PdfsViewedPage'),
                    _buildStatBox(
                        Icons.video_library,
                        'Videos Viewed',
                        totalVideosViewed.toString(),
                        Colors.orange,
                        context,
                        'VideosViewedPage'),
                    _buildStatBox(
                        Icons.school,
                        'Unique Colleges',
                        uniqueCollegesCount.toString(),
                        Colors.red,
                        context,
                        'UniqueCollegesPage'),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatBox(IconData icon, String label, String value, Color color,
      BuildContext context, String route) {
    bool isTapped = false;

    return GestureDetector(
      onTapDown: (_) => setState(() => isTapped = true), // Detect touch
      onTapUp: (_) => setState(() => isTapped = false), // Detect release
      onTapCancel: () => setState(() => isTapped = false), // Handle tap cancel
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AdminAppUsageStatistics()));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()
          ..scale(isTapped ? 0.95 : 1.0), // Scale on touch
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2), // Adding border
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: MediaQuery.of(context).size.width / 10,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value, // Display the dynamic value here
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
