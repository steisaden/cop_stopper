import 'package:flutter/material.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/services/emergency_contact_service.dart';

/// Emergency contacts overlay for video recording.
/// Shows list of contacts with individual send buttons.
class ContactsOverlay extends StatefulWidget {
  final EmergencyContactService emergencyService;
  final Function(EmergencyContact)? onContactSent;

  const ContactsOverlay({
    super.key,
    required this.emergencyService,
    this.onContactSent,
  });

  @override
  State<ContactsOverlay> createState() => _ContactsOverlayState();
}

class _ContactsOverlayState extends State<ContactsOverlay> {
  List<EmergencyContact> _contacts = [];
  final Set<String> _sentContacts = {};
  final Set<String> _sendingContacts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await widget.emergencyService.getEmergencyContacts();
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendAlert(EmergencyContact contact) async {
    if (_sentContacts.contains(contact.id) ||
        _sendingContacts.contains(contact.id)) {
      return;
    }

    setState(() => _sendingContacts.add(contact.id));

    try {
      final success = await widget.emergencyService.sendEmergencyNotification(
        message:
            '🚨 EMERGENCY: Recording in progress. Location and monitor link attached.',
        includeLocation: true,
        specificContactIds: [contact.id],
      );

      if (mounted) {
        setState(() {
          _sendingContacts.remove(contact.id);
          if (success) {
            _sentContacts.add(contact.id);
          }
        });
        widget.onContactSent?.call(contact);
      }
    } catch (e) {
      debugPrint('Error sending alert: $e');
      if (mounted) {
        setState(() => _sendingContacts.remove(contact.id));
      }
    }
  }

  Future<void> _sendToAll() async {
    for (final contact in _contacts) {
      if (!_sentContacts.contains(contact.id)) {
        await _sendAlert(contact);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
            color: AppColors.glassPrimary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_contacts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add,
              color: Colors.white.withOpacity(0.5),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No emergency contacts',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add contacts in Settings',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Send to all button
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _sentContacts.length == _contacts.length ? null : _sendToAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.glassRecording,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.send, size: 18),
              label: Text(
                _sentContacts.length == _contacts.length
                    ? 'ALL SENT ✓'
                    : 'SEND TO ALL',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),

        const Divider(color: AppColors.glassCardBorder, height: 1),

        // Contact list
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _contacts.length,
            itemBuilder: (context, index) =>
                _buildContactTile(_contacts[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile(EmergencyContact contact) {
    final isSent = _sentContacts.contains(contact.id);
    final isSending = _sendingContacts.contains(contact.id);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: isSent
            ? AppColors.glassSuccess.withOpacity(0.2)
            : AppColors.glassPrimary.withOpacity(0.2),
        child: Text(
          contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: isSent ? AppColors.glassSuccess : AppColors.glassPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      title: Text(
        contact.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        contact.phoneNumber,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
      trailing: SizedBox(
        width: 70,
        height: 32,
        child: ElevatedButton(
          onPressed: isSent ? null : () => _sendAlert(contact),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSent ? AppColors.glassSuccess : AppColors.glassRecording,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isSending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isSent ? 'Sent' : 'Send',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
