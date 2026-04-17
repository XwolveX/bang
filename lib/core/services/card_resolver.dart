import '../enums/game_enums.dart';
import '../models/card_model.dart';
import '../models/game_state.dart';
import '../models/player_model.dart';
import 'range_calculator.dart';
import 'win_checker.dart';

class CardResolver {
  // Điểm vào chính — gọi khi player đánh 1 lá bài
  static GameState playCard({
    required GameState state,
    required String playerId,
    required CardModel card,
    String? targetId, // null nếu bài không cần mục tiêu
  }) {
    final player = state.getPlayer(playerId)!;

    // Xóa bài khỏi tay player trước
    final updatedPlayer = player.copyWith(
      hand: player.hand.where((c) => c.id != card.id).toList(),
    );
    var currentState = _updatePlayer(state, updatedPlayer);

    // Xử lý theo loại bài
    return switch (card.type) {
      CardType.bang       => _resolveBang(currentState, playerId, targetId!),
      CardType.beer       => _resolveBeer(currentState, playerId),
      CardType.gatling    => _resolveGatling(currentState, playerId),
      CardType.indians    => _resolveIndians(currentState, playerId),
      CardType.stagecoach => _resolveStagecoach(currentState, playerId),
      CardType.wellsFargo => _resolveWellsFargo(currentState, playerId),
      CardType.catBalou   => _resolveCatBalou(currentState, playerId, targetId!),
      CardType.panic      => _resolvePanic(currentState, playerId, targetId!),
      CardType.jail       => _resolveJail(currentState, playerId, targetId!),
      CardType.dynamite   => _resolveEquipment(currentState, playerId, card),
      _                   => _resolveEquipment(currentState, playerId, card),
    };
  }

  // ─────────────────────────────────────────
  // BANG
  // ─────────────────────────────────────────
  static GameState _resolveBang(
      GameState state,
      String attackerId,
      String targetId,
      ) {
    final target = state.getPlayer(targetId)!;

    // Kiểm tra Barrel trước
    if (target.hasBarrel) {
      final barrelCard = _drawOneForCheck(state);
      if (barrelCard.suit == Suit.hearts) {
        // Barrel tự né — không cần MISS
        return _addLog(state, '${target.name} né bằng Barrel!');
      }
    }

    // Target có MISS trên tay không?
    final missCard = target.hand
        .where((c) => c.type == CardType.miss)
        .firstOrNull;

    if (missCard != null) {
      // AI tự động dùng MISS — trong hot-seat mode, UI sẽ hỏi
      final updatedTarget = target.copyWith(
        hand: target.hand.where((c) => c.id != missCard.id).toList(),
      );
      var newState = _updatePlayer(state, updatedTarget);
      newState = _addToDiscard(newState, missCard);
      return _addLog(newState, '${target.name} né được!');
    }

    // Không né được → mất máu
    return _dealDamage(state, targetId, 1);
  }

  // ─────────────────────────────────────────
  // BEER
  // ─────────────────────────────────────────
  static GameState _resolveBeer(GameState state, String playerId) {
    // Vô hiệu khi chỉ còn 2 người
    if (state.alivePlayers.length <= 2) {
      return _addLog(state, 'Beer vô hiệu khi còn 2 người!');
    }

    final player = state.getPlayer(playerId)!;

    // Không hồi nếu đã đầy máu
    if (player.hp >= player.maxHp) {
      return _addLog(state, '${player.name} đã đầy máu!');
    }

    final healed = player.copyWith(hp: player.hp + 1);
    final newState = _updatePlayer(state, healed);
    return _addLog(newState, '${player.name} hồi 1 máu (${healed.hp}/${healed.maxHp})');
  }

