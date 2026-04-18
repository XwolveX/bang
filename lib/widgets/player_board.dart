import 'package:flutter/material.dart';
import '../core/models/player_model.dart';
import '../core/enums/game_enums.dart';

class PlayerBoard extends StatelessWidget {
  final PlayerModel player;
  final bool isCurrentTurn;  // Đang đến lượt không?
  final bool isTargetable;   // Có thể chọn làm mục tiêu không?
  final VoidCallback? onTap;

  const PlayerBoard({
    super.key,
    required this.player,
    this.isCurrentTurn = false,
    this.isTargetable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getBoardColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(),
            width: isCurrentTurn || isTargetable ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tên + Role indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ⭐ Sheriff luôn lộ role
                if (player.role == Role.sheriff)
                  const Icon(Icons.star, color: Color(0xFFD4AF37), size: 12),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    player.name,
                    style: TextStyle(
                      color: player.isAlive ? Colors.white : Colors.white30,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Nhân vật
            Text(
              player.character.displayName,
              style: const TextStyle(
                color: Color(0xFF8B7355),
                fontSize: 9,
              ),
            ),

            const SizedBox(height: 6),

            // HP tokens
            _HpBar(hp: player.hp, maxHp: player.maxHp),

            const SizedBox(height: 4),

            // Số bài trên tay + trang bị
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _InfoChip(
                  icon: Icons.style,
                  value: '${player.hand.length}',
                  color: Colors.white54,
                ),
                const SizedBox(width: 4),
                if (player.equipment.isNotEmpty)
                  _InfoChip(
                    icon: Icons.shield,
                    value: '${player.equipment.length}',
                    color: const Color(0xFF4CAF50),
                  ),
                if (player.isInJail)
                  const Icon(Icons.lock, color: Colors.red, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBoardColor() {
    if (!player.isAlive) return const Color(0xFF1A1A1A);
    if (isCurrentTurn) return const Color(0xFF3D2317);
    if (isTargetable) return const Color(0xFF2D1A0E);
    return const Color(0xFF2C1810);
  }

  Color _getBorderColor() {
    if (!player.isAlive) return Colors.white12;
    if (isCurrentTurn) return const Color(0xFFD4AF37);
    if (isTargetable) return Colors.redAccent;
    return Colors.white24;
  }
}

// Thanh HP
class _HpBar extends StatelessWidget {
  final int hp;
  final int maxHp;

  const _HpBar({required this.hp, required this.maxHp});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxHp, (index) {
        final filled = index < hp;
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? Colors.redAccent : Colors.white12,
            border: Border.all(
              color: filled ? Colors.red : Colors.white24,
              width: 1,
            ),
          ),
        );
      }),
    );
  }
}

// Chip thông tin nhỏ
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 2),
        Text(value, style: TextStyle(color: color, fontSize: 10)),
      ],
    );
  }
}