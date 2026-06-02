import 'package:flutter/material.dart';
import 'package:powercare_flutter/features/presentation/jobs/job_screen.dart';

import '../home/home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const primary = Color(0xFFff5b1f);

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const JobScreen(),
    const Center(child: Text("Timelog Content", style: TextStyle(fontSize: 20))),
    const Center(child: Text("Job Status Content", style: TextStyle(fontSize: 20))),
    const Center(child: Text("Contact Book Content", style: TextStyle(fontSize: 20))),
  ];

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.grid_view_rounded,
    Icons.access_time_filled_rounded,
    Icons.insert_chart_rounded,
    Icons.contact_phone_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: Container(
          key: ValueKey(_selectedIndex),
          child: Material(
            type: MaterialType.transparency,
            child: _pages[_selectedIndex],
        )),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          // Padding around the bar to keep it floating
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 60, // Reduced height since labels are removed
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Circular rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: List.generate(_icons.length, (index) {
                final bool isSelected = _selectedIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: isSelected ? 1.2 : 1.0, // Slight pop effect when selected
                        child: Icon(
                          _icons[index],
                          size: 26,
                          color: isSelected ? primary : const Color(0xFFBBBBBB),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}