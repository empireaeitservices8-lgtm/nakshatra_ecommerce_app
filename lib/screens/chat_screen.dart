import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class ChatScreen extends StatefulWidget {
  static const String path = '/chat';
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Namaste! Welcome to Nakshathra Hallmark Jewellery. How may I assist you today?',
      'time': '12:00 PM',
    }
  ];

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final Color _goldDark = const Color(0xFFB8860B);
  final Color _goldMid = const Color(0xFFD4A017);
  final Color _emeraldGreen = const Color(0xFF2E513D);

  final List<String> _quickReplies = [
    'Check gold purity',
    'Live gold rate',
    'Custom order inquiries',
    'Store locations',
  ];

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

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
        'time': 'Just now',
      });
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Simulated chatbot responses
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      String reply = '';
      final lowerText = text.toLowerCase();

      if (lowerText.contains('purity') || lowerText.contains('hallmark') || lowerText.contains('pure')) {
        reply = 'All Nakshathra ornaments are certified 916 BIS Hallmarked 22 Karat gold, guaranteeing maximum purity and resale value.';
      } else if (lowerText.contains('rate') || lowerText.contains('price') || lowerText.contains('cost')) {
        reply = "Today's live Gold Rate is ₹6,890/gram for 22K Hallmarked Gold, and ₹7,516/gram for 24K Pure Gold.";
      } else if (lowerText.contains('custom') || lowerText.contains('design') || lowerText.contains('order')) {
        reply = 'Yes! We custom design jewellery according to your preference. You can share your design sketches with us at orders@nakshathrajewellers.com or call us at +91 90000 00000.';
      } else if (lowerText.contains('store') || lowerText.contains('location') || lowerText.contains('where')) {
        reply = 'We have showrooms located in Ernakulam, Kochi, Trivandrum, and Calicut. Our flagship store is located on MG Road, Kochi.';
      } else {
        reply = "Thank you for reaching out to Nakshathra. Our support team is online and will get back to you shortly. For immediate assistance, feel free to call +91 90000 00000.";
      }

      setState(() {
        _isTyping = false;
        _messages.add({
          'isUser': false,
          'text': reply,
          'time': 'Just now',
        });
      });
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isDark = cartProvider.isDarkMode;
    final bgCream = isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF);
    final cardWhite = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);
    final textMuted = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: cardWhite,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _emeraldGreen.withOpacity(0.12),
              child: Icon(Icons.support_agent_rounded, color: _emeraldGreen),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nakshathra AI Helper',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                Text(
                  'Online support assistant',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['isUser'] as bool;
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? _emeraldGreen
                            : (isDark ? const Color(0xFF262626) : Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: isUser
                            ? null
                            : Border.all(
                                color: _goldMid.withOpacity(0.12),
                                width: 1,
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['text'] as String,
                            style: GoogleFonts.poppins(
                              color: isUser ? Colors.white : textDark,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              msg['time'] as String,
                              style: GoogleFonts.poppins(
                                color: isUser ? Colors.white70 : textMuted,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF2E513D),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nakshathra AI is writing...',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Quick replies
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _quickReplies.length,
                itemBuilder: (context, index) {
                  final q = _quickReplies[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(
                        q,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _emeraldGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: _goldMid.withOpacity(0.1),
                      side: BorderSide(
                        color: _goldMid.withOpacity(0.3),
                        width: 0.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () => _handleSendMessage(q),
                    ),
                  );
                },
              ),
            ),

            // Message box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardWhite,
                border: Border(
                  top: BorderSide(
                    color: _goldMid.withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: bgCream,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: _goldMid.withOpacity(0.2),
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: _handleSendMessage,
                        style: TextStyle(color: textDark, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: textMuted, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _handleSendMessage(_messageController.text),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _emeraldGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _emeraldGreen.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
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
