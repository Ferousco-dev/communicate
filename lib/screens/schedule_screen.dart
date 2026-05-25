import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final schedule = appState.schedule;
        final nowIndex = appState.nowIndex;
        final activeChild = appState.activeChild;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFA),
          body: Stack(
            children: [
              Column(
                children: [
                  _header(activeChild?.name ?? "there"),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              // Progress Flow Line
                              Positioned(
                                left: 40,
                                top: 40,
                                bottom: 40,
                                child: Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFBDC9C6),
                                        Color(0xFF006A63),
                                        Color(0xFF84D7FD),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),

                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: schedule.length,
                                itemBuilder: (context, i) {
                                  final item = schedule[i];
                                  final isNow = i == nowIndex;
                                  final isDone = item.done;

                                  return _ScheduleItem(
                                    item: item,
                                    isNow: isNow,
                                    isDone: isDone,
                                    onTap: () => appState.toggleScheduleDone(item),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Motivational Banner
                          _MotivationalBanner(
                            count: appState.scheduleDone,
                            total: schedule.length,
                          ),
                          const SizedBox(height: 120), // Bottom nav space
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Lock FAB
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: const Color(0xFF191C1D),
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.lock),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(String name) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 12, 24, 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF84D7FD),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4DB6AC), width: 2),
            ),
            child: const Center(child: Icon(Icons.person, color: Color(0xFF005D79), size: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Hello!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF006A63)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF006A63), size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final dynamic item;
  final bool isNow;
  final bool isDone;
  final VoidCallback onTap;

  const _ScheduleItem({
    required this.item,
    required this.isNow,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        children: [
          // Icon Tile
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: isDone
                ? const Color(0xFFE6E8E8)
                : (isNow ? const Color(0xFF4DB6AC) : const Color(0xFF84D7FD)),
              borderRadius: BorderRadius.circular(24),
              border: isNow ? Border.all(color: const Color(0xFF006A63), width: 4) : null,
              boxShadow: [
                if (isNow) BoxShadow(color: const Color(0xFF006A63).withOpacity(0.15), blurRadius: 20),
              ],
            ),
            child: Center(
              child: Icon(
                item.icon,
                size: 40,
                color: isDone ? const Color(0xFFBDC9C6) : (isNow ? Colors.white : const Color(0xFF005D79)),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Content Card
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isNow ? const Color(0xFF006A63) : const Color(0xFFBDC9C6).withOpacity(0.3),
                    width: isNow ? 4 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDone ? const Color(0xFF6D7A77) : const Color(0xFF191C1D),
                            ),
                          ),
                          Text(
                            isDone ? 'Done' : (isNow ? 'Now' : 'Upcoming'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDone ? const Color(0xFFBDC9C6) : (isNow ? const Color(0xFF4DB6AC) : const Color(0xFF006685)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDone)
                      const Icon(Icons.check_circle, color: Color(0xFF006A63), size: 32)
                    else if (!isNow)
                      const Icon(Icons.arrow_forward_ios, color: Color(0xFFBDC9C6), size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MotivationalBanner extends StatelessWidget {
  final int count;
  final int total;

  const _MotivationalBanner({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFBDC9C6).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Great Job!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
                    const SizedBox(height: 4),
                    Text("You've finished $count tasks today. Keep going!", style: const TextStyle(fontSize: 16, color: Color(0xFF3D4947))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAQp-Nds3CStWm4YTQYfyF4j57S5G-OM1DoroP6TspxOI4I9F11x9akBgna3OGBCw2Gdo2T6rSlTDTBU_DwXsScSGFuY21m29ZdAmaI2DHP-KI-3XrJJZI9iRS1RUKatczS-w5sqykGnxGEYppcLFAGpOh2IMLbLTE24fJLCcY_mY6npJwV5CcxfllhJVJKwUE4xURuCkosHcg9WdpXXCE546W4N1rmDV5a_7KHJuCPDjYxK58B3Gyz_4xjTnuC7pDoJ55FQUTUinjb'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: count / total,
              minHeight: 12,
              backgroundColor: const Color(0xFFECEEEE),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF006A63)),
            ),
          ),
        ],
      ),
    );
  }
}
