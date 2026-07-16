import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/revosilium_theme.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';
import '../models/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/particle_background.dart';

class ChatScreen extends StatefulWidget {
  final ChatService svc;
  final StorageService storage;
  const ChatScreen({super.key, required this.svc, required this.storage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _msgs = [];
  StreamSubscription<ChatMessage>? _sub;
  StreamSubscription<bool>? _connSub;
  StreamSubscription<bool>? _typingSub;
  bool _connected = false;
  bool _peerTyping = false;
  bool _showReactionBar = false;
  int? _reactingToIndex;
  Timer? _typingTimer;
  bool _isTyping = false;

  late final AnimationController _pulseCtrl;
  late final AnimationController _slideCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: R.animMed,
    );

    _connected = widget.svc.connected;
    _loadHistory();

    _sub = widget.svc.messages.listen(_onMsg);
    _connSub = widget.svc.connStatus.listen((c) {
      if (mounted) setState(() => _connected = c);
    });
    _typingSub = widget.svc.typingStatus.listen((t) {
      if (mounted) setState(() => _peerTyping = t);
    });
  }

  void _loadHistory() {
    final peer = widget.svc.peerIp;
    if (peer.isNotEmpty) {
      final history = widget.storage.loadMessages(peer);
      if (history.isNotEmpty) {
        setState(() => _msgs.addAll(history));
        _scrollDown();
      }
    }
  }

