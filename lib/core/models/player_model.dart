import '../enums/game_enums.dart';
import 'card_model.dart';
import 'character_model.dart';

class PlayerModel {
  final String id;           // Firebase uid hoặc local id
  final String name;         // Tên hiển thị
  final Role role;           // Vai trò bí mật
  final int hp;              // Máu hiện tại
  final int maxHp;           // Máu tối đa
  final List<CardModel> hand;        // Bài trên tay
  final List<CardModel> equipment;   // Bài đặt trước mặt
  final CharacterModel character;    // Nhân vật đặc biệt
  final int seatIndex;       // Vị trí ngồi (0, 1, 2... theo chiều kim đồng hồ)
  final bool isAlive;
  final bool isInJail;       // Đang bị nhốt không?
  final bool hasDynamite;    // Có Dynamite trước mặt không?

  const PlayerModel({
    required this.id,
    required this.name,
    required this.role,
    required this.hp,
    required this.maxHp,
    required this.hand,
    required this.equipment,
    required this.character,
    required this.seatIndex,
    this.isAlive = true,
    this.isInJail = false,
    this.hasDynamite = false,
  });

  // Vũ khí đang trang bị (null = tay không, tầm 1)
  CardModel? get equippedWeapon => equipment
      .where((c) => c.isWeapon)
      .firstOrNull;

  // Tầm bắn hiện tại
  int get attackRange => equippedWeapon?.weaponRange ?? 1;

  // Có Mustang không? (+1 khoảng cách phòng thủ)
  bool get hasMustang => equipment.any((c) => c.type == CardType.mustang);

  // Có Scope không? (-1 khoảng cách tấn công)
  bool get hasScope => equipment.any((c) => c.type == CardType.scope);

  // Có Barrel không?
  bool get hasBarrel => equipment.any((c) => c.type == CardType.barrel);

  // Immutable update — trả về PlayerModel mới thay vì sửa trực tiếp
  PlayerModel copyWith({
    String? id,
    String? name,
    Role? role,
    int? hp,
    int? maxHp,
    List<CardModel>? hand,
    List<CardModel>? equipment,
    CharacterModel? character,
    int? seatIndex,
    bool? isAlive,
    bool? isInJail,
    bool? hasDynamite,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      hand: hand ?? this.hand,
      equipment: equipment ?? this.equipment,
      character: character ?? this.character,
      seatIndex: seatIndex ?? this.seatIndex,
      isAlive: isAlive ?? this.isAlive,
      isInJail: isInJail ?? this.isInJail,
      hasDynamite: hasDynamite ?? this.hasDynamite,
    );
  }

  @override
  String toString() => 'Player($name, $role, hp: $hp/$maxHp)';
}