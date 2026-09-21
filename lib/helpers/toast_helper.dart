// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../config/app_config.dart';

class ToastHelper {
  static void showErrorToast(BuildContext? context, String message) {
    final formattedMessage = _formatErrorMessage(message);
    _showToast(context, formattedMessage, isError: true);
  }

  static void showSuccessToast(BuildContext? context, String message) {
    _showToast(context, message, isError: false);
  }

  static String _formatErrorMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return 'An error occurred';

    final lower = trimmed.toLowerCase();

    // 404 / Not Found detection
    if (trimmed.contains('404') ||
        lower.contains('not found') ||
        lower.contains('page not found') ||
        lower.contains('status code of 404')) {
      return 'Resource not found (404)';
    }

    // 401 / 403 Unauthorized
    if (trimmed.contains('401') ||
        trimmed.contains('403') ||
        lower.contains('unauthorized') ||
        lower.contains('unauthenticated') ||
        lower.contains('forbidden')) {
      return 'Session expired or unauthenticated. Please log in again.';
    }

    // 500+ Internal Server Error
    if (trimmed.contains('500') ||
        trimmed.contains('502') ||
        trimmed.contains('503') ||
        lower.contains('internal server error')) {
      return 'Server error occurred. Please try again later.';
    }

    // Network / Timeouts
    if (lower.contains('timeout')) {
      return 'Connection timed out. Please try again.';
    }
    if (lower.contains('socketexception') ||
        lower.contains('connection error') ||
        lower.contains('network failure') ||
        lower.contains('network error') ||
        lower.contains('no internet connection')) {
      return 'No internet connection. Please check your network.';
    }

    // Raw HTML responses (e.g. from web servers on error)
    if (trimmed.contains('<!DOCTYPE') ||
        trimmed.contains('<html') ||
        trimmed.contains('<body')) {
      return 'Server returned an unexpected response. Please try again.';
    }

    // Raw DioException / RequestOptions verbose traces
    if (lower.contains('dioexception') ||
        lower.contains('requestoptions.validatestatus')) {
      return 'Unable to complete request. Please try again.';
    }

    // Remove technical prefix wrappers like "Exception: ", "APIException: "
    String cleaned = trimmed;
    if (cleaned.startsWith('Exception: ')) {
      cleaned = cleaned.substring('Exception: '.length);
    } else if (cleaned.startsWith('APIException: ')) {
      cleaned = cleaned.substring('APIException: '.length);
    }

    // If message is still overly long, trim to clean length
    if (cleaned.length > 120) {
      cleaned = '${cleaned.substring(0, 117)}...';
    }

    return cleaned.trim();
  }

  static void _showToast(
    BuildContext? context,
    String message, {
    required bool isError,
  }) {
    final ctx = context ?? AppConfig.navKey.currentContext;
    if (ctx == null) return;

    final overlay =
        Overlay.maybeOf(ctx, rootOverlay: true) ??
        Overlay.maybeOf(ctx) ??
        AppConfig.navKey.currentState?.overlay;
    if (overlay == null) return;

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (ctx) => _AnimatedToast(
        message: message,
        isError: isError,
        onDismiss: () {
          try {
            overlayEntry.remove();
          } catch (_) {}
        },
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _AnimatedToast extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _AnimatedToast({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeIn,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _controller.reverse().then((value) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: bottomPadding + 30,
      left: 16.0,
      right: 16.0,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isError
                      ? [const Color(0xFFE53935), const Color(0xFFD32F2F)]
                      : [const Color(0xFF2E513D), const Color(0xFF1E3529)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isError
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
