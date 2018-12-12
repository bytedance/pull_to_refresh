import 'dart:async';

import 'package:example/default_loading_layout.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh_widget.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool hasMore = true;
  int index = 0;

  List<int> items = List.generate(30, (i) => i);

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

  Widget buildContentWidget(BuildContext context) {
    return PullToRefreshWidget(
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
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: new Text(widget.title),
        ),
        body: new Container(child: buildContentWidget(context)));
  }

  DefaultRefreshHeaderWidget _buildHeaderWidget(BuildContext context) {
    return DefaultRefreshHeaderWidget();
  }

  Widget _buildFootWidget(BuildContext context) {
    return new Container(
      alignment: Alignment.center,
      height: 90.0,
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
}
