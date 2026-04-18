import 'package:flutter_test/flutter_test.dart';
import 'package:bang/core/services/range_calculator.dart';
import 'package:bang/core/services/character_ability_service.dart';
import 'package:bang/core/enums/game_enums.dart';
import 'package:bang/core/models/player_model.dart';
import 'package:bang/core/models/card_model.dart';

// Helper tạo player nhanh cho test
PlayerModel makePlayer({
  required String id,
  required int seatIndex,
  List<CardModel> equipment = const [],
  CharacterName character = CharacterName.willyTheKid,
}) {
  return PlayerModel(
    id: id,
    name: id,
    role: Role.outlaw,
    hp: 4,
    maxHp: 4,
    hand: [],
    equipment: equipment,
    character: CharacterAbilityService.createCharacter(character),
    seatIndex: seatIndex,
  );
}

void main() {
  group('RangeCalculator', () {

    // 5 người ngồi vòng tròn: 0 1 2 3 4
    late List<PlayerModel> players;

    setUp(() {
      players = [
        makePlayer(id: 'p0', seatIndex: 0),
        makePlayer(id: 'p1', seatIndex: 1),
        makePlayer(id: 'p2', seatIndex: 2),
        makePlayer(id: 'p3', seatIndex: 3),
        makePlayer(id: 'p4', seatIndex: 4),
      ];
    });

    test('khoảng cách người kế bên = 1', () {
      final distance = RangeCalculator.calculate(
        alivePlayers: players,
        attacker: players[0],
        target: players[1],
      );
      expect(distance, 1);
    });

    test('khoảng cách ngắn nhất theo vòng tròn', () {
      // p0 đến p4: đi xuôi = 4, đi ngược = 1 → min = 1
      final distance = RangeCalculator.calculate(
        alivePlayers: players,
        attacker: players[0],
        target: players[4],
      );
      expect(distance, 1);
    });

    test('khoảng cách đối diện trong 5 người = 2', () {
      // p0 đến p2: đi xuôi = 2, đi ngược = 3 → min = 2
      final distance = RangeCalculator.calculate(
        alivePlayers: players,
        attacker: players[0],
        target: players[2],
      );
      expect(distance, 2);
    });

    test('Mustang tăng khoảng cách lên 1', () {
      final mustang = CardModel(
        id: 'mustang_hearts_8',
        type: CardType.mustang,
        suit: Suit.hearts,
        value: 8,
      );

      // p1 có Mustang
      final p1WithMustang = players[1].copyWith(equipment: [mustang]);
      final playersUpdated = [
        players[0], p1WithMustang, ...players.sublist(2)
      ];

      final distance = RangeCalculator.calculate(
        alivePlayers: playersUpdated,
        attacker: players[0],
        target: p1WithMustang,
      );

      // Khoảng cách vật lý 1 + Mustang 1 = 2
      expect(distance, 2);
    });

    test('Scope giảm khoảng cách đi 1', () {
      final scope = CardModel(
        id: 'scope_spades_1',
        type: CardType.scope,
        suit: Suit.spades,
        value: 1,
      );

      // p0 có Scope
      final p0WithScope = players[0].copyWith(equipment: [scope]);
      final playersUpdated = [p0WithScope, ...players.sublist(1)];

      final distance = RangeCalculator.calculate(
        alivePlayers: playersUpdated,
        attacker: p0WithScope,
        target: players[2], // khoảng cách vật lý = 2
      );

      // 2 - Scope 1 = 1
      expect(distance, 1);
    });

    test('canAttack đúng với tầm mặc định', () {
      // Tay không tầm 1 — chỉ bắn được người kế bên
      expect(RangeCalculator.canAttack(
        alivePlayers: players,
        attacker: players[0],
        target: players[1], // khoảng cách 1 ✅
      ), true);

      expect(RangeCalculator.canAttack(
        alivePlayers: players,
        attacker: players[0],
        target: players[2], // khoảng cách 2 ❌
      ), false);
    });

    test('không thể tự bắn mình', () {
      expect(RangeCalculator.canAttack(
        alivePlayers: players,
        attacker: players[0],
        target: players[0],
      ), false);
    });

  });
}