import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {  const HomeScreen({super.key});

static const primaryColor = Color(0xFFff5b1f);

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F5),
    appBar: AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      title: const Text(
        "Home",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          onPressed: () {},
        ),
        const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hi, Jesica Macven",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 20),

          // Upcoming Jobs Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Upcoming Jobs",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Commercial Generator Installation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Stockton College",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text("02 Jun 2026", style: TextStyle(color: Colors.white)),
                    const Spacer(),
                    const Icon(Icons.access_time, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text("10:00 AM", style: TextStyle(color: Colors.white)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Grid of Menu Items
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,
            children: [
              _buildMenuCard("View Jobs", Icons.work_rounded, const Color(0xFFff5b1f)),
              _buildMenuCard("Create a Job", Icons.assignment_add, const Color(0xFFd4a373)),
              _buildMenuCard("Job Status", Icons.history_rounded, const Color(0xFF6b5b95)),
              _buildMenuCard("Materials", Icons.layers_rounded, const Color(0xFFb5a642)),
              _buildMenuCard("Archived Jobs", Icons.inventory_2_rounded, const Color(0xFF7b9ebc)),
              _buildMenuCard("Time Logs", Icons.update_rounded, const Color(0xFF67ab7c)),
            ],
          ),
          const SizedBox(height: 100), // Space for the bottom bar
        ],
      ),
    ),
  );
}

Widget _buildMenuCard(String title, IconData icon, Color iconColor) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.black.withOpacity(0.05)),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF333333),
          ),
        ),
        const Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: Icon(
            icon,
            size: 40,
            color: iconColor.withOpacity(0.8),
          ),
        ),
      ],
    ),
  );
}
}