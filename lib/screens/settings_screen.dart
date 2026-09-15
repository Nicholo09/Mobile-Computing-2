import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = themeProvider.isDarkMode;

    final Color sectionBg =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9FBF9);
    final Color dividerColor =
        isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE8EDE8);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── About Section ──────────────────────────────────
            const _SectionLabel(label: 'About'),
            _SettingsCard(
              color: sectionBg,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // App icon
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.phone_android,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mobile Computing 2\nPortfolio',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Version 1.0.0',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurface.withAlpha(153),
                              ),
                            ),
                            Text(
                              'Framework: Flutter',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurface.withAlpha(153),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(color: dividerColor, height: 1),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Appearance Section ─────────────────────────────
            const _SectionLabel(label: 'Appearance'),
            _SettingsCard(
              color: sectionBg,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.dark_mode_outlined,
                      color: theme.colorScheme.onSurface,
                      size: 26,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dark Mode',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Switch between light and dark theme',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(153),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (val) => themeProvider.toggleTheme(val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── About Us Section ───────────────────────────────
            const _SectionLabel(label: 'About Us'),
            _SettingsCard(
              color: sectionBg,
              child: Column(
                children: [
                  _DeveloperTile(
                    name: 'Nicholo Jhon D. Ricafort',
                    course: 'BS Computer Science',
                    divider: true,
                    dividerColor: dividerColor,
                  ),
                  _DeveloperTile(
                    name: 'Levin John Rojas',
                    course: 'BS Computer Science',
                    divider: false,
                    dividerColor: dividerColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final Color color;
  const _SettingsCard({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF3A3A3A)
              : const Color(0xFFE0E8E0),
        ),
      ),
      child: child,
    );
  }
}

class _DeveloperTile extends StatelessWidget {
  final String name;
  final String course;
  final bool divider;
  final Color dividerColor;

  const _DeveloperTile({
    required this.name,
    required this.course,
    required this.divider,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Avatar
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFDCEFDC),
                child: Icon(
                  Icons.person,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      course,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (divider) Divider(color: dividerColor, height: 1),
      ],
    );
  }
}