  // ─────────────────────────────────────────
  // GATLING
  // ─────────────────────────────────────────
  static GameState _resolveGatling(GameState state, String attackerId) {
    var currentState = state;
    final attacker = state.getPlayer(attackerId)!;

    for (final target in state.alivePlayers) {
      if (target.id == attackerId) continue; // Không tự bắn mình

      // Mỗi người cần 1 MISS
      final missCard = target.hand
          .where((c) => c.type == CardType.miss)
          .firstOrNull;

      if (missCard != null) {
        final updated = target.copyWith(
          hand: target.hand.where((c) => c.id != missCard.id).toList(),
        );
        currentState = _updatePlayer(currentState, updated);
        currentState = _addToDiscard(currentState, missCard);
        currentState = _addLog(currentState, '${target.name} né Gatling!');
      } else {
        currentState = _dealDamage(currentState, target.id, 1);
      }
    }

    return _addLog(currentState, '${attacker.name} bắn Gatling!');
  }

  // ─────────────────────────────────────────
  // INDIANS
  // ─────────────────────────────────────────
  static GameState _resolveIndians(GameState state, String playerId) {
    var currentState = state;
    final player = state.getPlayer(playerId)!;

    for (final target in state.alivePlayers) {
      if (target.id == playerId) continue;

      // Mỗi người cần 1 BANG
      final bangCard = target.hand
          .where((c) => c.type == CardType.bang)
          .firstOrNull;

      if (bangCard != null) {
        final updated = target.copyWith(
          hand: target.hand.where((c) => c.id != bangCard.id).toList(),
        );
        currentState = _updatePlayer(currentState, updated);
        currentState = _addToDiscard(currentState, bangCard);
        currentState = _addLog(currentState, '${target.name} chặn Indians!');
      } else {
        currentState = _dealDamage(currentState, target.id, 1);
      }
    }

    return _addLog(currentState, '${player.name} tung Indians!');
  }

  // ─────────────────────────────────────────
  // STAGECOACH & WELLS FARGO
  // ─────────────────────────────────────────
  static GameState _resolveStagecoach(GameState state, String playerId) {
    return _drawCards(state, playerId, 2);
  }

  static GameState _resolveWellsFargo(GameState state, String playerId) {
    return _drawCards(state, playerId, 3);
  }

  // ─────────────────────────────────────────
  // CAT BALOU
  // ─────────────────────────────────────────
  static GameState _resolveCatBalou(
      GameState state,
      String playerId,
      String targetCardId, // id của bài bị bỏ
      ) {
    // Tìm target có bài này
    for (final player in state.players) {
      // Tìm trong tay
      final inHand = player.hand.where((c) => c.id == targetCardId).firstOrNull;
      if (inHand != null) {
        final updated = player.copyWith(
          hand: player.hand.where((c) => c.id != targetCardId).toList(),
        );
        var newState = _updatePlayer(state, updated);
        newState = _addToDiscard(newState, inHand);
        return _addLog(newState, 'Cat Balou bắt ${player.name} bỏ bài!');
      }

      // Tìm trong equipment
      final inEquip = player.equipment
          .where((c) => c.id == targetCardId)
          .firstOrNull;
      if (inEquip != null) {
        final updated = player.copyWith(
          equipment: player.equipment
              .where((c) => c.id != targetCardId)
              .toList(),
        );
        var newState = _updatePlayer(state, updated);
        newState = _addToDiscard(newState, inEquip);
        return _addLog(newState, 'Cat Balou phá trang bị của ${player.name}!');
      }
    }

    return state; // Không tìm thấy bài
  }

  // ─────────────────────────────────────────
  // PANIC
  // ─────────────────────────────────────────
  static GameState _resolvePanic(
      GameState state,
      String playerId,
      String targetCardId,
      ) {
    final attacker = state.getPlayer(playerId)!;

    for (final player in state.players) {
      if (player.id == playerId) continue;

      final inHand = player.hand
          .where((c) => c.id == targetCardId)
          .firstOrNull;
      if (inHand != null) {
        final updatedTarget = player.copyWith(
          hand: player.hand.where((c) => c.id != targetCardId).toList(),
        );
        final updatedAttacker = attacker.copyWith(
          hand: [...attacker.hand, inHand],
        );
        var newState = _updatePlayer(state, updatedTarget);
        newState = _updatePlayer(newState, updatedAttacker);
        return _addLog(newState, '${attacker.name} lấy bài của ${player.name}!');
      }
    }

    return state;
  }

