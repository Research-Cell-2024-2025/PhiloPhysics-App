import 'dart:collection';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ephysicsapp/screens/Admin/adminUserUsageStatistics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  int pdfViewersCount = 0;
  double totalPdfUsageTime = 0;
  bool isLoading = true;
  int totalUserofApp = 0;
  int hour = 0;
  int mins = 0;

  @override
  void initState() {
    super.initState();
    getUserStatsAndCount();
  }

  Future<void> getUserStatsAndCount() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Users');

    try {
      // Get the data snapshot from Firebase
      DataSnapshot snapshot = await dbRef
          .get(); // Use .get() instead of .once()

      // Log the snapshot to verify data structure
      print('Snapshot data: ${snapshot.value}'); // Log the entire snapshot

      totalUserofApp = snapshot.children.length;
      print("Total USers of App : ${totalUserofApp}");

      if (snapshot.exists) {
        Set<String> uniqueColleges = HashSet<String>();

        int pdfsViewedTemp = 0;
        int videosViewedTemp = 0;
        int pdfViewersTemp = 0;
        double pdfUsageTimeTempInMinutes = 0; // Time in minutes

        // Fetch data in parallel for efficiency
        for (var userSnapshot in snapshot.children) {
          // Type-safe access to user data
          Map<dynamic, dynamic> userData = userSnapshot.value as Map<
              dynamic,
              dynamic>;

          if (userData.containsKey('pdfsViewed')) {
            pdfsViewedTemp += (userData['pdfsViewed'] as num).toInt();
            pdfViewersTemp++;
          }
          if (userData.containsKey('videosViewed')) {
            videosViewedTemp += (userData['videosViewed'] as num).toInt();
          }

          if (userData.containsKey('PdfUsage')) {
            Map<dynamic, dynamic> pdfUsage = userData['PdfUsage'];

            // Debug log to check the pdfUsage structure
            print('pdfUsage for ${userSnapshot
                .key}: $pdfUsage'); // Log the pdfUsage structure

            pdfUsage.forEach((monYear, dateMap) {
              // Log the month-year and its corresponding date map
              print('Mon-Year: $monYear, DateMap: $dateMap'); // Debug log

              dateMap.forEach((date, timeSpent) {
                // Log each date and the time spent on that date
                print('Date: $date, TimeSpent: $timeSpent'); // Debug log

                // Check if the timeSpent is a valid string before proceeding
                if (timeSpent is String) {
                  print('Valid timeSpent string: $timeSpent');
                  double timeInMinutes = convertTimeToMinutes(timeSpent);
                  print(
                      'Converted Time (minutes): $timeInMinutes'); // Log converted time
                  pdfUsageTimeTempInMinutes += timeInMinutes;
                } else {
                  print('Invalid time format for date: $date');
                }
              });
            });
          }

          if (userData.containsKey('college')) {
            uniqueColleges.add(userData['college']);
          }
        }

        setState(() {
          userCount = snapshot.children.length;
          totalPdfsViewed = pdfsViewedTemp;
          totalVideosViewed = videosViewedTemp;
          pdfViewersCount = pdfViewersTemp;
          totalPdfUsageTime =
              pdfUsageTimeTempInMinutes; // Time is in minutes now
          uniqueCollegesCount = uniqueColleges.length;
          isLoading = false;

          hours(pdfUsageTimeTempInMinutes);
          minutes(pdfUsageTimeTempInMinutes);
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

// Helper function to convert "HH:mm:ss" to total minutes
  double convertTimeToMinutes(String timeString) {
    List<String> parts = timeString.split(":");
    if (parts.length == 3) {
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      int seconds = int.parse(parts[2]);

      // Convert time to minutes
      return (hours * 60 + minutes + seconds / 60.0);
    }
    return 0.0; // Return 0.0 if the format is incorrect
  }


  void hours(double totalMinutes) {
    hour = totalMinutes ~/ 60; // Get the integer part for hours
  }

  void minutes(double totalMinutes) {
    mins = totalMinutes.toInt() % 60; // Get the remainder for minutes
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Statistics',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                  childAspectRatio: 1.1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatBox(Icons.people, 'Total Users',
                        userCount.toString(), Colors.blue, context,
                        AdminUserAppUsageStats()),
                    _buildStatBox(Icons.picture_as_pdf, 'PDFs Viewed',
                        totalPdfsViewed.toString(), Colors.green, context, null),
                    _buildStatBox(Icons.video_library, 'Videos Viewed',
                        totalVideosViewed.toString(), Colors.orange, context,
                        null),
                    _buildStatBox(Icons.school, 'Total Colleges',
                        uniqueCollegesCount.toString(), Colors.red, context,
                        null),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 30),
                _buildUsageStatsBox(
                    context, pdfViewersCount, totalUserofApp, hour, mins),
              ],
            ),
                    ),
                  ),
          ),
    );
  }

  Widget _buildStatBox(IconData icon,
      String label,
      String value,
      Color color,
      BuildContext context,
      Widget? pageToNavigate,) {
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
              radius: MediaQuery
                  .of(context)
                  .size
                  .width / 14,
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


  Widget _buildUsageStatsBox(BuildContext context, int pdfViewersCount,
      int totalUserofApp, int hour, int mins) {
    // Calculate the percentage of materials used
    double materialUsagePercent = totalUserofApp > 0
        ? (pdfViewersCount / totalUserofApp).clamp(0, 1).toDouble()
        : 0.0; // Avoid division by zero

    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height / 5.75,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Column for "Study", "Material", "Usage"
          SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width / 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  'Study',
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                AutoSizeText(
                  'Material',
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                AutoSizeText(
                  'Usage',
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Center: Circular Progress Indicator with Percentage
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery
                      .of(context)
                      .size
                      .height / 120),
                  child: CircularPercentIndicator(
                    radius: MediaQuery
                        .of(context)
                        .size
                        .width / 11.5,
                    // Slightly smaller radius
                    lineWidth: 9.0,
                    percent: materialUsagePercent,
                    center: AutoSizeText(
                      "${(materialUsagePercent * 100).toInt()}%",
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    progressColor: Colors.blue,
                    backgroundColor: Colors.grey.shade300,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                ),
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height / 500),
                Column(
                  children: [
                    // AutoSizeText(
                    //   'Materials Used',
                    //   maxLines: 1,
                    //   style: GoogleFonts.poppins(
                    //     fontSize: 13,
                    //     fontWeight: FontWeight.w600,
                    //     color: Colors.black87,
                    //   ),
                    // ),
                    AutoSizeText(
                      'Matrerial Used by Students',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right side: Time display aligned to the right
          SizedBox(width: 12),

          Container(
            width: MediaQuery
                .of(context)
                .size
                .width / 3.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  "${hour} Hr ${mins} Min",
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height / 120),
                AutoSizeText(
                  'Total Material Usage Time',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}