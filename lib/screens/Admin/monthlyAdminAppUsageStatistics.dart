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
  Map<String, int> dailyUsage = {};
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
    Map<String, int> tempDailyUsage = {};

    try {
      DatabaseEvent event = await dbRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        for (DataSnapshot userSnapshot in snapshot.children) {
          String userId = userSnapshot.key ?? '';
          String monthYear = '${months[selectedMonthIndex]} $selectedYear';
          Map<String, int> dailyUsageMap =
              await getTotalMonthlyUsage(userId, monthYear);

          dailyUsageMap.forEach((dayKey, dailySeconds) {
            tempDailyUsage[dayKey] =
                (tempDailyUsage[dayKey] ?? 0) + dailySeconds;
          });
        }

        setState(() {
          dailyUsage = tempDailyUsage;
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

  double getMaxY() {
    double maxUsage = dailyUsage.values.isEmpty
        ? 10.0
        : dailyUsage.values
            .fold(0, (max, value) => math.max(max, value / 60.0));
    return (maxUsage / 5).ceil() * 5.0;
  }

  int calculateYAxisInterval(double maxY) {
    return maxY > 0 ? (maxY / 5).ceil() : 1;
  }

  List<BarChartGroupData> getMonthlyChartData() {
    return List.generate(
      31,
      (index) {
        String dayKey = (index + 1).toString().padLeft(2, '0') +
            '-${selectedMonthIndex + 1}-$selectedYear';
        double usage = (dailyUsage[dayKey] ?? 0) / 60.0;
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
                    DropdownButton<int>(
                      value: selectedMonthIndex,
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
                    const SizedBox(height: 24),
                    GraphContainer(
                      maxY: getMaxY(),
                      yInterval: calculateYAxisInterval(getMaxY()),
                      getChartData: getMonthlyChartData,
                      title: 'Daily Usage for ${months[selectedMonthIndex]}',
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
          const SizedBox(height: 12),
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
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                barGroups: getChartData(),
              ),
            ),
          ),
        ],
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
