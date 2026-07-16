import 'package:flutter/material.dart';
import '../theme/revosilium_theme.dart';
import '../models/chat_message.dart';

/// Bulle de message néomorphique premium
class MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final VoidCallback? onReact;

  const MessageBubble({super.key, required this.msg, this.onReact});

  static const List<String> _quickReactions = ['🔥', '❤️', '👍', '😂', '😮', '💯'];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: w * 0.75),
        child: Column(
          crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: onReact,
              child: AnimatedContainer(
                duration: R.animFast,
                padding: EdgeInsets.all(msg.type == MessageType.voice ? 10 : 14),
                decoration: _bubbleDecoration(),
                child: _buildContent(),
              ),
            ),
            if (msg.reactions != null && msg.reactions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _buildReactions(),
              ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _bubbleDecoration() {
    if (msg.type == MessageType.system) {
      return BoxDecoration(
        color: R.pri.withOpacity(0.05),
        borderRadius: BorderRadius.circular(R.rFull),
        border: Border.all(color: R.pri.withOpacity(0.1)),
      );
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: msg.isMe
            ? [R.pri.withOpacity(0.1), R.pri.withOpacity(0.04)]
            : [R.srfAlt, R.srf],
      ),
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(22),
        topRight: const Radius.circular(22),
        bottomLeft: Radius.circular(msg.isMe ? 22 : 8),
        bottomRight: Radius.circular(msg.isMe ? 8 : 22),
      ),
      border: Border.all(
        color: msg.isMe
            ? R.pri.withOpacity(0.15)
            : Colors.white.withOpacity(0.04),
      ),
      boxShadow: [
        BoxShadow(
          color: msg.isMe
              ? R.pri.withOpacity(0.06)
              : Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (msg.type) {
      case MessageType.text:
        return _buildTextContent();
      case MessageType.file:
        return _buildFileContent();
      case MessageType.voice:
        return _buildVoiceContent();
      case MessageType.system:
        return _buildSystemContent();
    }
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (msg.ephemeral)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, size: 10, color: R.warn.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text('ÉPHÉMÈRE', style: TextStyle(
                  color: R.warn.withOpacity(0.7),
                  fontSize: 9,
                  letterSpacing: 2,
                )),
              ],
            ),
          ),
        Text(
          msg.text ?? '',
          style: R.body.copyWith(
            color: msg.isMe ? R.priL : R.txt,
            fontSize: 14.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: R.txt2.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
            ),
            if (msg.isMe) ...[
              const SizedBox(width: 4),
              _statusIcon(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFileContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: R.pri.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.attach_file, color: R.pri, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.fileName ?? 'Fichier',
              style: R.body.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              msg.fileSize != null ? _formatSize(msg.fileSize!) : '',
              style: R.monoSm,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoiceContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: R.gradientPrimary,
            boxShadow: R.shadowGlow(blur: 10, opacity: 0.2),
          ),
          child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF0A0A0A), size: 24),
        ),
        const SizedBox(width: 12),
        ...List.generate(7, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Container(
            width: 3,
            height: 8.0 + (i % 3) * 6.0,
            decoration: BoxDecoration(
              color: R.pri.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
        const SizedBox(width: 10),
        Text(
          msg.voiceDuration != null
              ? '${msg.voiceDuration}s'
              : '--:--',
          style: R.monoSm,
        ),
      ],
    );
  }

  Widget _buildSystemContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        msg.text ?? '',
        style: TextStyle(
          color: R.pri.withOpacity(0.6),
          fontSize: 10,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildReactions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: R.srfAlt,
        borderRadius: BorderRadius.circular(R.rFull),
        border: Border.all(color: R.pri.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: msg.reactions!.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Text('${e.key} ${e.value > 1 ? e.value : ''}',
            style: const TextStyle(fontSize: 13),
          ),
        )).toList(),
      ),
    );
  }

  Widget _statusIcon() {
    switch (msg.status) {
      case MessageStatus.sending:
        return Icon(Icons.access_time, size: 10, color: R.txt2.withOpacity(0.5));
      case MessageStatus.sent:
        return Icon(Icons.check, size: 12, color: R.txt2.withOpacity(0.5));
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 12, color: R.txt2.withOpacity(0.5));
      case MessageStatus.seen:
        return Icon(Icons.done_all, size: 12, color: R.pri);
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 12, color: R.err);
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class ReactionBar extends StatelessWidget {
  final void Function(String reaction) onSelect;

  const ReactionBar({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: R.srfAlt,
        borderRadius: BorderRadius.circular(R.rFull),
        border: Border.all(color: R.pri.withOpacity(0.15)),
        boxShadow: R.shadowElevated,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: MessageBubble._quickReactions.map((e) {
          return GestureDetector(
            onTap: () => onSelect(e),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(e, style: const TextStyle(fontSize: 22)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
