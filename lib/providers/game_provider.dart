import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/enums/game_enums.dart';
import '../core/models/card_model.dart';
import '../core/models/game_state.dart';
import '../core/models/player_model.dart';
import '../core/services/card_resolver.dart';
import '../core/services/character_ability_service.dart';
import '../core/services/deck_service.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
      (ref) => GameNotifier(),
);

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(_createInitialState());

  // ─────────────────────────────────────────
  // SETUP
  // ─────────────────────────────────────────

  void startGame(List<String> playerNames) {
    final int playerCount = playerNames.length;

    // Bước 1: Gán role TRƯỚC — HP phụ thuộc vào role
    final roles = _assignRoles(playerCount);

    // Debug — kiểm tra role nào là Sheriff
    for (int i = 0; i < playerCount; i++) {
      print('${playerNames[i]} → ${roles[i]}');
    }

    // Bước 2: HP theo role
    final hpList = List.generate(playerCount, (i) {
      final hp = roles[i] == Role.sheriff ? 5 : 4;
      print('${playerNames[i]} HP = $hp');
      return hp;
    });

    // Bước 3: Tạo và xáo bài
    final deck = DeckService.shuffle(DeckService.createDeck());

    // Bước 4: Chia bài theo HP
    final (remainingDeck, hands) = DeckService.dealCards(
      deck: deck,
      hpPerPlayer: hpList,
    );

    // Bước 5: Gán nhân vật ngẫu nhiên
    final characters = _assignCharacters(playerCount);

    // Bước 6: Tạo players
    final players = List.generate(playerCount, (i) {
      final hp = hpList[i];
      final player = PlayerModel(
        id: 'player_$i',
        name: playerNames[i],
        role: roles[i],
        hp: hp,
        maxHp: hp,
        hand: hands[i],
        equipment: [],
        character: CharacterAbilityService.createCharacter(characters[i]),
        seatIndex: i,
      );
      print('Created: ${player.name} role=${player.role} hp=${player.hp} maxHp=${player.maxHp}');
      return player;
    });

    // Bước 7: Sheriff đi trước
    final sheriffIndex = roles.indexOf(Role.sheriff);
    print('Sheriff index = $sheriffIndex → ${playerNames[sheriffIndex]}');

    state = GameState(
      roomId: 'local',
      phase: GamePhase.draw,
      players: players,
      deck: remainingDeck,
      discard: [],
      turnIndex: sheriffIndex,
      bangPlayedThisTurn: 0,
    );
  }

  // ─────────────────────────────────────────
  // GAME ACTIONS
  // ─────────────────────────────────────────

  void drawCards() {
    if (state.phase != GamePhase.draw) return;

    final currentPlayer = state.currentPlayer;
    final (newState, drawn) = CharacterAbilityService.onDrawPhase(
      state: state,
      player: currentPlayer,
    );

    print('${currentPlayer.name} rút ${drawn.length} bài');
    state = newState.copyWith(phase: GamePhase.play);
  }

  void playCard(CardModel card, {String? targetId}) {
    if (state.phase != GamePhase.play) return;

    final currentPlayer = state.currentPlayer;

    // Kiểm tra giới hạn BANG
    if (card.type == CardType.bang) {
      final canPlay = CharacterAbilityService.canPlayBang(
        currentPlayer,
        state.bangPlayedThisTurn,
      );
      if (!canPlay) {
        print('${currentPlayer.name} đã đánh BANG rồi!');
        return;
      }
    }

    // Xử lý effect
    var newState = CardResolver.playCard(
      state: state,
      playerId: currentPlayer.id,
      card: card,
      targetId: targetId,
    );

    // Tăng đếm BANG
    if (card.type == CardType.bang) {
      newState = newState.copyWith(
        bangPlayedThisTurn: newState.bangPlayedThisTurn + 1,
      );
    }

    state = newState;
  }

  void endTurn() {
    if (state.phase != GamePhase.play) return;

    final currentPlayer = state.currentPlayer;

    // Cần bỏ bài không?
    if (currentPlayer.hand.length > currentPlayer.hp) {
      print('${currentPlayer.name} cần bỏ ${currentPlayer.hand.length - currentPlayer.hp} bài');
      state = state.copyWith(phase: GamePhase.discard);
      return;
    }

    _nextTurn();
  }

  void discardCard(CardModel card) {
    if (state.phase != GamePhase.discard) return;

    final currentPlayer = state.currentPlayer;
    final updatedPlayer = currentPlayer.copyWith(
      hand: currentPlayer.hand
          .where((c) => c.id != card.id)
          .toList(),
    );

    final newState = state.copyWith(
      players: state.players
          .map((p) => p.id == currentPlayer.id ? updatedPlayer : p)
          .toList(),
      discard: [...state.discard, card],
    );

    // Đã bỏ đủ chưa?
    if (updatedPlayer.hand.length <= updatedPlayer.hp) {
      // Cập nhật state trước rồi mới next turn
      state = newState;
      _nextTurn();
    } else {
      state = newState;
    }
  }

  // ─────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────

  void _nextTurn() {
    var nextIndex = (state.turnIndex + 1) % state.players.length;

    // Skip player đã chết
    int safety = 0;
    while (!state.players[nextIndex].isAlive) {
      nextIndex = (nextIndex + 1) % state.players.length;
      safety++;
      if (safety > state.players.length) break; // Tránh infinite loop
    }

    print('--- Lượt tiếp: ${state.players[nextIndex].name} ---');

    state = state.copyWith(
      phase: GamePhase.draw,
      turnIndex: nextIndex,
      bangPlayedThisTurn: 0,
    );
  }

  static List<Role> _assignRoles(int playerCount) {
    final Map<int, List<Role>> roleMap = {
      4: [Role.sheriff, Role.outlaw, Role.outlaw, Role.renegade],
      5: [Role.sheriff, Role.deputy, Role.outlaw, Role.outlaw, Role.renegade],
      6: [Role.sheriff, Role.deputy, Role.outlaw, Role.outlaw, Role.outlaw, Role.renegade],
      7: [Role.sheriff, Role.deputy, Role.deputy, Role.outlaw, Role.outlaw, Role.outlaw, Role.renegade],
    };

    final roles = List<Role>.from(roleMap[playerCount]!);
    roles.shuffle();
    return roles;
  }

  static List<CharacterName> _assignCharacters(int playerCount) {
    final allCharacters = CharacterName.values.toList()..shuffle();
    return allCharacters.take(playerCount).toList();
  }

  static GameState _createInitialState() {
    return GameState(
      roomId: 'local',
      phase: GamePhase.waiting,
      players: [],
      deck: [],
      discard: [],
      turnIndex: 0,
    );
  }
}