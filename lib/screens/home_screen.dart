import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    7,
        (_) => TextEditingController(),
  );
  int _playerCount = 4;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  void _startGame() {
    final names = List.generate(_playerCount, (index) {
      final text = _controllers[index].text.trim();
      return text.isEmpty ? 'Người chơi ${index + 1}' : text;
    });
    ref.read(gameProvider.notifier).startGame(names);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      body: SafeArea(
        child: Row(
          children: [

            // ─── CỘT TRÁI — Title + chọn số người ───
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text(
                      'RUNG HOÀNG',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Card Game • Viễn Tây',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8B7355),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Chọn số người chơi
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2317),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Số người chơi',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _CountButton(
                                icon: Icons.remove,
                                onTap: () {
                                  if (_playerCount > 4) {
                                    setState(() => _playerCount--);
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24),
                                child: Text(
                                  '$_playerCount',
                                  style: const TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _CountButton(
                                icon: Icons.add,
                                onTap: () {
                                  if (_playerCount < 7) {
                                    setState(() => _playerCount++);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Nút bắt đầu
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: const Color(0xFF2C1810),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'BẮT ĐẦU GAME',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),

            // Divider giữa 2 cột
            Container(
              width: 1,
              color: const Color(0xFF3D2317),
            ),

            // ─── CỘT PHẢI — Nhập tên người chơi ───
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tên người chơi',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 4,
                        ),
                        itemCount: _playerCount,
                        itemBuilder: (context, index) {
                          return TextField(
                            controller: _controllers[index],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Người chơi ${index + 1}',
                              hintStyle: const TextStyle(
                                  color: Colors.white38),
                              prefixIcon: Icon(
                                index == 0 ? Icons.star : Icons.person,
                                color: index == 0
                                    ? const Color(0xFFD4AF37)
                                    : Colors.white38,
                                size: 18,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF3D2317),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// Widget nút tăng/giảm
class _CountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CountButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF5C3D2E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: const Color(0xFFD4AF37), width: 1),
        ),
        child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
      ),
    );
  }
}
