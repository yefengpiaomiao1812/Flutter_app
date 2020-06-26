import 'package:flutter/material.dart';
import '../../services/ScreenAdapter.dart';
import '../../model/CateModel.dart';
import 'package:dio/dio.dart';
import '../../config/Config.dart';

// 分类
class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with AutomaticKeepAliveClientMixin {
  // 选中的条目
  int _selectIndex = 0;

  // 左侧数据
  List _leftCateList = [];

  // 右侧数据
  List _rightCateList = [];

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // 获取左侧数据
    _getLeftCateData();
  }

  // 左侧数据请求
  _getLeftCateData() async {
    var result = await Dio().get(Config.pcateApi);
    var leftCateList = CateModel.fromJson(result.data);
    setState(() {
      this._leftCateList = leftCateList.result;
    });

    // 请求右侧数据
    _getRightCateData(this._leftCateList[0].sId);
  }

  // 右侧数据请求
  _getRightCateData(pid) async {
    var result = await Dio().get(Config.pcateApi + "?pid=${pid}");
    var rightCateList = CateModel.fromJson(result.data);
    setState(() {
      this._rightCateList = rightCateList.result;
    });
  }

  // 左侧栏目
  Widget _leftCateWidget(leftWidth) {
    if (this._leftCateList.length > 0) {
      return Container(
        width: leftWidth,
        height: double.infinity,
        //color: Colors.red,
        child: ListView.builder(
          itemCount: this._leftCateList.length,
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                // 点击变色条目
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectIndex = index;
                      // 获取右侧数据
                      _getRightCateData(this._leftCateList[_selectIndex].sId);
                    });
                  },
                  // 分类文本
                  child: Container(
                    width: double.infinity,
                    height: ScreenAdapter.height(84),
                    padding: EdgeInsets.only(top: ScreenAdapter.height(24)),
                    child: Text("${this._leftCateList[index].title}",
                        textAlign: TextAlign.center),
                    color: _selectIndex == index
                        ? Color.fromRGBO(240, 246, 246, 0.9)
                        : Colors.white,
                  ),
                ),
                // 线条
                Divider(height: 1)
              ],
            );
          },
        ),
      );
    } else {
      return Container(width: leftWidth, height: double.infinity);
    }
  }

  // 右侧栏目
  Widget _rightCateWidget(rightItemWidth, rightItemHeight) {
    if (this._rightCateList.length > 0) {
      return Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.all(10),
          height: double.infinity,
          color: Color.fromRGBO(240, 246, 246, 0.9),
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: rightItemWidth / rightItemHeight,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemCount: this._rightCateList.length,
              itemBuilder: (context, index) {
                // 图片地址处理
                String pic = this._rightCateList[index].pic;
                pic = Config.doMainApi + pic.replaceAll('\\', '/');

                return InkWell(
                  onTap: () {
                    // 跳转到商品列表
                    Navigator.pushNamed(context, '/productList',
                        arguments: {"cid": this._rightCateList[index].sId});
                  },
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 1 / 1,
                          child: Image.network(pic, fit: BoxFit.cover),
                        ),
                        SizedBox(height: ScreenAdapter.height(10)),
                        Container(
                          height: ScreenAdapter.height(28),
                          child: Text("${this._rightCateList[index].title}"),
                        )
                      ],
                    ),
                  ),
                );
              }),
        ),
      );
    } else {
      return Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(10),
            height: double.infinity,
            color: Color.fromRGBO(240, 246, 246, 0.9),
            child: Text("加载中..."),
          ));
    }
  }

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
    //注意用ScreenAdaper必须得在build方法里面初始化
    ScreenAdapter.init(context);

    //-------计算右侧GridView宽高比----------//
    // 左侧宽度
    var leftWidth = ScreenAdapter.getScreenWidth() / 4;
    // 右侧每一项宽度 = (总宽度-左侧宽度-GridView外侧元素左右的Padding值-GridView中间的间距)/3
    var rightItemWidth =
        (ScreenAdapter.getScreenWidth() - leftWidth - 20 - 20) / 3;

    // 获取计算后的适配宽度
    rightItemWidth = ScreenAdapter.width(rightItemWidth);
    // 获取计算后的适配高度
    var rightItemHeight = rightItemWidth + ScreenAdapter.height(24);

    return Scaffold(
      appBar: _appBar(),
      body: Row(
        children: <Widget>[
          // 左侧
          _leftCateWidget(leftWidth),
          // 右侧
          _rightCateWidget(rightItemWidth, rightItemHeight)
        ],
      ),
    );
  }
}