  void _onMsg(ChatMessage m) {
    if (!mounted) return;
    setState(() => _msgs.add(m));
    _scrollDown();
    final peer = widget.svc.peerIp;
    if (peer.isNotEmpty) {
      widget.storage.saveMessages(peer, _msgs);
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: R.animFast,
          curve: R.curveSmooth,
        );
      }
    });
  }

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    widget.svc.send(t);
    _ctrl.clear();
    setState(() => _isTyping = false);
    widget.svc.sendTyping(false);
    HapticFeedback.lightImpact();
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTyping) {
      setState(() => _isTyping = true);
      widget.svc.sendTyping(true);
    } else if (text.isEmpty && _isTyping) {
      setState(() => _isTyping = false);
      widget.svc.sendTyping(false);
    }

    _typingTimer?.cancel();
    if (text.isNotEmpty) {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isTyping = false);
          widget.svc.sendTyping(false);
        }
      });
    }
  }

  void _onReact(String emoji) {
    setState(() => _showReactionBar = false);
    if (_reactingToIndex != null && _reactingToIndex! < _msgs.length) {
      final msg = _msgs[_reactingToIndex!];
      final reactions = Map<String, int>.from(msg.reactions ?? {});
      reactions[emoji] = (reactions[emoji] ?? 0) + 1;

      _msgs[_reactingToIndex!] = msg.copyWith(reactions: reactions);
      widget.svc.sendReaction(msg.id, emoji);
      HapticFeedback.selectionClick();
    }
    _reactingToIndex = null;
  }

  void _sendFile() {
    HapticFeedback.mediumImpact();
    widget.svc.sendFile('document_secret.pdf', 2048576);
  }

  void _sendVoice() {
    HapticFeedback.mediumImpact();
    final duration = Random().nextInt(15) + 3;
    widget.svc.sendVoice(duration);
  }

  void _sendPhantom() {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhantomSheet(chatService: widget.svc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.bg,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _msgs.isEmpty
                ? _buildEmptyState()
                : GestureDetector(
                    onTap: () {
                      if (_showReactionBar) {
                        setState(() => _showReactionBar = false);
                      }
                    },
                    child: Stack(
                      children: [
                        ListView.builder(
                          controller: _scroll,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          itemCount: _msgs.length,
                          itemBuilder: (_, i) {
                            return GestureDetector(
                              onLongPress: () {
                                HapticFeedback.mediumImpact();
                                setState(() {
                                  _reactingToIndex = i;
                                  _showReactionBar = true;
                                });
                              },
                              child: MessageBubble(
                                msg: _msgs[i],
                                onReact: () {
                                  setState(() {
                                    _reactingToIndex = i;
                                    _showReactionBar = true;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        if (_peerTyping)
                          Positioned(
                            bottom: 8,
                            left: 16,
                            child: _typingIndicator(),
                          ),
                      ],
                    ),
                  ),
          ),
          if (_showReactionBar)
            ReactionBarOverlay(onSelect: _onReact, onClose: () {
              setState(() => _showReactionBar = false);
            }),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
        left: 4,
        right: 12,
      ),
      decoration: BoxDecoration(
        color: R.srf.withOpacity(0.6),
        border: Border(
          bottom: BorderSide(color: R.pri.withOpacity(0.06)),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: R.pri, size: 18),
              onPressed: () {
                widget.svc.disconnect();
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) {
                          return AnimatedContainer(
                            duration: R.animFast,
                            width: _connected ? 20 + _pulseCtrl.value * 8 : 10,
                            height: _connected ? 20 + _pulseCtrl.value * 8 : 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (_connected ? R.pri : R.txt2)
                                  .withOpacity(_connected ? 0.1 * _pulseCtrl.value : 0.3),
                            ),
                          );
                        },
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _connected ? R.pri : R.txt2,
                          boxShadow: _connected
                              ? [BoxShadow(color: R.pri.withOpacity(0.5), blurRadius: 8)]
                              : [],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.svc.peerIp,
                        style: R.monoMd.copyWith(fontSize: 13),
                      ),
                      Text(
                        _connected
                            ? (_peerTyping ? 'en train d\'écrire...' : 'CONNECTÉ')
                            : 'RECONNEXION...',
                        style: TextStyle(
                          color: _connected
                              ? (_peerTyping ? R.pri : R.pri.withOpacity(0.5))
                              : R.txt2.withOpacity(0.5),
                          fontSize: 9,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildHeaderAction(Icons.sms_rounded, _sendPhantom),
            const SizedBox(width: 4),
            _buildHeaderAction(Icons.attach_file_rounded, _sendFile),
            const SizedBox(width: 4),
            _buildHeaderAction(Icons.mic_rounded, _sendVoice),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: R.pri.withOpacity(0.05),
          border: Border.all(color: R.pri.withOpacity(0.08)),
        ),
        child: Icon(icon, color: R.pri.withOpacity(0.6), size: R.iconSm),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ParticleBackground(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          builder: (_, v, __) {
            return Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - v)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            R.pri.withOpacity(0.06),
                            R.pri.withOpacity(0.02),
                          ],
                        ),
                        border: Border.all(
                          color: R.pri.withOpacity(0.15),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 32,
                        color: R.pri.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'CANAL SÉCURISÉ ÉTABLI',
                      style: TextStyle(
                        color: R.pri.withOpacity(0.4),
                        fontSize: 11,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Messages chiffrés de bout en bout\nAES-256 · P2P · Zéro trace',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: R.txt2.withOpacity(0.3),
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: R.animFast,
      builder: (_, v, __) {
        return Opacity(
          opacity: v,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: R.srfAlt,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: R.pri.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'En train d\'écrire',
                  style: TextStyle(
                    color: R.pri.withOpacity(0.5),
                    fontSize: 10,
                    letterSpacing: 1,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 6),
                ...List.generate(3, (i) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + i * 150),
                    builder: (_, p, __) {
                      return Container(
                        width: 4,
                        height: 4 + p * 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: R.pri.withOpacity(0.3 + p * 0.4),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        10,
        6,
        10,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: R.srf.withOpacity(0.6),
        border: Border(
          top: BorderSide(color: R.pri.withOpacity(0.06)),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                setState(() => _showReactionBar = !_showReactionBar);
              },
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _showReactionBar
                      ? R.pri.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.emoji_emotions_outlined,
                  color: _showReactionBar ? R.pri : R.txt2,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: R.bgAlt,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: R.pri.withOpacity(0.06)),
                ),
                child: TextField(
                  controller: _ctrl,
                  onChanged: _onTextChanged,
                  style: R.body.copyWith(fontSize: 14.5),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: R.pri,
                  decoration: InputDecoration(
                    hintText: 'Message sécurisé...',
                    hintStyle: TextStyle(
                      color: R.txt2.withOpacity(0.3),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: AnimatedContainer(
                duration: R.animFast,
                width: 46,
                height: 46,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _ctrl.text.trim().isNotEmpty
                      ? R.gradientPrimary
                      : LinearGradient(
                          colors: [
                            R.txt3.withOpacity(0.3),
                            R.txt3.withOpacity(0.1),
                          ],
                        ),
                  boxShadow: _ctrl.text.trim().isNotEmpty
                      ? R.shadowGlow(blur: 10, opacity: 0.3)
                      : [],
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: _ctrl.text.trim().isNotEmpty
                      ? const Color(0xFF0A0A0A)
                      : R.txt2.withOpacity(0.3),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _sub?.cancel();
    _connSub?.cancel();
    _typingSub?.cancel();
    _pulseCtrl.dispose();
    _slideCtrl.dispose();
    _typingTimer?.cancel();
    widget.svc.disconnect();
    super.dispose();
  }
}

class _PhantomSheet extends StatefulWidget {
  final ChatService chatService;
  const _PhantomSheet({required this.chatService});
  @override
  State<_PhantomSheet> createState() => _PhantomSheetState();
}

class _PhantomSheetState extends State<_PhantomSheet> {
  String? _selectedFilePath;
  List<String>? _smsMessages;
  int _smsCount = 0;
  bool _loading = false;

  Future<void> _pickAndPrepare() async {
    setState(() => _loading = true);
    try {
      final messages = await widget.chatService.sendFileViaPhantom(
        '/storage/emulated/0/Download/document.pdf',
      );
      setState(() {
        _smsMessages = messages;
        _smsCount = messages.length;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: R.srf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: R.pri.withOpacity(0.1)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: R.pri.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 24),
              Container(
                width: 40,
                height: 40,
                decoration: R.glowCircle,
                child: const Icon(Icons.sms_rounded, color: R.pri, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BlackBox Phantom', style: R.h2),
                  const SizedBox(height: 2),
                  Text(
                    'Transfert chiffré via SMS · Hors-ligne',
                    style: R.caption.copyWith(letterSpacing: 1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: R.pri),
            )
          else if (_smsMessages == null)
            _buildPickButton()
          else
            _buildSMSPreview(),
        ],
      ),
    );
  }

  Widget _buildPickButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _pickAndPrepare,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: R.pri.withOpacity(0.2),
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            color: R.pri.withOpacity(0.03),
          ),
          child: Column(
            children: [
              const Icon(Icons.file_upload_rounded, color: R.pri, size: 36),
              const SizedBox(height: 10),
              Text('SÉLECTIONNER UN FICHIER', style: R.monoSm),
              const SizedBox(height: 6),
              Text(
                'Max 10 MB · Chiffré AES-256 · Via SMS',
                style: R.caption.copyWith(fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSMSPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: R.cardGlow(c: R.pri, a: 0.1),
        child: Column(
          children: [
            const Icon(Icons.check_circle_rounded, color: R.pri, size: 40),
            const SizedBox(height: 10),
            Text('$_smsCount SMS PRÊTS', style: R.monoMd),
            const SizedBox(height: 6),
            Text(
              'Les SMS doivent être envoyés via l\'app SMS native.\nCopiez-les ou partagez-les un par un.',
              textAlign: TextAlign.center,
              style: R.bodySmall.copyWith(color: R.txt2.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: R.bgAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _smsMessages!.length.clamp(0, 5),
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (_, i) {
                  final sms = _smsMessages![i];
                  final preview = sms.length > 50 ? '${sms.substring(0, 50)}...' : sms;
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: R.pri.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${i + 1}',
                          style: TextStyle(
                            color: R.pri,
                            fontSize: 0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          preview,
                          style: TextStyle(
                            color: R.txt.withOpacity(0.6),
                            fontSize: 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReactionBarOverlay extends StatelessWidget {
  final void Function(String emoji) onSelect;
  final VoidCallback onClose;

  const ReactionBarOverlay({
    super.key,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: R.srfAlt,
                borderRadius: BorderRadius.circular(R.rFull),
                border: Border.all(color: R.pri.withOpacity(0.2)),
                boxShadow: R.shadowElevated,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: ['🔥', '❤️', '👍', '😂', '😮', '💯', '👏', '🚀'].map((e) {
                  return GestureDetector(
                    onTap: () => onSelect(e),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(e, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
