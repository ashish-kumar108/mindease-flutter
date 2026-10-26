import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'home_screen.dart';
import '../data/cat_cow_data.dart';

class YogaSessionScreen extends StatefulWidget {
  final String title;
  final int minutes;
  final List<dynamic> postures;

  const YogaSessionScreen(
      {super.key,
      required this.title,
      required this.minutes,
      this.postures = const []});

  @override
  State<YogaSessionScreen> createState() => _YogaSessionScreenState();
}

class _YogaSessionScreenState extends State<YogaSessionScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  AudioPlayer? _player;
  String? _audioStatus;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.minutes * 60;
    _player = AudioPlayer();
  }

  bool _isCatCowSession(YogaSessionScreen w) {
    // Look for 'Cat-Cow' posture name in provided postures OR match title
    if (w.postures.isNotEmpty) {
      for (final p in w.postures) {
        if (p is Map && (p['name'] as String?)?.toLowerCase().contains('cat') == true) return true;
      }
    }
    return w.title.toLowerCase().contains('cat') || w.title.toLowerCase().contains('cow');
  }

  Future<void> _playCatCowAudio() async {
    if (_player == null) return;
    setState(() => _audioStatus = 'Loading...');
    try {
      // assemble playlist from catCowData -> assets.audio
      final audio = catCowData['assets']?['audio'] as Map?;
      final intro = audio?['intro'] as String?;
      final loop = audio?['loop'] as String?;
      final outro = audio?['outro'] as String?;

      // NOTE: assets must be declared in pubspec; attempt to load from assets/audio/
      final playlist = <AudioSource>[];
      if (intro != null) playlist.add(AudioSource.uri(Uri.parse('asset:///${'assets/audio/$intro'}')));
      if (loop != null) playlist.add(AudioSource.uri(Uri.parse('asset:///${'assets/audio/$loop'}')));
      if (outro != null) playlist.add(AudioSource.uri(Uri.parse('asset:///${'assets/audio/$outro'}')));

      if (playlist.isEmpty) throw Exception('No audio assets found in data');

      await _player!.setAudioSource(ConcatenatingAudioSource(children: playlist));
      await _player!.play();
      setState(() => _audioStatus = 'Playing');
    } catch (e) {
      setState(() => _audioStatus = 'Error: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player?.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 1) {
        t.cancel();
        setState(() {
          _isRunning = false;
          _remainingSeconds = 0;
        });
        _showComplete();
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = widget.minutes * 60;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    final total = widget.minutes * 60;
    if (total == 0) return 0.0;
    return 1.0 - (_remainingSeconds / total);
  }

  Future<void> _showComplete() async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Session complete'),
        content: const Text('Great job — your yoga session is complete.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final circleSize = MediaQuery.of(context).size.width * 0.64;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary.withAlpha(15)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                const SizedBox(height: 6),
                Center(
                  child: SizedBox(
                    width: circleSize,
                    height: circleSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: circleSize,
                          height: circleSize,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 12,
                            color: Theme.of(context).colorScheme.onPrimary,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        Container(
                          width: circleSize * 0.72,
                          height: circleSize * 0.72,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withAlpha(31),
                                    blurRadius: 12,
                                    offset: const Offset(0, 8))
                              ]),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(_formatTime(_remainingSeconds),
                                      key: ValueKey(_remainingSeconds),
                                      style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900)),
                                ),
                                const SizedBox(height: 8),
                                Text('${widget.minutes} min',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha(230),
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(_isRunning ? 'Pause' : 'Start'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(width: 14),
                    OutlinedButton.icon(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.replay),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.surface.withAlpha(15),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('What to focus on',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                            'Breathe smoothly. Move with awareness. Modify poses as needed.',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        Text('Postures',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        // Show a vertical list of postures (name + short desc)
                        Expanded(
                          child: widget.postures.isEmpty
                              ? Text('No postures provided for this session.',
                                  style:
                                      Theme.of(context).textTheme.bodySmall)
                              : ListView.separated(
                                  itemCount: widget.postures.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (c, i) {
                                    final p = widget.postures[i] as Map?;
                                    final name = p != null && p['name'] != null
                                        ? p['name'] as String
                                        : 'Pose ${i + 1}';
                                    final desc = p != null && p['desc'] != null
                                        ? p['desc'] as String
                                        : '';
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Theme.of(context).colorScheme.primary.withAlpha(20),
                                        child: const Icon(Icons.self_improvement),
                                      ),
                                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      subtitle: Text(desc),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 8),
                        // If this session is Cat-Cow, show a small player for the assembled audio
                        if (_isCatCowSession(widget)) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _playCatCowAudio,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Play Cat-Cow audio'),
                              ),
                              const SizedBox(width: 8),
                              if (_audioStatus != null) Text(_audioStatus!),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
