import '../enums/game_enums.dart';
import 'card_model.dart';
import 'player_model.dart';

class GameState {
  final String roomId;
  final GamePhase phase;
  final List<PlayerModel> players;
  final List<CardModel> deck;          // Bài chưa rút
  final List<CardModel> discard;       // Bài đã bỏ
  final int turnIndex;                 // Index của player đang đến lượt
  final int bangPlayedThisTurn;        // Số BANG đã đánh trong lượt này
  final String? pendingTargetFor;      // Card nào đang chờ chọn mục tiêu
  final String? winner;                // Phe thắng (null nếu game chưa kết thúc)
  final List<String> actionLog;        // Log hành động để hiển thị UI

  const GameState({
    required this.roomId,
    required this.phase,
    required this.players,
    required this.deck,
    required this.discard,
    required this.turnIndex,
    this.bangPlayedThisTurn = 0,
    this.pendingTargetFor,
    this.winner,
    this.actionLog = const [],
  });

  // Player đang đến lượt
  PlayerModel get currentPlayer => players[turnIndex];

  // Chỉ những player còn sống
  List<PlayerModel> get alivePlayers =>
      players.where((p) => p.isAlive).toList();

  // Tìm player theo id
  PlayerModel? getPlayer(String id) =>
      players.where((p) => p.id == id).firstOrNull;

  // Tìm Sheriff
  PlayerModel get sheriff =>
      players.firstWhere((p) => p.role == Role.sheriff);

  // Đã đánh BANG rồi chưa? (trừ Volcanic và Willy)
  bool get hasPlayedBang => bangPlayedThisTurn >= 1;

  GameState copyWith({
    String? roomId,
    GamePhase? phase,
    List<PlayerModel>? players,
    List<CardModel>? deck,
    List<CardModel>? discard,
    int? turnIndex,
    int? bangPlayedThisTurn,
    String? pendingTargetFor,
    String? winner,
    List<String>? actionLog,
  }) {
    return GameState(
      roomId: roomId ?? this.roomId,
      phase: phase ?? this.phase,
      players: players ?? this.players,
      deck: deck ?? this.deck,
      discard: discard ?? this.discard,
      turnIndex: turnIndex ?? this.turnIndex,
      bangPlayedThisTurn: bangPlayedThisTurn ?? this.bangPlayedThisTurn,
      pendingTargetFor: pendingTargetFor ?? this.pendingTargetFor,
      winner: winner ?? this.winner,
      actionLog: actionLog ?? this.actionLog,
    );
  }
}