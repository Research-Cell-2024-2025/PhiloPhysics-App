import 'package:ephysicsapp/screens/Admin/annualAdminAppUsageStatistics.dart';
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
  Map<int, int> weeklyUsage = {};
  String? selectedYear;
  bool isLoading = true;
  int? selectedMonthIndex;
  Set<String> availableYears = {};
  Map<String, Set<String>> availableMonthsPerYear = {};

  final List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    fetchAvailableMonthsAndYears();
  }

  Future<void> fetchAvailableMonthsAndYears() async {
    setState(() => isLoading = true);
    try {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Users');
      DatabaseEvent event = await dbRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        for (DataSnapshot userSnapshot in snapshot.children) {
          String userId = userSnapshot.key ?? '';
          await fetchUserAppUsageData(userId);
        }

        // Set initial selections after getting available data
        if (availableYears.isNotEmpty) {
          final currentYear = DateTime.now().year.toString();
          selectedYear = availableYears.contains(currentYear)
              ? currentYear
              : availableYears.last;

          if (selectedYear != null && availableMonthsPerYear[selectedYear]?.isNotEmpty == true) {
            final currentMonth = months[DateTime.now().month - 1];
            selectedMonthIndex = availableMonthsPerYear[selectedYear]!.contains(currentMonth)
                ? months.indexOf(currentMonth)
                : months.indexOf(availableMonthsPerYear[selectedYear]!.last);
          }

          // Fetch initial data
          if (selectedYear != null && selectedMonthIndex != null) {
            print("Avail months : ${availableMonthsPerYear} and years ${availableYears}");
            await getAppUsageData();
          }
        }
      }
    } catch (e) {
      print('Error fetching available months and years: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> fetchUserAppUsageData(String userId) async {
    DatabaseReference appUsageRef = FirebaseDatabase.instance
        .ref()
        .child('Users')
        .child(userId)
        .child('AppUsage');

    DatabaseEvent event = await appUsageRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> appUsageData =
      snapshot.value as Map<dynamic, dynamic>;

      for (var monthYear in appUsageData.keys) {
        String monthYearStr = monthYear.toString(); // e.g., "Nov 2024"
        List<String> parts = monthYearStr.split(' ');
        if (parts.length == 2) {
          String month = parts[0];
          String year = parts[1];

          // Add to available years
          availableYears.add(year);

          // Add to available months for this year
          availableMonthsPerYear.putIfAbsent(year, () => {}).add(month);
        }
      }
    }
  }

  int getWeekNumber(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final daysSinceFirstWeek = date.difference(firstDayOfMonth).inDays;
    final firstDayWeekday = firstDayOfMonth.weekday;
    return ((daysSinceFirstWeek + firstDayWeekday - 1) / 7).floor() + 1;
  }

  int getTotalWeeks(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    return getWeekNumber(lastDay);
  }

  Future<void> getAppUsageData() async {
    if (selectedYear == null || selectedMonthIndex == null) return;

    setState(() => isLoading = true);
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Users');
    Map<int, int> tempWeeklyUsage = {};

    try {
      DatabaseEvent event = await dbRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        for (DataSnapshot userSnapshot in snapshot.children) {
          String userId = userSnapshot.key ?? '';
          String monthYear = '${months[selectedMonthIndex!]} $selectedYear';
          Map<String, int> dailyUsageMap =
          await getTotalMonthlyUsage(userId, monthYear);

          // Group the daily usage data by weeks and add it to tempWeeklyUsage
          Map<int, int> userWeeklyUsage = await groupUsageByCalendarWeeks(dailyUsageMap);
          userWeeklyUsage.forEach((week, usage) {
            tempWeeklyUsage[week] = (tempWeeklyUsage[week] ?? 0) + usage;
          });
        }

        setState(() {
          weeklyUsage = tempWeeklyUsage;
          print("Weekly Usage : $weeklyUsage");
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

  Future<Map<String, int>> getTotalMonthlyUsage(String userId, String month) async {
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

  Future<Map<int, int>> groupUsageByCalendarWeeks(Map<String, int> dailyUsageMap) async {
    Map<int, int> weeklyUsage = {};
    int year = int.parse(selectedYear!);
    int month = selectedMonthIndex! + 1;

    // Initialize all weeks with 0
    int totalWeeks = getTotalWeeks(year, month);
    for (int i = 1; i <= totalWeeks; i++) {
      weeklyUsage[i] = 0;
    }

    // Iterate through each day in the month
    final lastDay = DateTime(year, month + 1, 0).day;
    for (int day = 1; day <= lastDay; day++) {
      // Ensure the day and month are in "dd-MM-yyyy" format
      String dayKey = '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
      if (dailyUsageMap.containsKey(dayKey)) {
        // Get the week number for this day
        DateTime date = DateTime(year, month, day);
        int weekNum = getWeekNumber(date);
        weeklyUsage[weekNum] = (weeklyUsage[weekNum] ?? 0) + (dailyUsageMap[dayKey] ?? 0);
      }
    }

    return weeklyUsage;
  }


  int convertTimeToSeconds(String time) {
    List<String> parts = time.split(':');
    return int.parse(parts[0]) * 3600 +
        int.parse(parts[1]) * 60 +
        int.parse(parts[2]);
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
    if (selectedYear == null || selectedMonthIndex == null) return [];

    int totalWeeks = getTotalWeeks(
        int.parse(selectedYear!), selectedMonthIndex! + 1);

    return List.generate(
      totalWeeks,
          (index) {
        int weekNumber = index + 1;
        double usage = (weeklyUsage[weekNumber] ?? 0) / 60.0;
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
            colors: [Colors.blueAccent, Colors.white],
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
                child: Row(
                  children: [
                    // Year Dropdown
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: DropdownButton<String>(
                          value: selectedYear,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.black),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                            items: () {
                              final years = availableYears.toList();
                              years.sort((a, b) => b.compareTo(a));
                              return years.map((year) => DropdownMenuItem<String>(
                                value: year,
                                child: Text(year.toString()),
                              )).toList();
                            }(),
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value;
                              // Reset month if not available in new year
                              if (selectedMonthIndex != null &&
                                  !availableMonthsPerYear[value]!.contains(
                                      months[selectedMonthIndex!])) {
                                selectedMonthIndex = months.indexOf(
                                    availableMonthsPerYear[value]!.first);
                              }
                            });
                            getAppUsageData();
                          },
                        ),
                      ),
                    ),
                    // Month Dropdown
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: DropdownButton<int>(
                          value: selectedMonthIndex,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.black),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          items: months
                              .asMap()
                              .entries
                              .where((entry) =>
                          selectedYear != null &&
                              availableMonthsPerYear[selectedYear]!
                                  .contains(entry.value))
                              .map((entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black),
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedMonthIndex = value);
                            getAppUsageData();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (selectedYear != null && selectedMonthIndex != null)
                GraphContainer(
                  maxY: getMaxY(),
                  yInterval: calculateYAxisInterval(getMaxY()),
                  getChartData: getWeeklyChartData,
                  title:
                  'Weekly Usage for ${months[selectedMonthIndex!]} $selectedYear',
                  selectedMonthIndex: selectedMonthIndex!,
                  selectedYear: selectedYear!,

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
  final String selectedYear;
  final int selectedMonthIndex;



  const GraphContainer({
    required this.maxY,
    required this.yInterval,
    required this.getChartData,
    required this.title,
    required this.selectedYear,
    required this.selectedMonthIndex,
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
        height: MediaQuery.of(context).size.height / 3.25,
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
                        int hours = (usageInMinutes / 60).round();
                        int minutes = (usageInMinutes - (hours * 60)).round();
                        int seconds = totalSeconds % 60;
                        String tooltipText = '';
                        tooltipText += '$hours hours ';
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
                      axisNameWidget: Text('Weeks in ${months[selectedMonthIndex]} ${selectedYear}',style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),),
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
                        strokeWidth: 2,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 2,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(
                          color: Colors.black, width: 2), // Left Y-axis
                      bottom: BorderSide(
                          color: Colors.black, width: 2), // Bottom X-axis
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
    double hours = value / 60;
    return '${hours.toStringAsFixed(1)}h'; // Display hours with one decimal
  }
}