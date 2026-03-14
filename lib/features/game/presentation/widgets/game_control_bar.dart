import 'package:flutter/material.dart';

// ignore_for_file: deprecated_member_use

/// Control bar with game action buttons (Undo, Notes, Hint, Erase)
class GameControlBar extends StatelessWidget {
  const GameControlBar({
    required this.onUndo,
    required this.onToggleNotes,
    required this.onHint,
    required this.onErase,
    this.canUndo = false,
    this.isNotesMode = false,
    this.canUseHint = false,
    this.canErase = false,
    this.hintCount,
    super.key,
  });

  final VoidCallback? onUndo;
  final VoidCallback? onToggleNotes;
  final VoidCallback? onHint;
  final VoidCallback? onErase;
  final bool canUndo;
  final bool isNotesMode;
  final bool canUseHint;
  final bool canErase;
  final int? hintCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            context: context,
            icon: Icons.undo,
            label: 'UNDO',
            onPressed: canUndo ? onUndo : null,
          ),
          _buildControlButton(
            context: context,
            icon: Icons.edit_outlined,
            label: 'NOTES',
            onPressed: onToggleNotes,
            isActive: isNotesMode,
          ),
          _buildControlButton(
            context: context,
            icon: Icons.lightbulb_outline,
            label: 'HINT',
            onPressed: canUseHint ? onHint : null,
            badge: hintCount != null && hintCount! > 0 ? '$hintCount' : null,
          ),
          _buildControlButton(
            context: context,
            icon: Icons.delete_outline,
            label: 'ERASE',
            onPressed: canErase ? onErase : null,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isActive = false,
    String? badge,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = onPressed != null;

    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(icon),
                onPressed: onPressed,
                color: isActive
                    ? colorScheme.primary
                    : (isEnabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.38)),
                iconSize: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? colorScheme.primary
                      : (isEnabled
                          ? colorScheme.onSurface.withOpacity(0.87)
                          : colorScheme.onSurface.withOpacity(0.38)),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (badge != null)
            Positioned(
              top: 0,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
