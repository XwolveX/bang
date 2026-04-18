import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/enums/game_enums.dart';
import '../core/models/card_model.dart';
import '../core/models/game_state.dart';
import '../core/models/player_model.dart';
import '../core/services/range_calculator.dart';
import '../providers/game_provider.dart';
import '../widgets/card_widget.dart';
import '../widgets/player_board.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  CardModel? _selectedCard; // Lá bài đang chọn

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    // Game over → hiện kết quả
    if (gameState.phase == GamePhase.gameOver) {
      return _buildGameOver(gameState);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A0F08),
      body: SafeArea(
        child: Column(
          children: [
            // ── Hàng trên: Người chơi đối diện ──
            Expanded(
              flex: 3,
              child: _buildTopPlayers(gameState),
            ),

            // ── Giữa: Bàn chơi (deck, discard, action) ──
            Expanded(
              flex: 4,
              child: _buildGameTable(gameState),
            ),

            // ── Hàng dưới: Bài trên tay người chơi hiện tại ──
            Expanded(
              flex: 3,
              child: _buildHandArea(gameState),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // HÀNG TRÊN — Người chơi đối diện
  // ─────────────────────────────────────────
  Widget _buildTopPlayers(GameState state) {
    // Lấy tất cả player TRỪ currentPlayer
    final otherPlayers = state.players
        .where((p) => p.id != state.currentPlayer.id)
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: otherPlayers.map((player) {
          final canTarget = _selectedCard != null &&
              _selectedCard!.type == CardType.bang &&
              player.isAlive &&
              RangeCalculator.canAttack(
                alivePlayers: state.alivePlayers,
                attacker: state.currentPlayer,
                target: player,
              );

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: PlayerBoard(
                player: player,
                isCurrentTurn: false,
                isTargetable: canTarget,
                onTap: canTarget ? () => _onTargetSelected(player) : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────
  // GIỮA — Bàn chơi
  // ─────────────────────────────────────────
  Widget _buildGameTable(GameState state) {
    return Row(
      children: [
        // Action log bên trái
        Expanded(
          flex: 2,
          child: _buildActionLog(state),
        ),

        // Deck + Discard ở giữa
        Expanded(
          flex: 3,
          child: _buildDeckArea(state),
        ),

        // Info + Actions bên phải
        Expanded(
          flex: 2,
          child: _buildActionButtons(state),
        ),
      ],
    );
  }

  // Action log
  Widget _buildActionLog(GameState state) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1810),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhật ký',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              reverse: true, // Tin mới nhất ở dưới
              itemCount: state.actionLog.length,
              itemBuilder: (context, index) {
                final logIndex =
                    state.actionLog.length - 1 - index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    state.actionLog[logIndex],
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 9,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Deck và Discard
  Widget _buildDeckArea(GameState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Phase indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getPhaseText(state.phase),
            style: const TextStyle(
              color: Color(0xFF2C1810),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Deck
            Column(
              children: [
                const CardBack(),
                const SizedBox(height: 4),
                Text(
                  '${state.deck.length} lá',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 9),
                ),
              ],
            ),

            const SizedBox(width: 24),

            // Discard
            Column(
              children: [
                Container(
                  width: 36,
                  height: 52,
                  decoration: BoxDecoration(
                    color: state.discard.isNotEmpty
                        ? const Color(0xFF3D2317)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: state.discard.isNotEmpty
                          ? Colors.white24
                          : Colors.white12,
                      style: state.discard.isEmpty
                          ? BorderStyle.solid
                          : BorderStyle.solid,
                    ),
                  ),
                  child: state.discard.isNotEmpty
                      ? Center(
                    child: Text(
                      _getCardName(state.discard.last.type),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : const Icon(Icons.add, color: Colors.white12, size: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bỏ bài',
                  style: TextStyle(color: Colors.white54, fontSize: 9),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Lượt của ai
        Text(
          'Lượt: ${state.currentPlayer.name}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Nút hành động
  Widget _buildActionButtons(GameState state) {
    final isMyTurn = true;

    return Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(  // ← thêm dòng này
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          // Nút Rút bài
          if (state.phase == GamePhase.draw)
            _ActionButton(
              label: 'RÚT BÀI',
              icon: Icons.download,
              color: const Color(0xFF4CAF50),
              onTap: isMyTurn
                  ? () => ref.read(gameProvider.notifier).drawCards()
                  : null,
            ),

          // Nút Kết thúc lượt
          if (state.phase == GamePhase.play) ...[
            _ActionButton(
              label: 'KẾT THÚC',
              icon: Icons.skip_next,
              color: const Color(0xFFD4AF37),
              onTap: () {
                setState(() => _selectedCard = null);
                ref.read(gameProvider.notifier).endTurn();
              },
            ),
            const SizedBox(height: 8),
            // Hủy chọn bài
            if (_selectedCard != null)
              _ActionButton(
                label: 'HỦY',
                icon: Icons.close,
                color: Colors.redAccent,
                onTap: () => setState(() => _selectedCard = null),
              ),
          ],

          // Discard phase
          if (state.phase == GamePhase.discard)
            const Text(
              'Chọn bài\nđể bỏ',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 12),

          // Thông tin bài đang chọn
          if (_selectedCard != null)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF3D2317),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: Text(
                'Đã chọn:\n${_getCardName(_selectedCard!.type)}',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
        ),
    );
  }

  // ─────────────────────────────────────────
  // HÀNG DƯỚI — Bài trên tay
  // ─────────────────────────────────────────
  Widget _buildHandArea(GameState state) {
    final currentPlayer = state.currentPlayer;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C1810),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                // ⭐ Nếu là Sheriff
                if (currentPlayer.role == Role.sheriff)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.star,
                        color: Color(0xFFD4AF37), size: 14),
                  ),
                Text(
                  '${currentPlayer.name} — ${currentPlayer.character.displayName}',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // HP hearts
                Row(
                  children: List.generate(currentPlayer.maxHp, (i) {
                    return Icon(
                      Icons.favorite,
                      size: 12,
                      color: i < currentPlayer.hp
                          ? Colors.redAccent
                          : Colors.white12,
                    );
                  }),
                ),
              ],
            ),
          ),
          // Bài trên tay — giữ nguyên
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: currentPlayer.hand.length,
              itemBuilder: (context, index) {
                final card = currentPlayer.hand[index];
                final isSelected = _selectedCard?.id == card.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CardWidget(
                    card: card,
                    isSelected: isSelected,
                    isPlayable: state.phase == GamePhase.play ||
                        state.phase == GamePhase.discard,
                    onTap: () => _onCardTapped(card, state),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // GAME OVER
  // ─────────────────────────────────────────
  Widget _buildGameOver(GameState state) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F08),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              _getWinnerText(state.winner),
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF2C1810),
              ),
              child: const Text('CHƠI LẠI'),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // HANDLERS
  // ─────────────────────────────────────────

  void _onCardTapped(CardModel card, GameState state) {
    if (state.phase == GamePhase.discard) {
      // Discard phase — bỏ bài ngay
      ref.read(gameProvider.notifier).discardCard(card);
      return;
    }

    if (state.phase != GamePhase.play) return;

    // Bài cần chọn mục tiêu
    if (_needsTarget(card.type)) {
      setState(() {
        _selectedCard = _selectedCard?.id == card.id ? null : card;
      });
      return;
    }

    // Bài không cần mục tiêu — đánh ngay
    ref.read(gameProvider.notifier).playCard(card);
    setState(() => _selectedCard = null);
  }

  void _onTargetSelected(PlayerModel target) {
    if (_selectedCard == null) return;
    ref.read(gameProvider.notifier).playCard(
      _selectedCard!,
      targetId: target.id,
    );
    setState(() => _selectedCard = null);
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────

  bool _needsTarget(CardType type) {
    return const {
      CardType.bang,
      CardType.jail,
      CardType.catBalou,
      CardType.panic,
    }.contains(type);
  }

  String _getPhaseText(GamePhase phase) {
    return switch (phase) {
      GamePhase.waiting => 'CHỜ',
      GamePhase.draw    => 'RÚT BÀI',
      GamePhase.play    => 'ĐÁNH BÀI',
      GamePhase.discard => 'BỎ BÀI',
      GamePhase.gameOver => 'KẾT THÚC',
    };
  }

  String _getWinnerText(String? winner) {
    return switch (winner) {
      'sheriff'  => '🌟 CẢNH SÁT THẮNG!',
      'outlaw'   => '💀 TỘI PHẠM THẮNG!',
      'renegade' => '🎭 KẺ PHẢN LOẠN THẮNG!',
      _ => 'KẾT THÚC',
    };
  }

  String _getCardName(CardType type) {
    return switch (type) {
      CardType.bang       => 'BANG!',
      CardType.miss       => 'MISS!',
      CardType.beer       => 'BEER',
      CardType.gatling    => 'GATLING',
      CardType.indians    => 'INDIANS',
      CardType.stagecoach => 'STAGECOACH',
      CardType.wellsFargo => 'WELLS FARGO',
      CardType.catBalou   => 'CAT BALOU',
      CardType.panic      => 'PANIC!',
      CardType.jail       => 'JAIL',
      CardType.dynamite   => 'DYNAMITE',
      CardType.volcanic   => 'VOLCANIC',
      CardType.schofield  => 'SCHOFIELD',
      CardType.remington  => 'REMINGTON',
      CardType.carabine   => 'CARABINE',
      CardType.winchester => 'WINCHESTER',
      CardType.barrel     => 'BARREL',
      CardType.mustang    => 'MUSTANG',
      CardType.scope      => 'SCOPE',
    };
  }
}

// Widget nút hành động
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: onTap != null ? color.withOpacity(0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onTap != null ? color : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: onTap != null ? color : Colors.white30, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: onTap != null ? color : Colors.white30,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}