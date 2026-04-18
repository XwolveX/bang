import 'package:flutter_test/flutter_test.dart';
import 'package:bang/core/services/win_checker.dart';
import 'package:bang/core/services/character_ability_service.dart';
import 'package:bang/core/enums/game_enums.dart';
import 'package:bang/core/models/game_state.dart';
import 'package:bang/core/models/player_model.dart';

// Helper tạo player nhanh
PlayerModel makePlayer(String id, Role role, {bool isAlive = true}) {
  return PlayerModel(
    id: id,
    name: id,
    role: role,
    hp: isAlive ? 4 : 0,
    maxHp: 4,
    hand: [],
    equipment: [],
    character: CharacterAbilityService.createCharacter(CharacterName.willyTheKid),
    seatIndex: 0,
    isAlive: isAlive,
  );
}

// Helper tạo GameState nhanh
GameState makeState(List<PlayerModel> players) {
  return GameState(
    roomId: 'test',
    phase: GamePhase.play,
    players: players,
    deck: [],
    discard: [],
    turnIndex: 0,
  );
}

void main() {
  group('WinChecker', () {

    test('Sheriff còn sống, còn Outlaw → chưa kết thúc', () {
      final state = makeState([
        makePlayer('sheriff', Role.sheriff),
        makePlayer('outlaw1', Role.outlaw),
        makePlayer('outlaw2', Role.outlaw),
      ]);
      expect(WinChecker.check(state), null);
    });

    test('Sheriff + Deputy thắng khi diệt hết địch', () {
      final state = makeState([
        makePlayer('sheriff', Role.sheriff),
        makePlayer('deputy', Role.deputy),
        makePlayer('outlaw', Role.outlaw, isAlive: false),
        makePlayer('renegade', Role.renegade, isAlive: false),
      ]);
      expect(WinChecker.check(state), 'sheriff');
    });

    test('Outlaw thắng khi Sheriff chết', () {
      final state = makeState([
        makePlayer('sheriff', Role.sheriff, isAlive: false),
        makePlayer('outlaw1', Role.outlaw),
        makePlayer('outlaw2', Role.outlaw),
        makePlayer('renegade', Role.renegade),
      ]);
      expect(WinChecker.check(state), 'outlaw');
    });

    test('Renegade thắng khi là người duy nhất còn sống', () {
      final state = makeState([
        makePlayer('sheriff', Role.sheriff, isAlive: false),
        makePlayer('outlaw', Role.outlaw, isAlive: false),
        makePlayer('renegade', Role.renegade),
      ]);
      expect(WinChecker.check(state), 'renegade');
    });

    test('Sheriff phạt khi hạ Deputy — mất toàn bộ bài', () {
      final sheriff = makePlayer('sheriff', Role.sheriff);
      final penalized = WinChecker.applySheriffPenalty(sheriff);

      expect(penalized.hand, isEmpty);
      expect(penalized.equipment, isEmpty);
    });

    test('shouldReward đúng — chỉ thưởng khi hạ Outlaw', () {
      expect(WinChecker.shouldReward(
          makePlayer('outlaw', Role.outlaw)), true);
      expect(WinChecker.shouldReward(
          makePlayer('deputy', Role.deputy)), false);
      expect(WinChecker.shouldReward(
          makePlayer('renegade', Role.renegade)), false);
    });

  });
}