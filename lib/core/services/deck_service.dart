import 'dart:math';
import '../enums/game_enums.dart';
import '../models/card_model.dart';

class DeckService {
  static final Random _random = Random();

  // Tạo bộ bài 80 lá đầy đủ
  static List<CardModel> createDeck() {
    final List<CardModel> deck = [];

    // Helper tạo bài nhanh
    void add(CardType type, Suit suit, int value) {
      deck.add(CardModel(
        id: '${type.name}_${suit.name}_$value',
        type: type,
        suit: suit,
        value: value,
      ));
    }

    // BANG! — 25 lá
    add(CardType.bang, Suit.spades, 2);
    add(CardType.bang, Suit.spades, 3);
    add(CardType.bang, Suit.spades, 4);
    add(CardType.bang, Suit.spades, 5);
    add(CardType.bang, Suit.spades, 6);
    add(CardType.bang, Suit.spades, 7);
    add(CardType.bang, Suit.spades, 8);
    add(CardType.bang, Suit.spades, 9);
    add(CardType.bang, Suit.hearts, 1);
    add(CardType.bang, Suit.hearts, 2);
    add(CardType.bang, Suit.hearts, 3);
    add(CardType.bang, Suit.hearts, 4);
    add(CardType.bang, Suit.hearts, 5);
    add(CardType.bang, Suit.hearts, 6);
    add(CardType.bang, Suit.hearts, 7);
    add(CardType.bang, Suit.hearts, 8);
    add(CardType.bang, Suit.hearts, 9);
    add(CardType.bang, Suit.diamonds, 1);
    add(CardType.bang, Suit.diamonds, 2);
    add(CardType.bang, Suit.diamonds, 3);
    add(CardType.bang, Suit.diamonds, 4);
    add(CardType.bang, Suit.diamonds, 5);
    add(CardType.bang, Suit.diamonds, 6);
    add(CardType.bang, Suit.diamonds, 7);
    add(CardType.bang, Suit.diamonds, 8);

    // MISS! — 12 lá
    add(CardType.miss, Suit.spades, 10);
    add(CardType.miss, Suit.spades, 11);
    add(CardType.miss, Suit.spades, 12);
    add(CardType.miss, Suit.spades, 13);
    add(CardType.miss, Suit.clubs, 2);
    add(CardType.miss, Suit.clubs, 3);
    add(CardType.miss, Suit.clubs, 4);
    add(CardType.miss, Suit.clubs, 5);
    add(CardType.miss, Suit.clubs, 6);
    add(CardType.miss, Suit.clubs, 7);
    add(CardType.miss, Suit.clubs, 8);
    add(CardType.miss, Suit.clubs, 9);

    // BEER — 6 lá
    add(CardType.beer, Suit.hearts, 10);
    add(CardType.beer, Suit.hearts, 11);
    add(CardType.beer, Suit.hearts, 12);
    add(CardType.beer, Suit.hearts, 13);
    add(CardType.beer, Suit.hearts, 6);
    add(CardType.beer, Suit.hearts, 7);

    // GATLING — 1 lá
    add(CardType.gatling, Suit.hearts, 10);

    // INDIANS — 2 lá
    add(CardType.indians, Suit.diamonds, 9);
    add(CardType.indians, Suit.diamonds, 10);

    // STAGECOACH — 2 lá
    add(CardType.stagecoach, Suit.spades, 9);
    add(CardType.stagecoach, Suit.spades, 9);

    // WELLS FARGO — 1 lá
    add(CardType.wellsFargo, Suit.hearts, 3);

    // CAT BALOU — 4 lá
    add(CardType.catBalou, Suit.diamonds, 11);
    add(CardType.catBalou, Suit.diamonds, 12);
    add(CardType.catBalou, Suit.diamonds, 13);
    add(CardType.catBalou, Suit.hearts, 9);

    // PANIC! — 4 lá
    add(CardType.panic, Suit.hearts, 11);
    add(CardType.panic, Suit.hearts, 12);
    add(CardType.panic, Suit.diamonds, 8);
    add(CardType.panic, Suit.spades, 1);

    // JAIL — 3 lá
    add(CardType.jail, Suit.spades, 11);
    add(CardType.jail, Suit.spades, 12);
    add(CardType.jail, Suit.hearts, 4);

    // DYNAMITE — 1 lá
    add(CardType.dynamite, Suit.hearts, 2);

    // VOLCANIC — 2 lá
    add(CardType.volcanic, Suit.spades, 10);
    add(CardType.volcanic, Suit.clubs, 10);

    // SCHOFIELD — 3 lá
    add(CardType.schofield, Suit.spades, 13);
    add(CardType.schofield, Suit.clubs, 11);
    add(CardType.schofield, Suit.clubs, 12);

    // REMINGTON — 1 lá
    add(CardType.remington, Suit.clubs, 13);

    // CARABINE — 1 lá
    add(CardType.carabine, Suit.diamonds, 13);

    // WINCHESTER — 1 lá
    add(CardType.winchester, Suit.spades, 8);

    // BARREL — 2 lá
    add(CardType.barrel, Suit.spades, 12);
    add(CardType.barrel, Suit.spades, 13);

    // MUSTANG — 2 lá
    add(CardType.mustang, Suit.hearts, 8);
    add(CardType.mustang, Suit.hearts, 9);

    // SCOPE — 1 lá
    add(CardType.scope, Suit.spades, 1);

    return deck;
  }

  // Xáo bài — Fisher-Yates shuffle
  static List<CardModel> shuffle(List<CardModel> deck) {
    final List<CardModel> shuffled = List.from(deck);
    for (int i = shuffled.length - 1; i > 0; i--) {
      final int j = _random.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
  }

  // Chia bài cho người chơi — trả về (deck còn lại, bài của từng người)
  static (List<CardModel>, List<List<CardModel>>) dealCards({
    required List<CardModel> deck,
    required List<int> hpPerPlayer, // HP của từng người = số bài được chia
  }) {
    final remaining = List<CardModel>.from(deck);
    final hands = <List<CardModel>>[];

    for (final hp in hpPerPlayer) {
      final hand = remaining.take(hp).toList();
      remaining.removeRange(0, hp);
      hands.add(hand);
    }

    return (remaining, hands);
  }
}