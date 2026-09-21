import 'dart:async';

/// Manages and deduplicates simultaneous in-flight asynchronous requests.
/// If an identical request key is already in progress, subsequent callers receive
/// the same Future until it resolves.
class RequestDeduplicator {
  static final RequestDeduplicator _instance = RequestDeduplicator._internal();
  factory RequestDeduplicator() => _instance;
  RequestDeduplicator._internal();

  final Map<String, Future<dynamic>> _inFlight = {};

  /// Runs [action] if no request with [key] is in-flight; otherwise shares the in-flight Future.
  Future<T> run<T>(String key, Future<T> Function() action) {
    if (_inFlight.containsKey(key)) {
      return _inFlight[key]! as Future<T>;
    }

    final future = action().whenComplete(() {
      _inFlight.remove(key);
    });

    _inFlight[key] = future;
    return future;
  }

  /// Check if a request with [key] is currently in-flight.
  bool isInFlight(String key) => _inFlight.containsKey(key);

  /// Clear all in-flight trackers (e.g. on logout or reset)
  void clear() => _inFlight.clear();
}
