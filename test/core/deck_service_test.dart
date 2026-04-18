import 'package:flutter_test/flutter_test.dart';
import 'package:bang/core/services/deck_service.dart';
import 'package:bang/core/enums/game_enums.dart';

void main() {
  group('DeckService', () {

    test('tạo đúng 74 lá bài', () {
      final deck = DeckService.createDeck();
      expect(deck.length, 74);
    });

    test('đúng số lượng từng loại bài', () {
      final deck = DeckService.createDeck();

      expect(deck.where((c) => c.type == CardType.bang).length,       25);
      expect(deck.where((c) => c.type == CardType.miss).length,       12);
      expect(deck.where((c) => c.type == CardType.beer).length,        6);
      expect(deck.where((c) => c.type == CardType.gatling).length,     1);
      expect(deck.where((c) => c.type == CardType.indians).length,     2);
      expect(deck.where((c) => c.type == CardType.stagecoach).length,  2);
      expect(deck.where((c) => c.type == CardType.wellsFargo).length,  1);
      expect(deck.where((c) => c.type == CardType.catBalou).length,    4);
      expect(deck.where((c) => c.type == CardType.panic).length,       4);
      expect(deck.where((c) => c.type == CardType.jail).length,        3);
      expect(deck.where((c) => c.type == CardType.dynamite).length,    1);
      expect(deck.where((c) => c.type == CardType.volcanic).length,    2);
      expect(deck.where((c) => c.type == CardType.schofield).length,   3);
      expect(deck.where((c) => c.type == CardType.remington).length,   1);
      expect(deck.where((c) => c.type == CardType.carabine).length,    1);
      expect(deck.where((c) => c.type == CardType.winchester).length,  1);
      expect(deck.where((c) => c.type == CardType.barrel).length,      2);
      expect(deck.where((c) => c.type == CardType.mustang).length,     2);
      expect(deck.where((c) => c.type == CardType.scope).length,       1);
    });

    test('tất cả id là unique — không có lá bài trùng', () {
      final deck = DeckService.createDeck();
      final ids = deck.map((c) => c.id).toSet();
      expect(ids.length, deck.length);
    });

    test('shuffle không mất bài', () {
      final deck = DeckService.createDeck();
      final shuffled = DeckService.shuffle(deck);
      expect(shuffled.length, 74);
    });

    test('shuffle giữ đúng số lượng từng loại bài', () {
      final deck = DeckService.createDeck();
      final shuffled = DeckService.shuffle(deck);
      expect(shuffled.where((c) => c.type == CardType.bang).length, 25);
      expect(shuffled.where((c) => c.type == CardType.miss).length, 12);
    });

    test('shuffle thay đổi thứ tự bài', () {
      final deck = DeckService.createDeck();
      final shuffled = DeckService.shuffle(deck);

      final sameOrder = deck
          .asMap()
          .entries
          .every((entry) => entry.value.id == shuffled[entry.key].id);

      expect(sameOrder, false);
    });

    test('chia bài đúng số lượng — 4 người chơi', () {
      final deck = DeckService.shuffle(DeckService.createDeck());

      final (remaining, hands) = DeckService.dealCards(
        deck: deck,
        hpPerPlayer: [5, 4, 4, 4],
      );

      expect(hands.length,    4);  // 4 người
      expect(hands[0].length, 5);  // Sheriff 5 máu → 5 bài
      expect(hands[1].length, 4);
      expect(hands[2].length, 4);
      expect(hands[3].length, 4);
      expect(remaining.length, 57); // 74 - 17 = 57
    });

    test('chia bài đúng số lượng — 7 người chơi', () {
      final deck = DeckService.shuffle(DeckService.createDeck());

      final (remaining, hands) = DeckService.dealCards(
        deck: deck,
        hpPerPlayer: [5, 4, 4, 4, 4, 4, 4],
      );

      expect(hands.length,    7);
      expect(hands[0].length, 5);  // Sheriff
      expect(hands[1].length, 4);
      expect(remaining.length, 74 - 5 - 4 - 4 - 4 - 4 - 4 - 4); // 45
    });

    test('chia bài không làm mất bài', () {
      final deck = DeckService.createDeck();
      final (remaining, hands) = DeckService.dealCards(
        deck: deck,
        hpPerPlayer: [5, 4, 4, 4],
      );

      // Tổng bài sau khi chia = deck ban đầu
      final totalAfter = remaining.length +
          hands.fold(0, (sum, hand) => sum + hand.length);
      expect(totalAfter, 74);
    });

  });
}