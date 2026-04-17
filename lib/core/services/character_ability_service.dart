import '../enums/game_enums.dart';
import '../models/card_model.dart';
import '../models/character_model.dart';
import '../models/game_state.dart';
import '../models/player_model.dart';
import 'card_resolver.dart';

class CharacterAbilityService {
  // Tạo CharacterModel đầy đủ cho từng nhân vật
  static CharacterModel createCharacter(CharacterName name) {
    return switch (name) {
      CharacterName.sheriffDan => CharacterModel(
        name: name,
        displayName: 'Sheriff Dan',
        abilityText: 'Mỗi khi có người bị loại, rút thêm 3 bài.',
        startingHp: 4,
      ),
      CharacterName.calamityJane => CharacterModel(
        name: name,
        displayName: 'Calamity Jane',
        abilityText: 'Có thể dùng BANG! như MISS! và ngược lại.',
        startingHp: 4,
      ),
      CharacterName.docHolliday => CharacterModel(
        name: name,
        displayName: 'Doc Holliday',
        abilityText: 'Mỗi khi hạ gục 1 người (trừ Sheriff), rút thêm 2 bài.',
        startingHp: 4,
      ),
      CharacterName.belleStarr => CharacterModel(
        name: name,
        displayName: 'Belle Starr',
        abilityText: 'Khi bị BANG!, có thể bỏ 1 trang bị thay vì mất máu.',
        startingHp: 4,
      ),
      CharacterName.joseDelgado => CharacterModel(
        name: name,
        displayName: 'Jose Delgado',
        abilityText: 'Có thể đánh đến 2 BANG! mỗi lượt.',
        startingHp: 4,
      ),
      CharacterName.blackJack => CharacterModel(
        name: name,
        displayName: 'Black Jack',
        abilityText: 'Khi rút bài, nếu bài thứ 2 là Rô hoặc Bích: rút thêm 1 bài.',
        startingHp: 4,
      ),
      CharacterName.sidKetchum => CharacterModel(
        name: name,
        displayName: 'Sid Ketchum',
        abilityText: 'Có thể bỏ 2 bài bất kỳ để hồi 1 máu.',
        startingHp: 4,
      ),
      CharacterName.kitCarlson => CharacterModel(
        name: name,
        displayName: 'Kit Carlson',
        abilityText: 'Khi rút bài, xem trước 3 bài, chọn 2 giữ, trả 1 xuống cuối.',
        startingHp: 4,
      ),
      CharacterName.luckyDuke => CharacterModel(
        name: name,
        displayName: 'Lucky Duke',
        abilityText: 'Khi phải lật bài kiểm tra, được lật 2 và chọn kết quả có lợi.',
        startingHp: 4,
      ),
      CharacterName.jesseJames => CharacterModel(
        name: name,
        displayName: 'Jesse James',
        abilityText: 'Khi bị hạ gục, đánh hết bài trên tay trước khi bị loại.',
        startingHp: 4,
      ),
      CharacterName.vultureSam => CharacterModel(
        name: name,
        displayName: 'Vulture Sam',
        abilityText: 'Khi bất kỳ người chơi nào bị loại, lấy hết bài trên tay họ.',
        startingHp: 4,
      ),
      CharacterName.willyTheKid => CharacterModel(
        name: name,
        displayName: 'Willy the Kid',
        abilityText: 'Có thể đánh không giới hạn BANG! mỗi lượt.',
        startingHp: 4,
      ),
      CharacterName.pedroRamirez => CharacterModel(
        name: name,
        displayName: 'Pedro Ramirez',
        abilityText: 'Đầu lượt có thể rút bài đầu tiên từ discard thay vì deck.',
        startingHp: 4,
      ),
      CharacterName.roseDoolan => CharacterModel(
        name: name,
        displayName: 'Rose Doolan',
        abilityText: 'Coi tất cả người chơi xa hơn +1. Khi tấn công tầm +1.',
        startingHp: 4,
      ),
    };
  }

  // ─────────────────────────────────────────
  // PASSIVE — kiểm tra trước khi đánh BANG
  // ─────────────────────────────────────────

