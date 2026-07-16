import 'package:flutter/material.dart';
import '../theme/revosilium_theme.dart';

/// Widget de progression de transfert animé
class TransferProgress extends StatefulWidget {
  final double progress;
  final String fileName;
  final String status;
  final String? detail;
  final VoidCallback? onCancel;
  final bool isSending;

  const TransferProgress({
    super.key,
    required this.progress,
    required this.fileName,
    required this.status,
    this.detail,
    this.onCancel,
    this.isSending = false,
  });

  @override
  State<TransferProgress> createState() => _TransferProgressState();
}

class _TransferProgressState extends State<TransferProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.progress >= 1.0;
    final isActive = !isComplete;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: R.cardGlow(c: R.pri, a: isActive ? 0.08 : 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) {
                  return Icon(
                    isComplete ? Icons.check_circle_rounded : Icons.sync_rounded,
                    color: isComplete
                        ? R.pri
                        : R.pri.withOpacity(0.6 + _pulseCtrl.value * 0.4),
                    size: 22,
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fileName,
                      style: R.body.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.detail ??
                          '${(widget.progress * 100).toStringAsFixed(0)}% • ${widget.status}',
                      style: TextStyle(
                        color: isComplete
                            ? R.pri.withOpacity(0.7)
                            : R.txt2.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive && widget.onCancel != null)
                GestureDetector(
                  onTap: widget.onCancel,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: R.err.withOpacity(0.1),
                    ),
                    child: Icon(Icons.close_rounded, color: R.err, size: 16),
                  ),
                ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: widget.progress,
                backgroundColor: R.srfAlt,
                color: R.pri,
                minHeight: 3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
