import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/enums/game_enums.dart';
import '../core/models/card_model.dart';
import '../core/models/game_state.dart';
import '../core/models/player_model.dart';
import '../core/services/character_ability_service.dart';
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
  CardModel? _selectedCard;
  PlayerModel? _panicTarget;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    if (gameState.phase == GamePhase.gameOver) {
      return _buildGameOver(gameState);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A0F08),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(flex: 3, child: _buildTopPlayers(gameState)),
            Expanded(flex: 4, child: _buildGameTable(gameState)),
            Expanded(flex: 3, child: _buildHandArea(gameState)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // TOP PLAYERS
  // ─────────────────────────────────────────
  Widget _buildTopPlayers(GameState state) {
    final otherPlayers = state.players
        .where((p) => p.id != state.currentPlayer.id)
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: otherPlayers.map((player) {
          final canTarget = _selectedCard != null &&
              player.isAlive &&
              _canTargetPlayer(player, state);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: PlayerBoard(
                player: player,
                isCurrentTurn: false,
                isTargetable: canTarget,
                onTap: canTarget ? () => _onTargetSelected(player, state) : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────
  // GAME TABLE
  // ─────────────────────────────────────────
  Widget _buildGameTable(GameState state) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildActionLog(state)),
        Expanded(flex: 3, child: _buildDeckArea(state)),
        Expanded(flex: 2, child: _buildActionButtons(state)),
      ],
    );
  }

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
              reverse: true,
              itemCount: state.actionLog.length,
              itemBuilder: (context, index) {
                final logIndex = state.actionLog.length - 1 - index;
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
                  style: const TextStyle(color: Colors.white54, fontSize: 9),
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
                      : const Icon(
                    Icons.add,
                    color: Colors.white12,
                    size: 16,
                  ),
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

        Text(
          'Lượt: ${state.currentPlayer.name}',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildActionButtons(GameState state) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nút RÚT BÀI
            if (state.phase == GamePhase.draw)
              _ActionButton(
                label: 'RÚT BÀI',
                icon: Icons.download,
                color: const Color(0xFF4CAF50),
                onTap: () => ref.read(gameProvider.notifier).drawCards(),
              ),

            // Nút ĐÁNH BÀI phase
            if (state.phase == GamePhase.play) ...[
              _ActionButton(
                label: 'KẾT THÚC',
                icon: Icons.skip_next,
                color: const Color(0xFFD4AF37),
                onTap: () {
                  setState(() {
                    _selectedCard = null;
                    _panicTarget = null;
                  });
                  ref.read(gameProvider.notifier).endTurn();
                },
              ),
              const SizedBox(height: 8),
              if (_selectedCard != null)
                _ActionButton(
                  label: 'HỦY',
                  icon: Icons.close,
                  color: Colors.redAccent,
                  onTap: () => setState(() {
                    _selectedCard = null;
                    _panicTarget = null;
                  }),
                ),
            ],

            // Discard phase
            if (state.phase == GamePhase.discard)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: const Text(
                  'Chọn bài\nđể bỏ',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 8),

            // Thông tin bài đang chọn
            if (_selectedCard != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D2317),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD4AF37)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Đã chọn:',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                      ),
                    ),
                    Text(
                      _getCardName(_selectedCard!.type),
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_needsTarget(_selectedCard!.type))
                      const Text(
                        '← Chọn mục tiêu',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // HAND AREA
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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                if (currentPlayer.role == Role.sheriff)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.star,
                      color: Color(0xFFD4AF37),
                      size: 14,
                    ),
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

          // Bài trên tay
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: currentPlayer.hand.length,
              itemBuilder: (context, index) {
                final card = currentPlayer.hand[index];
                final isSelected = _selectedCard?.id == card.id;
                final canPlay = _canPlayCard(card, currentPlayer, state);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onLongPress: () => _showCardInfo(context, card),
                    child: CardWidget(
                      card: card,
                      isSelected: isSelected,
                      isPlayable: (state.phase == GamePhase.play ||
                          state.phase == GamePhase.discard) &&
                          canPlay,
                      onTap: () => _onCardTapped(card, state),
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Hiện role tất cả mọi người
            ...state.players.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${p.name} — ${_getRoleName(p.role)} — ${p.character.displayName}',
                style: TextStyle(
                  color: _getRoleColor(p.role),
                  fontSize: 14,
                ),
              ),
            )),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF2C1810),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'CHƠI LẠI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
      ref.read(gameProvider.notifier).discardCard(card);
      return;
    }

    if (state.phase != GamePhase.play) return;

    final currentPlayer = state.currentPlayer;
    if (!_canPlayCard(card, currentPlayer, state)) return;

    // PANIC & CAT BALOU — cần chọn người rồi chọn bài
    if (card.type == CardType.panic || card.type == CardType.catBalou) {
      setState(() {
        _selectedCard = _selectedCard?.id == card.id ? null : card;
        _panicTarget = null;
      });
      return;
    }

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

  void _onTargetSelected(PlayerModel target, GameState state) {
    if (_selectedCard == null) return;

    // PANIC & CAT BALOU → hiện bottom sheet chọn bài
    if (_selectedCard!.type == CardType.panic ||
        _selectedCard!.type == CardType.catBalou) {
      setState(() => _panicTarget = target);
      _showTargetCardPicker(target);
      return;
    }

    // BANG, JAIL → targetId là player id
    ref.read(gameProvider.notifier).playCard(
      _selectedCard!,
      targetId: target.id,
    );
    setState(() {
      _selectedCard = null;
      _panicTarget = null;
    });
  }

  void _showTargetCardPicker(PlayerModel target) {
    final selectedCard = _selectedCard!;
    final isPanic = selectedCard.type == CardType.panic;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C1810),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final allCards = [
          ...target.hand.map((c) => (c, 'Tay')),
          ...target.equipment.map((c) => (c, 'Trang bị')),
        ];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPanic
                    ? 'PANIC! — Chọn bài lấy từ ${target.name}'
                    : 'CAT BALOU — Chọn bài bỏ của ${target.name}',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (allCards.isEmpty)
                Text(
                  '${target.name} không có bài nào!',
                  style: const TextStyle(color: Colors.white54),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: allCards.map((entry) {
                      final (card, label) = entry;
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          ref.read(gameProvider.notifier).playCard(
                            selectedCard,
                            targetId: card.id,
                          );
                          setState(() {
                            _selectedCard = null;
                            _panicTarget = null;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CardWidget(card: card, isPlayable: true),
                              const SizedBox(height: 4),
                              Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _selectedCard = null;
        _panicTarget = null;
      });
    });
  }

  void _showCardInfo(BuildContext context, CardModel card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C1810),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CardInfoSheet(card: card),
    );
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────

  bool _canTargetPlayer(PlayerModel player, GameState state) {
    if (_selectedCard == null || !player.isAlive) return false;

    return switch (_selectedCard!.type) {
      CardType.bang => RangeCalculator.canAttack(
        alivePlayers: state.alivePlayers,
        attacker: state.currentPlayer,
        target: player,
      ),
      CardType.jail => player.role != Role.sheriff,
      CardType.panic => RangeCalculator.calculate(
        alivePlayers: state.alivePlayers,
        attacker: state.currentPlayer,
        target: player,
      ) == 1,
      CardType.catBalou => true,
      _ => false,
    };
  }

  bool _canPlayCard(CardModel card, PlayerModel player, GameState state) {
    return switch (card.type) {
      CardType.beer => player.hp < player.maxHp &&
          state.alivePlayers.length > 2,
      CardType.bang => CharacterAbilityService.canPlayBang(
          player, state.bangPlayedThisTurn),
    // MISS — không đánh chủ động trong play phase
    // nhưng CÓ THỂ bỏ trong discard phase
      CardType.miss => state.phase == GamePhase.discard,
      _ => true,
    };
  }

  bool _needsTarget(CardType type) {
    return const {
      CardType.bang,
      CardType.jail,
      CardType.catBalou,
      CardType.panic,
    }.contains(type);
  }

  // ─────────────────────────────────────────
  // TEXT HELPERS
  // ─────────────────────────────────────────

  String _getPhaseText(GamePhase phase) => switch (phase) {
    GamePhase.waiting  => 'CHỜ',
    GamePhase.draw     => 'RÚT BÀI',
    GamePhase.play     => 'ĐÁNH BÀI',
    GamePhase.discard  => 'BỎ BÀI',
    GamePhase.gameOver => 'KẾT THÚC',
  };

  String _getWinnerText(String? winner) => switch (winner) {
    'sheriff'  => '🌟 CẢNH SÁT THẮNG!',
    'outlaw'   => '💀 TỘI PHẠM THẮNG!',
    'renegade' => '🎭 KẺ PHẢN LOẠN THẮNG!',
    _ => 'KẾT THÚC',
  };

  String _getRoleName(Role role) => switch (role) {
    Role.sheriff  => 'Cảnh sát trưởng',
    Role.deputy   => 'Phó cảnh sát',
    Role.outlaw   => 'Tội phạm',
    Role.renegade => 'Kẻ phản loạn',
  };

  Color _getRoleColor(Role role) => switch (role) {
    Role.sheriff  => const Color(0xFFD4AF37),
    Role.deputy   => Colors.blueAccent,
    Role.outlaw   => Colors.redAccent,
    Role.renegade => Colors.purpleAccent,
  };

  String _getCardName(CardType type) => switch (type) {
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

// ─────────────────────────────────────────
// ACTION BUTTON WIDGET
// ─────────────────────────────────────────
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
            Icon(
              icon,
              color: onTap != null ? color : Colors.white30,
              size: 14,
            ),
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

// ─────────────────────────────────────────
// CARD INFO SHEET
// ─────────────────────────────────────────
class _CardInfoSheet extends StatelessWidget {
  final CardModel card;

  const _CardInfoSheet({required this.card});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình lá bài lớn
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF3D2317),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFD4AF37), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getSuitSymbol(card.suit),
                  style: TextStyle(
                    fontSize: 28,
                    color: _getSuitColor(card.suit),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCardName(card.type),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _getValueText(card.value),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getSuitColor(card.suit),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getCardName(card.type),
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getTypeColor(card.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _getTypeColor(card.type), width: 1),
                  ),
                  child: Text(
                    _getTypeLabel(card.type),
                    style: TextStyle(
                      color: _getTypeColor(card.type),
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getCardDescription(card.type),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0F08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 ',
                          style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Text(
                          _getCardTip(card.type),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSuitSymbol(Suit suit) => switch (suit) {
    Suit.hearts   => '♥',
    Suit.diamonds => '♦',
    Suit.clubs    => '♣',
    Suit.spades   => '♠',
  };

  Color _getSuitColor(Suit suit) => switch (suit) {
    Suit.hearts   => Colors.red,
    Suit.diamonds => Colors.red,
    Suit.clubs    => Colors.white70,
    Suit.spades   => Colors.white70,
  };

  String _getValueText(int value) => switch (value) {
    1  => 'A',
    11 => 'J',
    12 => 'Q',
    13 => 'K',
    _  => '$value',
  };

  String _getCardName(CardType type) => switch (type) {
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

  Color _getTypeColor(CardType type) {
    if (const {CardType.bang, CardType.gatling, CardType.indians}
        .contains(type)) return Colors.redAccent;
    if (const {CardType.miss, CardType.beer}.contains(type))
      return Colors.greenAccent;
    if (const {CardType.stagecoach, CardType.wellsFargo}.contains(type))
      return Colors.blueAccent;
    if (const {
      CardType.volcanic, CardType.schofield, CardType.remington,
      CardType.carabine, CardType.winchester,
    }.contains(type)) return Colors.orangeAccent;
    return const Color(0xFFD4AF37);
  }

  String _getTypeLabel(CardType type) {
    if (const {CardType.bang, CardType.gatling, CardType.indians}
        .contains(type)) return '⚔️ Tấn công';
    if (const {CardType.miss, CardType.beer}.contains(type))
      return '🛡️ Phòng thủ';
    if (const {CardType.stagecoach, CardType.wellsFargo}.contains(type))
      return '🃏 Rút bài';
    if (const {
      CardType.volcanic, CardType.schofield, CardType.remington,
      CardType.carabine, CardType.winchester,
    }.contains(type)) return '🔫 Vũ khí';
    if (const {CardType.barrel, CardType.mustang, CardType.scope}
        .contains(type)) return '🛡️ Trang bị';
    return '🎴 Đặc biệt';
  }

  String _getCardDescription(CardType type) => switch (type) {
    CardType.bang =>
    'Bắn 1 người chơi trong tầm bắn. Mục tiêu cần dùng MISS! để né, '
        'nếu không sẽ mất 1 máu. Mỗi lượt chỉ được đánh 1 BANG! (trừ Volcanic).',
    CardType.miss =>
    'Dùng để né 1 đòn BANG! nhắm vào mình. '
        'Mỗi lần bị bắn cần 1 MISS! Không dùng chủ động được.',
    CardType.beer =>
    'Hồi 1 máu. Không dùng được nếu đã đầy máu. '
        'Vô hiệu hóa khi chỉ còn 2 người chơi trong game.',
    CardType.gatling =>
    'Bắn TẤT CẢ người chơi khác cùng lúc. '
        'Mỗi người cần 1 MISS! để né, nếu không mất 1 máu.',
    CardType.indians =>
    'Mỗi người chơi khác phải đánh 1 BANG! hoặc mất 1 máu. '
        'Không bị ảnh hưởng bởi tầm bắn.',
    CardType.stagecoach =>
    'Rút ngay 2 bài từ deck. Hiệu lực tức thì.',
    CardType.wellsFargo =>
    'Rút ngay 3 bài từ deck. Mạnh hơn Stagecoach '
        'nhưng hiếm hơn (chỉ có 1 lá).',
    CardType.catBalou =>
    'Bắt buộc 1 người chơi bỏ 1 bài bất kỳ — '
        'trên tay hoặc trang bị trước mặt.',
    CardType.panic =>
    'Lấy 1 bài từ tay người chơi kề bên (khoảng cách 1). '
        'Bài lấy được vào tay bạn.',
    CardType.jail =>
    'Giam 1 người chơi (không phải Sheriff). Đầu lượt họ lật 1 bài: '
        'ra ♥ Hoa thì thoát, còn lại mất lượt.',
    CardType.dynamite =>
    'Đặt trước mặt. Đầu mỗi lượt lật 1 bài: 2-9 ♠ Bích → nổ mất 3 máu. '
        'Còn lại truyền sang người kế bên.',
    CardType.volcanic =>
    'Vũ khí tầm 1. Cho phép đánh không giới hạn BANG! trong 1 lượt.',
    CardType.schofield  => 'Vũ khí tầm 2.',
    CardType.remington  => 'Vũ khí tầm 3.',
    CardType.carabine   => 'Vũ khí tầm 4.',
    CardType.winchester => 'Vũ khí tầm 5 — bắn được tất cả mọi người.',
    CardType.barrel =>
    'Khi bị BANG!, lật 1 bài: ra ♥ Hoa → tự động né.',
    CardType.mustang =>
    'Người khác coi bạn xa hơn +1. Khó bị bắn hơn.',
    CardType.scope =>
    'Bạn coi người khác gần hơn -1. Dễ bắn hơn.',
  };

  String _getCardTip(CardType type) => switch (type) {
    CardType.bang       => 'Ưu tiên bắn người có ít máu hoặc không có MISS!',
    CardType.miss       => 'Giữ MISS! phòng thân, đặc biệt khi có Gatling.',
    CardType.beer       => 'Dùng Beer khi còn 1 máu để tránh bị loại.',
    CardType.gatling    => 'Cực mạnh khi nhiều người không có MISS!',
    CardType.indians    => 'Dùng khi biết nhiều người không có BANG!',
    CardType.stagecoach => 'Dùng sớm để có nhiều bài lựa chọn hơn.',
    CardType.wellsFargo => 'Rất hiếm — dùng ngay khi có.',
    CardType.catBalou   => 'Ưu tiên phá Barrel hoặc Mustang của địch.',
    CardType.panic      => 'Dùng khi địch có nhiều bài trên tay.',
    CardType.jail       => 'Giam Sheriff nếu bạn là Outlaw.',
    CardType.dynamite   => 'Rủi ro nhưng có thể gây 3 damage.',
    CardType.volcanic   => 'Kết hợp với nhiều BANG! để tấn công dồn dập.',
    CardType.schofield  => 'Bổ sung tầm bắn tốt cho đầu game.',
    CardType.remington  => 'Cho phép bắn qua nhiều người.',
    CardType.carabine   => 'Gần như bắn được tất cả trong ván 4-5 người.',
    CardType.winchester => 'Bắn được tất cả — giữ bí mật đến khi cần.',
    CardType.barrel     => '50% tự né — hữu ích khi bị nhiều người tấn công.',
    CardType.mustang    => 'Đặt sớm để bảo vệ mình khỏi vũ khí tầm thấp.',
    CardType.scope      => 'Kết hợp với vũ khí tầm xa để bắn được nhiều người.',
  };
}