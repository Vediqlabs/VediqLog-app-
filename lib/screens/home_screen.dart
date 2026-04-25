import 'package:flutter/material.dart';

import 'home_dashboard.dart';
import 'timeline_screen.dart';
import 'upload_screen.dart';
import 'analytics_screen.dart';
import 'calender_screen.dart';
import 'package:vediqlog/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final pages = const [
    HomeDashboard(),
    TimelineScreen(),
    UploadScreen(),
    AnalyticsScreen(),
    CalendarScreen(),
  ];

  Widget navItem(IconData icon, int i) {
    final selected = index == i;

    return IconButton(
      onPressed: () {
        setState(() {
          index = i;
        });
      },
      icon: Icon(
        icon,
        size: 26,
        color: selected ? AppColors.gold : Colors.white.withOpacity(0.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],

      /// Floating Upload Button
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.gold,
          onPressed: () {
            setState(() {
              index = 2;
            });
          },
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.black,
            size: 28,
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        color: AppColors.graphite,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navItem(Icons.home, 0),
              navItem(Icons.timeline, 1),
              const SizedBox(width: 40),
              navItem(Icons.bar_chart, 3),
              navItem(Icons.calendar_month, 4),
            ],
          ),
        ),
      ),
    );
  }
}
