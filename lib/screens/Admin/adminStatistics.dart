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
        title: const Text('Admin Statistics'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 20.0,
            childAspectRatio: 1.125,
            children: [
              _buildStatBox(
                  Icons.people,
                  'Total Users',
                  userCount.toString(),
                  const Color(0xFF4A90E2), // Blue Gradient
                  context,
                  AdminAppUsageStatistics()),
              _buildStatBox(
                  Icons.picture_as_pdf,
                  'PDFs Viewed',
                  totalPdfsViewed.toString(),
                  const Color(0xFF50E3C2), // Green Gradient
                  context,
                  null),
              _buildStatBox(
                  Icons.video_library,
                  'Videos Viewed',
                  totalVideosViewed.toString(),
                  const Color(0xFFF5A623), // Orange Gradient
                  context,
                  null),
              _buildStatBox(
                  Icons.school,
                  'Unique Colleges',
                  uniqueCollegesCount.toString(),
                  const Color(0xFFD0021B), // Red Gradient
                  context,
                  null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String label, String value, Color color,
      BuildContext context, Widget? pageToNavigate) {
    bool isTapped = false;

    return GestureDetector(
      onTapDown: (_) => setState(() => isTapped = true),
      onTapUp: (_) => setState(() => isTapped = false),
      onTapCancel: () => setState(() => isTapped = false),
      onTap: () {
        if (pageToNavigate != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pageToNavigate),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(isTapped ? 0.98 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: MediaQuery.of(context).size.width / 8,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
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
