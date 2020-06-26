import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/Config.dart';
import '../services/ScreenAdapter.dart';
import '../services/SearchServices.dart';
import 'package:dio/dio.dart';
import '../model/ProductModel.dart';
import '../widget/LoadingWidget.dart';

// 商品列表
class ProductList extends StatefulWidget {
  // 接受传值参数
  Map arguments;

  ProductList({Key key, this.arguments}) : super(key: key);

  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  //Scaffold key
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //用于上拉分页
  ScrollController _scrollController = new ScrollController(); //listview 的控制器

  //分页
  int _page = 1;

  //每页有多少条数据
  int _pageSize = 8;

  //数据
  List _productList = [];

  /*
  排序:价格升序 sort=price_1 价格降序 sort=price_-1  销量升序 sort=salecount_1 销量降序 sort=salecount_-1
  */
  String _sort = "";

  //解决重复请求的问题
  bool flag = true;

  //是否有搜索的数据
  bool _hasData = true;

  //是否有更多数据
  bool _hasMore = true;

  /*二级导航数据*/
  List _subHeaderList = [
    {
      "id": 1,
      "title": "综合",
      "fileds": "all",
      "sort":
          -1, //排序     升序：price_1     {price:1}        降序：price_-1   {price:-1}
    },
    {"id": 2, "title": "销量", "fileds": 'salecount', "sort": -1},
    {"id": 3, "title": "价格", "fileds": 'price', "sort": -1},
    {"id": 4, "title": "筛选"}
  ];

  //二级导航选中判断
  int _selectHeaderId = 1;

  //配置search搜索框的值
  var _initKeywordsController=new TextEditingController();

  // cid
  var _cid;

  // keywords
  var _keywords;

