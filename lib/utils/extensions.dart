import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_error_model.dart';
import '../providers/_mixins.dart';
import '../widgets/app_progress_widget.dart';
import '../widgets/list_scroll_more_widget.dart';
import 'exceptions.dart';

extension APIFutureExtension<T> on Future<T> {
  Future<T> coverWithProgress(MixinProgressProvider provider) {
    provider.isLoading = true;
    return whenComplete(() => provider.isLoading = false);
  }

  Future<T> handleAPIException({
    required Function(APIException ex, {OnShowError? onShowError})
    handleAPIException,
    OnShowError? onShowError,
    VoidCallback? onInvalidToken,
  }) {
    return catchError((err) {
      if (err is APIException) {
        if (err.enumProperty == EnumAPIExceptions.invalidToken) {
          onInvalidToken?.call();
        }
        handleAPIException(err, onShowError: onShowError);
      } else {
        onShowError?.call(
          AppError(message: err.toString(), originalError: err),
        );
      }
      throw err;
    });
  }
}

typedef OnShowError = void Function(AppError msg);

extension WidgetProgressExtension on Widget {
  Widget showProgressOnCenter({
    required bool isLoading,
    double bgOpacity = 0.15,
  }) {
    return Stack(
      children: [
        AbsorbPointer(absorbing: isLoading, child: this),
        if (isLoading)
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(bgOpacity),
              child: const AppProgressWidget(),
            ),
          ),
      ],
    );
  }

  Widget orShowEmptyWidget({
    required List? items,
    bool isLoading = false,
    String text = "No records found",
    Widget? customEmptyWidget,
  }) {
    if (isLoading) return this;
    if (items == null || items.isEmpty) {
      return customEmptyWidget ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    text,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
    }
    return this;
  }
}

extension ListViewLoadMoreExtension on ListView {
  Widget withLoadMore({
    required void Function(BuildContext context) onLoadMore,
    required bool Function(BuildContext context) canLoadMore,
  }) {
    return ListScrollMoreWidget(
      onLoadMore: onLoadMore,
      canLoadMore: canLoadMore,
      child: this,
    );
  }
}

extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF0A4D3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  bool get isValidPhone {
    return length >= 10 && RegExp(r'^[0-9]+$').hasMatch(this);
  }
}

extension NumberExtension on num {
  String toCurrency([String symbol = '₹']) {
    return '$symbol ${toStringAsFixed(2)}';
  }
}
