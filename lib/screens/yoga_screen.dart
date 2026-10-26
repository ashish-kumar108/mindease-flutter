import 'package:flutter/material.dart';
import '../theme.dart';
import 'yoga_session_screen.dart';
import 'home_screen.dart';

class YogaScreen extends StatelessWidget {
  const YogaScreen({super.key});

  static final _sessions = [
    {
      'title': 'Morning Flow',
      'minutes': 15,
      'subtitle': 'Wake up gently with gentle stretches and breathwork.',
      'postures': [
        {'name': 'Cat-Cow', 'desc': 'Warm the spine with slow flexion/extension.'},
        {'name': 'Downward Dog', 'desc': 'Stretch the hamstrings and shoulders.'},
        {'name': 'Low Lunge', 'desc': 'Open the hips and stretch the front leg.'},
      ],
      'gradient': purpleBlueGradient,
    },
    {
      'title': 'Flex & Release',
      'minutes': 30,
      'subtitle': 'Improve mobility with hip and spine opening sequences.',
      'postures': [
        {'name': 'Pigeon Pose', 'desc': 'Deep hip opener to release tension.'},
        {'name': 'Bridge', 'desc': 'Strengthen the back and open the chest.'},
        {'name': 'Seated Twist', 'desc': 'Mobilize the spine and massage organs.'},
      ],
      'gradient': greenGradient,
    },
    {
      'title': 'Power Vinyasa',
      'minutes': 45,
      'subtitle': 'Build strength and heat with a dynamic flow.',
      'postures': [
        {'name': 'Warrior II', 'desc': 'Build leg strength and stability.'},
        {'name': 'Chaturanga', 'desc': 'Strengthen the arms and core.'},
        {'name': 'Crow Pose', 'desc': 'Arm balance to test focus and strength.'},
      ],
      'gradient': orangeGradient,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final navigator = Navigator.of(context);
            final didPop = await navigator.maybePop();
            if (!didPop) {
              navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => HomeScreen()));
            }
          },
        ),
        title: const Text('Yoga'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary.withAlpha(15)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Find your flow',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface)),
                const SizedBox(height: 6),
                Text('Short sequences to move, breathe and reset',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(217))),
                const SizedBox(height: 18),

                // horizontal session cards
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final s = _sessions[i];
                      final gradient = s['gradient'] as LinearGradient;
                      return _YogaCard(
                        title: s['title'] as String,
                        minutes: s['minutes'] as int,
                        subtitle: s['subtitle'] as String,
                        gradient: gradient,
                        onTap: () => _openSessionSheet(context, s),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                Text('More classes',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),

                // list of longer classes
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 6),
                      _ListClassTile(
                        icon: Icons.self_improvement,
                        iconColor: Colors.deepPurple,
                        title: 'Relax & Restore',
                        subtitle: 'Slow, supported sequences ideal before bed.',
                        minutes: 20,
                        gradient: pinkGradient,
                        onTap: () => _openSessionSheet(context, {
                            'title': 'Relax & Restore',
                            'minutes': 20,
                            'subtitle':
                                'Slow, supported sequences ideal before bed.',
                            'gradient': pinkGradient,
                            'postures': [
                              {'name': 'Child Pose', 'desc': 'Rest and lengthen the back.'},
                              {'name': 'Supported Bridge', 'desc': 'Gentle backbend with support.'},
                            ],
                          }),
                      ),
                      const Divider(color: Colors.white12),
                      _ListClassTile(
                        icon: Icons.accessibility_new,
                        iconColor: Colors.teal,
                        title: 'Core Strength',
                        subtitle:
                            'Focused core work to stabilize your practice.',
                        minutes: 25,
                        gradient: orangeGradient,
                        onTap: () => _openSessionSheet(context, {
                          'title': 'Core Strength',
                          'minutes': 25,
                          'subtitle':
                              'Focused core work to stabilize your practice.',
                          'gradient': orangeGradient,
                          'postures': [
                            {'name': 'Boat Pose', 'desc': 'Core strengthening balance.'},
                            {'name': 'Plank', 'desc': 'Build core and shoulder stability.'},
                          ],
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSessionSheet(BuildContext context, Map<String, Object> s) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (c) {
        final title = s['title'] as String;
        final minutes = s['minutes'] as int;
        final subtitle = s['subtitle'] as String;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  Text('$minutes min',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Session'),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
            onPressed: () {
            Navigator.of(context).pop();
            final postures = s['postures'] as List? ?? const [];
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => YogaSessionScreen(
                title: title,
                minutes: minutes,
                postures: postures)));
            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'))
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _YogaCard extends StatelessWidget {
  final String title;
  final int minutes;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _YogaCard(
      {required this.title,
      required this.minutes,
      required this.subtitle,
      required this.gradient,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: gradient.colors.last.withAlpha(31),
                blurRadius: 12,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
            const SizedBox(height: 6),
            Expanded(
                child: Text(subtitle,
                    style: const TextStyle(color: Colors.white70))),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$minutes min',
                    style: const TextStyle(color: Colors.white70)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.white24, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ListClassTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final int minutes;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ListClassTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: gradient.colors.first.withAlpha(36),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: Text('$minutes m',
          style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
