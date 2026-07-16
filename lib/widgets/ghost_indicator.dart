import 'package:flutter/material.dart';
import '../theme/revosilium_theme.dart';

/// Indicateur de mode Ghost (DTMF furtif)
class GhostIndicator extends StatefulWidget {
  final bool active;
  final VoidCallback? onTap;

  const GhostIndicator({
    super.key,
    required this.active,
    this.onTap,
  });

  @override
  State<GhostIndicator> createState() => _GhostIndicatorState();
}

class _GhostIndicatorState extends State<GhostIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: R.animFast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: widget.active
              ? R.ghost.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(R.rFull),
          border: Border.all(
            color: widget.active
                ? R.ghost.withOpacity(0.3)
                : R.txt2.withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) {
                return Opacity(
                  opacity: widget.active ? 1.0 : 0.4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.active
                          ? R.ghost.withOpacity(0.4 + _pulseCtrl.value * 0.6)
                          : R.txt2.withOpacity(0.3),
                      boxShadow: widget.active
                          ? [
                              BoxShadow(
                                color: R.ghost.withOpacity(0.3 * _pulseCtrl.value),
                                blurRadius: 6,
                              ),
                            ]
                          : [],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              widget.active ? '👻 GHOST ON' : '👻 GHOST',
              style: TextStyle(
                color: widget.active ? R.ghost : R.txt2,
                fontSize: 9,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
