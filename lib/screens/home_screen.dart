import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/revosilium_theme.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';
import '../widgets/revosilium_button.dart';
import '../widgets/particle_background.dart';
import 'chat_screen.dart';
import 'blackbox_screen.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final _svc = ChatService();
  final _storage = StorageService();
  final _ipC = TextEditingController();
  final _secretC = TextEditingController();

  String _myIp = 'Détection...';
  String? _inviter;
  bool _loading = false;
  bool _showQR = false;
  bool _showSecret = false;
  List<String> _recentPeers = [];

  late final AnimationController _fadeCtrl;
  late final AnimationController _cardCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: R.animGlacial,
    )..forward();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _boot();
  }

  Future<void> _boot() async {
    await _storage.init();
    await _svc.init();
    if (!mounted) return;
    setState(() {
      _myIp = _svc.myIp;
      _recentPeers = _storage.loadPeers();
    });
    _svc.inviteRequests.listen((ip) {
      if (mounted) {
        setState(() => _inviter = ip);
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _invite() async {
    final ip = _ipC.text.trim();
    if (ip.isEmpty) return;
    setState(() => _loading = true);
    HapticFeedback.mediumImpact();

    final ok = await _svc.invite(ip);
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      await _storage.savePeer(ip);
      Navigator.push(context, _route());
    } else {
      _showSnack('Connexion échouée. Vérifie l\'IP.', R.err);
    }
  }

  void _accept() async {
    HapticFeedback.mediumImpact();
    await _svc.accept();
    if (!mounted) return;
    if (_inviter != null) await _storage.savePeer(_inviter!);
    setState(() => _inviter = null);
    Navigator.push(context, _route());
  }

  void _refuse() {
    HapticFeedback.lightImpact();
    _svc.refuse();
    setState(() => _inviter = null);
  }

  void _quickConnect(String ip) {
    _ipC.text = ip;
    _invite();
  }

  MaterialPageRoute _route() =>
      MaterialPageRoute(builder: (_) => ChatScreen(svc: _svc, storage: _storage));

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: color, size: 18),
            const SizedBox(width: 10),
            Text(msg, style: R.bodySmall),
          ],
        ),
        backgroundColor: R.srfAlt,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: R.bg,
      body: ParticleBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeCtrl,
            builder: (_, __) {
              return Opacity(
                opacity: _fadeCtrl.value,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(size.width * 0.06),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.04),
                      _buildHeader(),
                      SizedBox(height: size.height * 0.04),
                      _buildIPCard(),
                      const SizedBox(height: 20),
                      if (_inviter != null) _buildInviteCard(),
                      if (_inviter != null) const SizedBox(height: 20),
                      _buildInviteForm(),
                      if (_recentPeers.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildRecentPeers(),
                      ],
                      const SizedBox(height: 20),
                      _buildBottomActions(),
                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: R.curveSpring,
      builder: (_, v, __) {
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - v)),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1800),
                  builder: (_, r, __) {
                    return Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            R.pri.withOpacity(0.08 + r * 0.05),
                            R.pri.withOpacity(0.02),
                          ],
                        ),
                        border: Border.all(
                          color: R.pri.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: R.shadowGlow(blur: 25, opacity: 0.18),
                      ),
                      child: Center(
                        child: Text(
                          'R',
                          style: TextStyle(
                            color: R.pri,
                            fontSize: 32,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) => R.gradientPrimary.createShader(bounds),
                  child: const Text('REVOSILIUM', style: R.h1),
                ),
                const SizedBox(height: 6),
                Text(
                  'P2P · CHIFFRÉ · INTRAÇABLE',
                  style: TextStyle(
                    color: R.txt2.withOpacity(0.4),
                    fontSize: 9,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIPCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (_, v, __) {
        return Opacity(
          opacity: v,
          child: Transform.scale(
            scale: 0.9 + 0.1 * v,
            child: GestureDetector(
              onTap: () {
                setState(() => _showQR = !_showQR);
                if (_showQR) HapticFeedback.mediumImpact();
              },
              child: AnimatedContainer(
                duration: R.animMed,
                width: double.infinity,
                padding: const EdgeInsets.all(R.pad),
                decoration: _showQR
                    ? R.cardGlow(c: R.pri, a: 0.12)
                    : R.cardNeo,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('MON ADRESSE', style: R.caption),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: _myIp));
                                HapticFeedback.selectionClick();
                                _showSnack('IP copiée !', R.pri);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: R.pri.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.copy, color: R.pri, size: 16),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() => _showQR = !_showQR);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (_showQR ? R.pri : R.txt2).withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.qr_code_2,
                                  color: _showQR ? R.pri : R.txt2,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: R.animMed,
                      child: _showQR
                          ? Column(
                              key: const ValueKey('qr'),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: QrImageView(
                                    data: 'revosilium://$_myIp',
                                    version: QrVersions.auto,
                                    size: 160,
                                    backgroundColor: Colors.white,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: const Color(0xFF050505),
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.square,
                                      color: const Color(0xFF050505),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Scanne pour connecter',
                                  style: TextStyle(
                                    color: R.txt2.withOpacity(0.5),
                                    fontSize: 10,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            )
                          : SelectableText(
                              _myIp,
                              key: const ValueKey('ip'),
                              style: R.monoLg,
                              textAlign: TextAlign.center,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Partage cette adresse avec ton contact',
                      style: TextStyle(
                        color: R.txt2.withOpacity(0.4),
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInviteCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: R.animMed,
      curve: R.curveSpring,
      builder: (_, v, __) {
        return Opacity(
          opacity: v,
          child: Transform.scale(
            scale: 0.8 + 0.2 * v,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(R.pad),
              decoration: R.cardGlow(c: R.pri, a: 0.1),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: R.glowCircle,
                    child: const Icon(Icons.call_received_rounded, color: R.pri, size: 26),
                  ),
                  const SizedBox(height: 14),
                  const Text('INVITATION ENTRANTE', style: R.h2),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: R.pri.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(R.rFull),
                    ),
                    child: Text(
                      _inviter ?? '',
                      style: R.monoMd,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _actionBtn(
                          'REFUSER',
                          R.err,
                          _refuse,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: RevosiliumButton(
                          label: 'ACCEPTER',
                          icon: Icons.check_rounded,
                          onTap: _accept,
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInviteForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(R.pad),
      decoration: R.cardNeo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('INVITER UN CONTACT', style: R.caption),
          const SizedBox(height: 16),
          Focus(
            onFocusChange: (focused) {},
            child: TextField(
              controller: _ipC,
              style: R.body.copyWith(fontSize: 15),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              cursorColor: R.pri,
              decoration: InputDecoration(
                hintText: '192.168.1.X',
                hintStyle: TextStyle(
                  color: R.txt2.withOpacity(0.3),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: R.bgAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(R.rMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(R.rMd),
                  borderSide: BorderSide(color: R.pri.withOpacity(0.3)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                prefixIcon: Icon(Icons.language, color: R.txt2.withOpacity(0.4), size: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),
          RevosiliumButton(
            label: 'INVITER',
            icon: Icons.send_rounded,
            onTap: _loading ? null : _invite,
            loading: _loading,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPeers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text('CONNEXIONS RÉCENTES', style: R.caption),
        ),
        ...(_recentPeers.take(3).map((ip) => GestureDetector(
          onTap: () => _quickConnect(ip),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: R.srfAlt,
              borderRadius: BorderRadius.circular(R.rMd),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: R.pri.withOpacity(0.06),
                  ),
                  child: const Icon(Icons.person_outline, color: R.pri, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ip, style: R.monoMd.copyWith(fontSize: 14)),
                      Text('Appuyer pour reconnecter',
                        style: TextStyle(color: R.txt2.withOpacity(0.4), fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: R.txt2.withOpacity(0.3), size: 18),
              ],
            ),
          ),
        ))),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _actionIcon(Icons.sms_rounded, 'BlackBox', () {
          HapticFeedback.mediumImpact();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BlackBoxScreen()));
        }),
        const SizedBox(width: 14),
        _actionIcon(Icons.people_outline_rounded, 'Contacts', () {
          HapticFeedback.mediumImpact();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactsScreen()));
        }),
        const SizedBox(width: 14),
        _actionIcon(Icons.security_rounded, 'Sécurité', () => _showSecurityDialog()),
        const SizedBox(width: 14),
        _actionIcon(Icons.settings_rounded, 'Paramètres', () {
          HapticFeedback.mediumImpact();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        }),
      ],
    );
  }

  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: R.srfAlt,
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Icon(icon, color: R.txt2.withOpacity(0.5), size: 18),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: R.txt2.withOpacity(0.3), fontSize: 8, letterSpacing: 1)),
        ],
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Icon(Icons.shield, color: R.pri, size: 22),
                const SizedBox(width: 10),
                const Text('SÉCURITÉ', style: R.h2),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: R.cardGlow(c: R.pri, a: 0.06),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Chiffrement AES-256', style: R.body),
                          Icon(Icons.check_circle, color: R.pri, size: 18),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('P2P Direct', style: R.body),
                          Icon(Icons.check_circle, color: R.pri, size: 18),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Zéro Serveur', style: R.body),
                          Icon(Icons.check_circle, color: R.pri, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _secretC,
                  style: R.body,
                  decoration: InputDecoration(
                    hintText: 'Phrase secrète partagée (optionnel)',
                    hintStyle: TextStyle(color: R.txt2.withOpacity(0.3), fontSize: 12),
                    filled: true,
                    fillColor: R.bgAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.vpn_key, color: R.txt2.withOpacity(0.4), size: 18),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('FERMER'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _actionBtn(String label, Color c, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        color: c.withOpacity(0.06),
        borderRadius: BorderRadius.circular(R.rMd),
        border: Border.all(color: c.withOpacity(0.25)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: c,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _cardCtrl.dispose();
    _ipC.dispose();
    _secretC.dispose();
    if (_inviter == null) _svc.dispose();
    super.dispose();
  }
}
