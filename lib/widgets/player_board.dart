import 'package:flutter/material.dart';
import '../core/models/player_model.dart';
import '../core/enums/game_enums.dart';
import '../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  Gradient? _getBoardGradient() {
    if (!player.isAlive) return null;
    if (isCurrentTurn) {
      return const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF8B5A2B), Color(0xFF4A2F13)],
      );
    }
    if (isTargetable) {
      return LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppTheme.bloodRed.withOpacity(0.4),
          const Color(0xFF3D2317).withOpacity(0.6),
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF6E4720), Color(0xFF3D2317)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: player.isAlive ? null : Colors.black87,
          gradient: _getBoardGradient(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(),
            width: isCurrentTurn || isTargetable ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            if (isCurrentTurn)
              BoxShadow(
                color: AppTheme.goldAccent.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tên + Role indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ⭐ Sheriff luôn lộ role
                    if (player.role == Role.sheriff)
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF8B7355),
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Color(0xFF2C1810),
                          size: 10,
                        ),
                      ),
                    Flexible(
                      child: Text(
                        player.name,
                        style: TextStyle(
                          color: player.isAlive ? AppTheme.goldAccent : Colors.white30,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Nhân vật
                Text(
                  player.character.displayName,
                  style: const TextStyle(
                    color: AppTheme.goldDim,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 6),

                // HP tokens (Bullets)
                _HpBar(hp: player.hp, maxHp: player.maxHp),

                const SizedBox(height: 6),

                // Số bài trên tay + trang bị
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _InfoChip(
                      icon: Icons.style,
                      value: '${player.hand.length}',
                      color: AppTheme.parchment,
                    ),
                    const SizedBox(width: 6),
                    if (player.equipment.isNotEmpty)
                      _InfoChip(
                        icon: Icons.shield,
                        value: '${player.equipment.length}',
                        color: Colors.greenAccent,
                      ),
                  ],
                ),
              ],
            ),

            // Jail Overlay
            if (player.isInJail && player.isAlive)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 4 Jail bars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) => Container(
                          width: 3,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade400.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 1,
                                offset: const Offset(1, 0),
                              ),
                            ],
                          ),
                        )),
                      ),
                      // Prominent brass padlock in the center
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC5A059),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF8B7355),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF2C1810),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ).animate(target: isTargetable ? 1 : 0)
       .shake(hz: 4, curve: Curves.easeInOutCubic, duration: 300.ms)
       .tint(color: AppTheme.bloodRed.withOpacity(0.3), duration: 200.ms),
    );
  }

  Color _getBorderColor() {
    if (!player.isAlive) return Colors.white12;
    if (isCurrentTurn) return AppTheme.goldAccent;
    if (isTargetable) return AppTheme.bloodRed;
    return AppTheme.woodHighlight;
  }
}

// Thanh HP bằng viên đạn
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
          width: 6,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: filled ? AppTheme.goldAccent : Colors.transparent,
            border: Border.all(
              color: filled ? AppTheme.goldAccent : AppTheme.goldDim.withOpacity(0.5),
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