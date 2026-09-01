import 'package:flutter/material.dart';

class ListScrollMoreWidget extends StatefulWidget {
  final Widget child;
  final void Function(BuildContext context) onLoadMore;
  final bool Function(BuildContext context) canLoadMore;
  final double triggerThreshold;

  const ListScrollMoreWidget({
    super.key,
    required this.child,
    required this.onLoadMore,
    required this.canLoadMore,
    this.triggerThreshold = 200.0,
  });

  @override
  State<ListScrollMoreWidget> createState() => _ListScrollMoreWidgetState();
}

class _ListScrollMoreWidgetState extends State<ListScrollMoreWidget> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - widget.triggerThreshold) {
          if (widget.canLoadMore(context)) {
            widget.onLoadMore(context);
          }
        }
        return false;
      },
      child: widget.child,
    );
  }
}

class GridScrollMoreWidget extends StatelessWidget {
  final Widget child;
  final void Function(BuildContext context) onLoadMore;
  final bool Function(BuildContext context) canLoadMore;
  final double triggerThreshold;

  const GridScrollMoreWidget({
    super.key,
    required this.child,
    required this.onLoadMore,
    required this.canLoadMore,
    this.triggerThreshold = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListScrollMoreWidget(
      onLoadMore: onLoadMore,
      canLoadMore: canLoadMore,
      triggerThreshold: triggerThreshold,
      child: child,
    );
  }
}
