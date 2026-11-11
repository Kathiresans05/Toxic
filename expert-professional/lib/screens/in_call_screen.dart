import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expert_professional/constants.dart';
import 'package:expert_professional/services/socket_service.dart';

class InCallScreen extends StatefulWidget {
  final String callerName;
  final String channelName;
  final String callType; // 'audio' or 'video'

  const InCallScreen({
    super.key,
    required this.callerName,
    required this.channelName,
    this.callType = 'audio',
  });

  @override
  State<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends State<InCallScreen> with SingleTickerProviderStateMixin {
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isVideoEnabled = false;
  int _callDurationSeconds = 0;
  Timer? _timer;

  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _isVideoEnabled = widget.callType == 'video';
    _startTimer();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _endCall() {
    _timer?.cancel();
    SocketService().sendEvent('CALL_END', {
      'channelName': widget.channelName,
      'durationSeconds': _callDurationSeconds,
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Call Ended. Duration: ${_formatDuration(_callDurationSeconds)}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, color: Colors.greenAccent, size: 16),
                const SizedBox(width: 6),
                Text(
                  'End-to-End Encrypted ${widget.callType.toUpperCase()} Call',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Caller Info & Timer
            Text(
              widget.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDuration(_callDurationSeconds),
                style: TextStyle(
                  color: ExpertColors.primaryYellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const Spacer(),

            // Avatar / Video View Center Widget
            Center(
              child: _isVideoEnabled
                  ? Container(
                      width: 240,
                      height: 320,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: ExpertColors.primaryYellow, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam, color: ExpertColors.primaryYellow, size: 60),
                          const SizedBox(height: 12),
                          const Text(
                            'Video Stream Active',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber.shade900.withValues(alpha: 0.3),
                          border: Border.all(color: ExpertColors.primaryYellow, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: ExpertColors.primaryYellow.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 80,
                            color: ExpertColors.primaryYellow,
                          ),
                        ),
                      ),
                    ),
            ),

            const Spacer(),

            // Call Controls Toolbar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(36),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute Button
                  IconButton(
                    iconSize: 28,
                    icon: Icon(
                      _isMuted ? Icons.mic_off : Icons.mic,
                      color: _isMuted ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                    },
                  ),

                  // Speaker Button
                  IconButton(
                    iconSize: 28,
                    icon: Icon(
                      _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      color: _isSpeakerOn ? ExpertColors.primaryYellow : Colors.white60,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSpeakerOn = !_isSpeakerOn;
                      });
                    },
                  ),

                  // Video Toggle Button
                  IconButton(
                    iconSize: 28,
                    icon: Icon(
                      _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                      color: _isVideoEnabled ? ExpertColors.primaryYellow : Colors.white60,
                    ),
                    onPressed: () {
                      setState(() {
                        _isVideoEnabled = !_isVideoEnabled;
                      });
                    },
                  ),

                  // End Call Button
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
