import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/refresh_header_widget.dart';
import 'package:pull_to_refresh/proxy_header_widget.dart';
import 'dart:math' as math;

/// 刷新状态
enum _RefreshStatus {
  /// 初始化状态
  reset,

  /// 下拉可以刷新
  pullToRefresh,

  /// 松开后刷新
  releaseToRefresh,

  /// 刷新中，此时手指已离开屏幕
  refreshing,
}

/// 创建下拉头部视图函数
typedef HeaderBuilder = RefreshHeaderWidget Function(BuildContext context);

/// 创建上拉底部视图
typedef FooterBuilder = Widget Function(BuildContext context);

/// 下拉刷新回调
typedef Future<void> OnRefreshCallback();

/// 加载更多回调
typedef Future<void> OnLoadMoreCallback();

class PullToRefreshWidget extends StatefulWidget {
  /// 下拉头部视图创建者
  final HeaderBuilder headerBuilder;

  /// 上拉底部视图创建者
  final FooterBuilder footerBuilder;

  /// 是否开启上拉加载更多
  final bool isLoadMoreEnable;

  /// 是否下拉刷新
  final bool isRefreshEnable;

  /// 监听下拉刷新属性
  final OnRefreshCallback onRefresh;

  /// 监听上拉加载更多
  final OnLoadMoreCallback onLoadMore;

  /// 内容视图
  final Widget child;

  /// 触发刷新距离 与 HeaderHeight 的比率
  final double headerTriggerRate;

  const PullToRefreshWidget(
      {Key key,
      @required this.child,
      this.headerTriggerRate = 1.0,
      this.onRefresh,
      this.onLoadMore,
      this.headerBuilder,
      this.isRefreshEnable = false,
      this.footerBuilder,
      this.isLoadMoreEnable = false})
      : assert(child != null),
        super(key: key);

  @override
  State createState() {
    return new _PullRefreshState();
  }
}

class _PullRefreshState extends State<PullToRefreshWidget> {
  /// 下拉刷新头部控件的高度
  double _headerHeight = 0.0;

  /// 触发刷新的最大距离
  double _maxDistance = 0.0;

  /// 头部控件的key,用来获取头部的高度
  final GlobalKey _headerKey = new GlobalKey();

  /// 下拉刷新的刷新状态
  _RefreshStatus _headerState = _RefreshStatus.reset;

  /// 是否正在加载更多，防止来回滑动导致接口调用多次的问题
  bool _isLoadingMore;

  /// scrollview的滑动监听者
  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if (!widget.isLoadMoreEnable) {
        return;
      }

