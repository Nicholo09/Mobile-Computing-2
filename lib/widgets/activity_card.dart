import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isAvailable;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isAvailable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color iconBg = isAvailable
        ? (isDark ? const Color(0xFF2E7D32) : const Color(0xFFDCEFDC))
        : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5));

    final Color iconColor = isAvailable
        ? (isDark ? Colors.white : const Color(0xFF2E7D32))
        : (isDark ? Colors.grey.shade500 : Colors.grey.shade600);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),

              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(
                Icons.chevron_right,
                color: isAvailable
                    ? theme.colorScheme.onSurface.withAlpha(153)
                    : theme.colorScheme.onSurface.withAlpha(60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
