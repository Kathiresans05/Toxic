import 'package:flutter/material.dart';
import 'package:expert_professional/services/ringtone_service.dart';
import 'package:expert_professional/screens/incoming_call_screen.dart';
import 'package:expert_professional/screens/call_screen.dart';
import 'package:expert_professional/services/call_service.dart';

class CallNotificationService {
  static final CallNotificationService _instance = CallNotificationService._internal();
  factory CallNotificationService() => _instance;
  CallNotificationService._internal();

  OverlayEntry? _overlayEntry;

  void showIncomingCallBanner({
    required BuildContext context,
    required String callId,
    required String callerName,
    required String channelName,
    double pricePerMinute = 5.0,
    String callType = 'video',
  }) {
    // Stop any previous banner & start ringtone
    hideBanner();
    RingtoneService().startRingtone();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                hideBanner();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IncomingCallScreen(
                      callId: callId,
                      callerName: callerName,
                      channelName: channelName,
                      pricePerMinute: pricePerMinute,
                      callType: callType,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141418),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFC107), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // Phone Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC107),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_in_talk_rounded, color: Colors.black, size: 22),
                    ),
                    const SizedBox(width: 12),
                    // Caller Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                callerName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6)),
                                ),
                                child: const Text('LIVE CALL', style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('Rate: ₹${pricePerMinute.toStringAsFixed(0)}/min • Tap to view', style: const TextStyle(color: Color(0xFF8A8A93), fontSize: 11)),
                        ],
                      ),
                    ),
                    // Action Buttons
                    IconButton(
                      icon: const Icon(Icons.call_end_rounded, color: Colors.redAccent, size: 24),
                      onPressed: () {
                        CallService().rejectCall(callId);
                        hideBanner();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_rounded, color: Color(0xFFFFC107), size: 24),
                      onPressed: () {
                        hideBanner();
                        CallService().acceptCall(callId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CallScreen(
                              expertName: callerName,
                              expertId: 'live_call',
                              pricePerMinute: pricePerMinute,
                              channelName: channelName,
                              callId: callId,
                              callType: callType,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hideBanner() {
    RingtoneService().stopRingtone();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
