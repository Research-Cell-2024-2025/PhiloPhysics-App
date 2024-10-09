// import 'dart:collection';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';

// class AdminStatistics extends StatefulWidget {
//   const AdminStatistics({super.key});

//   @override
//   _AdminStatisticsState createState() => _AdminStatisticsState();
// }

// class _AdminStatisticsState extends State<AdminStatistics> {
//   int userCount = 0;
//   int totalPdfsViewed = 0;
//   int totalVideosViewed = 0;
//   int uniqueCollegesCount = 0;
//   bool isLoading = true; // To manage loading state

//   @override
//   void initState() {
//     super.initState();
//     print('Fetching methods');
//     getUserStatsAndCount();
//     print('complete fetching methods');
//   }

//   Future<void> getUserStatsAndCount() async {
//     DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Users');

//     try {
//       DataSnapshot snapshot =
//           await dbRef.once().then((event) => event.snapshot);

//       if (snapshot.exists) {
//         Set<String> uniqueColleges = HashSet<String>();

//         snapshot.children.forEach((userSnapshot) {
//           Map<dynamic, dynamic> userData =
//               userSnapshot.value as Map<dynamic, dynamic>;

//           if (userData.containsKey('pdfsViewed')) {
//             totalPdfsViewed += (userData['pdfsViewed'] as num)
//                 .toInt(); // Cast to num and then to int
//           }
//           if (userData.containsKey('videosViewed')) {
//             totalVideosViewed += (userData['videosViewed'] as num)
//                 .toInt(); // Cast to num and then to int
//           }

//           if (userData.containsKey('college')) {
//             uniqueColleges.add(userData['college']);
//           }
//         });

//         setState(() {
//           userCount = snapshot.children.length;
//           uniqueCollegesCount = uniqueColleges.length;
//           isLoading = false; // Data fetched, stop loading
//         });
//       } else {
//         setState(() {
//           isLoading = false; // No data found, stop loading
//         });
//       }
//     } catch (e) {
//       print('Error: $e');
//       setState(() {
//         isLoading = false; // Stop loading in case of error
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     throw UnimplementedError();
//   }
// }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Admin Statistics'),
// //         centerTitle: true,
// //       ),
// //       body: isLoading
// //           ? const Center(
// //               child:
// //                   CircularProgressIndicator()) // Show loading indicator while data is fetched
// //           : Center(
// //               child: Padding(
// //                 padding: const EdgeInsets.symmetric(
// //                     horizontal: 25.0, vertical: 20.0),
// //                 child: GridView.count(
// //                   crossAxisCount: 2, // 2 boxes per row
// //                   crossAxisSpacing: 20.0,
// //                   mainAxisSpacing: 20.0,
// //                   childAspectRatio:
// //                       1.2, // Aspect ratio to control the height/width ratio of the boxes
// //                   children: [
// //                     _buildStatBox(
// //                         Icons.people,
// //                         'Total Users',
// //                         userCount.toString(),
// //                         Colors.blue,
// //                         context,
// //                         'TotalUsersPage'),
// //                     _buildStatBox(
// //                         Icons.picture_as_pdf,
// //                         'PDFs Viewed',
// //                         totalPdfsViewed.toString(),
// //                         Colors.green,
// //                         context,
// //                         'PdfsViewedPage'),
// //                     _buildStatBox(
// //                         Icons.video_library,
// //                         'Videos Viewed',
// //                         totalVideosViewed.toString(),
// //                         Colors.orange,
// //                         context,
// //                         'VideosViewedPage'),
// //                     _buildStatBox(
// //                         Icons.school,
// //                         'Unique Colleges',
// //                         uniqueCollegesCount.toString(),
// //                         Colors.red,
// //                         context,
// //                         'UniqueCollegesPage'),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //     );
// //   }

// //   Widget _buildStatBox(IconData icon, String label, String value, Color color,
// //       BuildContext context, String route) {
// //     bool isTapped = false;

// //     return GestureDetector(
// //       onTapDown: (_) => setState(() => isTapped = true), // Detect touch
// //       onTapUp: (_) => setState(() => isTapped = false), // Detect release
// //       onTapCancel: () => setState(() => isTapped = false), // Handle tap cancel
// //       onTap: () {
// //         Navigator.push(
// //             context, MaterialPageRoute(builder: (context) => AppUsageStats()));
// //       },
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 150),
// //         transform: Matrix4.identity()
// //           ..scale(isTapped ? 0.95 : 1.0), // Scale on touch
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(color: color, width: 2), // Adding border
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.grey.withOpacity(0.5),
// //               spreadRadius: 2,
// //               blurRadius: 5,
// //               offset: const Offset(0, 3), // changes position of shadow
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               icon,
// //               size: MediaQuery.of(context).size.width / 10,
// //               color: color,
// //             ),
// //             const SizedBox(height: 10),
// //             Text(
// //               label,
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //                 color: color,
// //               ),
// //             ),
// //             const SizedBox(height: 5),
// //             Text(
// //               value, // Display the dynamic value here
// //               style: TextStyle(
// //                 fontSize: 24,
// //                 fontWeight: FontWeight.bold,
// //                 color: color,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AdminStatistics extends StatefulWidget {
  const AdminStatistics({Key? key}) : super(key: key);

  @override
  _AdminStatisticsState createState() => _AdminStatisticsState();
}

class _AdminStatisticsState extends State<AdminStatistics> {
  Map<String, Map<String, int>> yearlyUsage = {};
  bool isLoading = true;
  List<String> availableYears = [];
  int currentYearIndex = 0;
  late PageController? _pageController;

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
    if (maxY <= 60) return 15; // 0, 15, 30, 45, 60
    if (maxY <= 120) return 30; // 0, 30, 60, 90, 120
    if (maxY <= 240) return 60; // 0, 60, 120, 180, 240
    return (maxY / 5).ceil(); // Aim for about 5 labels
  }

  List<BarChartGroupData> getBarChartData(String year) {
    Map<String, int> monthlyUsage = yearlyUsage[year] ?? {};
    return List.generate(12, (index) {
      double usage =
          (monthlyUsage[months[index]] ?? 0) / 60; // Convert seconds to minutes
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: usage,
            color: Colors.blue.shade300,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    });
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
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Statistics'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: availableYears.length,
                    controller: _pageController,
                    onPageChanged: switchYear,
                    itemBuilder: (context, index) {
                      String year = availableYears[index];
                      double maxY = getMaxY(year);
                      int yInterval = calculateYAxisInterval(maxY);
                      return Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Year: $year',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 200,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxY,
                                minY: 0,
                                groupsSpace: 12,
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
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            months[value.toInt()],
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
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
                                  border: const Border(
                                    bottom: BorderSide(
                                        color: Colors.black, width: 2),
                                    left: BorderSide(
                                        color: Colors.black, width: 2),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 60,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.black12,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                barGroups: getBarChartData(year),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SmoothPageIndicator(
                            controller: _pageController!,
                            count: availableYears.length,
                            effect: WormEffect(
                              dotHeight: 12.0,
                              dotWidth: 12.0,
                              activeDotColor: Colors.red,
                              dotColor: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
