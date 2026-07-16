import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/settings.dart';
import '../theme/revosilium_theme.dart';
import '../widgets/ghost_indicator.dart';
import '../widgets/particle_background.dart';

/// Écran de paramètres REVOSILIUM v3
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings _settings = AppSettings();
  final _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordCtrl.text = _settings.blackBoxPassword;
  }

  void _update(void Function() fn) {
    setState(() => fn());
    HapticFeedback.selectionClick();
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _section('🔒 SÉCURITÉ'),
                    _tile(
                      'Mot de passe BlackBox',
                      subtitle: 'Clé de chiffrement AES-256',
                      trailing: SizedBox(
                        width: 140,
                        child: TextField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          style: TextStyle(color: R.txt, fontSize: 12),
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (v) => _settings.blackBoxPassword = v,
                        ),
                      ),
                    ),
                    _switchTile(
                      'Mode Ghost',
                      subtitle: 'Communication furtive DTMF',
                      value: _settings.ghostMode,
                      icon: '👻',
                      onChanged: (v) => _update(() => _settings.ghostMode = v),
                    ),
                    _switchTile(
                      'Effacement automatique',
                      subtitle: 'Shred des traces après transfert',
                      value: _settings.autoWipe,
                      icon: '🧹',
                      onChanged: (v) => _update(() => _settings.autoWipe = v),
                    ),

                    const SizedBox(height: 20),
                    _section('🔔 NOTIFICATIONS'),
                    _switchTile(
                      'Vibrations',
                      subtitle: 'Retour haptique',
                      value: _settings.vibration,
                      icon: '📳',
                      onChanged: (v) => _update(() => _settings.vibration = v),
                    ),
                    _switchTile(
                      'Notifications',
                      subtitle: 'Alertes de transfert',
                      value: _settings.notifications,
                      icon: '🔔',
                      onChanged: (v) => _update(() => _settings.notifications = v),
                    ),

                    const SizedBox(height: 20),
                    _section('⚙️ AVANCÉ'),
                    _tile(
                      'Délai SMS',
                      subtitle: '${_settings.smsDelay}ms entre chaque SMS',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _update(() {
                              if (_settings.smsDelay > 100) _settings.smsDelay -= 100;
                            }),
                            child: Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: R.pri.withOpacity(0.1),
                              ),
                              child: Icon(Icons.remove, color: R.pri, size: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('${_settings.smsDelay}ms',
                                style: R.monoSm),
                          ),
                          GestureDetector(
                            onTap: () => _update(() {
                              if (_settings.smsDelay < 3000) _settings.smsDelay += 100;
                            }),
                            child: Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: R.pri.withOpacity(0.1),
                              ),
                              child: Icon(Icons.add, color: R.pri, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    _section('📱 APPLICATION'),
                    _tile(
                      'Version',
                      subtitle: 'REVOSILIUM v3.0.0',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: R.pri.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('v3.0', style: TextStyle(color: R.pri, fontSize: 10)),
                      ),
                    ),
                    _tile(
                      'Build',
                      subtitle: 'BlackBox Phantom intégré',
                      trailing: const Icon(Icons.check_circle, color: R.ghost, size: 18),
                    ),

                    const SizedBox(height: 30),

                    // Bouton de réinitialisation
                    Center(
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Paramètres réinitialisés'),
                              backgroundColor: R.srfAlt,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Text('RÉINITIALISER',
                            style: TextStyle(
                                color: R.err.withOpacity(0.6),
                                fontSize: 10,
                                letterSpacing: 2)),
                      ),
                    ),
                  ],
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
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: R.pri.withOpacity(0.06),
                border: Border.all(color: R.pri.withOpacity(0.1)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: R.pri, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Text('⚙️ Paramètres', style: R.h2),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: R.caption),
    );
  }

  Widget _tile(String title,
      {String? subtitle, Widget? trailing, String? icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: R.cardNeo,
      child: Row(
        children: [
          if (icon != null) ...[
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: R.body.copyWith(fontSize: 13)),
                if (subtitle != null)
                  Text(subtitle,
                      style: TextStyle(color: R.txt2, fontSize: 10)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _switchTile(String title,
      {String? subtitle,
      required bool value,
      required String icon,
      required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: R.cardNeo,
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: R.body.copyWith(fontSize: 13)),
                if (subtitle != null)
                  Text(subtitle,
                      style: TextStyle(color: R.txt2, fontSize: 10)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: R.pri),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }
}
