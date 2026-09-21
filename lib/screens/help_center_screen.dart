// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/help_center_viewmodel.dart';
import '../models/help_center.dart';
import '../utils/app_palette.dart';
import 'chat_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  static const String path = '/help-center';

  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HelpCenterViewModel>(
        context,
        listen: false,
      ).fetchHelpCenterData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppPalette.bgDark : AppPalette.bgCream;
    final cardBg = isDark ? AppPalette.surfaceDark : AppPalette.surfaceWhite;
    final textColor = isDark ? AppPalette.textLight : AppPalette.textDark;

    final helpCenterVM = Provider.of<HelpCenterViewModel>(context);

    final filteredFaqs = helpCenterVM.faqs.where((faq) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help Center',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: textColor,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppPalette.gold,
        onRefresh: () async {
          await helpCenterVM.fetchHelpCenterData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner with search
              _buildHeroHeader(isDark, cardBg, textColor),
              const SizedBox(height: 24),

              // Contact Channels Row
              Text(
                'Direct Assistance',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildSupportChannels(
                context,
                isDark,
                cardBg,
                helpCenterVM.chatInfo,
              ),
              const SizedBox(height: 28),

              // FAQ Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (filteredFaqs.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${filteredFaqs.length} FAQs',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.goldDark,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // FAQ List / Loading / Empty State
              if (helpCenterVM.isLoading && helpCenterVM.faqs.isEmpty)
                _buildLoadingState()
              else if (filteredFaqs.isEmpty)
                _buildEmptyState(textColor)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredFaqs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final faq = filteredFaqs[index];
                    return _buildFaqTile(faq, isDark, cardBg, textColor);
                  },
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(bool isDark, Color cardBg, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppPalette.emerald, AppPalette.emeraldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppPalette.emerald.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: AppPalette.goldLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'How can we help you?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Search through questions or connect with our support team.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.poppins(
                color: AppPalette.textDark,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Search for answers, order tracing...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppPalette.emerald,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportChannels(
    BuildContext context,
    bool isDark,
    Color cardBg,
    ChatInfo? chatInfo,
  ) {
    final whatsappNum = chatInfo?.whatsappNumber.isNotEmpty == true
        ? chatInfo!.whatsappNumber
        : '+916282116343';
    final availability = chatInfo?.availability.isNotEmpty == true
        ? chatInfo!.availability
        : 'Available 9AM - 9PM';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildChannelCard(
                icon: Icons.chat_outlined,
                title: 'Live Chat',
                subtitle: 'In-app assistant',
                iconColor: AppPalette.emerald,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
                },
                isDark: isDark,
                cardBg: cardBg,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChannelCard(
                icon: Icons.phone_in_talk_outlined,
                title: 'Call Support',
                subtitle: availability,
                iconColor: AppPalette.goldDark,
                onTap: () => _showContactDialog(
                  context,
                  title: 'Customer Care',
                  contactValue: whatsappNum,
                  availability: availability,
                  chatLink: chatInfo?.chatLink,
                  isDark: isDark,
                  cardBg: cardBg,
                ),
                isDark: isDark,
                cardBg: cardBg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildWhatsAppCard(context, chatInfo, isDark, cardBg),
      ],
    );
  }

  Widget _buildWhatsAppCard(
    BuildContext context,
    ChatInfo? chatInfo,
    bool isDark,
    Color cardBg,
  ) {
    final whatsappNum = chatInfo?.whatsappNumber.isNotEmpty == true
        ? chatInfo!.whatsappNumber
        : '+916282116343';
    final availability = chatInfo?.availability.isNotEmpty == true
        ? chatInfo!.availability
        : 'Available 9AM - 9PM';
    final chatLink = chatInfo?.chatLink.isNotEmpty == true
        ? chatInfo!.chatLink
        : 'https://wa.me/916282116343';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _launchWhatsApp(chatLink, whatsappNum, context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF25D366).withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25D366).withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Color(0xFF25D366),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'WhatsApp Support',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppPalette.textLight
                              : AppPalette.textDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Online',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF25D366),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$whatsappNum • $availability',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF25D366).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chat',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(
    String? link,
    String? phone,
    BuildContext context,
  ) async {
    String targetUrl = '';
    if (link != null && link.trim().isNotEmpty) {
      targetUrl = link.trim();
    } else if (phone != null && phone.trim().isNotEmpty) {
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      targetUrl = 'https://wa.me/$cleanPhone';
    } else {
      targetUrl = 'https://wa.me/916282116343';
    }

    try {
      final uri = Uri.parse(targetUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        Clipboard.setData(ClipboardData(text: phone ?? targetUrl));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open WhatsApp directly. Number copied: ${phone ?? targetUrl}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            backgroundColor: AppPalette.emerald,
          ),
        );
      }
    }
  }

  void _showContactDialog(
    BuildContext context, {
    required String title,
    required String contactValue,
    required String availability,
    String? chatLink,
    required bool isDark,
    required Color cardBg,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.support_agent_rounded,
              color: AppPalette.emerald,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Number:',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              contactValue,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppPalette.goldDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Availability: $availability',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (chatLink != null && chatLink.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Direct Link: $chatLink',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _launchWhatsApp(chatLink, contactValue, context);
            },
            icon: const Icon(Icons.chat_bubble_rounded, size: 16),
            label: Text(
              'WhatsApp',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: contactValue));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Copied $contactValue to clipboard!',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  backgroundColor: AppPalette.emerald,
                ),
              );
            },
            child: Text(
              'Copy',
              style: GoogleFonts.poppins(
                color: AppPalette.emerald,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isDark,
    required Color cardBg,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.gold.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppPalette.textLight : AppPalette.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(
    FaqItem faq,
    bool isDark,
    Color cardBg,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.gold.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppPalette.gold.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              size: 18,
              color: AppPalette.goldDark,
            ),
          ),
          title: Text(
            faq.question,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : AppPalette.bgCream.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                faq.answer,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  height: 1.5,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: CircularProgressIndicator(color: AppPalette.gold),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No FAQs found',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching with different keywords',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
