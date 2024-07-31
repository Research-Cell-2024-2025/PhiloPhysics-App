import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/screens/Admin/addModule.dart';
import 'package:ephysicsapp/services/authentication.dart';

import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';

import 'modulesMaster.dart';

class NotesHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HomeWidgetState();
  }
}

class HomeWidgetState extends State<NotesHomePage> with TickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    new Tab(text: "SAKEC"),
    new Tab(text: "Others"),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color1,
      appBar: new AppBar(
        // title: Text("Homepage"),
        // actions: [
        //   isLoggedIn()
        //       ? IconButton(
        //           icon: Icon(Icons.exit_to_app),
        //           onPressed: () {
        //             onLogout(context);
        //           },
        //         )
        //       : IconButton(
        //           icon: Icon(Icons.person),
        //           onPressed: () async {
        //             Navigator.push(context,
        //                 MaterialPageRoute(builder: (context) => AdminLogin()));
        //           })
        // ],
        backgroundColor: color1,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: new TabBar(
          isScrollable: false,
          unselectedLabelColor: color5,
          labelColor: color2,
          
          labelPadding: EdgeInsets.symmetric(
              horizontal: (MediaQuery.of(context).size.width / 12)),
          indicatorPadding: EdgeInsets.symmetric(horizontal: 10.0), // Adjust the padding as needed,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: new BubbleTabIndicator(
            indicatorHeight:40.0,
            indicatorColor:color5,
            indicatorRadius: 10,
            tabBarIndicatorSize: TabBarIndicatorSize.tab,
          ),
          tabs: tabs,
          controller: _tabController,
        ),
      ),
      body: new TabBarView(
        controller: _tabController,
        children: tabs.map((Tab tab) {
          String section = "1";
          if (tab.text == tabs[1].text)
            section = "2";
          else
            section = "1";
          return ModuleMaster(section: section);
        }).toList(),
      ),
      // floatingActionButton: isLoggedIn()? FloatingActionButton(
      //   backgroundColor: color4,
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => AddModule()),
      //     );
      //   }
      //   child: Icon(Icons.add,),
      // ):Container(),
    );
  }
}
