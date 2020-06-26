import 'package:flutter/material.dart';
import '../../services/ScreenAdapter.dart';

import 'HomePage.dart';
import 'CategoryPage.dart';
import 'CartPage.dart';
import 'UserPage.dart';

class Tabs extends StatefulWidget {
  Tabs({Key key}) : super(key: key);

  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;

  // 页面切换保存状态
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    this._pageController = new PageController(initialPage: this._currentIndex);
  }

  // 页面装入集合
  List<Widget> _pageList = [HomePage(), CategoryPage(), CartPage(), UsetPage()];

  // AppBar
  Widget _appBar() {
    return AppBar(
      // 左侧按钮图标
      leading: IconButton(
        icon: Icon(Icons.center_focus_weak, size: 28, color: Colors.black87),
        onPressed: null,
      ),
      title: InkWell(
        child: Container(
          height: ScreenAdapter.height(68),
          decoration: BoxDecoration(
              color: Color.fromRGBO(233, 233, 233, 0.8),
              borderRadius: BorderRadius.circular(30)),
          padding: EdgeInsets.only(left: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.search),
              Text(
                "笔记本",
                style: TextStyle(fontSize: ScreenAdapter.size(28)),
              )
            ],
          ),
        ),
        onTap: () {
          // 跳转搜索页面
          Navigator.pushNamed(context, '/search');
        },
      ),

      // 右侧按钮图标
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.message, size: 28, color: Colors.black87),
          onPressed: null,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    ScreenAdapter.init(context);

    return Scaffold(
      //appBar: _currentIndex != 3 ? _appBar() : AppBar(title: Text("用户中心")),
      body: PageView(
        controller: this._pageController,
        children: this._pageList,
        onPageChanged: (index) {
          setState(() {
            this._currentIndex = index;
          });
        },
        // 禁止pageView滑动
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: this._currentIndex,
        onTap: (index) {
          setState(() {
            this._currentIndex = index;
            this._pageController.jumpToPage(index);
          });
        },

        type: BottomNavigationBarType.fixed,
        // bar类型
        fixedColor: Colors.green,
        // bar颜色

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("首页"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            title: Text("分类"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            title: Text("购物车"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text("我的"),
          )
        ],
      ),
    );
  }
}
