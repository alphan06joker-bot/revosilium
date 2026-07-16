import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/peer.dart';
import '../core/extensions.dart';
import '../theme/revosilium_theme.dart';
import '../widgets/particle_background.dart';

/// Écran de gestion des contacts REVOSILIUM v3
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with TickerProviderStateMixin {
  final List<Peer> _peers = [];
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ipCtrl = TextEditingController();
  bool _showAdd = false;

  @override
  void initState() {
    super.initState();
    _loadDummyContacts();
  }

  void _loadDummyContacts() {
    _peers.addAll([
      Peer(
        id: '1',
        name: 'Alice',
        phoneNumber: '+33 6 12 34 56 78',
        ipAddress: '192.168.1.42',
        addedAt: DateTime.now().subtract(const Duration(days: 30)),
        isFavorite: true,
        messagesCount: 142,
        lastMessage: DateTime.now().subtract(const Duration(minutes: 5)),
        isOnline: true,
      ),
      Peer(
        id: '2',
        name: 'Bob',
        phoneNumber: '+33 7 98 76 54 32',
        ipAddress: '192.168.1.100',
        addedAt: DateTime.now().subtract(const Duration(days: 15)),
        messagesCount: 67,
        lastMessage: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Peer(
        id: '3',
        name: 'Charlie',
        phoneNumber: '+33 6 55 44 33 22',
        addedAt: DateTime.now().subtract(const Duration(days: 7)),
        messagesCount: 12,
      ),
    ]);
  }

  void _addContact() {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) return;

    setState(() {
      _peers.add(Peer(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        ipAddress: _ipCtrl.text.trim().isEmpty ? null : _ipCtrl.text.trim(),
        addedAt: DateTime.now(),
        isFavorite: false,
        messagesCount: 0,
      ));
      _showAdd = false;
    });

    _nameCtrl.clear();
    _phoneCtrl.clear();
    _ipCtrl.clear();
    HapticFeedback.mediumImpact();
  }

  void _toggleFavorite(String id) {
    setState(() {
      final idx = _peers.indexWhere((p) => p.id == id);
      if (idx >= 0) {
        _peers[idx] = _peers[idx].copyWith(isFavorite: !_peers[idx].isFavorite);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _deleteContact(String id) {
    setState(() => _peers.removeWhere((p) => p.id == id));
    HapticFeedback.mediumImpact();
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
                child: _peers.isEmpty ? _emptyState() : _list(),
              ),
              if (_showAdd) _addPanel(),
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
        right: 8,
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
                Text('👥 Contacts', style: R.h2),
                Text('${_peers.length} contacts', style: TextStyle(
                  color: R.txt2.withOpacity(0.4), fontSize: 9)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showAdd = !_showAdd),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _showAdd ? R.gradientPrimary : null,
                color: _showAdd ? null : R.pri.withOpacity(0.06),
                border: Border.all(color: R.pri.withOpacity(0.1)),
              ),
              child: Icon(
                _showAdd ? Icons.close_rounded : Icons.person_add_rounded,
                color: _showAdd ? const Color(0xFF0A0A0A) : R.pri,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list() {
    final favorites = _peers.where((p) => p.isFavorite).toList();
    final others = _peers.where((p) => !p.isFavorite).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (favorites.isNotEmpty) ...[
          Text('⭐ FAVORIS', style: R.caption),
          const SizedBox(height: 8),
          ...favorites.map(_peerTile),
          const SizedBox(height: 16),
        ],
        if (others.isNotEmpty) ...[
          Text('📋 TOUS LES CONTACTS', style: R.caption),
          const SizedBox(height: 8),
          ...others.map(_peerTile),
        ],
      ],
    );
  }

  Widget _peerTile(Peer peer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: R.cardNeo,
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      R.pri.withOpacity(0.2),
                      R.pri.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(color: R.pri.withOpacity(0.15)),
                ),
                child: Center(
                  child: Text(
                    peer.name[0].toUpperCase(),
                    style: TextStyle(
                      color: R.pri,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (peer.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: R.ghost,
                      border: Border.all(color: R.bg, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(peer.name, style: R.body.copyWith(fontSize: 14)),
                    if (peer.isFavorite) ...[
                      const SizedBox(width: 4),
                      const Text('⭐', style: TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${peer.phoneNumber}${peer.lastMessage != null ? ' · ${peer.lastMessage!.timeAgo}' : ''}',
                  style: TextStyle(color: R.txt2, fontSize: 10),
                ),
              ],
            ),
          ),
          // Actions
          GestureDetector(
            onTap: () => _toggleFavorite(peer.id),
            child: Icon(
              peer.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: peer.isFavorite ? R.amber : R.txt2,
              size: 22,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _deleteContact(peer.id),
            child: Icon(Icons.delete_outline_rounded, color: R.txt2, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [R.pri.withOpacity(0.06), R.pri.withOpacity(0.02)],
              ),
              border: Border.all(color: R.pri.withOpacity(0.15)),
            ),
            child: Icon(Icons.people_outline_rounded, size: 30, color: R.pri.withOpacity(0.3)),
          ),
          const SizedBox(height: 16),
          Text('AUCUN CONTACT', style: TextStyle(
            color: R.pri.withOpacity(0.3), fontSize: 11, letterSpacing: 3)),
          const SizedBox(height: 6),
          Text('Ajoutez votre premier contact', style: TextStyle(
            color: R.txt2.withOpacity(0.3), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _addPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: R.srf,
        border: Border(top: BorderSide(color: R.pri.withOpacity(0.08))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _field('Nom', _nameCtrl, Icons.person_outline_rounded),
          const SizedBox(height: 8),
          _field('Téléphone', _phoneCtrl, Icons.phone_rounded, TextInputType.phone),
          const SizedBox(height: 8),
          _field('IP (optionnel)', _ipCtrl, Icons.language_rounded),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _addContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: R.pri,
                foregroundColor: const Color(0xFF0A0A0A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('AJOUTER', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String hint, TextEditingController ctrl, IconData icon,
      [TextInputType? keyboardType]) {
    return TextField(
      controller: ctrl,
      style: R.body,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: R.txt2.withOpacity(0.3)),
        filled: true,
        fillColor: R.bgAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: R.txt2, size: 18),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _ipCtrl.dispose();
    super.dispose();
  }
}