  // Willy và Jose có thể đánh nhiều BANG
  static bool canPlayBang(PlayerModel player, int bangPlayedThisTurn) {
    if (bangPlayedThisTurn == 0) return true; // Ai cũng được đánh BANG đầu tiên

    return switch (player.character.name) {
      CharacterName.willyTheKid  => true, // Không giới hạn
      CharacterName.joseDelgado  => bangPlayedThisTurn < 2, // Tối đa 2
      _ => false,
    };
  }

  // Calamity Jane dùng MISS như BANG và ngược lại
  static bool canUseMissAsBang(PlayerModel player) {
    return player.character.name == CharacterName.calamityJane;
  }

  // Rose Doolan tầm bắn +1
  static int getAttackRangeBonus(PlayerModel player) {
    return player.character.name == CharacterName.roseDoolan ? 1 : 0;
  }

  // Rose Doolan phòng thủ +1 (khó bị bắn hơn)
  static int getDefenseRangeBonus(PlayerModel player) {
    return player.character.name == CharacterName.roseDoolan ? 1 : 0;
  }

  // ─────────────────────────────────────────
  // TRIGGER — kích hoạt khi có sự kiện xảy ra
  // ─────────────────────────────────────────

  // Gọi sau mỗi lần có player bị loại
  static GameState onPlayerEliminated({
    required GameState state,
    required PlayerModel eliminated,
    required PlayerModel killer,
  }) {
    var currentState = state;

    // Sheriff Dan — rút 3 bài khi có người bị loại
    for (final player in state.alivePlayers) {
      if (player.character.name == CharacterName.sheriffDan) {
        currentState = _drawCards(currentState, player.id, 3);
      }
    }

    // Vulture Sam — lấy hết bài của người bị loại
    final vultureSam = state.alivePlayers
        .where((p) => p.character.name == CharacterName.vultureSam)
        .firstOrNull;

    if (vultureSam != null && eliminated.id != vultureSam.id) {
      final allCards = [...eliminated.hand, ...eliminated.equipment];
      final updated = vultureSam.copyWith(
        hand: [...vultureSam.hand, ...allCards],
      );
      currentState = _updatePlayer(currentState, updated);
    }

    // Doc Holliday — rút 2 bài khi hạ gục người (trừ Sheriff)
    if (killer.character.name == CharacterName.docHolliday &&
        eliminated.role != Role.sheriff) {
      currentState = _drawCards(currentState, killer.id, 2);
    }

    return currentState;
  }

  // Gọi lúc bắt đầu draw phase — xử lý draw đặc biệt
  static (GameState, List<CardModel>) onDrawPhase({
    required GameState state,
    required PlayerModel player,
  }) {
    return switch (player.character.name) {
      CharacterName.pedroRamirez => _drawPedroRamirez(state, player),
      CharacterName.blackJack    => _drawBlackJack(state, player),
      CharacterName.kitCarlson   => _drawKitCarlson(state, player),
      _ => _drawNormal(state, player),
    };
  }

  // Belle Starr — bỏ trang bị thay vì mất máu
  static GameState onHitByBang({
    required GameState state,
    required PlayerModel target,
    required CardModel equipmentToSacrifice,
  }) {
    if (target.character.name != CharacterName.belleStarr) return state;
    if (!target.equipment.any((c) => c.id == equipmentToSacrifice.id)) {
      return state;
    }

    final updated = target.copyWith(
      equipment: target.equipment
          .where((c) => c.id != equipmentToSacrifice.id)
          .toList(),
    );
    var newState = _updatePlayer(state, updated);
    return _addToDiscard(newState, equipmentToSacrifice);
  }

  // Lucky Duke — lật 2 bài chọn 1 khi kiểm tra Jail/Dynamite
  static CardModel onFlipCheck({
    required GameState state,
    required PlayerModel player,
    required CardModel card1,
    required CardModel card2,
    required bool Function(CardModel) isGood,
  }) {
    if (player.character.name != CharacterName.luckyDuke) return card1;
    return isGood(card1) ? card1 : card2;
  }

