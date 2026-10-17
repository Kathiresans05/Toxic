import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expert_professional/constants.dart';
import 'package:expert_professional/providers/auth_provider.dart';
import 'package:expert_professional/services/chat_service.dart';

class ChatMessage {
  final String text;
  final bool isSender;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isSender,
    required this.timestamp,
  });
}

class ChatScreen extends StatefulWidget {
  final String customerName;
  final String customerId;

  const ChatScreen({
    super.key,
    required this.customerName,
    required this.customerId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _chatSubscription;

  @override
  void initState() {
    super.initState();
    _setupFirestoreChat();
    _messages.add(
      ChatMessage(
        text: "Hi! Connected with customer ${widget.customerName}.",
        isSender: false,
        timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
      ),
    );
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupFirestoreChat() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user ?? {};
    final userId = user['id'] ?? '';

    if (userId.isNotEmpty) {
      _chatSubscription?.cancel();
      _chatSubscription = _chatService
          .getMessagesStream(userId, widget.customerId)
          .listen((snapshot) {
        if (mounted) {
          final List<ChatMessage> newMessages = [];
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final senderId = data['senderId'];
            final text = data['text'] ?? '';
            final timestampData = data['timestamp'];
            
            DateTime timestamp = DateTime.now();
            if (timestampData is Timestamp) {
              timestamp = timestampData.toDate();
            }

            newMessages.add(
              ChatMessage(
                text: text,
                isSender: senderId == userId,
                timestamp: timestamp,
              ),
            );
          }
          
          setState(() {
            _messages.clear();
            if (newMessages.isEmpty) {
              _messages.add(
                ChatMessage(
                  text: "Hi! Connected with customer ${widget.customerName}.",
                  isSender: false,
                  timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
                ),
              );
            } else {
              _messages.addAll(newMessages);
            }
          });
          _scrollToBottom();
        }
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user ?? {};
    final userId = user['id'] ?? '';

    _messageController.clear();

    await _chatService.sendMessage(
      senderId: userId,
      receiverId: widget.customerId,
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExpertColors.background,
      appBar: AppBar(
        backgroundColor: ExpertColors.cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: ExpertColors.primaryYellow.withValues(alpha: 0.2),
              child: Text(
                widget.customerName.isNotEmpty ? widget.customerName[0].toUpperCase() : 'C',
                style: const TextStyle(color: ExpertColors.primaryYellow, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customerName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Online',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildBubble(msg);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isMe = msg.isSender;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? ExpertColors.primaryYellow : ExpertColors.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: ExpertColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: isMe ? Colors.black : Colors.white,
                fontSize: 14,
                fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isMe ? Colors.black54 : ExpertColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ExpertColors.cardBg,
        border: const Border(top: BorderSide(color: ExpertColors.borderColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type your response...',
                  hintStyle: const TextStyle(color: ExpertColors.textMuted),
                  filled: true,
                  fillColor: ExpertColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor: ExpertColors.primaryYellow,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
