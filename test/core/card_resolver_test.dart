import 'package:flutter_test/flutter_test.dart';
import 'package:bang/core/enums/game_enums.dart';
import 'package:bang/core/models/card_model.dart';
import 'package:bang/core/models/game_state.dart';
import 'package:bang/core/models/player_model.dart';
import 'package:bang/core/services/card_resolver.dart';
import 'package:bang/core/services/character_ability_service.dart';

// ─────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────

PlayerModel makePlayer({
  required String id,
  required int seatIndex,
  Role role = Role.outlaw,
  int hp = 4,
  int maxHp = 4,
  List<CardModel> hand = const [],
  List<CardModel> equipment = const [],
  bool isAlive = true,
  bool isInJail = false,
}) {
  return PlayerModel(
    id: id,
    name: id,
    role: role,
    hp: hp,
    maxHp: maxHp,
    hand: hand,
    equipment: equipment,
    character: CharacterAbilityService.createCharacter(
      CharacterName.willyTheKid,
    ),
    seatIndex: seatIndex,
    isAlive: isAlive,
    isInJail: isInJail,
  );
}

CardModel makeCard(CardType type, {
  Suit suit = Suit.hearts,
  int value = 5,
}) {
  return CardModel(
    id: '${type.name}_${suit.name}_$value',
    type: type,
    suit: suit,
    value: value,
  );
}

GameState makeState({
  required List<PlayerModel> players,
  int turnIndex = 0,
  List<CardModel> deck = const [],
  List<CardModel> discard = const [],
  GamePhase phase = GamePhase.play,
}) {
  return GameState(
    roomId: 'test',
    phase: phase,
    players: players,
    deck: deck,
    discard: discard,
    turnIndex: turnIndex,
  );
}

// ─────────────────────────────────────────
// TESTS
// ─────────────────────────────────────────

