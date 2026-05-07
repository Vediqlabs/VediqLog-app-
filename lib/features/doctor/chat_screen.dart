import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final Map doctor;
  final String issue;
  final String sessionId;

  const ChatScreen({
    super.key,
    required this.doctor,
    required this.issue,
    required this.sessionId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  // ← lifecycle observer
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final MessageService messageService = MessageService();

  List<Map<String, dynamic>> messages = [];
  RealtimeChannel? channel;
  bool isSending = false;
  bool _realtimeReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ← register
    _subscribeRealtime();
    _loadMessages();
  }

  // ← reconnect when app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (channel != null) {
        Supabase.instance.client.removeChannel(channel!);
      }
      _realtimeReady = false;
      _subscribeRealtime();
      _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    try {
      final res = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('session_id', widget.sessionId)
          .order('created_at', ascending: true);

      if (!mounted) return;
      setState(() {
        messages = List<Map<String, dynamic>>.from(res);
        _realtimeReady = true;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $e')),
      );
    }
  }

  void _subscribeRealtime() {
    channel = Supabase.instance.client
        .channel('vediqlog-${widget.sessionId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            if (!_realtimeReady) return;
            final newMsg = Map<String, dynamic>.from(payload.newRecord);
            if (newMsg['session_id'] != widget.sessionId) return;
            if (!mounted) return;

            final exists = messages.any((m) => m['id'] == newMsg['id']);
            if (exists) return;

            setState(() => messages.add(newMsg));
            _scrollToBottom();
          },
        )
        .subscribe();
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty || isSending) return;

    setState(() => isSending = true);
    controller.clear();

    try {
      await messageService.sendMessage(
        sessionId: widget.sessionId,
        message: text,
      );
    } catch (e) {
      controller.text = text;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      if (scrollController.position.maxScrollExtent <= 0) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ← unregister
    if (channel != null) {
      Supabase.instance.client.removeChannel(channel!);
    }
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.doctor['name'] ?? 'Doctor',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.issue,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text(
                          "Start your consultation",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    reverse: false,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final text = msg['message']?.toString() ?? '';
                      final isMe = msg['sender_type'] == 'user';

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.72,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isMe ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => sendMessage(),
                        decoration: const InputDecoration(
                          hintText: "Type message...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isSending ? Colors.grey : const Color(0xFF0F172A),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: isSending ? null : sendMessage,
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
}
