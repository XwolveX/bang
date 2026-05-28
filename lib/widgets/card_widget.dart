import 'package:flutter/material.dart';
import '../core/models/card_model.dart';
import '../core/enums/game_enums.dart';
import '../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  String? _getCardIllustration() {
    return switch (card.type) {
      CardType.bang       => 'assets/images/bang.png',
      CardType.gatling    => 'assets/images/bang.png',
      CardType.indians    => 'assets/images/bang.png',
      CardType.miss       => 'assets/images/miss.png',
      CardType.beer       => 'assets/images/beer.png',
      CardType.dynamite   => 'assets/images/dynamite.png',
      CardType.jail       => 'assets/images/jail.png',
      CardType.volcanic   ||
      CardType.schofield  ||
      CardType.remington  ||
      CardType.carabine   ||
      CardType.winchester => 'assets/images/weapons.png',
      _                   => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final hasIllustration = _getCardIllustration() != null;
    final String borderAsset = card.isEquipment
        ? 'assets/images/equipment_frame.png'
        : 'assets/images/action_frame.png';

    return GestureDetector(
      onTap: isPlayable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // Lá bài được chọn thì nhô lên
        margin: EdgeInsets.only(bottom: isSelected ? 12 : 0),
        width: 64,
        height: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppTheme.goldAccent.withOpacity(0.65),
              blurRadius: 12,
              spreadRadius: 4,
            )
          ]
              : isPlayable
              ? [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.35),
              blurRadius: 6,
              spreadRadius: 1.5,
            )
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              offset: const Offset(1, 2),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Frame Background
              Positioned.fill(
                child: Opacity(
                  opacity: isPlayable ? 1.0 : 0.4,
                  child: Image.asset(
                    borderAsset,
                    fit: BoxFit.fill,
                  ),
                ),
              ),

              // Card illustration (offset to center nicely in the frame)
              if (hasIllustration)
                Positioned(
                  top: 14,
                  left: 6,
                  right: 6,
                  height: 48,
                  child: Opacity(
                    opacity: isPlayable ? 1.0 : 0.4,
                    child: Image.asset(
                      _getCardIllustration()!,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              else
                Positioned(
                  top: 18,
                  left: 6,
                  right: 6,
                  height: 40,
                  child: Center(
                    child: Icon(
                      _getCardIcon(),
                      size: 20,
                      color: isPlayable
                          ? (card.isEquipment ? AppTheme.goldAccent : AppTheme.woodBackground)
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),

              // Suit & Value in top-left
              Positioned(
                top: 3,
                left: 5,
                child: Opacity(
                  opacity: isPlayable ? 1.0 : 0.4,
                  child: Row(
                    children: [
                      Text(
                        _getValueText(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: _getSuitColor(),
                        ),
                      ),
                      const SizedBox(width: 1),
                      Text(
                        _getSuitSymbol(),
                        style: TextStyle(
                          fontSize: 9,
                          color: _getSuitColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title Text overlay at the bottom parchment area
              Positioned(
                bottom: 8,
                left: 4,
                right: 4,
                child: Opacity(
                  opacity: isPlayable ? 1.0 : 0.4,
                  child: Text(
                    _getCardName(),
                    style: AppTheme.cardTitleStyle.copyWith(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF4E2C10),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate(target: isSelected ? 1 : 0)
       .scaleXY(end: 1.08, duration: 200.ms, curve: Curves.easeOut)
       .animate(onPlay: (controller) => controller.repeat(reverse: true))
       .shimmer(
         duration: 1500.ms,
         color: isPlayable ? AppTheme.goldAccent.withOpacity(0.25) : Colors.transparent,
       ),
    );
  }


  IconData _getCardIcon() {
    return switch (card.type) {
      CardType.bang       => Icons.local_fire_department,
      CardType.miss       => Icons.shield,
      CardType.beer       => Icons.local_drink,
      CardType.gatling    => Icons.cyclone,
      CardType.indians    => Icons.warning,
      CardType.stagecoach => Icons.directions_car,
      CardType.wellsFargo => Icons.account_balance,
      CardType.catBalou   => Icons.delete,
      CardType.panic      => Icons.pan_tool,
      CardType.jail       => Icons.lock,
      CardType.dynamite   => Icons.dangerous,
      CardType.volcanic   => Icons.hardware,
      CardType.schofield  => Icons.hardware,
      CardType.remington  => Icons.hardware,
      CardType.carabine   => Icons.hardware,
      CardType.winchester => Icons.hardware,
      CardType.barrel     => Icons.security,
      CardType.mustang    => Icons.pets,
      CardType.scope      => Icons.visibility,
    };
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
      Suit.hearts   => AppTheme.bloodRed,
      Suit.diamonds => AppTheme.bloodRed,
      Suit.clubs    => AppTheme.textDark,
      Suit.spades   => AppTheme.textDark,
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
  final double width;
  final double height;

  const CardBack({
    super.key,
    this.width = 36,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/images/card_back.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}