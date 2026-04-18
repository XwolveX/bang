import 'package:flutter/material.dart';
import '../core/models/card_model.dart';
import '../core/enums/game_enums.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;
  final bool isSelected;
  final bool isPlayable;  // Có thể đánh không?
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.isPlayable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPlayable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // Lá bài được chọn thì nhô lên
        margin: EdgeInsets.only(bottom: isSelected ? 12 : 0),
        width: 56,
        height: 80,
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4AF37)
                : isPlayable
                ? Colors.white54
                : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Suit icon
            Text(
              _getSuitSymbol(),
              style: TextStyle(
                fontSize: 16,
                color: _getSuitColor(),
              ),
            ),

            const SizedBox(height: 2),

            // Tên bài
            Text(
              _getCardName(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: isPlayable ? Colors.white : Colors.white30,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 2),

            // Value
            Text(
              _getValueText(),
              style: TextStyle(
                fontSize: 9,
                color: _getSuitColor().withOpacity(isPlayable ? 1 : 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor() {
    if (!isPlayable) return const Color(0xFF1A1A1A);
    if (isSelected) return const Color(0xFF3D2317);
    return const Color(0xFF2C1810);
  }

  String _getSuitSymbol() {
    return switch (card.suit) {
      Suit.hearts   => '♥',
      Suit.diamonds => '♦',
      Suit.clubs    => '♣',
      Suit.spades   => '♠',
    };
  }

  Color _getSuitColor() {
    return switch (card.suit) {
      Suit.hearts   => Colors.red,
      Suit.diamonds => Colors.red,
      Suit.clubs    => Colors.white70,
      Suit.spades   => Colors.white70,
    };
  }

  String _getCardName() {
    return switch (card.type) {
      CardType.bang       => 'BANG!',
      CardType.miss       => 'MISS!',
      CardType.beer       => 'BEER',
      CardType.gatling    => 'GATLING',
      CardType.indians    => 'INDIANS',
      CardType.stagecoach => 'STAGE',
      CardType.wellsFargo => 'WELLS',
      CardType.catBalou   => 'CAT B.',
      CardType.panic      => 'PANIC!',
      CardType.jail       => 'JAIL',
      CardType.dynamite   => 'DYNAM.',
      CardType.volcanic   => 'VOLC.',
      CardType.schofield  => 'SCHOF.',
      CardType.remington  => 'REMIN.',
      CardType.carabine   => 'CARAB.',
      CardType.winchester => 'WINCH.',
      CardType.barrel     => 'BARREL',
      CardType.mustang    => 'MUST.',
      CardType.scope      => 'SCOPE',
    };
  }

  String _getValueText() {
    return switch (card.value) {
      1  => 'A',
      11 => 'J',
      12 => 'Q',
      13 => 'K',
      _  => '${card.value}',
    };
  }
}

// Mặt sau lá bài (bài của người khác)
class CardBack extends StatelessWidget {
  const CardBack({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF3D2317),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: const Center(
        child: Text('🤠', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}