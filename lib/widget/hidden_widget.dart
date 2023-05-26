import 'dart:collection';
import 'package:flutter/material.dart';

class HiddenController {
  HiddenController._();

  static HiddenController instant = HiddenController._();
  final HashMap _controllers = HashMap<State, ScrollController>();
  final HashSet _hiddenChanges = HashSet<_ScrollHiddenState>();

  void dispose(State state) {
    _controllers.remove(state);
  }

  void _addHiddenListener(_ScrollHiddenState state) {
    _hiddenChanges.add(state);
  }

  void _removeHiddenListener(_ScrollHiddenState state) {
    _hiddenChanges.remove(state);
  }

  ScrollController newController(State state) {
    ScrollController? controller = _controllers[state];
    if (controller == null) {
      controller = ScrollController();
      controller.addListener(() {
        var it = _hiddenChanges.iterator;
        while (it.moveNext()) {
          _ScrollHiddenState state = it.current;
          state.onScrollChange(controller!.offset);
        }
      });
      _controllers[state] = controller;
    }
    return controller;
  }

  void removeController(State state) {
    _controllers.remove(state);
  }
}

// ignore: must_be_immutable
class ScrollHidden extends StatefulWidget {
  Widget? child;
  int slideSize;

  ScrollHidden({super.key, this.child, this.slideSize = 56});

  @override
  State<StatefulWidget> createState() {
    return _ScrollHiddenState();
  }
}

class _ScrollHiddenState extends State<ScrollHidden>
    with SingleTickerProviderStateMixin implements OnScrollChange{
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    HiddenController.instant._addHiddenListener(this);
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _animation = Tween(begin: 1.0, end: 0.0).animate(_controller);
    _controller.forward();
    _controller.addListener(() {
      setState(() {});
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _isAnimating = false;
      } else if (status == AnimationStatus.forward ||
          status == AnimationStatus.reverse) {
        _isAnimating = true;
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    HiddenController.instant._removeHiddenListener(this);
    _controller.dispose();
  }

  @override
  void onScrollChange(double scroll) {
    if (scroll < widget.slideSize) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      heightFactor: _controller.value,
      alignment: const Alignment(0, -1),
      child: widget.child,
    );
  }
}

class OnScrollChange {
  void onScrollChange(double scroll) {}
}
