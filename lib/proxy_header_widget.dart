import 'package:flutter/material.dart';
import 'package:pull_to_refresh/refresh_header_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh_widget.dart';

const Duration _kSizeDuration = Duration(milliseconds: 200);

RefreshObserver of(BuildContext context) {
  /// 这个方法内，调用 context.inheritFromWidgetOfExactType
  InheritedWidget widget =
      context.inheritFromWidgetOfExactType(_InheritedRefreshContainer);
  if (widget is _InheritedRefreshContainer) {
    return widget.observer;
  } else {
    return null;
  }
}

/// 刷新头的代理类
class ProxyIndicatorWidget extends StatefulWidget {
  final HeaderBuilder builder;
  final double height;

  const ProxyIndicatorWidget({Key key, this.builder, this.height})
      : super(key: key);

  @override
  State createState() {
    return new _ProxyIndicatorState();
  }
}

class _ProxyIndicatorState extends State<ProxyIndicatorWidget>
    with TickerProviderStateMixin, RefreshListener {
  AnimationController _sizeController;
  RefreshObserver observer;

  @override
  void initState() {
    _sizeController = new AnimationController(
        vsync: this, lowerBound: 0.000001, duration: _kSizeDuration);
    observer = new RefreshObserver();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _sizeController.dispose();
    observer = null;
    super.initState();
  }

  @override
  void reset() {
    if (observer == null ||
        observer.callbacks == null ||
        observer.callbacks.isEmpty) {
      return;
    }
    for (RefreshListener listener in observer.callbacks) {
      listener.reset();
    }

    _sizeController.animateTo(0.0);
  }

  @override
  void refreshing() {
    _sizeController.value = 1.0;
    if (observer == null ||
        observer.callbacks == null ||
        observer.callbacks.isEmpty) {
      return;
    }
    for (RefreshListener listener in observer.callbacks) {
      listener.refreshing();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new SizeTransition(
          sizeFactor: _sizeController,
          child: new Container(height: widget.height),
        ),
        _InheritedRefreshContainer(
            observer: observer, child: widget.builder(context)),
      ],
    );
  }

  @override
  void onMoving(double offset, double totalHeight, double maxDragHeight) {
    if (observer == null ||
        observer.callbacks == null ||
        observer.callbacks.isEmpty) {
      return;
    }
    for (RefreshListener listener in observer.callbacks) {
      listener.onMoving(offset, totalHeight, maxDragHeight);
    }
  }
}

/// 刷新接口的观察者
class RefreshObserver {
  /// 注册被观察者的列表
  List<RefreshListener> callbacks = List();

  addListener(RefreshListener listener) {
    if (listener != null && !callbacks.contains(listener)) {
      callbacks.add(listener);
    }
  }

  removeListener(RefreshListener listener) {
    callbacks.remove(listener);
  }
}

class _InheritedRefreshContainer extends InheritedWidget {
  final RefreshObserver observer;

  /// 我们知道InheritedWidget总是包裹的一层，所以它必有child
  _InheritedRefreshContainer(
      {Key key, @required this.observer, @required Widget child})
      : super(key: key, child: child);

  /// 参考MediaQuery,这个方法通常都是这样实现的。如果新的值和旧的值不相等，就需要notify
  @override
  bool updateShouldNotify(_InheritedRefreshContainer oldWidget) =>
      observer != oldWidget.observer;
}
