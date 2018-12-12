# pull_to_refresh

提供上拉加载和下拉刷新的组件


## 特性

* 提供上拉加载和下拉刷新
* 接口简单，接入十分方便
* 支持Flutter中大部分的控件


## 例子

<img src="https://github.com/bytedance/pull_to_refresh/blob/master/doc/image.gif" width="320">


## 如何使用？

1. 添加依赖文件： ```import package:pull_to_refresh/pull_to_refresh_widget.dart; ```
2. 使用PullToRefreshWidget包裹待展示的内容控件，child就是需要展示的控件
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

3. 设置PullToRefreshWidget中的headerBuilder和footerBuilder用来生成header控件和footer控件。其中header控件必须继承于DefaultRefreshHeaderWidget
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
4. 当进入刷新和加载更多状态时会分别调用onRefresh和onLoadMore函数。这两个函数必须返回[Future]类型，用来决定刷新和加载更多何时结束
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

具体的例子可以参照main.dart文件


