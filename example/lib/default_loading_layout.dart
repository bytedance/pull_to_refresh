import 'package:flutter/material.dart';
import 'package:pull_to_refresh/refresh_header_widget.dart';

class DefaultRefreshHeaderWidget<_DefaultIndicatorState>
    extends RefreshHeaderWidget {
  DefaultRefreshHeaderWidget({Key key}) : super(key: key);

  @override
  _DefaultLoadingState createState() {
    return new _DefaultLoadingState();
  }
}

const int _reset = 0;
const int _releaseToRefresh = 1;
const int _pullToRefresh = 2;
const int _refreshing = 3;

class _DefaultLoadingState extends RefreshState {
  int mode = 0;

  @override
  void reset() {
    setState(() {
      mode = _reset;
    });
  }

  @override
  void onMoving(double offset, double totalHeight, double maxDragHeight) {
    if (offset > maxDragHeight) {
      if (mode != _releaseToRefresh) {
        setState(() {
          mode = _releaseToRefresh;
        });
      }
    } else {
      if (mode != _pullToRefresh) {
        setState(() {
          mode = _pullToRefresh;
        });
      }
    }
  }

  @override
  void refreshing() {
    setState(() {
      mode = _refreshing;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget textWidget = _buildText();
    Widget iconWidget = _buildIcon();

    List<Widget> children = <Widget>[
      iconWidget,
      new Container(width: 15.0, height: 15.0),
      textWidget
    ];

    return new Container(
      alignment: Alignment.center,
      height: 60.0,
      child: new Center(
        child: new Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget _buildText() {
    switch (mode) {
      case _releaseToRefresh:
        return new Text("Refresh when release");
      case _refreshing:
        return new Text("Refreshing...");
      default:
        return new Text("Pull down to refresh");
    }
  }

  Widget _buildIcon() {
    switch (mode) {
      case _releaseToRefresh:
        return Icon(Icons.arrow_upward, color: Colors.grey);
      case _refreshing:
        return new CircularProgressIndicator(strokeWidth: 2.0);
      default:
        return Icon(Icons.arrow_downward, color: Colors.grey);
    }
  }
}
