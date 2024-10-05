import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AppUsageStats extends StatefulWidget {
  const AppUsageStats({Key? key}) : super(key: key);

  @override
  _AppUsageStatsState createState() => _AppUsageStatsState();
}

class _AppUsageStatsState extends State<AppUsageStats> {
  late List<String> years; // Change to List<String>
  late Map<String,
      Map<String, int>> yearlyUsage; // Change to Map<String, Map<String, int>>
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    print("Navigating to App Usage Stats Page");
    fetchAppUsageData();
  }

  Future<void> fetchAppUsageData() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Users');

    try {
      DataSnapshot snapshot = await dbRef.once().then((event) =>
      event.snapshot);

      if (snapshot.exists) {
        Map<String, Map<String, int>> tempUsage = {};

        snapshot.children.forEach((userSnapshot) {
          Map<dynamic, dynamic> userData = userSnapshot.value as Map<
              dynamic,
              dynamic>;

          if (userData.containsKey('AppUsage')) {
            Map<dynamic, dynamic> appUsage = userData['AppUsage'] as Map<
                dynamic,
                dynamic>;

            appUsage.forEach((month, usageTime) {
              if (usageTime is String) {
                int totalMinutes = convertTimeToMinutes(usageTime);
                String year = month.split(" ")[1];

                tempUsage.putIfAbsent(year, () => {});
                tempUsage[year]![month] =
                    (tempUsage[year]![month] ?? 0) + totalMinutes;
              }
            });
          }
        });

        setState(() {
          yearlyUsage = tempUsage;
          years = yearlyUsage.keys.toList();
          print(yearlyUsage);
          print(years);
        });
      } else {
        print("No data found at reference");
      }
    } catch (e) {
      print('Error fetching app usage data: $e');
    }
  }

  int convertTimeToMinutes(String time) {
    List<String> parts = time.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);
    return hours * 60 + minutes + (seconds > 0 ? 1 : 0);
  }

  String convertMinutesToHHMM(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(
        2, '0')}';
  }

  double convertHHMMToDouble(String time) {
    List<String> parts = time.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    return hours + (minutes / 60.0);
  }

  List<UsageData> getUsageDataForYear(String year) {
    if (!yearlyUsage.containsKey(year)) return [];

    Map<String, int> monthlyData = yearlyUsage[year]!;
    return monthlyData.entries.map((entry) {
      String usageInHHMM = convertMinutesToHHMM(entry.value);
      double usageInHours = convertHHMMToDouble(usageInHHMM);
      return UsageData(entry.key, usageInHours);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Usage Statistics')),
      body: yearlyUsage.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          height: MediaQuery
              .of(context)
              .size
              .height / 2,
          child: Column(
            children: [
              Expanded(
                child: CarouselSlider.builder(
                  itemCount: years.length,
                  itemBuilder: (context, index, realIndex) {
                    String year = years[index];
                    return buildYearlyBarChart(year); // Use the year directly
                  },
                  options: CarouselOptions(
                    height: 400.0,
                    autoPlay: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        if (_currentIndex > 0) {
                          setState(() {
                            _currentIndex--;
                          });
                        }
                      },
                    ),
                    Text(
                      'Year: ${years[_currentIndex]}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        if (_currentIndex < years.length - 1) {
                          setState(() {
                            _currentIndex++;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildYearlyBarChart(String year) {
    List<UsageData> data = getUsageDataForYear(year);

    if (data.isEmpty) {
      return Center(child: const Text('No data available for this year.'));
    }

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(title: AxisTitle(text: 'Usage (Hours)')),
        series: [
          ColumnSeries<UsageData, String>(
            dataSource: data,
            xValueMapper: (UsageData usage, _) => usage.month,
            yValueMapper: (UsageData usage, _) => usage.usageInHours,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}
// Usage data model
class UsageData {
  final String month;
  final double usageInHours;

  UsageData(this.month, this.usageInHours);
}