  // ─────────────────────────────────────────
  // JAIL
  // ─────────────────────────────────────────
  static GameState _resolveJail(
      GameState state,
      String playerId,
      String targetId,
      ) {
    final target = state.getPlayer(targetId)!;
    final updated = target.copyWith(isInJail: true);
    final newState = _updatePlayer(state, updated);
    return _addLog(newState, '${target.name} bị bỏ tù!');
  }

  // ─────────────────────────────────────────
  // EQUIPMENT (Volcanic, Mustang, Barrel, v.v.)
  // ─────────────────────────────────────────
  static GameState _resolveEquipment(
      GameState state,
      String playerId,
      CardModel card,
      ) {
    final player = state.getPlayer(playerId)!;
    final updated = player.copyWith(
      equipment: [...player.equipment, card],
    );
    final newState = _updatePlayer(state, updated);
    return _addLog(newState, '${player.name} trang bị ${card.type.name}!');
  }

  // ─────────────────────────────────────────
  // HELPER METHODS
  // ─────────────────────────────────────────

  // Trừ máu và kiểm tra player có chết không
  static GameState _dealDamage(
      GameState state,
      String targetId,
      int amount,
      ) {
    final target = state.getPlayer(targetId)!;
    final newHp = target.hp - amount;

    if (newHp <= 0) {
      return _eliminatePlayer(state, targetId);
    }

    final updated = target.copyWith(hp: newHp);
    var newState = _updatePlayer(state, updated);
    return _addLog(newState, '${target.name} mất $amount máu (${newHp}/${target.maxHp})');
  }

  // Loại player khỏi game
  static GameState _eliminatePlayer(GameState state, String playerId) {
    final player = state.getPlayer(playerId)!;
    final eliminated = player.copyWith(isAlive: false, hp: 0);
    var newState = _updatePlayer(state, eliminated);

    // Thưởng 3 bài nếu hạ Outlaw
    if (WinChecker.shouldReward(player)) {
      // Tìm người vừa gây sát thương — tạm thời dùng currentPlayer
      newState = _drawCards(newState, newState.currentPlayer.id, 3);
    }

    // Phạt Sheriff nếu hạ Deputy
    if (player.role == Role.deputy) {
      final sheriff = newState.sheriff;
      final penalized = WinChecker.applySheriffPenalty(sheriff);
      newState = _updatePlayer(newState, penalized);
    }

    newState = _addLog(newState, '${player.name} bị loại! (${player.role.name})');

    // Kiểm tra thắng thua
    final winner = WinChecker.check(newState);
    if (winner != null) {
      return newState.copyWith(
        phase: GamePhase.gameOver,
        winner: winner,
      );
    }

    return newState;
  }

  // Rút n bài từ deck
  static GameState _drawCards(GameState state, String playerId, int count) {
    final player = state.getPlayer(playerId)!;
    var deck = List<CardModel>.from(state.deck);
    var discard = List<CardModel>.from(state.discard);

    // Hết bài → xáo lại discard
    if (deck.length < count) {
      deck = [...deck, ...discard];
      discard = [];
    }

    final drawn = deck.take(count).toList();
    deck.removeRange(0, drawn.length);

    final updated = player.copyWith(hand: [...player.hand, ...drawn]);
    return state.copyWith(
      players: state.players.map((p) =>
      p.id == playerId ? updated : p
      ).toList(),
      deck: deck,
      discard: discard,
    );
  }

  // Lật 1 bài để kiểm tra (Barrel, Dynamite, Jail)
  static CardModel _drawOneForCheck(GameState state) {
    return state.deck.isNotEmpty ? state.deck.first : state.discard.first;
  }

  // Thêm bài vào discard
  static GameState _addToDiscard(GameState state, CardModel card) {
    return state.copyWith(discard: [...state.discard, card]);
  }

  // Cập nhật 1 player trong danh sách
  static GameState _updatePlayer(GameState state, PlayerModel updated) {
    return state.copyWith(
      players: state.players.map((p) =>
      p.id == updated.id ? updated : p
      ).toList(),
    );
  }

  // Thêm log hành động
  static GameState _addLog(GameState state, String message) {
    return state.copyWith(
      actionLog: [...state.actionLog, message],
    );
  }
}