  @override
  void initState() {
    super.initState();

    this._cid=widget.arguments["cid"];
    this._keywords=widget.arguments["keywords"];
    //给search框框赋值
    this._initKeywordsController.text=this._keywords;


    //获取商品列表的数据
    _getProductListData();

    //监听滚动条滚动事件
    _scrollController.addListener(() {
      //_scrollController.position.pixels //获取滚动条滚动的高度
      //_scrollController.position.maxScrollExtent  //获取页面高度
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 20) {
        if (this.flag && this._hasMore) {
          _getProductListData();
        }
      }
    });
  }

  //获取商品列表的数据
  _getProductListData() async {
    setState(() {
      this.flag = false;
    });

    var api;

    if(this._keywords==null){
      api ='${Config.plistApi}?cid=${this._cid}&page=${this._page}&sort=${this._sort}&pageSize=${this._pageSize}';
    }else{
      api ='${Config.plistApi}?search=${this._keywords}&page=${this._page}&sort=${this._sort}&pageSize=${this._pageSize}';
    }


    print(api);

    var result = await Dio().get(api);
    var productList = new ProductModel.fromJson(result.data);

    //判断是否有搜索数据
    if(productList.result.length==0 && this._page==1){
      setState(() {
        this._hasData=false;
      });
    }else{
      this._hasData=true;
    }

    //判断最后一页有没有数据
    if (productList.result.length < this._pageSize) {
      setState(() {
        // this._productList = productList.result;
        this._productList.addAll(productList.result);
        this._hasMore = false;
        this.flag = true;
      });
    } else {
      setState(() {
        // this._productList = productList.result;
        this._productList.addAll(productList.result);
        this._page++;
        this.flag = true;
      });
    }
  }

  // 显示加载中的圈圈
  Widget _showMore(index) {
    if (this._hasMore) {
      return (index == this._productList.length - 1)
          ? LoadingWidget()
          : Text("");
    } else {
      return (index == this._productList.length - 1)
          ? Text("-- 没有更多了 --")
          : Text("");
    }
  }

  //导航改变的时候触发
  _subHeaderChange(id) {
    if (id == 4) {
      _scaffoldKey.currentState.openEndDrawer();
      setState(() {
        this._selectHeaderId = id;
      });
    } else {
      setState(() {
        this._selectHeaderId = id;
        this._sort =
            "${this._subHeaderList[id - 1]["fileds"]}_${this._subHeaderList[id - 1]["sort"]}";

        //重置分页
        this._page = 1;
        //重置数据
        this._productList = [];
        //改变sort排序
        this._subHeaderList[id - 1]['sort'] =
            this._subHeaderList[id - 1]['sort'] * -1;

        //回到顶部
        if(_scrollController.hasClients){
          _scrollController.jumpTo(0);
        }

        //重置_hasMore
        this._hasMore = true;
        //重新请求
        this._getProductListData();
      });
    }
  }

  //显示header Icon
  Widget _showIcon(id) {
    if (id == 2 || id == 3) {
      if (this._subHeaderList[id - 1]["sort"] == 1) {
        return Icon(Icons.arrow_drop_down,
            color: (this._selectHeaderId == id) ? Colors.red : Colors.black54);
      }
      return Icon(Icons.arrow_drop_up,
          color: (this._selectHeaderId == id) ? Colors.red : Colors.black54);
    }
    return Text("");
  }

  // 顶部按钮
  Widget _subHeaderWidget() {
    return Positioned(
      top: 0,
      height: ScreenAdapter.height(80),
      width: ScreenAdapter.width(750),
      child: Container(
        width: ScreenAdapter.width(750),
        height: ScreenAdapter.height(80),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 1, color: Color.fromRGBO(233, 233, 233, 0.9)))),
        child: Row(
          children: this._subHeaderList.map((value) {
            return Expanded(
              flex: 1,
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      0, ScreenAdapter.height(16), 0, ScreenAdapter.height(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "${value["title"]}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: (this._selectHeaderId == value["id"])
                                ? Colors.red
                                : Colors.black54),
                      ),
                      _showIcon(value["id"])
                    ],
                  ),
                ),
                onTap: () {
                  _subHeaderChange(value["id"]);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 商品列表
  Widget __productListWidget() {
    if (this._productList.length > 0) {
      return Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(top: ScreenAdapter.height(80)),
        child: ListView.builder(
            controller: _scrollController,
            itemCount: this._productList.length,
            itemBuilder: (context, index) {
              // 图片地址
              String pic = this._productList[index].pic;
              pic = Config.doMainApi + pic.replaceAll('\\', '/');

              // 每一个元素
              return Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // 图片
                      Container(
                        width: ScreenAdapter.width(180),
                        height: ScreenAdapter.height(180),
                        child: Image.network(pic, fit: BoxFit.cover),
                      ),

                      // 文字及其描述
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: ScreenAdapter.height(180),
                          margin: EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("${this._productList[index].title}",
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: ScreenAdapter.height(36),
                                    margin: EdgeInsets.only(right: 10),
                                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),

                                    //注意 如果Container里面加上decoration属性，这个时候color属性必须得放在BoxDecoration
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromRGBO(230, 230, 230, 0.9),
                                    ),

                                    child: Text("4g"),
                                  ),
                                  Container(
                                    height: ScreenAdapter.height(36),
                                    margin: EdgeInsets.only(right: 10),
                                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromRGBO(230, 230, 230, 0.9),
                                    ),
                                    child: Text("126"),
                                  ),
                                ],
                              ),
                              Text(
                                "¥${this._productList[index].price}",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(height: 20),
                  _showMore(index)
                ],
              );
            }),
      );
    } else {
      return LoadingWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    ScreenAdapter.init(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar:AppBar(
        title: Container(
          child: TextField(
            controller: this._initKeywordsController,
            autofocus: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none)),
            onChanged: (value){
              setState(() {
                this._keywords=value;
              });
            },
          ),
          height: ScreenAdapter.height(68),
          decoration: BoxDecoration(
              color: Color.fromRGBO(233, 233, 233, 0.8),
              borderRadius: BorderRadius.circular(30)),
        ),
        actions: <Widget>[
          InkWell(
            child: Container(
              height: ScreenAdapter.height(68),
              width: ScreenAdapter.width(80),
              child: Row(
                children: <Widget>[Text("搜索")],
              ),
            ),
            onTap: () {
              SearchServices.setHistoryData(this._keywords);
              this._subHeaderChange(1);
            },
          )
        ],
      ),

      endDrawer: Drawer(
        child: Container(
          child: Text("实现筛选功能"),
        ),
      ),

      //body: Text("${widget.arguments}"),
      body: _hasData?Stack(
        children: <Widget>[
          // 商品列表
          __productListWidget(),
          // 顶部按钮
          _subHeaderWidget()
        ],
      ):Center(
          child: Text("没有您要浏览的数据")
      )
    );
  }
}