  // Sid Ketchum — bỏ 2 bài để hồi máu
  static GameState sidKetchumHeal({
    required GameState state,
    required PlayerModel player,
    required CardModel card1,
    required CardModel card2,
  }) {
    if (player.character.name != CharacterName.sidKetchum) return state;
    if (player.hp >= player.maxHp) return state;

    final updated = player.copyWith(
      hp: player.hp + 1,
      hand: player.hand
          .where((c) => c.id != card1.id && c.id != card2.id)
          .toList(),
    );
    var newState = _updatePlayer(state, updated);
    newState = _addToDiscard(newState, card1);
    return _addToDiscard(newState, card2);
  }

  // ─────────────────────────────────────────
  // DRAW HELPERS
  // ─────────────────────────────────────────

  static (GameState, List<CardModel>) _drawNormal(
      GameState state,
      PlayerModel player,
      ) {
    final drawn = state.deck.take(2).toList();
    final newDeck = state.deck.skip(2).toList();
    final updated = player.copyWith(hand: [...player.hand, ...drawn]);
    final newState = _updatePlayer(
      state.copyWith(deck: newDeck),
      updated,
    );
    return (newState, drawn);
  }

  static (GameState, List<CardModel>) _drawPedroRamirez(
      GameState state,
      PlayerModel player,
      ) {
    if (state.discard.isEmpty) return _drawNormal(state, player);

    // Rút bài đầu tiên từ discard
    final fromDiscard = state.discard.last;
    final fromDeck = state.deck.first;
    final newDiscard = state.discard.sublist(0, state.discard.length - 1);
    final newDeck = state.deck.skip(1).toList();

    final updated = player.copyWith(
      hand: [...player.hand, fromDiscard, fromDeck],
    );
    final newState = _updatePlayer(
      state.copyWith(deck: newDeck, discard: newDiscard),
      updated,
    );
    return (newState, [fromDiscard, fromDeck]);
  }

  static (GameState, List<CardModel>) _drawBlackJack(
      GameState state,
      PlayerModel player,
      ) {
    final drawn = state.deck.take(2).toList();
    var newDeck = state.deck.skip(2).toList();
    var allDrawn = List<CardModel>.from(drawn);

    // Bài thứ 2 là Rô hoặc Bích → rút thêm 1
    final second = drawn.length > 1 ? drawn[1] : null;
    if (second != null &&
        (second.suit == Suit.diamonds || second.suit == Suit.spades)) {
      final bonus = newDeck.first;
      allDrawn.add(bonus);
      newDeck = newDeck.skip(1).toList();
    }

    final updated = player.copyWith(hand: [...player.hand, ...allDrawn]);
    final newState = _updatePlayer(
      state.copyWith(deck: newDeck),
      updated,
    );
    return (newState, allDrawn);
  }

  static (GameState, List<CardModel>) _drawKitCarlson(
      GameState state,
      PlayerModel player,
      ) {
    // Xem 3 bài trên cùng, chọn 2 giữ, trả 1 xuống cuối
    // Trong offline mode: AI chọn 2 bài đầu tiên
    // Trong online mode: UI sẽ cho player chọn
    final top3 = state.deck.take(3).toList();
    final kept = top3.take(2).toList();
    final returned = top3.last;

    final newDeck = [
      ...state.deck.skip(3),
      returned, // trả xuống cuối
    ];

    final updated = player.copyWith(hand: [...player.hand, ...kept]);
    final newState = _updatePlayer(
      state.copyWith(deck: newDeck),
      updated,
    );
    return (newState, kept);
  }

  // ─────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────

  static GameState _drawCards(GameState state, String playerId, int count) {
    final player = state.getPlayer(playerId)!;
    final drawn = state.deck.take(count).toList();
    final newDeck = state.deck.skip(count).toList();
    final updated = player.copyWith(hand: [...player.hand, ...drawn]);
    return _updatePlayer(state.copyWith(deck: newDeck), updated);
  }

  static GameState _updatePlayer(GameState state, PlayerModel updated) {
    return state.copyWith(
      players: state.players
          .map((p) => p.id == updated.id ? updated : p)
          .toList(),
    );
  }

  static GameState _addToDiscard(GameState state, CardModel card) {
    return state.copyWith(discard: [...state.discard, card]);
  }
}