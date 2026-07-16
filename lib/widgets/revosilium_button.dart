import 'package:flutter/material.dart';
import '../theme/revosilium_theme.dart';

/// Bouton néomorphique premium REVOSILIUM
class RevosiliumButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool loading;
  final bool outlined;
  final double? width;
  final double height;

  const RevosiliumButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.color,
    this.loading = false,
    this.outlined = false,
    this.width,
    this.height = 54,
  });

  @override
  State<RevosiliumButton> createState() => _RevosiliumButtonState();
}

class _RevosiliumButtonState extends State<RevosiliumButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: R.animFast,
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? R.pri;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _pulseCtrl.forward();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _pulseCtrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _pulseCtrl.reverse();
      },
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) {
          final scale = 1.0 - (_pressed ? 0.03 : 0.0);
          return Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: R.animFast,
              curve: R.curveSpring,
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.outlined
                    ? null
                    : LinearGradient(
                        colors: [c, c.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: widget.outlined ? Colors.transparent : null,
                borderRadius: BorderRadius.circular(R.rLg),
                border: widget.outlined
                    ? Border.all(color: c.withOpacity(0.4), width: 1.2)
                    : null,
                boxShadow: widget.outlined
                    ? []
                    : [
                        ...R.shadowGlow(
                          blur: _pressed ? 8 : 20,
                          opacity: _pressed ? 0.1 : 0.25,
                        ),
                        BoxShadow(
                          color: c.withOpacity(_pressed ? 0.05 : 0.15),
                          blurRadius: _pressed ? 4 : 10,
                          offset: Offset(0, _pressed ? 2 : 5),
                        ),
                      ],
              ),
              child: Center(
                child: widget.loading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.outlined ? c : const Color(0xFF0A0A0A),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: R.iconSm,
                              color: widget.outlined ? c : const Color(0xFF0A0A0A),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.label,
                            style: R.btn.copyWith(
                              color: widget.outlined ? c : const Color(0xFF0A0A0A),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
