import 'package:flutter/material.dart';
import '../theme/revosilium_theme.dart';
import '../services/modem_service.dart';

/// Widget d'affichage du statut du modem
class ModemStatusWidget extends StatefulWidget {
  final ModemService? modemService;

  const ModemStatusWidget({
    super.key,
    this.modemService,
  });

  @override
  State<ModemStatusWidget> createState() => _ModemStatusWidgetState();
}

class _ModemStatusWidgetState extends State<ModemStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(ModemStatus status) {
    switch (status) {
      case ModemStatus.available:
        return R.ghost;
      case ModemStatus.busy:
        return Colors.amber;
      case ModemStatus.error:
        return R.err;
      default:
        return R.txt2;
    }
  }

  String _statusText(ModemStatus status) {
    switch (status) {
      case ModemStatus.available:
        return 'CONNECTÉ';
      case ModemStatus.busy:
        return 'OCCUPÉ';
      case ModemStatus.error:
        return 'ERREUR';
      case ModemStatus.notSupported:
        return 'SIMULATION';
      default:
        return 'INCONNU';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.modemService?.status ?? ModemStatus.unknown;
    final color = _statusColor(status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) {
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.4 + _pulseCtrl.value * 0.6),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3 * _pulseCtrl.value),
                    blurRadius: 6,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        Text(
          _statusText(status),
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 8,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
