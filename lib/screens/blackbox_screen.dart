import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../services/blackbox_service.dart';
import '../services/modem_service.dart';
import '../models/transfer.dart';
import '../theme/revosilium_theme.dart';
import '../widgets/transfer_progress.dart';
import '../widgets/ghost_indicator.dart';
import '../widgets/particle_background.dart';

/// Écran BlackBox Phantom — Transfert de fichiers via SMS/Ghost
class BlackBoxScreen extends StatefulWidget {
  const BlackBoxScreen({super.key});

  @override
  State<BlackBoxScreen> createState() => _BlackBoxScreenState();
}

class _BlackBoxScreenState extends State<BlackBoxScreen>
    with TickerProviderStateMixin {
  final BlackBoxService _bb = BlackBoxService();
  final _phoneCtrl = TextEditingController();
  bool _initialized = false;
  bool _ghostMode = false;
  List<BlackBoxTransfer> _transfers = [];
  List<String> _logs = [];
  String _selectedFile = '';
  String? _selectedFilePath;

  late AnimationController _slideCtrl;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: R.animSlow,
    )..forward();
    _init();
  }

  Future<void> _init() async {
    await _bb.init();
    setState(() => _initialized = true);

    _bb.transfers.listen((t) {
      setState(() {
        final idx = _transfers.indexWhere((e) => e.id == t.id);
        if (idx >= 0) {
          _transfers[idx] = t;
        } else {
          _transfers.add(t);
        }
      });
    });

    _bb.logs.listen((log) {
      setState(() {
        _logs.insert(0, log);
        if (_logs.length > 50) _logs.removeLast();
      });
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first.name;
          _selectedFilePath = result.files.first.path;
        });
      }
    } catch (e) {
      _snack('Erreur: $e', R.err);
    }
  }

  Future<void> _send() async {
    if (_phoneCtrl.text.isEmpty) {
      _snack('Numéro de téléphone requis', R.err);
      return;
    }
    if (_selectedFilePath == null) {
      _snack('Sélectionne un fichier', R.err);
      return;
    }

    try {
      await _bb.sendFile(
        _selectedFilePath!,
        _phoneCtrl.text.trim(),
        mode: _ghostMode ? BlackBoxMode.ghost : BlackBoxMode.sms,
      );
      _snack('📤 Fichier envoyé !', R.pri);
      HapticFeedback.heavyImpact();
    } catch (e) {
      _snack('Erreur: $e', R.err);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: R.bodySmall),
      backgroundColor: R.srfAlt,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.bg,
      body: ParticleBackground(
        child: SafeArea(
          child: Column(
            children: [
              _appBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _statusCard(),
                      const SizedBox(height: 12),
                      _ghostToggle(),
                      const SizedBox(height: 12),
                      _sendCard(),
                      const SizedBox(height: 12),
                      if (_transfers.isNotEmpty) _transfersList(),
                      const SizedBox(height: 12),
                      _logPanel(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: R.srf.withOpacity(0.6),
        border: Border(bottom: BorderSide(color: R.pri.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: R.pri.withOpacity(0.06),
                border: Border.all(color: R.pri.withOpacity(0.1)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: R.pri, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🖤 BlackBox Phantom', style: R.h2),
                Text(
                  'Hors-ligne · AES-256 · SMS/DTMF',
                  style: TextStyle(color: R.txt2.withOpacity(0.4), fontSize: 9),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _initialized
                  ? R.pri.withOpacity(0.08)
                  : R.err.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _initialized
                    ? R.pri.withOpacity(0.2)
                    : R.err.withOpacity(0.2),
              ),
            ),
            child: Text(
              _initialized ? 'PRÊT' : '...',
              style: TextStyle(
                color: _initialized ? R.pri : R.err,
                fontSize: 8,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: R.cardNeo,
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.cell_tower_rounded, color: R.pri, size: 18),
              const SizedBox(width: 10),
              Text('STATUT MODEM', style: R.caption),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _initialized ? R.pri : R.txt3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statItem('📡', 'Voie', _ghostMode ? 'DTMF' : 'SMS'),
              const SizedBox(width: 8),
              _statItem('🔒', 'Chiffrement', 'AES-256'),
              const SizedBox(width: 8),
              _statItem('📦', 'Chunks', '140 chars'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: R.srfAlt,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: R.txt2, fontSize: 8)),
            Text(value,
                style: TextStyle(
                    color: R.pri, fontSize: 9, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _ghostToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => _ghostMode = !_ghostMode);
        HapticFeedback.mediumImpact();
        _snack(_ghostMode ? '👻 Mode Ghost activé' : 'Mode Ghost désactivé',
            _ghostMode ? R.ghost : R.txt2);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: _ghostMode
              ? LinearGradient(colors: [
                  R.ghost.withOpacity(0.1),
                  R.srfAlt,
                ], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          color: _ghostMode ? null : R.srfAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _ghostMode
                ? R.ghost.withOpacity(0.2)
                : Colors.white.withOpacity(0.03),
          ),
        ),
        child: Row(
          children: [
            Text(_ghostMode ? '👻' : '🔇', style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _ghostMode ? 'Mode Ghost Activé' : 'Mode Ghost Désactivé',
                    style: R.body.copyWith(fontSize: 13),
                  ),
                  Text(
                    _ghostMode
                        ? 'Communication invisible par DTMF'
                        : 'Activez pour un canal furtif',
                    style: TextStyle(color: R.txt2, fontSize: 10),
                  ),
                ],
              ),
            ),
            Switch(
              value: _ghostMode,
              onChanged: (_) {},
              activeColor: R.ghost,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sendCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: R.cardGlow(c: R.pri, a: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📤 ENVOYER UN FICHIER', style: R.caption),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            style: R.body,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+33 6 12 34 56 78',
              hintStyle: TextStyle(color: R.txt2.withOpacity(0.3)),
              filled: true,
              fillColor: R.bgAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.phone_rounded, color: R.txt2, size: 18),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: R.bgAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: R.pri.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file_rounded, color: R.pri, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedFile.isEmpty ? 'Sélectionner un fichier' : _selectedFile,
                      style: TextStyle(
                        color: _selectedFile.isEmpty ? R.txt2 : R.txt,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Icon(Icons.folder_open_rounded, color: R.txt2, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _send,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('ENVOYER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: R.pri,
                foregroundColor: const Color(0xFF0A0A0A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transfersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📦 TRANSFERTS', style: R.caption),
        const SizedBox(height: 8),
        ..._transfers.reversed.take(3).map((t) => TransferProgress(
              progress: t.progress,
              fileName: t.fileName,
              status: t.status.name,
              detail: '${t.receivedChunks}/${t.totalChunks} chunks',
              isSending: t.status == TransferStatus.sending,
              onCancel: t.status == TransferStatus.sending
                  ? () => _bb.cancelTransfer(t.id)
                  : null,
            )),
      ],
    );
  }

  Widget _logPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('📋 LOGS', style: R.caption),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _logs.clear()),
              child: Text('EFFACER',
                  style: TextStyle(
                      color: R.txt2, fontSize: 8, letterSpacing: 2)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: R.bgAlt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(8),
            itemCount: _logs.length,
            itemBuilder: (_, i) {
              final log = _logs[i];
              final isErr = log.contains('❌');
              final isOk = log.contains('✅');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(
                  log,
                  style: TextStyle(
                    color: isErr ? R.err : isOk ? R.pri : R.txt2,
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _slideCtrl.dispose();
    _bb.dispose();
    super.dispose();
  }
}
