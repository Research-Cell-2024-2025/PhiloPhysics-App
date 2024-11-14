import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class MonthlyAdminAppUsageStatistics extends StatefulWidget {
  const MonthlyAdminAppUsageStatistics({Key? key}) : super(key: key);

  @override
  _MonthlyAdminAppUsageStatisticsState createState() =>
      _MonthlyAdminAppUsageStatisticsState();
}

class _MonthlyAdminAppUsageStatisticsState
    extends State<MonthlyAdminAppUsageStatistics> {
  Map<String, Map<String, int>> yearlyUsage = {};
  Map<String, int> weeklyUsage = {};
  String selectedYear = DateTime.now().year.toString();
  bool isLoading = true;
  int selectedMonthIndex = DateTime.now().month - 1;
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
    getAppUsageData();
  }

  Future<void> getAppUsageData() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Users');
    Map<String, int> tempWeeklyUsage = {};

    try {
      DatabaseEvent event = await dbRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        for (DataSnapshot userSnapshot in snapshot.children) {
          String userId = userSnapshot.key ?? '';
          String monthYear = '${months[selectedMonthIndex]} $selectedYear';
          Map<String, int> dailyUsageMap =
              await getTotalMonthlyUsage(userId, monthYear);

          // Group daily usage into weekly usage
          tempWeeklyUsage = groupUsageByWeeks(dailyUsageMap);
        }

        setState(() {
          weeklyUsage = tempWeeklyUsage;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, int>> getTotalMonthlyUsage(
      String userId, String month) async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref();
    final userAppUsageRef =
        ref.child('Users').child(userId).child('AppUsage').child(month);

    Map<String, int> dailyUsageMap = {};
    DataSnapshot snapshot = await userAppUsageRef.get();

    if (snapshot.exists) {
      snapshot.children.forEach((dateSnapshot) {
        String dateKey = dateSnapshot.key ?? '';
        String timeStr = dateSnapshot.value as String;
        int totalSeconds = convertTimeToSeconds(timeStr);
        dailyUsageMap[dateKey] = totalSeconds;
      });
    }

    return dailyUsageMap;
  }

  int convertTimeToSeconds(String time) {
    List<String> parts = time.split(':');
    return int.parse(parts[0]) * 3600 +
        int.parse(parts[1]) * 60 +
        int.parse(parts[2]);
  }

  /// Group usage by weeks in a month
  Map<String, int> groupUsageByWeeks(Map<String, int> dailyUsageMap) {
    Map<String, int> weeklyUsage = {};
    int daysInMonth =
        DateTime(int.parse(selectedYear), selectedMonthIndex + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      String dayKey = day.toString().padLeft(2, '0') +
          '-${selectedMonthIndex + 1}-$selectedYear';

      // Determine the week of the current day
      int weekNumber = ((day - 1) ~/ 7) + 1;
      String weekKey = 'Week $weekNumber';

      weeklyUsage[weekKey] =
          (weeklyUsage[weekKey] ?? 0) + (dailyUsageMap[dayKey] ?? 0);
    }

    return weeklyUsage;
  }

  double getMaxY() {
    double maxUsage = weeklyUsage.values.isEmpty
        ? 10.0
        : weeklyUsage.values
            .fold(0, (max, value) => math.max(max, value / 60.0));
    return (maxUsage / 5).ceil() * 5.0;
  }

  int calculateYAxisInterval(double maxY) {
    return maxY > 0 ? (maxY / 5).ceil() : 1;
  }

  List<BarChartGroupData> getWeeklyChartData() {
    return List.generate(
      weeklyUsage.length,
      (index) {
        String weekKey = 'Week ${index + 1}';
        double usage = (weeklyUsage[weekKey] ?? 0) / 60.0;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: usage,
              gradient: const LinearGradient(
                colors: [Color(0xFFff7e5f), Color(0xFFfeb47b)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 18,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent,
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white, // White background
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey
                                  .withOpacity(0.3), // Soft shadow effect
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3), // Shadow position
                            ),
                          ],
                        ),
                        child: DropdownButton<int>(
                          value: selectedMonthIndex,
                          isExpanded: true,
                          underline:
                              const SizedBox(), // Removes default underline
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.black),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          items: List.generate(
                            months.length,
                            (index) => DropdownMenuItem(
                              value: index,
                              child: Text(
                                months[index],
                                style: GoogleFonts.poppins(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedMonthIndex = value!;
                              isLoading = true;
                            });
                            getAppUsageData();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GraphContainer(
                      maxY: getMaxY(),
                      yInterval: calculateYAxisInterval(getMaxY()),
                      getChartData: getWeeklyChartData,
                      title: 'Weekly Usage for ${months[selectedMonthIndex]}',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}

class GraphContainer extends StatelessWidget {
  final double maxY;
  final int yInterval;
  final List<BarChartGroupData> Function() getChartData;
  final String title;

  const GraphContainer({
    required this.maxY,
    required this.yInterval,
    required this.getChartData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
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
        height: 220,
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
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        double usageInMinutes = rod.toY;
                        int totalSeconds = (usageInMinutes * 60).round();
                        int minutes = totalSeconds ~/ 60;
                        int seconds = totalSeconds % 60;
                        String tooltipText = '';
                        if (minutes > 0) tooltipText += '$minutes min ';
                        tooltipText += '$seconds sec';
                        return BarTooltipItem(
                          tooltipText,
                          TextStyle(color: Colors.white),
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
                        interval: 5,
                        getTitlesWidget: (value, meta) => Text(
                          (value + 1).toInt().toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: yInterval.toDouble(),
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(
                          color: Colors.black, width: 1), // Left Y-axis
                      bottom: BorderSide(
                          color: Colors.black, width: 1), // Bottom X-axis
                    ),
                  ),
                  barGroups: getChartData(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatYAxisLabel(double value) {
    int totalSeconds = (value * 60).round();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return seconds == 0 ? '${minutes}m' : '${minutes}m ${seconds}s';
  }
}
