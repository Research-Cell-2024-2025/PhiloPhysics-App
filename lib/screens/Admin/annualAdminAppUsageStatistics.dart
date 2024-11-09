import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:math' as math;

const List<String> months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

class AnnualAdminAppUsageStatistics extends StatefulWidget {
  const AnnualAdminAppUsageStatistics({Key? key}) : super(key: key);

  @override
  _AdminStatisticsState createState() => _AdminStatisticsState();
}

class _AdminStatisticsState extends State<AnnualAdminAppUsageStatistics> {
  Map<String, Map<String, int>> yearlyUsage = {};
  bool isLoading = true;
  List<String> availableYears = [];
  int currentYearIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    getAppUsageData();
  }

  Future<void> getAppUsageData() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Users');

    try {
      DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists && snapshot.value is Map) {
        // Attempt to cast the snapshot value to Map<String, dynamic>
        Map<String, dynamic> usersData;
        try {
          usersData = Map<String, dynamic>.from(snapshot.value as Map);
        } catch (e) {
          // Fallback to JSON encoding/decoding if casting fails
          print('Casting failed, using JSON workaround: $e');
          final jsonString = jsonEncode(snapshot.value);
          usersData = Map<String, dynamic>.from(jsonDecode(jsonString));
        }

        for (var userEntry in usersData.entries) {
          String userId = userEntry.key;
          Map<String, dynamic> userData =
              Map<String, dynamic>.from(userEntry.value as Map);

          if (userData.containsKey('AppUsage')) {
            Map<String, dynamic> appUsage =
                Map<String, dynamic>.from(userData['AppUsage'] as Map);

            // Debugging: Print the app usage data
            print('App usage data for user $userId: $appUsage');

            appUsage.forEach((key, value) {
              List<String> parts = key.split(' ');
              String month = parts[0];
              String year = parts[1];
              int monthIndex = months.indexOf(month);

              if (monthIndex != -1) {
                if (value is String) {
                  // Case 1: Direct time string
                  int totalSeconds = convertTimeToSeconds(value);
                  yearlyUsage[year] ??= {};
                  yearlyUsage[year]![months[monthIndex]] =
                      (yearlyUsage[year]![months[monthIndex]] ?? 0) +
                          totalSeconds;
                } else if (value is Map<Object?, Object?>) {
                  // Case 2: Map of date-time entries
                  value.forEach((dateKey, timeStr) {
                    // Debugging: Print each dateKey and timeStr
                    print(
                        'Processing dateKey: $dateKey with timeStr: $timeStr');

                    try {
                      // Validate dateKey format after casting to String
                      String dateKeyStr = dateKey as String; // Cast to String
                      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(dateKeyStr)) {
                        // Explicitly cast timeStr to String
                        if (timeStr is String) {
                          // Check if timeStr is indeed a String
                          int totalSeconds = convertTimeToSeconds(
                              timeStr); // Now this should work
                          yearlyUsage[year] ??= {};
                          yearlyUsage[year]![months[monthIndex]] =
                              (yearlyUsage[year]![months[monthIndex]] ?? 0) +
                                  totalSeconds;
                        } else {
                          print(
                              'Expected timeStr to be a String but got: ${timeStr.runtimeType}');
                        }
                      } else {
                        print('Invalid date format for $dateKeyStr');
                      }
                    } catch (e) {
                      print('Error parsing time for $dateKey: $e');
                    }
                  });
                } else {
                  print(
                      'Unexpected format for $month $year: ${value.runtimeType} - $value');
                }
              } else {
                print('Invalid month: $month');
              }
            });
          } else {
            print('User $userId has no app usage data');
          }
        }

        setState(() {
          availableYears = yearlyUsage.keys.toList()..sort();
          isLoading = false;
        });
      } else {
        print('No users found in the database');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  int convertTimeToSeconds(dynamic time) {
    if (time is String) {
      List<String> parts = time.split(':');
      return int.parse(parts[0]) * 3600 +
          int.parse(parts[1]) * 60 +
          int.parse(parts[2]);
    } else if (time is Map<Object?, Object?>) {
      // Adjusted type check
      int totalSeconds = 0;
      time.forEach((dateKey, timeStr) {
        List<String> timeParts = timeStr.toString().split(':');
        totalSeconds += int.parse(timeParts[0]) * 3600 +
            int.parse(timeParts[1]) * 60 +
            int.parse(timeParts[2]);
      });
      return totalSeconds;
    } else {
      throw Exception('Unexpected time format: $time');
    }
  }

  double getMaxY(String year) {
    Map<String, int> monthlyUsage = yearlyUsage[year] ?? {};
    double maxUsage =
        monthlyUsage.values.fold(0, (max, value) => math.max(max, value / 60));
    return (maxUsage / 5).ceil() * 5.0;
  }

  int calculateYAxisInterval(double maxY) {
    return (maxY / 5).ceil();
  }

  String formatYAxisLabel(double value) {
    if (value >= 60) {
      int hours = value ~/ 60;
      int minutes = (value % 60).toInt();
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      return '${value.toInt()}m';
    }
  }

  List<BarChartGroupData> getSemesterChartData(
      String year, bool isOddSemester) {
    Map<String, int> monthlyUsage = yearlyUsage[year] ?? {};
    return List.generate(
      isOddSemester ? 6 : 5,
      (index) {
        int monthIndex = isOddSemester ? index + 5 : index;
        double usage = (monthlyUsage[months[monthIndex]] ?? 0) / 60;
        return BarChartGroupData(
          x: monthIndex,
          barsSpace: 8,
          barRods: [
            BarChartRodData(
              toY: usage.toDouble(),
              gradient: const LinearGradient(
                colors: [Color(0xFFff7e5f), Color(0xFFfeb47b)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 14,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        );
      },
    );
  }

  List<BarChartGroupData> getOddSemesterChartData(String year) {
    return getSemesterChartData(year, true);
  }

  List<BarChartGroupData> getEvenSemesterChartData(String year) {
    return getSemesterChartData(year, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: availableYears.isNotEmpty
                    ? Column(
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            'Usage Statistics: ${availableYears[currentYearIndex]}',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          GraphContainer(
                            year: availableYears[currentYearIndex],
                            maxY: getMaxY(availableYears[currentYearIndex]),
                            yInterval: calculateYAxisInterval(
                                getMaxY(availableYears[currentYearIndex])),
                            getChartData: getOddSemesterChartData,
                            title: 'Odd Semester Usage',
                          ),
                          const SizedBox(height: 16),
                          GraphContainer(
                            year: availableYears[currentYearIndex],
                            maxY: getMaxY(availableYears[currentYearIndex]),
                            yInterval: calculateYAxisInterval(
                                getMaxY(availableYears[currentYearIndex])),
                            getChartData: getEvenSemesterChartData,
                            title: 'Even Semester Usage',
                          ),
                          const SizedBox(height: 16),
                          SmoothPageIndicator(
                            controller: _pageController,
                            count: availableYears.length,
                            effect: ExpandingDotsEffect(
                              dotHeight: 8.0,
                              dotWidth: 8.0,
                              activeDotColor: Colors.blueAccent,
                              dotColor: Colors.white,
                              expansionFactor: 4,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      )
                    : const Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ),
    );
  }
}

class GraphContainer extends StatelessWidget {
  final String year;
  final double maxY;
  final int yInterval;
  final List<BarChartGroupData> Function(String year) getChartData;
  final String title;

  const GraphContainer({
    required this.year,
    required this.maxY,
    required this.yInterval,
    required this.getChartData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width,
      height: 220, // Adjust height as necessary
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      double totalSeconds = rod.toY * 60;
                      String formattedTime = formatSeconds(totalSeconds);

                      return BarTooltipItem(
                        formattedTime,
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                groupsSpace: 18,
                titlesData: FlTitlesData(
                  show: true,
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: yInterval.toDouble(),
                      getTitlesWidget: (value, meta) => Text(
                        formatYAxisLabel(value),
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          months[value.toInt()],
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                barGroups: getChartData(year),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatYAxisLabel(double value) {
    if (value >= 60) {
      int hours = value ~/ 60;
      int minutes = (value % 60).toInt();
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      return '${value.toInt()}m';
    }
  }

  String formatSeconds(double totalSeconds) {
    int hours = (totalSeconds / 3600).floor();
    int minutes = ((totalSeconds % 3600) / 60).floor();
    int seconds = (totalSeconds % 60).floor();

    return '$hours hours $minutes minutes $seconds seconds';
  }
}
