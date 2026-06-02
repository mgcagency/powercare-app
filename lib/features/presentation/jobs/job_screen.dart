import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  int selected = 0;

  Color primaryColor = AppColors.primary;

  final jobs = [
    {
      "title": "Electrical Maintenance",
      "desc": "Full wiring inspection & panel servicing",
      "date": "02 Jun 2026",
      "time": "10:30 AM",
      "phone": "9876543210",
      "location": "123 Main St, City",
      "note": "Urgent safety inspection",
      "engineers": ["A", "R", "M"],
    },
    {
      "title": "Generator Service",
      "desc": "Diesel generator monthly service",
      "date": "03 Jun 2026",
      "time": "02:00 PM",
      "phone": "9123456780",
      "location": "123 Main St, City",
      "note": "Client requested afternoon slot",
      "engineers": ["S"],
    },
  ];

  Color getStatusColor(int index) {
    switch (index % 3) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ---------------- FILTER BAR ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _chip("All Jobs", 0),
                    _chip("My Jobs", 1),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------------- LIST ----------------
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jobs.length,
                itemBuilder: (context, i) {
                  final job = jobs[i];

                  // ✅ LIST ANIMATION ADDED
                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 300 + (i * 80)),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.easeOut,
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: _ticketCard(job, i),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CHIP ----------------
  Widget _chip(String text, int index) {
    final active = selected == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selected = index),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: active ? 1.05 : 1.0,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active ? primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              boxShadow: active
                  ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
                  : [],
            ),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: active ? Colors.white : primaryColor.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                child: Text(text),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- JOB CARD ----------------
  Widget _ticketCard(Map job, int index) {
    final statusColor = getStatusColor(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 5),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE + STATUS
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job["title"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      index == 0 ? "Active" : "Pending",
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                job["desc"],
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _info(Icons.pin_drop_rounded, job["location"]),
                  ),
                  const SizedBox(width: 12),
                  _engineers(job["engineers"]),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: [
                  _info(Icons.phone, job["phone"]),
                  _info(Icons.calendar_month, job["date"]),
                  _info(Icons.access_time, job["time"]),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "💡 ${job["note"]}",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- ENGINEERS ----------------
  Widget _engineers(List list) {
    return SizedBox(
      height: 30,
      width: list.length == 1 ? 30 : list.length * 20,
      child: Stack(
        children: List.generate(list.length, (i) {
          return Positioned(
            left: i * 16,
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 300),
              tween: Tween<double>(begin: 0.5, end: 1),
              curve: Curves.easeOutBack,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: CircleAvatar(
                radius: 12,
                backgroundColor: primaryColor.withOpacity(0.8),
                child: Text(
                  list[i],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------------- INFO CHIP ----------------
  Widget _info(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryColor),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}