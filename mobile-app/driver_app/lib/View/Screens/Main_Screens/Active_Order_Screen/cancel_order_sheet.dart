import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Cancel reasons
// ─────────────────────────────────────────────────────────────────────────────
class CancelReason {
  final String id;
  final String label;
  final String description;

  const CancelReason({
    required this.id,
    required this.label,
    required this.description,
  });
}

const List<CancelReason> kCancelReasons = [
  CancelReason(
    id: 'restaurant_closed',
    label: 'Restaurant fermé',
    description: 'Le restaurant est fermé ou n\'accepte plus de commandes',
  ),
  CancelReason(
    id: 'too_far',
    label: 'Distance trop élevée',
    description: 'La destination est hors de ma zone de livraison',
  ),
  CancelReason(
    id: 'vehicle_issue',
    label: 'Problème de véhicule',
    description: 'Panne, crevaison ou problème mécanique',
  ),
  CancelReason(
    id: 'personal_emergency',
    label: 'Urgence personnelle',
    description: 'Situation d\'urgence qui nécessite mon attention immédiate',
  ),
  CancelReason(
    id: 'other',
    label: 'Autre raison',
    description: 'Ma raison n\'est pas dans la liste ci-dessus',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Sheet widget
// ─────────────────────────────────────────────────────────────────────────────
class CancelOrderSheet extends StatefulWidget {
  /// Called when the driver confirms the cancellation.
  /// Receives the selected reason id + optional note.
  final void Function(String reasonId, String? note) onConfirm;
  final VoidCallback onDismiss;

  const CancelOrderSheet({
    Key? key,
    required this.onConfirm,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<CancelOrderSheet> {
  String? _selectedId;
  final TextEditingController _noteCtrl = TextEditingController();
  bool _showNote = false;

  static const Color _red = Color(0xFFE8000E);

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _selectReason(String id) {
    setState(() {
      _selectedId = id;
      _showNote = id == 'other';
    });
  }

  void _confirm() {
    if (_selectedId == null) return;
    final note = _showNote ? _noteCtrl.text.trim() : null;
    widget.onConfirm(_selectedId!, note?.isEmpty == true ? null : note);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle bar ─────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Title ──────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_outlined,
                    color: _red, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Annuler la commande',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                  ),
                  Text(
                    'Sélectionnez une raison',
                    style:
                        TextStyle(fontSize: 13, color: Colors.black45),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Reason list ────────────────────────────────────────
          ...kCancelReasons.map((r) => _ReasonTile(
                reason: r,
                isSelected: _selectedId == r.id,
                onTap: () => _selectReason(r.id),
              )),

          // ── Note field (only for "other") ──────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _showNote
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText:
                            'Décrivez votre raison (optionnel)…',
                        hintStyle: const TextStyle(
                            fontSize: 14, color: Colors.black38),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _red, width: 1.5),
                        ),
                        counterStyle: const TextStyle(
                            fontSize: 11, color: Colors.black38),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),

          // ── Action buttons ─────────────────────────────────────
          Row(
            children: [
              // Keep order
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onDismiss,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Garder',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              // Confirm cancel
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedId == null ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Confirmer',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single reason tile
// ─────────────────────────────────────────────────────────────────────────────
class _ReasonTile extends StatelessWidget {
  final CancelReason reason;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonTile({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _red = Color(0xFFE8000E);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _red.withOpacity(0.06) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _red : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Radio dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _red : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? _red : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reason.description,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: show the sheet
// ─────────────────────────────────────────────────────────────────────────────
Future<void> showCancelOrderSheet(
  BuildContext context, {
  required void Function(String reasonId, String? note) onConfirm,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CancelOrderSheet(
      onConfirm: (id, note) {
        Navigator.of(context).pop();
        onConfirm(id, note);
      },
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );
}