import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../constants/app_colors.dart';

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  Color get _bgCream => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF121212)
      : const Color(0xFFFAF6EF);
  Color get _textDark => Provider.of<CartProvider>(context).isDarkMode
      ? Colors.white
      : const Color(0xFF2C1A00);
  Color get _textMuted => Provider.of<CartProvider>(context).isDarkMode
      ? Colors.white60
      : const Color(0xFF8B6914);

  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.local_shipping_outlined,
      'title': 'Order Shipped!',
      'body': 'Your Bangles Set is on the way. Expected by tomorrow.',
      'time': '2 min ago',
      'isRead': false,
      'color': emeraldGreen,
    },
    {
      'icon': Icons.local_offer_outlined,
      'title': '40% Off — Today Only!',
      'body': 'Flash sale on all Gold Necklaces. Don\'t miss out!',
      'time': '1 hr ago',
      'isRead': false,
      'color': goldDark,
    },
    {
      'icon': Icons.star_rounded,
      'title': 'Review Your Purchase',
      'body': 'How was the Diamond Ring? Share your experience.',
      'time': '3 hrs ago',
      'isRead': true,
      'color': goldAccent,
    },
    {
      'icon': Icons.check_circle_outline_rounded,
      'title': 'Order Delivered',
      'body': 'Your Wedding Set has been delivered successfully.',
      'time': 'Yesterday',
      'isRead': true,
      'color': Colors.green,
    },
    {
      'icon': Icons.card_giftcard_outlined,
      'title': 'Refer & Earn ₹500',
      'body': 'Invite a friend and earn rewards on their first purchase.',
      'time': '2 days ago',
      'isRead': true,
      'color': goldDark,
    },
  ];

  int get _unreadCount =>
      _notifications.where((n) => !(n['isRead'] as bool)).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: Provider.of<CartProvider>(context).isDarkMode
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        children: [
          // ── Handle ───────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    if (_unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: goldDark,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$_unreadCount new',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_unreadCount > 0)
                  GestureDetector(
                    onTap: _markAllRead,
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 13,
                        color: goldDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: goldAccent.withOpacity(0.2)),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 56,
                          color: goldAccent.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 15,
                            color: _textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 20,
                      color: goldAccent.withOpacity(0.15),
                    ),
                    itemBuilder: (_, i) {
                      final n = _notifications[i];
                      final isRead = n['isRead'] as bool;
                      return Dismissible(
                        key: ValueKey(i),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red.shade50,
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                          ),
                        ),
                        onDismissed: (_) =>
                            setState(() => _notifications.removeAt(i)),
                        child: InkWell(
                          onTap: () => setState(() => n['isRead'] = true),
                          child: Container(
                            color: isRead ? Colors.transparent : _bgCream,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon circle
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: (n['color'] as Color).withOpacity(
                                      0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    n['icon'] as IconData,
                                    color: n['color'] as Color,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n['title'] as String,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: isRead
                                                    ? FontWeight.w500
                                                    : FontWeight.w700,
                                                color: _textDark,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            n['time'] as String,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: _textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n['body'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _textMuted,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Unread dot
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(
                                      top: 4,
                                      left: 8,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: goldDark,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
