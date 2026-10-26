import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _quickActionsController =
      PageController(viewportFraction: 0.86);
  double _currentPage = 0.0;
  String _userName = 'User';
  late StreamSubscription<User?> _userSub;

  void _onTab(int index) => setState(() => _selectedIndex = index);

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Prefer displayName; if not set yet, fall back to the email prefix
      final name = (user.displayName != null && user.displayName!.isNotEmpty)
          ? user.displayName!
          : (user.email != null ? user.email!.split('@').first : 'User');
      setState(() => _userName = name);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    // Listen for profile updates so display name updates immediately
    _userSub = FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null && user.displayName != null) {
        setState(() => _userName = user.displayName!);
      }
    });
    _quickActionsController.addListener(() =>
        setState(() => _currentPage = _quickActionsController.page ?? 0.0));
  }

  @override
  void dispose() {
    _quickActionsController.dispose();
    _userSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgGradient = LinearGradient(
      colors: [
        theme.colorScheme.surface,
        theme.colorScheme.primary.withAlpha(15)
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final homeContent = Stack(
      children: [
        Container(decoration: BoxDecoration(gradient: bgGradient)),
        Positioned(
          top: -80,
          left: -60,
          child: _DecorativeBlob(size: 220, colors: [
            theme.colorScheme.secondary.withAlpha(46),
            theme.colorScheme.secondary.withAlpha(15)
          ]),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 10,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFEEF7FF),
                          child: Icon(Icons.person, color: Colors.black54)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good Morning, $_userName',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800, fontSize: 18),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Text('Breathe. Be here now.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(200),
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                    _GlassIconButton(
                        icon: Icons.notifications_none, onPressed: () {}),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, 8, 20, 100 + MediaQuery.of(context).padding.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  _StreakCard(),
                                  SizedBox(height: 12),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                                flex: 3,
                                child: Column(children: const [
                                  _LargeWhiteStat(
                                      title: 'Today',
                                      value: '12m',
                                      icon: Icons.access_time)
                                ])),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Quick Actions',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: PageView.builder(
                            controller: _quickActionsController,
                            padEnds: true,
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              final items = [
                                {
                                  'title': 'Meditation',
                                  'icon': Icons.self_improvement,
                                  'route': '/meditation'
                                },
                                {
                                  'title': 'Yoga',
                                  'icon': Icons.sports_gymnastics,
                                  'route': '/yoga'
                                },
                                {
                                  'title': 'Journal',
                                  'icon': Icons.book,
                                  'route': '/journal'
                                },
                                {
                                  'title': 'Sleep',
                                  'icon': Icons.bedtime,
                                  'route': '/sleep'
                                },
                              ];
                              final it = items[index];
                              final scale =
                                  (1 - ((index - _currentPage).abs() * 0.12))
                                      .clamp(0.88, 1.0);
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: index == 0 ? 8 : 10,
                                    right: index == 3 ? 16 : 10),
                                child: Transform.scale(
                                  scale: scale,
                                  child: _ReadableQuickActionCard(
                                    title: it['title'] as String,
                                    icon: it['icon'] as IconData,
                                    onTap: () => Navigator.pushNamed(
                                        context, it['route'] as String),
                                    accent: primaryGradient,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text('Highlights',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.92,
                          children: [
                            _HomeFeatureTile(
                                title: 'Daily Session',
                                subtitle: '10 min • Focused breathing',
                                icon: Icons.play_circle_fill,
                                onTap: () =>
                                    Navigator.pushNamed(context, '/meditation'),
                                accent: purpleBlueGradient),
                            _HomeFeatureTile(
                                title: 'Start Yoga',
                                subtitle: '15 min • Gentle flow',
                                icon: Icons.self_improvement,
                                onTap: () =>
                                    Navigator.pushNamed(context, '/yoga'),
                                accent: greenGradient),
                            _HomeFeatureTile(
                                title: 'Write Journal',
                                subtitle: 'Reflect on your day',
                                icon: Icons.book,
                                onTap: () =>
                                    Navigator.pushNamed(context, '/journal'),
                                accent: orangeGradient),
                            _HomeFeatureTile(
                                title: 'Mood Check',
                                subtitle: 'How are you feeling?',
                                icon: Icons.sentiment_satisfied,
                                onTap: () {},
                                accent: pinkGradient),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    Widget statsView() {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stats',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Today'),
                      SizedBox(height: 8),
                      Text('12 min',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Weekly'),
                      SizedBox(height: 8),
                      Text('1 hr 20 min',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget leaderboardView() {
      final sample = [
        {'name': _userName, 'minutes': 120},
        {'name': 'Ava', 'minutes': 95},
        {'name': 'Liam', 'minutes': 80},
        {'name': 'Noah', 'minutes': 70},
      ];
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Leaderboard',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: sample.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final row = sample[index];
                    final name = row['name']?.toString() ?? 'User';
                    return ListTile(
                      leading: CircleAvatar(
                          child: Text(name.isEmpty ? 'U' : name[0])),
                      title: Text(name),
                      trailing: Text('${row['minutes']}m'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [homeContent, statsView(), leaderboardView()],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                height: 64,
                decoration: BoxDecoration(color: Colors.white.withAlpha(178)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomNavItem(
                        icon: Icons.home,
                        label: 'Home',
                        selected: _selectedIndex == 0,
                        onTap: () => _onTab(0)),
                    _BottomNavItem(
                        icon: Icons.show_chart,
                        label: 'Stats',
                        selected: _selectedIndex == 1,
                        onTap: () => _onTab(1)),
                    const SizedBox(width: 48),
                    _BottomNavItem(
                        icon: Icons.leaderboard,
                        label: 'Leaderboard',
                        selected: _selectedIndex == 2,
                        onTap: () => _onTab(2)),
                    _BottomNavItem(
                        icon: Icons.settings,
                        label: 'Settings',
                        selected: _selectedIndex == 3,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DecorativeBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  const _DecorativeBlob({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle, gradient: RadialGradient(colors: colors)));
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _GlassIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
            color: Colors.white.withAlpha(12),
            child: IconButton(
                icon: Icon(icon, color: Colors.black54), onPressed: onPressed)),
      ),
    );
  }
}

class _ReadableQuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final LinearGradient accent;
  const _ReadableQuickActionCard(
      {required this.title,
      required this.icon,
      required this.onTap,
      required this.accent});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 12,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Row(children: [
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    gradient: accent, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: Colors.white)),
            const SizedBox(width: 14),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16))),
            const Icon(Icons.chevron_right, color: Colors.black26)
          ]),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ]),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('🔥 Streak', style: TextStyle(color: Colors.white)),
        SizedBox(height: 8),
        Text('7 days',
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _MiniStat(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: Colors.black54),
              ),
              const SizedBox(width: 8),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _GlassStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _GlassStatCard(
      {required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
          color: Colors.white.withAlpha(230),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 6))
          ]),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(title, style: const TextStyle(color: Colors.black54))
        ])
      ]),
    );
  }
}

class _LargeWhiteStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _LargeWhiteStat(
      {required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ]),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon,
                color: Theme.of(context).colorScheme.primary, size: 22)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.black54))
        ])
      ]),
    );
  }
}

class _HomeFeatureTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final LinearGradient? accent;
  const _HomeFeatureTile(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.onTap,
      this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 8,
                decoration: BoxDecoration(
                  gradient: accent ?? primaryGradient,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8)),
                        child: Icon(icon),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(subtitle,
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 12)),
                          ],
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

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _BottomNavItem(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color =
        selected ? Theme.of(context).colorScheme.primary : Colors.black54;
    return GestureDetector(
        onTap: onTap,
        child: SizedBox(
            width: 64,
            height: double.infinity,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              FittedBox(
                  child: Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                      maxLines: 1))
            ])));
  }
}
