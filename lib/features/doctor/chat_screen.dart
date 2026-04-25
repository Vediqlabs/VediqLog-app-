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

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final MessageService messageService = MessageService();

  List<Map<String, dynamic>> messages = [];
  RealtimeChannel? channel;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    loadMessages();
    subscribeRealtime();
  }

  Future<void> loadMessages() async {
    try {
      final res = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('session_id', widget.sessionId)
          .order('created_at', ascending: false);
      if (!mounted) return;

      setState(() {
        messages = List<Map<String, dynamic>>.from(res);
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $e')),
      );
    }
  }

  void subscribeRealtime() {
    channel = Supabase.instance.client.channel(
      'messages-${widget.sessionId}',
    );

    channel!
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      // ❌ REMOVE FILTER COMPLETELY
      callback: (payload) {
        print("REALTIME HIT: ${payload.newRecord}");

        final newMessage = Map<String, dynamic>.from(payload.newRecord);

        /// ✅ MANUAL FILTER (SAFE)
        if (newMessage['session_id'] != widget.sessionId) return;

        if (!mounted) return;

        setState(() {
          messages.insert(0, newMessage);
        });
      },
    )
        .subscribe((status, [error]) {
      print("SUB STATUS: $status");
      if (error != null) {
        print("SUB ERROR: $error");
      }
    });
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty || isSending) return;

    setState(() {
      isSending = true;
    });

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
      setState(() {
        isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
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
        title: Text(widget.doctor['name'] ?? 'Doctor'),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text("Start your consultation..."),
                  )
                : ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final text = msg['message']?.toString() ?? '';

                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            text,
                            style: const TextStyle(color: Colors.white),
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
