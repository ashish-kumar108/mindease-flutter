import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_audio/just_audio.dart';
import '../theme.dart';
import 'home_screen.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final List<int> _durations = [5, 10, 15, 30]; // minutes
  int _selectedIndex = 1; // default 10 minutes

  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  // audio
  AudioPlayer? _audioPlayer;
  // per-session audio mappings (title -> asset path as declared in pubspec.yaml)
  final Map<String, String> _sessionAssetPaths = {};
  // optional mapping from duration (minutes) to session title
  final Map<int, String> _durationToSessionTitle = {};

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _durations[_selectedIndex] * 60;
    _audioPlayer = AudioPlayer();
    // Map session titles to assets declared in pubspec.yaml
    // Make sure these asset files exist under assets/audio/ and are listed in pubspec.yaml
    _sessionAssetPaths['Morning Calm'] = 'assets/audio/morning_meditation.mp3';
    _sessionAssetPaths['Stress Relief'] =
        'assets/audio/stressRelief_meditation.mp3';
    _sessionAssetPaths['Deep Relaxation'] = 'assets/audio/deep_meditation.mp3';
    _sessionAssetPaths['Sleep Meditation'] =
        'assets/audio/sleep_meditation.mp3';

    // map durations to sessions so selecting a duration chip can also play audio
    _durationToSessionTitle[5] = 'Morning Calm';
    _durationToSessionTitle[10] = 'Stress Relief';
    _durationToSessionTitle[15] = 'Deep Relaxation';
    _durationToSessionTitle[30] = 'Sleep Meditation';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    _audioPlayer?.dispose();
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
        _showSessionComplete();
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    // pause timer and audio playback
    _audioPlayer?.pause();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _durations[_selectedIndex] * 60;
    });
    // stop any playing audio when timer is reset
    _stopAudio();
  }

  void _selectDuration(int index, {bool playAudio = false}) {
    _timer?.cancel();
    setState(() {
      _selectedIndex = index;
      _isRunning = false;
      _remainingSeconds = _durations[_selectedIndex] * 60;
    });
    if (playAudio) {
      final minutes = _durations[index];
      final title = _durationToSessionTitle[minutes];
      if (title != null) {
        _playSessionAudio(title);
      }
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    final total = _durations[_selectedIndex] * 60;
    if (total == 0) return 0.0;
    return 1.0 - (_remainingSeconds / total);
  }

  Future<void> _showSessionComplete() async {
    if (!mounted) return;
    // stop session audio when completed
    // Capture a local reference to the BuildContext to avoid using the
    // State object's context across an async gap.
    final localContext = context;
    await _stopAudio();
    // Schedule the dialog to show on the next frame to avoid using
    // the State's BuildContext across an async gap.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: localContext,
        builder: (c) => AlertDialog(
          title: const Text('Session complete'),
          content: const Text('Well done — you completed your session.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      );
    });
  }

  void _selectAndStartForTitle(int minutes, String? title) {
    final idx = _durations.indexOf(minutes);
    if (idx == -1) return;
    _selectDuration(idx);
    Future.delayed(const Duration(milliseconds: 120), () {
      _startTimer();
      if (title != null) _playSessionAudio(title);
    });
  }

  // Runtime file picking/attaching removed. Add audio files as assets in
  // pubspec.yaml and map session titles to asset paths in `_sessionAssetPaths`.

  Future<void> _playSessionAudio(String title) async {
    final assetPath = _sessionAssetPaths[title];
    if (assetPath == null) return; // nothing configured for this session
    // Capture messenger before any awaits so we don't use BuildContext
    // across async gaps.
    final messenger = ScaffoldMessenger.of(context);
    try {
      // stop any previous audio, load the asset and loop it for the session
      await _audioPlayer?.stop();
      await _audioPlayer?.setAsset(assetPath);
      await _audioPlayer?.setLoopMode(LoopMode.one);
      await _audioPlayer?.play();
      setState(() {});
    } catch (e) {
      // Show snackbar after the current frame to avoid async-context use.
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          messenger.showSnackBar(SnackBar(
            content: Text('Could not play "$title" (asset: $assetPath).'),
          ));
        });
      }
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer?.pause();
      await _audioPlayer?.seek(Duration.zero);
      setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () async {
            // Try to pop first. Avoid using BuildContext across the await by
            // capturing the NavigatorState before awaiting.
            final navigator = Navigator.of(context);
            final didPop = await navigator.maybePop();
            if (!didPop) {
              // Fallback: replace with Home screen so user lands on app home
              navigator.pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
            }
          },
        ),
        title: const Text('Meditation'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withAlpha(235),
              theme.colorScheme.secondary.withAlpha(15)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final circleSize = (maxWidth * 0.62).clamp(140.0, 260.0);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    16 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Focus on your breath',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // circular progress area
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: circleSize,
                              height: circleSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: _progress,
                                    strokeWidth: circleSize * 0.06,
                                    color: theme.colorScheme.onPrimary,
                  backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                                  ),
                                  // solid squircle for time display (stronger/darker, no blur)
                                  Container(
                                    width: circleSize * 0.72,
                                    height: circleSize * 0.72,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(26),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(31),
                                          blurRadius: 12,
                                          offset: const Offset(0, 8),
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _formatTime(_remainingSeconds),
                                            style: TextStyle(
                                                color:
                                                    theme.colorScheme.onSurface,
                                                fontSize: 28,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${_durations[_selectedIndex]} min',
                                            style: TextStyle(
                        color: theme
                          .colorScheme.onSurface
                          .withAlpha(230),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // control buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed:
                                      _isRunning ? _pauseTimer : _startTimer,
                                  icon: Icon(_isRunning
                                      ? Icons.pause
                                      : Icons.play_arrow),
                                  label: Text(_isRunning ? 'Pause' : 'Start'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: _resetTimer,
                                  icon: const Icon(Icons.replay),
                                  label: const Text('Reset'),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: theme.colorScheme.outline),
                                    foregroundColor:
                                        theme.colorScheme.onSurface,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // session audio is configured via assets in pubspec.yaml
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                _audioPlayer != null &&
                                        _audioPlayer!.playing &&
                                        _audioPlayer!.sequence != null
                                    ? 'Playing session audio...'
                                    : 'No session audio playing',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // duration selector chips (modern rounded-rect style)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: List.generate(_durations.length, (i) {
                            final selected = i == _selectedIndex;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _DurationChip(
                                label: '${_durations[i]}m',
                                selected: selected,
                                onTap: () =>
                                    _selectDuration(i, playAudio: true),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // recommended sessions
                      Text('Recommended',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white.withAlpha(242),
                fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _SmallSessionCard(
                                title: 'Morning Calm',
                                minutes: 5,
                                gradient: purpleBlueGradient,
                                onTap: () =>
                                    _selectAndStartForTitle(5, 'Morning Calm')),
                            _SmallSessionCard(
                                title: 'Stress Relief',
                                minutes: 10,
                                gradient: greenGradient,
                                onTap: () => _selectAndStartForTitle(
                                    10, 'Stress Relief')),
                            _SmallSessionCard(
                                title: 'Deep Relaxation',
                                minutes: 15,
                                gradient: pinkGradient,
                                onTap: () => _selectAndStartForTitle(
                                    15, 'Deep Relaxation')),
                            _SmallSessionCard(
                                title: 'Sleep Meditation',
                                minutes: 30,
                                gradient: primaryGradient,
                                onTap: () => _selectAndStartForTitle(
                                    30, 'Sleep Meditation')),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(minWidth: 64),
        decoration: BoxDecoration(
          gradient: selected ? primaryGradient : null,
          color: selected ? null : Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? null
              : Border.all(color: Colors.white.withAlpha(31)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(31),
                    blurRadius: 8,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Icon(Icons.check, size: 16, color: theme.colorScheme.onPrimary)
            else
              const SizedBox(width: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallSessionCard extends StatelessWidget {
  final String title;
  final int minutes;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _SmallSessionCard({
    required this.title,
    required this.minutes,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.last.withAlpha(31),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$minutes min',
                          style: const TextStyle(color: Colors.white70)),
                      const Icon(Icons.play_arrow, color: Colors.white)
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}