void main() {

  // ═══════════════════════════════════════
  // BANG
  // ═══════════════════════════════════════
  group('BANG!', () {

    test('bắn trúng → mục tiêu mất 1 máu', () {
      final attacker = makePlayer(id: 'a', seatIndex: 0);
      final target   = makePlayer(id: 'b', seatIndex: 1);
      final bang     = makeCard(CardType.bang);

      final state  = makeState(players: [attacker, target]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: bang,
        targetId: 'b',
      );

      expect(result.getPlayer('b')!.hp, 3); // 4 - 1 = 3
    });

    test('bắn bị né bởi MISS → mục tiêu không mất máu', () {
      final miss   = makeCard(CardType.miss, suit: Suit.spades, value: 10);
      final target = makePlayer(id: 'b', seatIndex: 1, hand: [miss]);
      final attacker = makePlayer(id: 'a', seatIndex: 0);
      final bang   = makeCard(CardType.bang);

      final state  = makeState(players: [attacker, target]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: bang,
        targetId: 'b',
      );

      expect(result.getPlayer('b')!.hp, 4); // Không mất máu
      expect(result.getPlayer('b')!.hand, isEmpty); // MISS đã dùng
    });

    test('bắn trúng → bài BANG bị bỏ khỏi tay', () {
      final bang     = makeCard(CardType.bang);
      final attacker = makePlayer(id: 'a', seatIndex: 0, hand: [bang]);
      final target   = makePlayer(id: 'b', seatIndex: 1);

      final state  = makeState(players: [attacker, target]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: bang,
        targetId: 'b',
      );

      expect(result.getPlayer('a')!.hand, isEmpty); // BANG đã đánh
    });

    test('bắn chết người → player bị loại', () {
      final target   = makePlayer(id: 'b', seatIndex: 1, hp: 1);
      final attacker = makePlayer(id: 'a', seatIndex: 0);
      final bang     = makeCard(CardType.bang);

      final state  = makeState(players: [attacker, target]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: bang,
        targetId: 'b',
      );

      expect(result.getPlayer('b')!.isAlive, false);
      expect(result.getPlayer('b')!.hp, 0);
    });

  });

  // ═══════════════════════════════════════
  // BEER
  // ═══════════════════════════════════════
  group('BEER', () {

    test('hồi 1 máu khi chưa đầy', () {
      final player = makePlayer(id: 'a', seatIndex: 0, hp: 3, maxHp: 4);
      final beer   = makeCard(CardType.beer);

      final state  = makeState(players: [
        player,
        makePlayer(id: 'b', seatIndex: 1),
        makePlayer(id: 'c', seatIndex: 2),
      ]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: beer,
      );

      expect(result.getPlayer('a')!.hp, 4);
    });

    test('không hồi khi đã đầy máu', () {
      final player = makePlayer(id: 'a', seatIndex: 0, hp: 4, maxHp: 4);
      final beer   = makeCard(CardType.beer);

      final state  = makeState(players: [
        player,
        makePlayer(id: 'b', seatIndex: 1),
        makePlayer(id: 'c', seatIndex: 2),
      ]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: beer,
      );

      expect(result.getPlayer('a')!.hp, 4); // Không đổi
    });

    test('vô hiệu khi chỉ còn 2 người', () {
      final player = makePlayer(id: 'a', seatIndex: 0, hp: 2, maxHp: 4);
      final beer   = makeCard(CardType.beer);

      // Chỉ 2 người alive
      final state = makeState(players: [
        player,
        makePlayer(id: 'b', seatIndex: 1),
      ]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: beer,
      );

      expect(result.getPlayer('a')!.hp, 2); // Không hồi
    });

  });

  // ═══════════════════════════════════════
  // GATLING
  // ═══════════════════════════════════════
  group('GATLING', () {

    test('bắn tất cả → tất cả mất 1 máu nếu không có MISS', () {
      final players = [
        makePlayer(id: 'a', seatIndex: 0),
        makePlayer(id: 'b', seatIndex: 1),
        makePlayer(id: 'c', seatIndex: 2),
        makePlayer(id: 'd', seatIndex: 3),
      ];
      final gatling = makeCard(CardType.gatling);

      final state  = makeState(players: players);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: gatling,
      );

      // a là attacker — không tự bắn mình
      expect(result.getPlayer('a')!.hp, 4); // Không đổi
      expect(result.getPlayer('b')!.hp, 3); // Mất 1
      expect(result.getPlayer('c')!.hp, 3); // Mất 1
      expect(result.getPlayer('d')!.hp, 3); // Mất 1
    });

    test('người có MISS → né được Gatling', () {
      final miss = makeCard(CardType.miss, suit: Suit.clubs, value: 2);
      final players = [
        makePlayer(id: 'a', seatIndex: 0),
        makePlayer(id: 'b', seatIndex: 1, hand: [miss]), // có MISS
        makePlayer(id: 'c', seatIndex: 2),
      ];
      final gatling = makeCard(CardType.gatling);

      final state  = makeState(players: players);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: gatling,
      );

      expect(result.getPlayer('b')!.hp, 4); // Né được
      expect(result.getPlayer('b')!.hand, isEmpty); // MISS đã dùng
      expect(result.getPlayer('c')!.hp, 3); // Không né
    });

  });

  // ═══════════════════════════════════════
  // INDIANS
  // ═══════════════════════════════════════
  group('INDIANS', () {

    test('mỗi người cần BANG hoặc mất máu', () {
      final bang = makeCard(CardType.bang, suit: Suit.spades, value: 2);
      final players = [
        makePlayer(id: 'a', seatIndex: 0),
        makePlayer(id: 'b', seatIndex: 1, hand: [bang]), // có BANG
        makePlayer(id: 'c', seatIndex: 2),               // không có BANG
      ];
      final indians = makeCard(CardType.indians);

      final state  = makeState(players: players);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: indians,
      );

      expect(result.getPlayer('b')!.hp, 4); // Chặn được
      expect(result.getPlayer('b')!.hand, isEmpty); // BANG đã dùng
      expect(result.getPlayer('c')!.hp, 3); // Mất máu
    });

  });

  // ═══════════════════════════════════════
  // STAGECOACH & WELLS FARGO
  // ═══════════════════════════════════════
  group('STAGECOACH & WELLS FARGO', () {

    test('Stagecoach rút 2 bài', () {
      final deck = List.generate(10, (i) =>
          makeCard(CardType.bang, suit: Suit.hearts, value: i + 1));
      final player     = makePlayer(id: 'a', seatIndex: 0);
      final stagecoach = makeCard(CardType.stagecoach);

      final state  = makeState(players: [player], deck: deck);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: stagecoach,
      );

      expect(result.getPlayer('a')!.hand.length, 2);
      expect(result.deck.length, 8); // 10 - 2 = 8
    });

    test('Wells Fargo rút 3 bài', () {
      final deck = List.generate(10, (i) =>
          makeCard(CardType.bang, suit: Suit.hearts, value: i + 1));
      final player     = makePlayer(id: 'a', seatIndex: 0);
      final wellsFargo = makeCard(CardType.wellsFargo);

      final state  = makeState(players: [player], deck: deck);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: wellsFargo,
      );

      expect(result.getPlayer('a')!.hand.length, 3);
      expect(result.deck.length, 7); // 10 - 3 = 7
    });

  });

  // ═══════════════════════════════════════
  // CAT BALOU
  // ═══════════════════════════════════════
  group('CAT BALOU', () {

    test('bắt bỏ bài trên tay', () {
      final targetCard = makeCard(CardType.bang, suit: Suit.spades, value: 3);
      final target     = makePlayer(
          id: 'b', seatIndex: 1, hand: [targetCard]);
      final attacker   = makePlayer(id: 'a', seatIndex: 0);
      final catBalou   = makeCard(CardType.catBalou);

      final state  = makeState(players: [attacker, target]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: catBalou,
        targetId: targetCard.id, // id của bài bị bỏ
      );

      expect(result.getPlayer('b')!.hand, isEmpty);
      expect(result.discard.any((c) => c.id == targetCard.id), true);
    });

    test('phá trang bị', () {
      final mustang  = makeCard(CardType.mustang, suit: Suit.hearts, value: 8);
      final target   = makePlayer(
          id: 'b', seatIndex: 1, equipment: [mustang]);
      final attacker = makePlayer(id: 'a', seatIndex: 0);
      final catBalou = makeCard(CardType.catBalou);

      final state  = makeState(players: [attacker, target]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: catBalou,
        targetId: mustang.id,
      );

      expect(result.getPlayer('b')!.equipment, isEmpty);
      expect(result.discard.any((c) => c.id == mustang.id), true);
    });

  });

  // ═══════════════════════════════════════
  // PANIC
  // ═══════════════════════════════════════
  group('PANIC!', () {

    test('lấy bài từ tay người khác', () {
      final targetCard = makeCard(CardType.beer, suit: Suit.hearts, value: 10);
      final target     = makePlayer(
          id: 'b', seatIndex: 1, hand: [targetCard]);
      final attacker   = makePlayer(id: 'a', seatIndex: 0);
      final panic      = makeCard(CardType.panic);

      final state  = makeState(players: [attacker, target]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: panic,
        targetId: targetCard.id,
      );

      // b mất bài
      expect(result.getPlayer('b')!.hand, isEmpty);
      // a nhận bài
      expect(result.getPlayer('a')!.hand.any(
              (c) => c.id == targetCard.id), true);
    });

  });

  // ═══════════════════════════════════════
  // JAIL
  // ═══════════════════════════════════════
  group('JAIL', () {

    test('giam người chơi', () {
      final target   = makePlayer(id: 'b', seatIndex: 1);
      final attacker = makePlayer(id: 'a', seatIndex: 0);
      final jail     = makeCard(CardType.jail);

      final state  = makeState(players: [attacker, target]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: jail,
        targetId: 'b',
      );

      expect(result.getPlayer('b')!.isInJail, true);
    });

  });

  // ═══════════════════════════════════════
  // EQUIPMENT
  // ═══════════════════════════════════════
  group('Equipment', () {

    test('trang bị Mustang → vào equipment', () {
      final mustang = makeCard(CardType.mustang, suit: Suit.hearts, value: 8);
      final player  = makePlayer(id: 'a', seatIndex: 0, hand: [mustang]);

      final state  = makeState(players: [player]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: mustang,
      );

      expect(result.getPlayer('a')!.equipment.length, 1);
      expect(result.getPlayer('a')!.equipment.first.type, CardType.mustang);
      expect(result.getPlayer('a')!.hand, isEmpty);
    });

    test('trang bị Scope → vào equipment', () {
      final scope  = makeCard(CardType.scope, suit: Suit.spades, value: 1);
      final player = makePlayer(id: 'a', seatIndex: 0, hand: [scope]);

      final state  = makeState(players: [player]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: scope,
      );

      expect(result.getPlayer('a')!.equipment.length, 1);
      expect(result.getPlayer('a')!.hasScope, true);
    });

    test('trang bị Barrel → vào equipment', () {
      final barrel = makeCard(CardType.barrel, suit: Suit.spades, value: 12);
      final player = makePlayer(id: 'a', seatIndex: 0, hand: [barrel]);

      final state  = makeState(players: [player]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: barrel,
      );

      expect(result.getPlayer('a')!.hasBarrel, true);
    });

    test('trang bị Schofield → tầm bắn = 2', () {
      final schofield = makeCard(
          CardType.schofield, suit: Suit.spades, value: 13);
      final player    = makePlayer(
          id: 'a', seatIndex: 0, hand: [schofield]);

      final state  = makeState(players: [player]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: schofield,
      );

      expect(result.getPlayer('a')!.attackRange, 2);
    });

    test('trang bị Winchester → tầm bắn = 5', () {
      final winchester = makeCard(
          CardType.winchester, suit: Suit.spades, value: 8);
      final player     = makePlayer(
          id: 'a', seatIndex: 0, hand: [winchester]);

      final state  = makeState(players: [player]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: winchester,
      );

      expect(result.getPlayer('a')!.attackRange, 5);
    });

  });

  // ═══════════════════════════════════════
  // ACTION LOG
  // ═══════════════════════════════════════
  group('Action Log', () {

    test('mỗi hành động append vào log', () {
      final attacker = makePlayer(id: 'a', seatIndex: 0);
      final target   = makePlayer(id: 'b', seatIndex: 1);
      final bang     = makeCard(CardType.bang);

      final state  = makeState(players: [attacker, target]);
      final result = CardResolver.playCard(
        state: state,
        playerId: 'a',
        card: bang,
        targetId: 'b',
      );

      expect(result.actionLog, isNotEmpty);
    });

  });
  group('Character Ability', () {

    test('Willy the Kid đánh nhiều BANG trong 1 lượt', () {
      final willy = PlayerModel(
        id: 'a', name: 'Willy', role: Role.outlaw,
        hp: 4, maxHp: 4, hand: [], equipment: [],
        character: CharacterAbilityService.createCharacter(
            CharacterName.willyTheKid),
        seatIndex: 0,
      );

      // Lần 1 — bangPlayedThisTurn = 0
      expect(CharacterAbilityService.canPlayBang(willy, 0), true);
      // Lần 2 — bangPlayedThisTurn = 1
      expect(CharacterAbilityService.canPlayBang(willy, 1), true);
      // Lần 3 — bangPlayedThisTurn = 2
      expect(CharacterAbilityService.canPlayBang(willy, 2), true);
    });

    test('Player thường chỉ đánh 1 BANG', () {
      final normal = PlayerModel(
        id: 'a', name: 'Normal', role: Role.outlaw,
        hp: 4, maxHp: 4, hand: [], equipment: [],
        character: CharacterAbilityService.createCharacter(
            CharacterName.kitCarlson),
        seatIndex: 0,
      );

      expect(CharacterAbilityService.canPlayBang(normal, 0), true);
      expect(CharacterAbilityService.canPlayBang(normal, 1), false); // ← chặn
    });

    test('Jose Delgado đánh tối đa 2 BANG', () {
      final jose = PlayerModel(
        id: 'a', name: 'Jose', role: Role.outlaw,
        hp: 4, maxHp: 4, hand: [], equipment: [],
        character: CharacterAbilityService.createCharacter(
            CharacterName.joseDelgado),
        seatIndex: 0,
      );

      expect(CharacterAbilityService.canPlayBang(jose, 0), true);
      expect(CharacterAbilityService.canPlayBang(jose, 1), true);  // ← lần 2
      expect(CharacterAbilityService.canPlayBang(jose, 2), false); // ← chặn
    });

  });

}
