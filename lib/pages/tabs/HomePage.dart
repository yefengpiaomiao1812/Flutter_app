import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutterapp/model/FocusModel.dart';
import 'package:flutterapp/model/ProductModel.dart';
import 'package:flutterapp/services/ScreenAdapter.dart';
import 'package:dio/dio.dart';
import '../../config/Config.dart';

// 首页
class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  // 轮播图数据集合
  List _focusList = [];

  // 猜你喜欢图数据集合
  List _hotProductList = [];

  // 热门推荐数据集合
  List _bestProductList = [];

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // 轮播图数据
    _getFocusData();
    // 猜你喜欢数据
    _getHotProductData();
    // 热门推荐数据
    _getBestProductData();
  }

  // 获取轮播图数据
  _getFocusData() async {
    var result = await Dio().get(Config.focusApi);
    var focusList = FocusModel.fromJson(result.data);
    setState(() {
      this._focusList = focusList.result;
    });
  }

  // 获取猜你喜欢的数据
  _getHotProductData() async {
    var result = await Dio().get(Config.hotProductApi);
    var hotProductList = ProductModel.fromJson(result.data);
    setState(() {
      this._hotProductList = hotProductList.result;
    });
  }

  // 获取热门推荐的数据
  _getBestProductData() async {
    var result = await Dio().get(Config.bestProductApi);
    var bestProductList = ProductModel.fromJson(result.data);
    setState(() {
      this._bestProductList = bestProductList.result;
    });
  }

  // 轮播图
  Widget _swiperWidget() {
    if (this._focusList.length > 0) {
      return Container(
        child: AspectRatio(
          // 纵横比、宽高比
          aspectRatio: 2 / 1,
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              String pic = this._focusList[index].pic;
              pic = Config.doMainApi + pic.replaceAll('\\', '/');
              return new Image.network(
                pic,
                fit: BoxFit.fill,
              );
            },

            autoplay: true, // 自动轮播
            itemCount: this._focusList.length, // 轮播图个数
            pagination: new SwiperPagination(), // 分页器
            //control: new SwiperControl(),
          ),
        ),
      );
    } else {
      return Text("加载中...");
    }
  }

  // 公共title
  Widget _titleWidget(value) {
    return Container(
      margin: EdgeInsets.only(left: ScreenAdapter.width(10)),
      padding: EdgeInsets.only(left: ScreenAdapter.width(10)),
      decoration: BoxDecoration(
          // 红色竖线
          border: Border(
        left: BorderSide(color: Colors.red, width: ScreenAdapter.width(4)),
      )),
      child: Text(
        value,
        style: TextStyle(color: Colors.black54),
      ),
    );
  }

  // 热门商品
  Widget _hotProductListWidget() {
    if (this._hotProductList.length > 0) {
      return Container(
        height: ScreenAdapter.height(234),
        //width: double.infinity,
        padding: EdgeInsets.all(ScreenAdapter.width(20)),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            // 处理图片
            String sPic = this._hotProductList[index].sPic;
            sPic = Config.doMainApi + sPic.replaceAll('\\', '/');
            return Column(
              children: <Widget>[
                Container(
                  // 图片
                  height: ScreenAdapter.height(140),
                  width: ScreenAdapter.width(140),
                  margin: EdgeInsets.only(right: ScreenAdapter.width(21)),
                  child: Image.network(
                    sPic,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  // 文字
                  padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                  height: ScreenAdapter.height(44),
                  child: Text(
                    "¥${this._hotProductList[index].price}",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            );
          },
          itemCount: this._hotProductList.length,
        ),
      );
    } else {
      return Text("正在加载...");
    }
  }

  // 推荐商品
  _recProductItemWidget() {
    var itemWidth = (ScreenAdapter.getScreenWidth() - 30) / 2;

    return Container(
      padding: EdgeInsets.all(10),
      child: Wrap(
        runSpacing: 10,
        spacing: 10,
        children: this._bestProductList.map((value) {
          // 图片
          String sPic = value.sPic;
          sPic = Config.doMainApi + sPic.replaceAll('\\', '/');

          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/productContent',
                  arguments: {"id": value.sId});
            },
            child: Container(
              padding: EdgeInsets.all(10),
              width: itemWidth,

              // 边框
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Color.fromRGBO(233, 233, 233, 0.9), width: 1)),

              child: Column(
                children: <Widget>[
                  // 图片
                  Container(
                    width: double.infinity,
                    child: AspectRatio(
                      //防止服务器返回的图片大小不一致导致高度不一致问题
                      aspectRatio: 1 / 1,
                      child: Image.network("${sPic}", fit: BoxFit.cover),
                    ),
                  ),

                  // 文字描述
                  Padding(
                    padding: EdgeInsets.only(top: ScreenAdapter.height(20)),
                    child: Text(
                      "${value.title}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),

                  // 价格
                  Padding(
                    padding: EdgeInsets.only(top: ScreenAdapter.height(20)),
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "¥${value.price}",
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "¥${value.oldPrice}",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
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
    ScreenAdapter.init(context); // 初始化屏幕适配类
    // TODO: implement build

    return Scaffold(
      appBar: _appBar(),
      body: ListView(
        children: <Widget>[
          _swiperWidget(),
          SizedBox(height: ScreenAdapter.height(20)),
          _titleWidget("猜你喜欢"),
          SizedBox(height: ScreenAdapter.height(20)),
          _hotProductListWidget(),
          _titleWidget("热门推荐"),
          _recProductItemWidget()
        ],
      ),
    );
  }
}
