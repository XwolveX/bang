import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../core/theme/app_theme.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
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
                      Text(
                        'BANG!',
                        style: AppTheme.titleStyle.copyWith(fontSize: 48),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Card Game • Viễn Tây',
                        style: AppTheme.subtitleStyle,
                      ),
                      const SizedBox(height: 20),

                      // Chọn số người chơi
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.woodBorder,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.goldDim.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Số người chơi',
                              style: AppTheme.subtitleStyle,
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
                                    style: AppTheme.titleStyle.copyWith(fontSize: 36),
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
                            backgroundColor: AppTheme.goldAccent,
                            foregroundColor: AppTheme.textDark,
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
                width: 2,
                color: AppTheme.woodBorder,
              ),

              // ─── CỘT PHẢI — Nhập tên người chơi ───
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tên người chơi',
                        style: AppTheme.titleStyle.copyWith(fontSize: 20),
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
                              style: AppTheme.normalText,
                              decoration: InputDecoration(
                                hintText: 'Người chơi ${index + 1}',
                                hintStyle: AppTheme.normalText.copyWith(color: Colors.white38),
                                prefixIcon: Icon(
                                  index == 0 ? Icons.star : Icons.person,
                                  color: index == 0
                                      ? AppTheme.goldAccent
                                      : AppTheme.goldDim,
                                  size: 18,
                                ),
                                filled: true,
                                fillColor: AppTheme.woodBorder,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppTheme.goldDim.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppTheme.goldAccent,
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
          color: AppTheme.woodHighlight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: AppTheme.goldAccent, width: 1),
        ),
        child: Icon(icon, color: AppTheme.goldAccent, size: 20),
      ),
    );
  }
}
