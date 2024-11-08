import 'dart:collection';
import 'package:flutter/material.dart';

import '../util/base_export.dart';

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

  late final double _kBounce = 0.4;
  late final int _kDuration = 800;
  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: Duration(milliseconds: _kDuration));
  late final ElegantSpring _elegantCurve = ElegantSpring(bounce: _kBounce);
  late final CurvedAnimation _animation = CurvedAnimation(
      parent: _animationController,
      curve: _elegantCurve,
      reverseCurve: _elegantCurve.flipped);

  @override
  void initState() {
    super.initState();
    HiddenController.instant._addHiddenListener(this);

    _animationController.drive(Tween(begin: 1.0, end: 0.5));
    _animationController.forward();
    _animationController.addListener(() {
      setState(() {});
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
      } else if (status == AnimationStatus.forward ||
          status == AnimationStatus.reverse) {
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    HiddenController.instant._removeHiddenListener(this);
    _animationController.dispose();
  }

  @override
  void onScrollChange(double scroll) {
    if (scroll < widget.slideSize) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      heightFactor: _animation.value.clamp(0.0, double.infinity),
      alignment: const Alignment(0, -1),
      child: widget.child,
    );
  }
}

class OnScrollChange {
  void onScrollChange(double scroll) {}
}
