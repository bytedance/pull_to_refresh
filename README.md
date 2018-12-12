# pull_to_refresh

A widget that provided to  pull-up load and pull-down refresh with Flutter.

## Features

* pull up and pull down
* Simple interface, easy access
* support most of the component in Flutter such as scroll and non-scroll component


## Show cases

<img src="https://github.com/bytedance/pull_to_refresh/blob/master/doc/image.gif" width="320">


## Quick Start
1. Add ```import package:pull_to_refresh/pull_to_refresh_widget.dart; ```
2. Using PullToRefreshWidget wrap outside your content widget
```
PullToRefreshWidget(
    isRefreshEnable: true,
    headerBuilder: _buildHeaderWidget,
    onRefresh: _handleRefresh,
    isLoadMoreEnable: hasMore,
    onLoadMore: _onLoadMore,
    footerBuilder: _buildFootWidget,
    child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
        return new ListTile(
            title: Text("Index$index"),
        );
    }));
```

3. You should set the headerBuilder and footerBuilder in PullToRefreshWidget that generate header widget and footer widget. 
The header widget must inherit DefaultRefreshHeaderWidget.
```
DefaultRefreshHeaderWidget _buildHeaderWidget(BuildContext context) {
    return DefaultRefreshHeaderWidget();
  }

Widget _buildFootWidget(BuildContext context) {
    return new Container(
      alignment: Alignment.center,
      height: 60.0,
      child: new Center(
        child: new Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new Text("正在加载中。。。"),
              new CircularProgressIndicator(strokeWidth: 2.0)
            ]),
      ),
    );
  }
```
4. The onRefresh and onLoadMore will be callback when the indicator state is refreshed and load more. 
The function returned [Future] must complete when the refresh operation is finished.

```
  Future<Null> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 50), () {
      setState(() {
        items.clear();
        items = List.generate(40, (i) => i);
      });
    });
  }

  Future<Null> _onLoadMore() async {
    await Future.delayed(Duration(seconds: 50), () {
      setState(() {
        if (index == 2) {
          hasMore = false;
        }
        int length = items.length;
        index++;
        items.addAll(List.generate(16, (i) => i + length));
      });
    });
  }
```

full example see here: main.dart.