      ///当滑动的距离大于可滑动的最大像素时回调下拉刷新接口
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        /// 防止回调多次
        if (_isLoadingMore == true) {
          return;
        }
        if (widget.onLoadMore != null) {
          _isLoadingMore = true;
          widget.onLoadMore().whenComplete(() {
            _isLoadingMore = false;
          });
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      setState(() {
        if (widget.isRefreshEnable) {
          _headerHeight = _headerKey.currentContext.size.height;
          _maxDistance = widget.headerTriggerRate * _headerHeight;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_scrollController != null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  /// 下拉刷新头是否合法
  bool _isHeaderValid() {
    return widget.isRefreshEnable &&
        (_headerKey.currentState is RefreshListener);
  }

  bool _onNotification(ScrollNotification notification) {
    if (!_isHeaderValid()) {
      return false;
    }

    /// 滚动区域超过屏幕时，不进行处理
    if (!(notification.metrics.pixels < 0) &&
        !(notification.metrics.pixels > 0)) {
      return false;
    }

    /// 正在滑动中，此时滑动位置会变化
    if (notification is ScrollUpdateNotification) {
      /// notification.dragDetails 表明此时我们的手指已经离开了屏幕
      if (notification.dragDetails == null) {
        _handleScrollEnd(notification);
      } else {
        _handleScrollUpdate(notification);
      }
    } else if (notification is ScrollEndNotification) {
      /// 滑动结束
      _handleScrollEnd(notification);
    }
    return false;
  }

  /// 处理正在滑动中
  bool _handleScrollUpdate(ScrollUpdateNotification notification) {
    if (notification.metrics.pixels <= notification.metrics.minScrollExtent) {
      if (!widget.isRefreshEnable) {
        return false;
      }
    } else {
      return false;
    }

    /// 已经处于正在刷新状态，就直接返回
    if (_headerState == _RefreshStatus.refreshing) {
      return false;
    }

    double offset =
        notification.metrics.minScrollExtent - notification.metrics.pixels;
    RefreshListener refreshListener =
        _headerKey.currentState as RefreshListener;

    refreshListener.onMoving(offset, _headerHeight, _maxDistance);

    if (_headerState == _RefreshStatus.pullToRefresh &&
        offset >= _maxDistance) {
      _headerState = _RefreshStatus.releaseToRefresh;
    } else if (_headerState != _RefreshStatus.pullToRefresh &&
        offset < _maxDistance) {
      _headerState = _RefreshStatus.pullToRefresh;
    }
    return false;
  }

  bool _handleScrollEnd(ScrollNotification notification) {
    if (!_isHeaderValid()) {
      return false;
    }
    if (!(_headerKey.currentState is RefreshListener)) {
      return false;
    }

    RefreshListener callback = _headerKey.currentState as RefreshListener;

    /// 松开后刷新
    if (_headerState == _RefreshStatus.releaseToRefresh &&
        widget.onRefresh != null) {
      _headerState = _RefreshStatus.refreshing;
      callback.refreshing();

      final Future<void> refreshResult = widget.onRefresh();
      if (refreshResult == null) {
        return false;
      }
      refreshResult.whenComplete(() {
        _headerState = _RefreshStatus.reset;
        callback.reset();
      });

      return false;
    }

    if (_headerState == _RefreshStatus.refreshing) return false;
    callback.reset();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = new List();
    if (widget.isRefreshEnable) {
      Widget header = widget.headerBuilder != null
          ? new ProxyIndicatorWidget(
              builder: widget.headerBuilder,
              key: _headerKey,
              height: _headerHeight,
            )
          : new Container();
      children.add(SliverToBoxAdapter(
        child: header,
      ));
    }

    if (widget.child is ScrollView) {
      children.addAll((widget.child as ScrollView).buildSlivers(context));
    } else {
      children.add(SliverToBoxAdapter(
        child: widget.child,
      ));
    }

    if (widget.isLoadMoreEnable && widget.footerBuilder != null) {
      children.add(SliverToBoxAdapter(child: widget.footerBuilder(context)));
    }

    return new LayoutBuilder(builder: (context, cons) {
      return new Stack(
        children: <Widget>[
          new Positioned(
              top: -_headerHeight,
              bottom: 0,
              left: 0.0,
              right: 0.0,
              child: new NotificationListener(
                child: new CustomScrollView(
                  controller: _scrollController,
                  physics: widget.isRefreshEnable
                      ? new _PullToRefreshScrollPhysics()
                      : null,
                  slivers: children,
                ),
                onNotification: _onNotification,
              )),
        ],
      );
    });
  }
}

///copy from BouncingScrollPhysics ,用来控制下拉刷新的滑动特性
class _PullToRefreshScrollPhysics extends ScrollPhysics {
  const _PullToRefreshScrollPhysics({ScrollPhysics parent})
      : super(parent: parent);

  @override
  _PullToRefreshScrollPhysics applyTo(ScrollPhysics ancestor) {
    return _PullToRefreshScrollPhysics(parent: buildParent(ancestor));
  }

  double frictionFactor(double overscrollFraction) =>
      0.52 * math.pow(1 - overscrollFraction, 2);

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // TODO: implement shouldAcceptUserOffset
    return true;
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    if (!position.outOfRange) return offset;

    final double overscrollPastStart =
        math.max(position.minScrollExtent - position.pixels, 0.0);
    final double overscrollPastEnd =
        math.max(position.pixels - position.maxScrollExtent, 0.0);
    final double overscrollPast =
        math.max(overscrollPastStart, overscrollPastEnd);
    final bool easing = (overscrollPastStart > 0.0 && offset < 0.0) ||
        (overscrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing
        // Apply less resistance when easing the overscroll vs tensioning.
        ? frictionFactor(
            (overscrollPast - offset.abs()) / position.viewportDimension)
        : frictionFactor(overscrollPast / position.viewportDimension);
    final double direction = offset.sign;
    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(
      double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) return absDelta * gamma;
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (position.maxScrollExtent <= position.pixels && position.pixels < value)
      return value - position.pixels;
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value)
      return value - position.maxScrollExtent;
    return 0.0;
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return new BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity * 0.91,
        // TODO(abarth): We should move this constant closer to the drag end.
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  double get minFlingVelocity => 2.5 * 2.0;

  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign *
        math.min(0.000816 * math.pow(existingVelocity.abs(), 1.967).toDouble(),
            40000.0);
  }

  @override
  double get dragStartDistanceMotionThreshold => 3.5;
}
