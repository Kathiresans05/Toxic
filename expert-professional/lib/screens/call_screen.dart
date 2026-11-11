import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expert_professional/services/socket_service.dart';
import 'package:expert_professional/services/api_service.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:expert_professional/widgets/privacy_video_overlay.dart';
import 'dart:typed_data';

import 'package:expert_professional/services/call_service.dart';

const String appId = "c9afe369772c48659610c8b6368df693";

class CallScreen extends StatefulWidget {
  final String expertName;
  final String expertId;
  final double pricePerMinute;
  final String channelName;
  final String? callId;
  final String callType;

  const CallScreen({
    super.key,
    required this.expertName,
    required this.expertId,
    required this.pricePerMinute,
    required this.channelName,
    this.callId,
    this.callType = 'video',
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Timer? _callTimer;
  int _secondsElapsed = 0;
  double _accumulatedEarnings = 0.0;

  bool _isSpeakerActive = true;
  bool _isMuted = false;
  bool _isBluetoothActive = false;
  
  RtcEngine? _engine;
  int? _remoteUid;
  int? _dataStreamId;

  String _privacyMode = 'normal';
  double _blurStrength = 15.0;
  final String _avatarAsset = 'assets/images/mask.png';

  double _adminCommissionPercent = 20.0;

  @override
  void initState() {
    super.initState();
    _fetchCommission();
    _initAgora();
    _listenToCallStatus();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
          // Expert earning per minute after Admin commission
          final expertRatePerMin = widget.pricePerMinute * (1 - (_adminCommissionPercent / 100));
          _accumulatedEarnings += expertRatePerMin / 60;
        });
      }
    });
  }

  void _listenToCallStatus() {
    SocketService().onCallEnded = (data) {
      if (mounted) {
        final reasonCode = data['reason']?.toString();
        if (reasonCode == 'INSUFFICIENT_BALANCE') {
          _endCall(reason: 'Customer ran out of balance. Call ended.');
        } else {
          _endCall(reason: 'Call Ended');
        }
      }
    };
  }

  Future<void> _initAgora() async {
    final micStatus = await Permission.microphone.request();
    if (widget.callType == 'video') {
      await Permission.camera.request();
    }
    debugPrint('Expert Microphone permission status: $micStatus');

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _dataStreamId = await _engine!.createDataStream(const DataStreamConfig(
      syncWithAudio: true,
      ordered: true,
    ));

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Expert local user ${connection.localUid} joined successfully");
          _engine?.setEnableSpeakerphone(true);
          _engine?.adjustPlaybackSignalVolume(100);
          _engine?.adjustRecordingSignalVolume(100);
          _engine?.muteLocalAudioStream(false);
          _engine?.muteAllRemoteAudioStreams(false);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Expert remote user $remoteUid joined successfully");
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
          // Customer left
          _endCall();
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

    final tokenData = await ApiService().getAgoraToken(widget.channelName, '0');
    final token = tokenData?['token'] ?? '';

    await _engine!.joinChannel(
      token: token,
      channelId: widget.channelName,
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

  Future<void> _fetchCommission() async {
    final settings = await ApiService().getSettings();
    if (settings != null && mounted) {
      setState(() {
        _adminCommissionPercent = double.tryParse(settings['commissionPercentage']?.toString() ?? '') ?? 20.0;
      });
    }
  }

  void _setPrivacyMode(String mode) async {
    if (_privacyMode == mode) return;

    setState(() {
      _privacyMode = mode;
    });

    if (_dataStreamId != null && _engine != null) {
      _engine!.sendStreamMessage(
        streamId: _dataStreamId!,
        data: Uint8List.fromList(mode.codeUnits),
        length: mode.length,
      );
    }

    if (mode == 'normal') {
      await _engine!.getMediaEngine().setExternalVideoSource(
        enabled: false,
        useTexture: false,
      );
      await _engine!.enableLocalVideo(true);
    } else if (mode == 'audio') {
      await _engine!.enableLocalVideo(false);
    } else {
      await _engine!.enableLocalVideo(false);
      await _engine!.getMediaEngine().setExternalVideoSource(
        enabled: true,
        useTexture: false,
      );
    }
  }

  void _showPrivacyPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141418),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Privacy Settings', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _modeChip('normal', 'Normal', Icons.videocam, setSheetState),
                      _modeChip('audio', 'Audio Only', Icons.mic_off, setSheetState),
                      _modeChip('blur', 'Face Blur', Icons.blur_on, setSheetState),
                      _modeChip('avatar', 'Avatar Mask', Icons.face, setSheetState),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_privacyMode == 'blur') ...[
                    const Text('Blur Strength', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Slider(
                      value: _blurStrength,
                      min: 5,
                      max: 30,
                      activeColor: const Color(0xFFFFC107),
                      onChanged: (val) {
                        setSheetState(() => _blurStrength = val);
                        setState(() {});
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _modeChip(String mode, String label, IconData icon, Function setSheetState) {
    final isActive = _privacyMode == mode;
    return GestureDetector(
      onTap: () {
        _setPrivacyMode(mode);
        setSheetState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFC107) : const Color(0xFF23232A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.black : Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isActive ? Colors.black : Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  String _formatDuration(int totalSecs) {
    final int hours = totalSecs ~/ 3600;
    final int minutes = (totalSecs % 3600) ~/ 60;
    final int seconds = totalSecs % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  final bool _isCameraOff = false;

  @override
  Widget build(BuildContext context) {
    if (widget.callType == 'video') {
      return _buildVideoCallUI();
    }
    return _buildAudioCallUI();
  }

  Widget _buildVideoCallUI() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen Remote Video or Waiting View
          if (_remoteUid != null && _engine != null)
            Positioned.fill(
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine!,
                  canvas: VideoCanvas(uid: _remoteUid!),
                  connection: RtcConnection(channelId: widget.channelName),
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
                          color: const Color(0xFF181820),
                          border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.5), width: 2),
                        ),
                        child: const Icon(Icons.person_rounded, size: 55, color: Color(0xFFFFC107)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.expertName,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Connecting video...',
                        style: TextStyle(color: Color(0xFF8A8A93), fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFC107)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating PIP: Self Preview (Expert Camera with Privacy support)
          if (_engine != null && !_isCameraOff)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              right: 16,
              child: Container(
                width: 110,
                height: 155,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.7), width: 1.5),
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
                  child: _privacyMode == 'normal'
                      ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine!,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        )
                      : PrivacyVideoOverlay(
                          privacyMode: _privacyMode,
                          blurStrength: _blurStrength,
                          avatarAsset: _avatarAsset,
                          onFramePushed: (image, bytes) {
                            _engine?.getMediaEngine().pushVideoFrame(
                                  frame: ExternalVideoFrame(
                                    type: VideoBufferType.videoBufferRawData,
                                    format: VideoPixelFormat.videoPixelRgba,
                                    buffer: bytes,
                                    stride: image.width,
                                    height: image.height,
                                    cropLeft: 0,
                                    cropTop: 0,
                                    cropRight: 0,
                                    cropBottom: 0,
                                    rotation: 0,
                                    timestamp: DateTime.now().millisecondsSinceEpoch,
                                  ),
                                );
                          },
                        ),
                ),
              ),
            ),

          // Top Header Overlay (Live Call duration & earnings)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Timer pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(_secondsElapsed),
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Earnings pill & Report Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '₹${_accumulatedEarnings.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFFFFC107), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showReportModal,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_outlined, color: Colors.redAccent, size: 14),
                              SizedBox(width: 4),
                              Text('Report', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Privacy mode indicator badge if active
          if (_privacyMode != 'normal')
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFC107), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _privacyMode == 'blur' ? Icons.blur_on : Icons.face,
                      color: const Color(0xFFFFC107),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _privacyMode == 'blur' ? 'Face Blurred' : 'Avatar Mask',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Control Overlay
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF141418).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Switch camera
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 24),
                    onPressed: () => _engine?.switchCamera(),
                    tooltip: 'Flip Camera',
                  ),
                  // Mute Mic
                  IconButton(
                    icon: Icon(_isMuted ? Icons.mic_off : Icons.mic,
                        color: _isMuted ? Colors.redAccent : Colors.white, size: 24),
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                      _engine?.muteLocalAudioStream(_isMuted);
                    },
                    tooltip: 'Mute',
                  ),
                  // Privacy Shield
                  IconButton(
                    icon: Icon(Icons.shield,
                        color: _privacyMode != 'normal' ? const Color(0xFFFFC107) : Colors.white, size: 24),
                    onPressed: _showPrivacyPanel,
                    tooltip: 'Privacy',
                  ),
                  // Speaker
                  IconButton(
                    icon: Icon(_isSpeakerActive ? Icons.volume_up : Icons.volume_off,
                        color: _isSpeakerActive ? const Color(0xFFFFC107) : Colors.white, size: 24),
                    onPressed: () {
                      setState(() {
                        _isSpeakerActive = !_isSpeakerActive;
                      });
                      _engine?.setEnableSpeakerphone(_isSpeakerActive);
                    },
                    tooltip: 'Speaker',
                  ),
                  // Hang up
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call_end, color: Colors.white, size: 26),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioCallUI() {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top header timer & real-time earnings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Column(
                    children: [
                      const Text(
                        'Live Call',
                        style: TextStyle(color: Color(0xFF8A8A93), fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(_secondsElapsed),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${_accumulatedEarnings.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFFFFC107), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showReportModal,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_outlined, color: Colors.redAccent, size: 13),
                                SizedBox(width: 3),
                                Text('Report', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Portrait avatar with halo glow ring
              Expanded(
                child: Center(
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
                        backgroundColor: Color(0xFF141418),
                        child: Icon(Icons.person_rounded, size: 78, color: Color(0xFFFFC107)),
                      ),
                    ],
                  ),
                ),
              ),

              // Name & category
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.expertName,
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
                  const SizedBox(height: 6),
                  const Text(
                    'Relationship • English',
                    style: TextStyle(color: Color(0xFF8A8A93), fontSize: 16),
                  ),
                ],
              ),

              // Rate & Earnings cards display
              Row(
                children: [
                  Expanded(
                    child: _buildCallStatusPill('Rate', '₹ ${widget.pricePerMinute.toInt()} /min', Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCallStatusPill('Earning', '₹ ${_accumulatedEarnings.toStringAsFixed(2)}', const Color(0xFFFFC107)),
                  ),
                ],
              ),

              // Control buttons grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlBtn(
                    icon: Icons.volume_up,
                    label: 'Speaker',
                    isActive: _isSpeakerActive,
                    onTap: () {
                      setState(() {
                        _isSpeakerActive = !_isSpeakerActive;
                      });
                      _engine?.setEnableSpeakerphone(_isSpeakerActive);
                    },
                  ),
                  _buildControlBtn(
                    icon: Icons.mic_off,
                    label: 'Mute',
                    isActive: _isMuted,
                    onTap: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                      _engine?.muteLocalAudioStream(_isMuted);
                    },
                  ),
                  _buildControlBtn(
                    icon: Icons.bluetooth,
                    label: 'Bluetooth',
                    isActive: _isBluetoothActive,
                    onTap: () {
                      setState(() {
                        _isBluetoothActive = !_isBluetoothActive;
                      });
                    },
                  ),
                ],
              ),

              // Decline/Hangup button
              Center(
                child: GestureDetector(
                  onTap: _endCall,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE53935).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.call_end, color: Colors.white, size: 36),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _endCall({String? reason, bool isReported = false}) async {
    _callTimer?.cancel();

    if (widget.callId != null) {
      await CallService().endCall(widget.callId!);
    }

    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}

    SocketService().sendEvent('CALL_END', {
      'callId': widget.callId,
      'durationSeconds': _secondsElapsed,
    });
    await ApiService().recordCompletedCall(
      durationSeconds: _secondsElapsed,
      amountCharged: _accumulatedEarnings,
    );
    if (context.mounted) {
      if (isReported) {
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
                    'Caller reported. Session disconnected safely.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (reason != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call ended: $reason')),
        );
      }
      Navigator.pop(context);
    }
  }

  void _showReportModal() {
    final reasons = [
      'Vulgar / Abusive behavior or harassment',
      'Inappropriate video / Nudity violation',
      'Pressuring for personal phone / WhatsApp',
      'Refund scam / Threatening behavior',
      'Other creator safety violation',
    ];
    String selectedReason = reasons.first;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141418),
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
                                'Report & Disconnect Caller',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Zero Tolerance for Host Abuse • Disconnects call immediately',
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
                            color: isSelected ? Colors.red.withValues(alpha: 0.15) : const Color(0xFF1E1E26),
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
    // 1. Log incident to backend API for review
    try {
      ApiService().reportCall(
        callId: widget.callId ?? widget.channelName,
        reason: reason,
        details: 'Caller reported by creator ${widget.expertName} (${widget.expertId})',
        targetType: 'CUSTOMER',
      );
    } catch (e) {
      debugPrint('Backend safety report error: $e');
    }

    // 3. Immediately disconnect call and exit
    _endCall(reason: 'Reported: $reason', isReported: true);
  }

  Widget _buildCallStatusPill(String title, String val, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF24242A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF8A8A93), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: TextStyle(color: textCol, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFFC107).withValues(alpha: 0.15) : const Color(0xFF141418),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? const Color(0xFFFFC107) : const Color(0xFF24242A),
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFFFFC107) : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFFFC107) : const Color(0xFF8A8A93),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
