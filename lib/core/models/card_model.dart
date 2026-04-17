import '../enums/game_enums.dart';

class CardModel {
  final String id;
  final CardType type;
  final Suit suit;
  final int value;

  const CardModel({
    required this.id,
    required this.type,
    required this.suit,
    required this.value,
});
  // Bài có phải đặt trước mặt (equipment) không?
  bool get isEquipment => const {
    CardType.volcanic,
    CardType.schofield,
    CardType.remington,
    CardType.carabine,
    CardType.winchester,
    CardType.barrel,
    CardType.mustang,
    CardType.scope,
    CardType.dynamite,
    CardType.jail,
  }.contains(type);
  // Bài có phải vũ khí không?
  bool get isWeapon => const {
    CardType.volcanic,
    CardType.schofield,
    CardType.remington,
    CardType.carabine,
    CardType.winchester,
  }.contains(type);
  // Tầm bắn của vũ khí (vũ khí mặc định = 1)
  int get weaponRange => switch (type) {
    CardType.volcanic   => 1,
    CardType.schofield  => 2,
    CardType.remington  => 3,
    CardType.carabine   => 4,
    CardType.winchester => 5,
    _                   => 1,
  };
  @override
  String toString() => 'Card($type, $suit, $value)';
}