import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_professional/providers/auth_provider.dart';
import 'package:expert_professional/services/api_service.dart';

class ExpertColors {
  static const Color background = Color(0xFF08080A);
  static const Color cardBg = Color(0xFF141418);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color primaryYellowDark = Color(0xFFFFB800);
  static const Color textMuted = Color(0xFF8A8A93);
  static const Color borderColor = Color(0xFF24242A);
}

enum RecordingState { idle, recording, recorded, playing }

class VoiceBioScreen extends StatefulWidget {
  const VoiceBioScreen({super.key});

  @override
  State<VoiceBioScreen> createState() => _VoiceBioScreenState();
}

class _VoiceBioScreenState extends State<VoiceBioScreen> with TickerProviderStateMixin {
  RecordingState _state = RecordingState.idle;
  int _secondsRecorded = 0;
  Timer? _timer;
  bool _isSaving = false;
  late AnimationController _pulseController;
  late AnimationController _waveController;

  final List<double> _waveAmplitudes = List.generate(24, (index) => 0.2 + (index % 5) * 0.15);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _state = RecordingState.recording;
      _secondsRecorded = 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRecorded >= 30) {
        _stopRecording();
      } else {
        setState(() {
          _secondsRecorded++;
        });
      }
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _state = RecordingState.recorded;
    });
  }

  void _playRecording() {
    setState(() {
      _state = RecordingState.playing;
    });

    int playElapsed = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (playElapsed >= _secondsRecorded) {
        timer.cancel();
        setState(() {
          _state = RecordingState.recorded;
        });
      } else {
        playElapsed++;
      }
    });
  }

  void _resetRecording() {
    _timer?.cancel();
    setState(() {
      _state = RecordingState.idle;
      _secondsRecorded = 0;
    });
  }

  Future<void> _saveVoiceBio() async {
    setState(() {
      _isSaving = true;
    });

    final String simulatedVoiceUrl = 'https://expert-cdn.com/audio/voice_bio_${DateTime.now().millisecondsSinceEpoch}.mp3';
    await ApiService().updateExpertProfile(voiceSampleUrl: simulatedVoiceUrl);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      Provider.of<AuthProvider>(context, listen: false).refreshProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Voice Bio updated successfully! Customers can now preview your audio.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String activeTimerText = '00:${_secondsRecorded.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: ExpertColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ExpertColors.primaryYellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Voice Bio Intro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Info Banner Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ExpertColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ExpertColors.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ExpertColors.primaryYellow.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.graphic_eq_rounded, color: ExpertColors.primaryYellow, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '30-Second Voice Preview',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Record a friendly greeting introducing your expertise. Customers listen before calling!',
                            style: TextStyle(color: ExpertColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Central Pulse Recording Container
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Glowing Ring when recording or playing
                    if (_state == RecordingState.recording || _state == RecordingState.playing)
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 180 + (_pulseController.value * 30),
                            height: 180 + (_pulseController.value * 30),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ExpertColors.primaryYellow.withValues(alpha: 0.15 * (1 - _pulseController.value)),
                              border: Border.all(
                                color: ExpertColors.primaryYellow.withValues(alpha: 0.4 * (1 - _pulseController.value)),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),

                    // Mic Central Button
                    GestureDetector(
                      onTap: () {
                        if (_state == RecordingState.idle) {
                          _startRecording();
                        } else if (_state == RecordingState.recording) {
                          _stopRecording();
                        }
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _state == RecordingState.recording
                                ? [const Color(0xFFE53935), const Color(0xFFD32F2F)]
                                : [const Color(0xFFFFC107), const Color(0xFFFFB800)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_state == RecordingState.recording ? Colors.red : ExpertColors.primaryYellow).withValues(alpha: 0.4),
                              blurRadius: 24,
                              spreadRadius: 4,
                            )
                          ],
                        ),
                        child: Icon(
                          _state == RecordingState.recording
                              ? Icons.stop_rounded
                              : _state == RecordingState.playing
                                  ? Icons.volume_up_rounded
                                  : Icons.mic_rounded,
                          size: 60,
                          color: _state == RecordingState.recording ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Digital Timer & Status Label
              Text(
                _state == RecordingState.idle
                    ? '30 Seconds Available'
                    : _state == RecordingState.recording
                        ? 'Recording: $activeTimerText / 00:30'
                        : _state == RecordingState.playing
                            ? 'Playing Audio Preview...'
                            : 'Audio Recorded ($activeTimerText)',
                style: TextStyle(
                  color: _state == RecordingState.recording ? Colors.redAccent : ExpertColors.primaryYellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Live Waveform Visualizer
              SizedBox(
                height: 48,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_waveAmplitudes.length, (index) {
                        double heightFactor = _waveAmplitudes[index];
                        if (_state == RecordingState.recording || _state == RecordingState.playing) {
                          heightFactor = (heightFactor + (_waveController.value * 0.4 * (index % 3 == 0 ? 1 : -0.5))).clamp(0.15, 1.0);
                        }
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          width: 4,
                          height: 40 * heightFactor,
                          decoration: BoxDecoration(
                            color: (_state == RecordingState.recording || _state == RecordingState.playing)
                                ? ExpertColors.primaryYellow
                                : ExpertColors.borderColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),

              const Spacer(),

              // Action Buttons Row
              if (_state == RecordingState.recorded || _state == RecordingState.playing) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _state == RecordingState.playing ? null : _playRecording,
                        icon: Icon(_state == RecordingState.playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                        label: Text(_state == RecordingState.playing ? 'Playing' : 'Listen Sample'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetRecording,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Re-record'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ExpertColors.textMuted,
                          side: const BorderSide(color: ExpertColors.borderColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveVoiceBio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ExpertColors.primaryYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Text('Save & Publish Voice Bio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ] else ...[
                Text(
                  _state == RecordingState.recording ? 'Tap Red Circle to Finish' : 'Tap Yellow Microphone to Start Recording',
                  style: const TextStyle(color: ExpertColors.textMuted, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
