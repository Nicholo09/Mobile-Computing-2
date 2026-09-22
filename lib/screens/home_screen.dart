import 'package:flutter/material.dart';

import '../widgets/activity_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── App Bar ───────────────────────────────────────────────
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mobile Computing 2',
                        style: Theme.of(context)
                            .appBarTheme
                            .titleTextStyle
                            ?.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Laboratory Activity Portfolio',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Settings gear button
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.settings,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
        toolbarHeight: 88,
      ),

      // ── Body ─────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Laboratory Activities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
            ),
            const SizedBox(height: 16),

            // Activity 2 — available, navigates to Activity2Screen
            ActivityCard(
              icon: Icons.wifi,
              title: 'Activity 2',
              subtitle: 'Active Network Monitor &\nHandover Handling',
              isAvailable: true,
              onTap: () => Navigator.pushNamed(context, '/activity2'),
            ),

            // Activity 3 — available
            ActivityCard(
              icon: Icons.network_check,
              title: 'Activity 3',
              subtitle: 'Dynamic Performance Throttle App',
              isAvailable: true,
              onTap: () => Navigator.pushNamed(context, '/activity3'),
            ),

            // Activity 4 — locked
            const ActivityCard(
              icon: Icons.hourglass_empty,
              title: 'Activity 4',
              subtitle: 'Not Available Yet',
            ),

            // Activity 5 — locked
            const ActivityCard(
              icon: Icons.hourglass_empty,
              title: 'Activity 5',
              subtitle: 'Not Available Yet',
            ),

            // Activity 6 — locked
            const ActivityCard(
              icon: Icons.hourglass_empty,
              title: 'Activity 6',
              subtitle: 'Not Available Yet',
            ),
          ],
        ),
      ),
    );
  }
}
