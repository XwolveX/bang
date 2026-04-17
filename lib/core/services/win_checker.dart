import '../enums/game_enums.dart';
import '../models/game_state.dart';
import '../models/player_model.dart';

class WinChecker {
  // Kiểm tra sau mỗi hành động — trả về phe thắng hoặc null
  static String? check(GameState state) {
    final alive = state.alivePlayers;

    // Kiểm tra Sheriff còn sống không
    final bool sheriffAlive = alive.any((p) => p.role == Role.sheriff);

    // Kiểm tra còn Outlaw không
    final bool outlawAlive = alive.any((p) => p.role == Role.outlaw);

    // Kiểm tra còn Renegade không
    final bool renegadeAlive = alive.any((p) => p.role == Role.renegade);

    // Sheriff chết → Tội phạm thắng (kể cả Renegade thua)
    if (!sheriffAlive) {
      // Trường hợp đặc biệt: chỉ còn Renegade và Sheriff vừa chết
      // → Renegade thắng (là người duy nhất còn sống)
      if (alive.length == 1 && alive.first.role == Role.renegade) {
        return 'renegade';
      }
      return 'outlaw';
    }

    // Sheriff còn sống, không còn Outlaw và Renegade → Sheriff + Deputy thắng
    if (!outlawAlive && !renegadeAlive) {
      return 'sheriff';
    }

    // Game chưa kết thúc
    return null;
  }

  // Kiểm tra player có trong phe thắng không
  static bool isWinner(PlayerModel player, String? winner) {
    if (winner == null) return false;

    return switch (winner) {
      'sheriff' => player.role == Role.sheriff ||
          player.role == Role.deputy,
      'outlaw'  => player.role == Role.outlaw,
      'renegade' => player.role == Role.renegade,
      _ => false,
    };
  }

  // Xử lý khi Sheriff hạ gục Deputy — Sheriff mất toàn bộ bài
  static PlayerModel applySheriffPenalty(PlayerModel sheriff) {
    return sheriff.copyWith(
      hand: [],
      equipment: [],
    );
  }

  // Thưởng 3 bài khi hạ gục Outlaw
  static bool shouldReward(PlayerModel eliminated) {
    return eliminated.role == Role.outlaw;
  }
}