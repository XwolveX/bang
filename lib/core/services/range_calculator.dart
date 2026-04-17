import 'dart:math';

import '../models/player_model.dart';

class RangeCalculator {
  // Tính khoảng cách từ attacker đến target
  static int calculate({
    required List<PlayerModel> alivePlayers,
    required PlayerModel attacker,
    required PlayerModel target,
  }) {
    // Bước 1: tính khoảng cách vật lý theo vòng tròn
    final int distance = _circularDistance(alivePlayers, attacker, target);

    // Bước 2: target có Mustang không? (+1 khó bắn hơn)
    final int mustangBonus = target.hasMustang ? 1 : 0;

    // Bước 3: attacker có Scope không? (-1 dễ bắn hơn)
    final int scopeBonus = attacker.hasScope ? 1 : 0;

    return distance + mustangBonus - scopeBonus;
  }

  // Kiểm tra attacker có thể bắn target không
  static bool canAttack({
    required List<PlayerModel> alivePlayers,
    required PlayerModel attacker,
    required PlayerModel target,
  }) {
    if (attacker.id == target.id) return false; // Không tự bắn mình

    final int distance = calculate(
      alivePlayers: alivePlayers,
      attacker: attacker,
      target: target,
    );

    return distance <= attacker.attackRange;
  }

  // Tính khoảng cách ngắn nhất theo vòng tròn
  static int _circularDistance(
      List<PlayerModel> alivePlayers,
      PlayerModel from,
      PlayerModel to,
      ) {
    final int fromIndex = alivePlayers.indexOf(from);
    final int toIndex = alivePlayers.indexOf(to);
    final int n = alivePlayers.length;

    // Khoảng cách đi xuôi chiều kim đồng hồ
    final int clockwise = (toIndex - fromIndex + n) % n;

    // Khoảng cách đi ngược chiều kim đồng hồ
    final int counterClockwise = n - clockwise;

    // Lấy khoảng cách ngắn nhất
    return min(clockwise, counterClockwise);
  }
}