import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expert_professional/screens/call_screen.dart';
import 'package:expert_professional/services/ringtone_service.dart';
import 'package:expert_professional/services/call_service.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final String callerName;
  final String channelName;
  final String? callerId;
  final double pricePerMinute;
  final String callType;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callerName,
    required this.channelName,
    this.callerId,
    this.pricePerMinute = 3.0,
    this.callType = 'video',
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  late Timer _waveTimer;
  List<double> _waveFluctuations = List.generate(35, (index) => 10.0 + (index % 3) * 15.0);

  @override
  void initState() {
    super.initState();
    RingtoneService().startRingtone();
    // Simulate real-time fluctuating sound waves
    _waveTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (mounted) {
        setState(() {
          _waveFluctuations = List.generate(35, (index) {
            return 8.0 + (index * 7.5 + DateTime.now().millisecondsSinceEpoch ~/ 100) % 45.0;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _waveTimer.cancel();
    RingtoneService().stopRingtone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Incoming Call',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Spacer to balance back arrow
                ],
              ),

              // Avatar with thick yellow glow ring
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFC107).withValues(alpha: 0.35),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFFFC107), width: 3),
                      ),
                    ),
                    const CircleAvatar(
                      radius: 78,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200'),
                    ),
                  ],
                ),
              ),

              // Name, category and rates
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.callerName,
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Relationship • English',
                    style: TextStyle(color: Color(0xFF8A8A93), fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '₹ 5 /min',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // Waveform audio visualizer
              SizedBox(
                height: 80,
                width: double.infinity,
                child: CustomPaint(
                  painter: WaveformPainter(amplitudes: _waveFluctuations),
                ),
              ),

              // Action decline/accept buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline
                  SizedBox(
                    width: 140,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.call_end, color: Colors.white),
                      label: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      onPressed: () {
                        CallService().rejectCall(widget.callId);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),

                  // Accept
                  SizedBox(
                    width: 140,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.call, color: Colors.black),
                      label: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                      onPressed: () {
                        CallService().acceptCall(widget.callId);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CallScreen(
                              expertName: widget.callerName,
                              expertId: widget.callerId ?? widget.channelName,
                              pricePerMinute: widget.pricePerMinute,
                              channelName: widget.channelName,
                              callId: widget.callId,
                              callType: widget.callType,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// Waveform Painter
class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  WaveformPainter({required this.amplitudes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / (amplitudes.length * 1.6);
    final spacing = barWidth * 0.6;

    for (int i = 0; i < amplitudes.length; i++) {
      final double x = i * (barWidth + spacing);
      final double h = amplitudes[i];
      final double y = (size.height - h) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, h),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) => true;
}
