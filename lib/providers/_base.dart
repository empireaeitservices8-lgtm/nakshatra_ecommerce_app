import 'dart:io';
import 'package:flutter/material.dart';
import '../models/app_error_model.dart';
import '_mixins.dart';

typedef OnShowError = void Function(AppError msg);

abstract class BaseProvider extends ChangeNotifier {
  final String? _providerName;
  bool _isDisposed = false;

  String? get providerName => _providerName;
  bool get isDisposed => _isDisposed;

  BaseProvider({String? name})
      : _providerName = name,
        super();

  int get deviceType {
    if (Platform.isAndroid) return 1;
    if (Platform.isIOS) return 2;
    return -1;
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      try {
        super.notifyListeners();
      } catch (ex) {
        debugPrint("Error in notifyListeners of $providerName: $ex");
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

/// Generic provider to manage a single API resource model
abstract class BaseSimpleAPIProvider<M> extends BaseProvider
    with MixinAPIProvider, MixinProgressProvider {
  BaseSimpleAPIProvider({String? name})
      : super(name: name ?? "BaseSimpleAPIProvider");

  M? _iModel;
  M? get iModel => _iModel;

  set iModel(M? value) {
    _iModel = value;
    notifyListeners();
  }

  void resetIModel() {
    _iModel = null;
    notifyListeners();
  }

  @protected
  Future<M?> apiService();

  Future<M?> fetchFromAPIService({
    required OnShowError onShowError,
    void Function(M? m)? onSuccess,
    VoidCallback? onInvalidSession,
  }) async {
    startProgress();
    try {
      final value = await apiService();
      _iModel = value;
      onSuccess?.call(value);
      notifyListeners();
      return value;
    } catch (e) {
      onShowError(AppError(message: e.toString(), originalError: e));
      return null;
    } finally {
      stopProgress();
    }
  }
}

/// Generic provider for paginated / load-more lists
abstract class BaseListLoadMoreProvider<IM> extends BaseProvider
    with MixinAPIProvider, MixinProgressProvider {
  final List<IM> _list = [];
  int _page = 1;
  int _totalPages = 1;
  bool _isAllCompleted = false;

  BaseListLoadMoreProvider({String? name})
      : super(name: name ?? "BaseListLoadMoreProvider");

  List<IM> get list => _list;
  int get currentPage => _page;
  bool get isAllCompleted => _isAllCompleted;

  @protected
  Future<List<IM>> fetchPage(int page);

  Future<void> loadFirstPage({OnShowError? onShowError}) async {
    reset();
    startProgress();
    try {
      final items = await fetchPage(1);
      _list.addAll(items);
      _page = 1;
      _isAllCompleted = items.isEmpty;
      notifyListeners();
    } catch (e) {
      onShowError?.call(AppError(message: e.toString(), originalError: e));
    } finally {
      stopProgress();
    }
  }

  Future<void> loadNextPage({OnShowError? onShowError}) async {
    if (_isAllCompleted || isLoading) return;
    startProgress();
    try {
      final nextPage = _page + 1;
      final items = await fetchPage(nextPage);
      if (items.isEmpty) {
        _isAllCompleted = true;
      } else {
        _list.addAll(items);
        _page = nextPage;
      }
      notifyListeners();
    } catch (e) {
      onShowError?.call(AppError(message: e.toString(), originalError: e));
    } finally {
      stopProgress();
    }
  }

  void reset() {
    _page = 1;
    _isAllCompleted = false;
    _list.clear();
    notifyListeners();
  }
}
