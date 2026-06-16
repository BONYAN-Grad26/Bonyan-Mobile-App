import 'package:flutter/material.dart';

enum MetricVariant { nutrition, health, workout, defaultVariant }
enum TrendDirection { up, down, flat }

class MetricTrend {
  final double value;
  final TrendDirection direction;

  const MetricTrend({required this.value, required this.direction});
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.variant,
    required this.progress,
    this.trend,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final MetricVariant variant;
  final double progress;
  final MetricTrend? trend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color accentColor;
    switch (variant) {
      case MetricVariant.nutrition:
        accentColor = colorScheme.primary;
        break;
      case MetricVariant.health:
        accentColor = colorScheme.secondary;
        break;
      case MetricVariant.workout:
        accentColor = colorScheme.tertiary;
        break;
      default:
        accentColor = colorScheme.primary;
    }

    final bool hasTrend = trend != null;
    final bool isUp = hasTrend && trend?.direction == TrendDirection.up;
    final bool isDown = hasTrend && trend?.direction == TrendDirection.down;
    final int trendValue = hasTrend ? (trend?.value.toInt() ?? 0) : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              if (hasTrend)
                Row(
                  children: [
                    Icon(
                      isUp ? Icons.arrow_upward : isDown ? Icons.arrow_downward : Icons.horizontal_rule,
                      size: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$trendValue%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Text(
                  unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.15),
              borderRadius: BorderRadius.circular(99),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (progress / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}