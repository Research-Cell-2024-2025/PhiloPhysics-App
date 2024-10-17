import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AdminAppUsageStatistics extends StatefulWidget {
  const AdminAppUsageStatistics({Key? key}) : super(key: key);

  @override
  _AdminStatisticsState createState() => _AdminStatisticsState();
}

class _AdminStatisticsState extends State<AdminAppUsageStatistics> {
  Map<String, Map<String, int>> yearlyUsage = {};
  bool isLoading = true;
  List<String> availableYears = [];
  int currentYearIndex = 0;
  late PageController _pageController;

  // Define months list
  final List<String> months = [
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentYearIndex);
    getAppUsageData();
  }

  Future<void> getAppUsageData() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Users');
    try {
      DatabaseEvent event = await dbRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        snapshot.children.forEach((userSnapshot) {
          Map<dynamic, dynamic> userData =
              userSnapshot.value as Map<dynamic, dynamic>;

          if (userData.containsKey('AppUsage')) {
            Map<dynamic, dynamic> usageData = userData['AppUsage'];
            usageData.forEach((key, value) {
              List<String> parts = key.split(' ');
              String month = parts[0];
              String year = parts[1];
              int totalSeconds = convertTimeToSeconds(value);

              if (!yearlyUsage.containsKey(year)) {
                yearlyUsage[year] = {};
              }
              yearlyUsage[year]![month] =
                  (yearlyUsage[year]![month] ?? 0) + totalSeconds;
            });
          }
        });

        setState(() {
          availableYears = yearlyUsage.keys.toList()..sort();
          isLoading = false;
          print(availableYears);
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

  int convertTimeToSeconds(String time) {
    List<String> parts = time.split(':');
    return int.parse(parts[0]) * 3600 +
        int.parse(parts[1]) * 60 +
        int.parse(parts[2]);
  }

  String formatMinutes(double seconds) {
    int minutes = (seconds / 60).round();
    return '$minutes min';
  }

  double getMaxY(String year) {
    Map<String, int> monthlyUsage = yearlyUsage[year] ?? {};
    double maxUsage =
        monthlyUsage.values.fold(0, (max, value) => math.max(max, value / 60));
    return (maxUsage / calculateYAxisInterval(maxUsage)).ceil() *
        calculateYAxisInterval(maxUsage).toDouble();
  }

  int calculateYAxisInterval(double maxY) {
    if (maxY <= 60) return 15;
    if (maxY <= 120) return 30;
    if (maxY <= 240) return 60;
    return (maxY / 5).ceil();
  }

  List<BarChartGroupData> getBarChartData(String year) {
    Map<String, int> monthlyUsage = yearlyUsage[year] ?? {};
    return List.generate(12, (index) {
      double usage = (monthlyUsage[months[index]] ?? 0) / 60;
      return BarChartGroupData(
        x: index,
        barsSpace: 8,
        barRods: [
          BarChartRodData(
            toY: usage,
            gradient: LinearGradient(
              colors: [Color(0xFFff7e5f), Color(0xFFfeb47b)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 14,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ],
      );
    });
  }

  void switchToNextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void switchToPreviousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void switchYear(int newIndex) {
    setState(() {
      currentYearIndex = newIndex;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Statistics',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent,
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      itemCount: availableYears.length,
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentYearIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        String year = availableYears[index];
                        double maxY = getMaxY(year);
                        int yInterval = calculateYAxisInterval(maxY);
                        return Column(
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              'Usage Statistics: $year',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black.withOpacity(0.3),
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 8.0,
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 5,
                                        blurRadius: 15,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  height: 220,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: maxY,
                                      minY: 0,
                                      groupsSpace: 18,
                                      titlesData: FlTitlesData(
                                        show: true,
                                        topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 50,
                                            interval: yInterval.toDouble(),
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                formatYAxisLabel(value),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                child: Text(
                                                  months[value.toInt()],
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border.all(
                                          color:
                                              Colors.blueGrey.withOpacity(0.2),
                                        ),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval:
                                            yInterval.toDouble(),
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Colors.blueGrey
                                                .withOpacity(0.1),
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      barTouchData: BarTouchData(
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipItem: (group, groupIndex,
                                              rod, rodIndex) {
                                            return BarTooltipItem(
                                              '${months[group.x]}: ${formatYAxisLabel(rod.toY)}',
                                              const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          },
                                          getTooltipColor: (group) => Colors
                                              .blueAccent
                                              .withOpacity(0.8),
                                        ),
                                        touchCallback: (event, response) {},
                                        allowTouchBarBackDraw: true,
                                        enabled: true,
                                      ),
                                      barGroups: getBarChartData(year),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: -12,
                                  child: IconButton(
                                    onPressed: switchToPreviousPage,
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -12,
                                  child: IconButton(
                                    onPressed: switchToNextPage,
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
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
                            const SizedBox(
                              height: 24,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
