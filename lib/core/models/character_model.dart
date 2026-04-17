import '../enums/game_enums.dart';

class CharacterModel {
  final CharacterName name;
  final String displayName;   // "Willy the Kid", "Kit Carlson"...
  final String abilityText;   // Mô tả ability để hiển thị UI
  final int startingHp;       // Máu khởi đầu (thường là 4)

  const CharacterModel({
    required this.name,
    required this.displayName,
    required this.abilityText,
    required this.startingHp,
  });

  @override
  String toString() => 'Character($displayName)';
}