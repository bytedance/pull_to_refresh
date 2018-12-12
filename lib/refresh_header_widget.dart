import 'package:flutter/material.dart';
import 'package:pull_to_refresh/proxy_header_widget.dart';

/// 下拉刷新头部 widget
abstract class RefreshHeaderWidget<T extends RefreshState>
    extends StatefulWidget {
  const RefreshHeaderWidget({Key key}) : super(key: key);

  @override
  RefreshState createState();
}

abstract class RefreshState<T extends StatefulWidget> extends State<T>
    implements RefreshListener {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RefreshObserver observer = of(context);

    /// 添加监听事件
    if (observer != null) {
      observer.addListener(this);
    }
  }

  @override
  void dispose() {
    RefreshObserver observer = of(context);

    /// 移除监听事件
    if (observer != null) {
      observer.removeListener(this);
    }
    super.dispose();
  }
}

/// 监听下拉刷新状态接口
abstract class RefreshListener {
  /// 开始刷新，Header 进入刷新状态之前调用。
  void refreshing();

  /// 手指拖动下拉
  /// [offset] 下拉的像素偏移量
  /// height 高度 HeaderHeight or FooterHeight
  /// maxDragHeight 最大拖动高度
  void onMoving(double offset, double totalHeight, double maxDragHeight);

  /// 重置，回到初始状态
  void reset();
}
