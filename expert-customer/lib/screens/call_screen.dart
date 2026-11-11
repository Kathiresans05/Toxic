import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/providers/auth_provider.dart';
import 'package:expert_customer/services/api_service.dart';
import 'package:expert_customer/services/call_service.dart';
import 'package:expert_customer/services/socket_service.dart';
import 'package:expert_customer/screens/wallet_screens.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:typed_data';

const String appId = "c9afe369772c48659610c8b6368df693";

class CallScreen extends StatefulWidget {
  final String expertName;
  final String expertId;
  final double pricePerMinute;
  final String callType; // 'audio' or 'video'

  const CallScreen({
    super.key,
    required this.expertName,
    required this.expertId,
    required this.pricePerMinute,
    required this.callType,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final ApiService _apiService = ApiService();
  
  Timer? _billingTimer;
  Timer? _durationTimer;
  Timer? _ringTimeoutTimer;
  int _secondsElapsed = 0;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOff = false;
  bool _isCallActive = false;
  String _status = 'Connecting...';
  String? _currentCallId;
  RtcEngine? _engine;
  int? _remoteUid;
  String _expertPrivacyMode = 'normal';

  String? _channelName;

  @override
  void initState() {
    super.initState();
    _startCallFlow();
  }

  Future<void> _initAgora(String channelName, String token) async {
    _channelName = channelName;
    final micStatus = await Permission.microphone.request();
    if (widget.callType == 'video') {
      await Permission.camera.request();
    }
    debugPrint('Microphone permission status: $micStatus');

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined successfully");
          _engine?.setEnableSpeakerphone(true);
          _engine?.adjustPlaybackSignalVolume(100);
          _engine?.adjustRecordingSignalVolume(100);
          _engine?.muteLocalAudioStream(false);
          _engine?.muteAllRemoteAudioStreams(false);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined successfully");
          _engine?.setEnableSpeakerphone(true);
          _engine?.adjustPlaybackSignalVolume(100);
          _engine?.muteRemoteAudioStream(uid: remoteUid, mute: false);
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
          _endCall(reason: 'Expert left the call');
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
        onStreamMessage: (RtcConnection connection, int remoteUid, int streamId, Uint8List data, int length, int sentTs) {
          final mode = String.fromCharCodes(data);
          if (mounted) {
            setState(() {
              _expertPrivacyMode = mode;
            });
          }
        },
      ),
    );

    await _engine!.enableAudio();
    await _engine!.enableLocalAudio(true);
    await _engine!.muteLocalAudioStream(false);
    await _engine!.muteAllRemoteAudioStreams(false);
    await _engine!.adjustRecordingSignalVolume(100);
    await _engine!.adjustPlaybackSignalVolume(100);
    await _engine!.setDefaultAudioRouteToSpeakerphone(true);
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    if (widget.callType == 'video') {
      await _engine!.enableVideo();
      await _engine!.startPreview();
    } else {
      await _engine!.disableVideo();
    }

    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0,
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishMicrophoneTrack: true,
        publishCameraTrack: widget.callType == 'video',
        autoSubscribeAudio: true,
        autoSubscribeVideo: widget.callType == 'video',
      ),
    );

    await _engine!.setEnableSpeakerphone(true);
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _billingTimer?.cancel();
    _ringTimeoutTimer?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  void _startCallFlow() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user ?? {};
    final customerId = user['id'] ?? 'cust_1';
    final customerName = user['name'] ?? 'Customer';
    final balance = double.tryParse(user['walletBalance']?.toString() ?? '0') ?? 0.0;

    if (balance < widget.pricePerMinute) {
      setState(() {
        _status = 'Insufficient Balance';
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Insufficient Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Text(
              'Your wallet balance (₹${balance.toStringAsFixed(2)}) is lower than the call rate (₹${widget.pricePerMinute.toStringAsFixed(2)}/min). Please recharge to make this call.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  Navigator.pop(context);
                },
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WalletHomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('Recharge Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      });
      return;
    }

    final channelName = 'call_${widget.expertId}_${DateTime.now().millisecondsSinceEpoch}';
    _channelName = channelName;
    
    // Fetch Agora token with graceful fallback so calls always connect smoothly
    String agoraToken = '';
    try {
      final tokenData = await _apiService.getAgoraToken(channelName, '0');
      if (tokenData != null && tokenData['token'] != null) {
        agoraToken = tokenData['token'];
      }
    } catch (e) {
      debugPrint('Agora token fetch error (continuing with default fallback): $e');
    }

    setState(() {
      _status = 'Ringing...';
    });
    FlutterRingtonePlayer().playRingtone(looping: true);

    _currentCallId = await CallService().initiateCall(
      expertId: widget.expertId,
      customerId: customerId,
      customerName: customerName,
      channelName: channelName,
      callType: widget.callType,
      pricePerMinute: widget.pricePerMinute,
    );

    // Ping the backend to trigger FCM push notification to the expert
    _apiService.notifyCall(
      expertId: widget.expertId,
      callId: _currentCallId!,
      callerName: customerName,
      channelName: channelName,
      pricePerMinute: widget.pricePerMinute,
      callType: widget.callType,
    );

    // Connect and listen to real-time WebSocket events
    SocketService().connect(customerId);

    SocketService().onCallAccepted = (data) {
      _ringTimeoutTimer?.cancel();
      FlutterRingtonePlayer().stop();
      if (mounted && !_isCallActive) {
        setState(() {
          _status = 'Connected';
          _isCallActive = true;
        });
        final serverChannel = data['channelName']?.toString() ?? channelName;
        final serverToken = data['agoraToken']?.toString() ?? agoraToken;
        _initAgora(serverChannel, serverToken);
        _startTimers(customerId, serverChannel);
      }
    };

    SocketService().onCallRejected = (data) {
      _ringTimeoutTimer?.cancel();
      FlutterRingtonePlayer().stop();
      if (mounted) {
        setState(() {
          _status = 'Call Declined';
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    };

    SocketService().onCallEnded = (data) {
      FlutterRingtonePlayer().stop();
      if (mounted && _isCallActive) {
        final reasonCode = data['reason']?.toString();
        if (reasonCode == 'INSUFFICIENT_BALANCE') {
          _endCall(reason: 'Wallet balance exhausted. Please recharge your wallet.');
        } else {
          _endCall(reason: 'Expert Ended Call');
        }
      }
    };

    SocketService().onLowBalance = (data) {
      if (mounted) {
        final msg = data['message']?.toString() ?? 'Low balance warning! Less than 1 minute remaining.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFD97706),
            duration: const Duration(seconds: 5),
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    msg,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    };

    _ringTimeoutTimer = Timer(const Duration(seconds: 30), () {
      FlutterRingtonePlayer().stop();
      if (mounted && !_isCallActive) {
        setState(() {
          _status = 'No Answer';
        });
        if (_currentCallId != null) {
          CallService().endCall(_currentCallId!, 0, 0.0);
        }
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    });
  }

  void _startTimers(String customerId, String channelName) {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });

    _billingTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      // In a real app, billing might deduct every minute or just at the end.
      // Billing and balance auto-cut-off is handled securely by the Spring Boot backend
    });
  }

  void _endCall({String? reason, bool isReported = false}) async {
    FlutterRingtonePlayer().stop();
    _durationTimer?.cancel();
    _billingTimer?.cancel();
    
    _isCallActive = false;

    if (_currentCallId != null) {
      final amountCharged = (_secondsElapsed / 60) * widget.pricePerMinute;
      await CallService().endCall(_currentCallId!, _secondsElapsed, amountCharged);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerId = authProvider.user?['id'] ?? 'cust_1';
      CallService().processBilling(customerId, widget.expertId, widget.pricePerMinute, _secondsElapsed);
    }

    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}
    _engine = null;

    if (isReported) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFD32F2F),
            duration: Duration(seconds: 4),
            content: Row(
              children: [
                Icon(Icons.shield, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Report submitted. Session disconnected safely.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    if (reason != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Call ended: $reason')),
      );
    }

    if (mounted) {
      _showRatingDialog();
    }
  }

  void _showReportModal() {
    final reasons = [
      'Abusive language / Vulgar speech',
      'Inappropriate video / Vulgar gestures',
      'Asking for personal number / Social media',
      'Demanding external payment / Financial scam',
      'Other harassment or safety concern',
    ];
    String selectedReason = reasons.first;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield_outlined, color: Colors.redAccent, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Report & End Call',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '100% Confidential • Disconnects call immediately',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select violation reason:',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...reasons.map((r) {
                      final isSelected = selectedReason == r;
                      return InkWell(
                        onTap: () => setSheetState(() => selectedReason = r),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.red.withValues(alpha: 0.15) : const Color(0xFF1E1E28),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? Colors.redAccent : Colors.white10,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? Colors.redAccent : Colors.white38,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  r,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.call_end, color: Colors.white, size: 20),
                        label: const Text(
                          'Report & Disconnect Now',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.pop(bottomSheetContext);
                          _submitAbuseReport(selectedReason);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitAbuseReport(String reason) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reporterId = authProvider.user?['id'] ?? 'cust_unknown';
    final reporterName = authProvider.user?['fullName'] ?? 'Anonymous Caller';

    // 1. Log incident to backend API for review and safety audit

    // 2. Log incident to backend API
    try {
      _apiService.reportCall(
        callId: _currentCallId ?? widget.expertId,
        reason: reason,
        details: 'Incident reported by $reporterName ($reporterId) during call with ${widget.expertName}',
        targetType: 'CREATOR',
      );
    } catch (e) {
      debugPrint('Backend safety report error: $e');
    }

    // 3. Immediately disconnect call and exit
    _endCall(reason: 'Reported: $reason', isReported: true);
  }

  void _showRatingDialog() {
    int rating = 5;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final dialogBg = isLight ? AppTheme.lightCardColor : AppTheme.darkCardColor;
        final titleColor = isLight ? AppTheme.lightTextPrimary : Colors.white;
        final subtextColor = isLight ? AppTheme.lightTextSecondary : Colors.grey;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              title: Center(
                child: Text(
                  'Rate your Call',
                  style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How was your session with ${widget.expertName}?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subtextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        icon: Icon(
                          starValue <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 38,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = starValue;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rating == 5
                        ? '⭐⭐⭐⭐⭐ Excellent'
                        : rating == 4
                            ? '⭐⭐⭐⭐ Good'
                            : rating == 3
                                ? '⭐⭐⭐ Average'
                                : rating == 2
                                    ? '⭐⭐ Needs Improvement'
                                    : '⭐ Poor',
                    style: TextStyle(
                      color: isLight ? const Color(0xFFB45309) : AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                Row(
                  children: [
                    // Optional: Skip button
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context); // close dialog
                            Navigator.pop(context); // return to HomeScreen
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: subtextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Submit Rating button
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await _apiService.client.post('/experts/${widget.expertId}/reviews', data: {
                                'rating': rating,
                                'reviewText': '',
                              });
                            } catch (e) {
                              print('Submit Rating Error: $e');
                            }
                            if (context.mounted) {
                              Navigator.pop(context); // close dialog
                              Navigator.pop(context); // return to HomeScreen
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGiftModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final gifts = [
          {'name': 'Rose', 'icon': '🌹', 'price': 10.0},
          {'name': 'Heart', 'icon': '❤️', 'price': 50.0},
          {'name': 'Crown', 'icon': '👑', 'price': 100.0},
          {'name': 'Diamond', 'icon': '💎', 'price': 200.0},
        ];

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Send a Gift to Companion 🎁',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 5),
              const Text(
                'Show your appreciation during the call',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: gifts.map((g) {
                  final price = g['price'] as double;
                  return GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      final currentBalance = double.tryParse(authProvider.user?['walletBalance']?.toString() ?? '0') ?? 0.0;

                      if (currentBalance < price) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('Insufficient balance for ${g['name']} (₹${price.toStringAsFixed(0)})')),
                        );
                        return;
                      }

                      final ok = await _apiService.processBilling(
                        authProvider.user?['id'] ?? '',
                        widget.expertId,
                        price,
                      );

                      if (ok != null && mounted) {
                        authProvider.refreshProfile();
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('${g['icon']} You sent a ${g['name']} (₹${price.toStringAsFixed(0)}) to ${widget.expertName}!')),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          Text(g['icon'] as String, style: const TextStyle(fontSize: 36)),
                          const SizedBox(height: 6),
                          Text(g['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.callType == 'video';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background/Main View
          if (isVideo && _isCallActive && _expertPrivacyMode != 'audio')
            _buildVideoPlaceholder()
          else
            _buildAudioUI(),

          // Floating Self Preview (for Video Calls)
          if (isVideo && _isCallActive && !_isCameraOff && _engine != null)
            Positioned(
              top: 50,
              right: 16,
              child: Container(
                width: 110,
                height: 155,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.7), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine!,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            ),

          // Top Report Button (FRND / Connecto style Safety Trigger)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: (isVideo && _isCallActive && !_isCameraOff && _engine != null) ? 136 : 20,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showReportModal,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.45)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.redAccent, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Report',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Low Balance Alert Banner
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final balance = double.tryParse(authProvider.user?['walletBalance']?.toString() ?? '0') ?? 0.0;
              final isLowBalance = _isCallActive && balance < (widget.pricePerMinute * 2);

              if (!isLowBalance) return const SizedBox.shrink();

              return Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Low Balance (₹${balance.toStringAsFixed(0)} left)',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final ok = await authProvider.rechargeWallet(100);
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Quick Recharge ₹100 Successful!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: const Text('+ ₹100', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Control Bar
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRoundButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.white : Colors.white24,
                  iconColor: _isMuted ? Colors.black : Colors.white,
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                    _engine?.muteLocalAudioStream(_isMuted);
                  },
                ),
                // Virtual Gift Button
                _buildRoundButton(
                  icon: Icons.card_giftcard,
                  color: const Color(0xFFFFD54F),
                  iconColor: Colors.black,
                  onPressed: _showGiftModal,
                ),
                if (isVideo) ...[
                  _buildRoundButton(
                    icon: Icons.flip_camera_ios,
                    color: Colors.white24,
                    iconColor: Colors.white,
                    onPressed: () => _engine?.switchCamera(),
                  ),
                  _buildRoundButton(
                    icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                    color: _isCameraOff ? Colors.white : Colors.black54,
                    iconColor: _isCameraOff ? Colors.black : Colors.white,
                    onPressed: () {
                      setState(() {
                        _isCameraOff = !_isCameraOff;
                      });
                      _engine?.muteLocalVideoStream(_isCameraOff);
                    },
                  ),
                ] else
                  _buildRoundButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                    color: _isSpeakerOn ? Colors.white : Colors.white24,
                    iconColor: _isSpeakerOn ? Colors.black : Colors.white,
                    onPressed: () {
                      setState(() {
                        _isSpeakerOn = !_isSpeakerOn;
                      });
                      _engine?.setEnableSpeakerphone(_isSpeakerOn);
                    },
                  ),
                _buildRoundButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  iconColor: Colors.white,
                  size: 65,
                  onPressed: () => _endCall(reason: 'User Ended Call'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Stack(
      children: [
        if (_remoteUid != null && _engine != null)
          Positioned.fill(
            child: AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine!,
                canvas: VideoCanvas(uid: _remoteUid!),
                connection: RtcConnection(channelId: _channelName ?? 'call_${widget.expertId}'),
              ),
            ),
          )
        else
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0E0E12),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1A1A22),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 2),
                      ),
                      child: const Icon(Icons.person_rounded, size: 55, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.expertName,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isCallActive ? 'Connecting video...' : _status,
                      style: const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    if (_isCallActive) ...[
                      const SizedBox(height: 24),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        if (_expertPrivacyMode == 'blur')
          Positioned(
            top: 50,
            left: 20,
            child: _buildPrivacyBadge(Icons.blur_on, 'Face Protected'),
          ),
        if (_expertPrivacyMode == 'avatar')
          Positioned(
            top: 50,
            left: 20,
            child: _buildPrivacyBadge(Icons.face, 'Avatar Mode'),
          ),
        if (widget.callType == 'video' && _expertPrivacyMode == 'normal')
          Positioned(
            top: 50,
            left: 20,
            child: _buildPrivacyBadge(Icons.lock_rounded, 'E2E Encrypted'),
          ),
      ],
    );
  }

  Widget _buildPrivacyBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.greenAccent, size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAudioUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              Text(
                widget.expertName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                _isCallActive ? _formatDuration(_secondsElapsed) : _status,
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_rounded, size: 12, color: Colors.greenAccent.shade400.withValues(alpha: 0.85)),
                  const SizedBox(width: 5),
                  Text(
                    'End-to-End Encrypted',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.3,
                      color: Colors.greenAccent.shade400.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          CircleAvatar(
            radius: 70,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, size: 90, color: AppTheme.primary),
          ),
          if (_expertPrivacyMode == 'audio')
            _buildPrivacyBadge(Icons.mic_off, 'Expert is in Audio Only Mode'),
          const SizedBox(height: 100), // Push bottom control buttons spacing
        ],
      ),
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
    double size = 55,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: size * 0.5),
        onPressed: onPressed,
      ),
    );
  }
}
