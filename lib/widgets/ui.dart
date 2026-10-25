import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Signature element: a slim pacing gauge with a gradient fill and a vertical
/// "expected today" marker. The recurring device of the whole app.
class PacingGauge extends StatelessWidget {
  final double spentFraction; // 0..1+
  final double expectedFraction; // 0..1
  final Color color;
  final double height;

  const PacingGauge({
    super.key,
    required this.spentFraction,
    required this.expectedFraction,
    required this.color,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    final track = context.palette.track;
    final fill = spentFraction.clamp(0.0, 1.0);
    final marker = expectedFraction.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return SizedBox(
          height: height,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: track,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fill == 0 ? 0.001 : fill,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.65), color],
                    ),
                    borderRadius: BorderRadius.circular(height),
                  ),
                ),
              ),
              // Expected-today marker tick.
              Positioned(
                left: (marker * w).clamp(0.0, w - 2),
                top: -2,
                bottom: -2,
                child: Container(
                  width: 2.5,
                  decoration: BoxDecoration(
                    color: context.palette.ink,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A pill badge used for status / pacing labels.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool solid;

  const StatusPill(
      {super.key, required this.label, required this.color, this.solid = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: solid ? Colors.white : color,
        ),
      ),
    );
  }
}

/// A large metric display: value in Space Grotesk over a small label.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool big;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: p.muted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: big ? 26 : 18,
            fontWeight: FontWeight.w700,
            height: 1.05,
            color: valueColor ?? p.ink,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// A bordered surface card with consistent padding.
class PanelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const PanelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: card,
    );
  }
}

/// A small "?" affordance that shows a speech-bubble tooltip on tap.
/// Used next to form fields to explain where to pull each value.
class HelpDot extends StatelessWidget {
  final String message;
  const HelpDot(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    if (message.trim().isEmpty) return const SizedBox.shrink();
    final p = context.palette;
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      preferBelow: true,
      decoration: BoxDecoration(
        color: p.ink,
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.5,
        height: 1.4,
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.track,
            shape: BoxShape.circle,
            border: Border.all(color: p.line),
          ),
          child: Icon(Icons.question_mark_rounded, size: 12, color: p.muted),
        ),
      ),
    );
  }
}

/// Small section heading used inside cards / screens.
class SectionHeading extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeading(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        ?trailing,
      ],
    );
  }
}
