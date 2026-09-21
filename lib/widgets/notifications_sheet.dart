// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:nakshatra_app/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

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
      ? Colors.white54
      : const Color(0x992C1A00);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerId =
          Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ??
          '1';
      Provider.of<NotificationViewModel>(
        context,
        listen: false,
      ).fetchNotifications(customerId);
    });
  }

  void _markAllRead(NotificationViewModel notifVM) {
    final customerId =
        Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ??
        '1';
    for (final n in notifVM.notifications) {
      if (!n.read) {
        notifVM.markAsRead(customerId, n.id);
      }
    }
  }

  IconData _getIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('shipped') || t.contains('deliver')) {
      return Icons.local_shipping_outlined;
    } else if (t.contains('off') ||
        t.contains('coupon') ||
        t.contains('sale')) {
      return Icons.local_offer_outlined;
    } else if (t.contains('review') || t.contains('rate')) {
      return Icons.star_rounded;
    } else if (t.contains('refer')) {
      return Icons.card_giftcard_outlined;
    }
    return Icons.notifications_none;
  }

  Color _getColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('shipped') || t.contains('delivered')) {
      return emeraldGreen;
    } else if (t.contains('off') || t.contains('refer')) {
      return goldDark;
    }
    return goldAccent;
  }

  @override
  Widget build(BuildContext context) {
    final notifVM = Provider.of<NotificationViewModel>(context);

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
                    if (notifVM.unreadCount > 0) ...[
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
                          '${notifVM.unreadCount} new',
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
                if (notifVM.unreadCount > 0)
                  GestureDetector(
                    onTap: () => _markAllRead(notifVM),
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
            child: notifVM.isBusy && notifVM.notifications.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: goldAccent),
                  )
                : notifVM.notifications.isEmpty
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
                    itemCount: notifVM.notifications.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 20,
                      color: goldAccent.withOpacity(0.15),
                    ),
                    itemBuilder: (_, i) {
                      final n = notifVM.notifications[i];
                      final isRead = n.read;
                      final color = _getColor(n.title);
                      final icon = _getIcon(n.title);

                      return InkWell(
                        onTap: () {
                          if (!isRead) {
                            final customerId =
                                Provider.of<AuthViewModel>(
                                  context,
                                  listen: false,
                                ).currentUser?.id ??
                                '1';
                            notifVM.markAsRead(customerId, n.id);
                          }
                        },
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
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: color, size: 22),
                              ),
                              const SizedBox(width: 14),
                              // Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n.title,
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
                                          n.time,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n.message,
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
