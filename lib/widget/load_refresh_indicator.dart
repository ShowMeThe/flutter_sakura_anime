import 'package:flutter/material.dart';

typedef RefreshCallback = Future<void> Function();

class LoadRefreshIndicator extends StatefulWidget {
  final VoidCallback? onEndOfPage;
  final bool isLoading;
  final RefreshCallback? onRefresh;
  final Widget? child;

  const LoadRefreshIndicator({
    Key? key,
    @required this.onEndOfPage,
    this.isLoading = false,
    @required this.onRefresh,
    @required this.child,
  })  : assert(child != null),
        assert(onRefresh != null),
        assert(onEndOfPage != null),
        super(key: key);

  @override
  State createState() => _LoadRefreshIndicatorState();
}

class _LoadRefreshIndicatorState extends State<LoadRefreshIndicator> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
  }

  @override
  void didUpdateWidget(LoadRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isLoading = widget.isLoading;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      child: RefreshIndicator(
        child: widget.child!,
        onRefresh: widget.onRefresh!,
      ),
      onNotification: _handleLoadMoreScroll,
    );
  }

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.maxScrollExtent > notification.metrics.pixels &&
          notification.metrics.maxScrollExtent - notification.metrics.pixels <=
              notification.metrics.maxScrollExtent * 1 / 3) {
        if (!_isLoading) {
          _isLoading = true;
          widget.onEndOfPage!();
        }
      }
    }
    return false;
  }
}
